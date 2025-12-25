//
//  ScreenCaptureAudioRecorder.swift
//  AudionotesApp
//
//  System audio capture using ScreenCaptureKit - works with all audio outputs including Bluetooth
//

import Foundation
import ScreenCaptureKit
import AVFoundation
import OSLog

/// Thread-safe state for audio processing (accessed from audio callback queue)
final class AudioProcessingState: @unchecked Sendable {
    private let lock = NSLock()

    private var _audioFile: AVAudioFile?
    private var _bufferCount: Int = 0
    private var _maxAmplitude: Float = 0

    var audioFile: AVAudioFile? {
        get { lock.withLock { _audioFile } }
        set { lock.withLock { _audioFile = newValue } }
    }

    var bufferCount: Int {
        get { lock.withLock { _bufferCount } }
        set { lock.withLock { _bufferCount = newValue } }
    }

    var maxAmplitude: Float {
        get { lock.withLock { _maxAmplitude } }
        set { lock.withLock { _maxAmplitude = newValue } }
    }

    func reset() {
        lock.withLock {
            _bufferCount = 0
            _maxAmplitude = 0
        }
    }
}

/// Records system audio using ScreenCaptureKit - works with Bluetooth and all audio devices
@MainActor
final class ScreenCaptureAudioRecorder: NSObject, ObservableObject {

    private let logger = Logger(subsystem: "AudioCap", category: "ScreenCaptureAudioRecorder")

    // MARK: - Published Properties

    @Published private(set) var isRecording = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var capturedAppName: String?

    // MARK: - Private Properties

    private var stream: SCStream?
    private var fileURL: URL?
    private let audioQueue = DispatchQueue(label: "com.audionotes.screencapture.audio", qos: .userInitiated)

    // Thread-safe storage for audio processing (accessed from audioQueue)
    private let audioState = AudioProcessingState()

    // MARK: - Public API

    /// Start recording system audio to the specified file
    /// - Parameters:
    ///   - url: The URL to save the audio file
    ///   - appBundleID: Optional bundle ID to capture audio from a specific app only
    func startRecording(to url: URL, appBundleID: String? = nil) async throws {
        guard !isRecording else {
            logger.warning("Already recording")
            return
        }

        errorMessage = nil
        audioState.reset()

        logger.info("Starting ScreenCaptureKit audio recording to: \(url.lastPathComponent)")
        debugLog("SCK: Starting recording to \(url.lastPathComponent)")

        // Get available content
        let content: SCShareableContent
        do {
            content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        } catch {
            errorMessage = "Failed to get shareable content: \(error.localizedDescription)"
            debugLog("SCK ERROR: \(errorMessage!)")
            throw error
        }

        guard let display = content.displays.first else {
            errorMessage = "No display found"
            debugLog("SCK ERROR: No display found")
            throw RecorderError.noDisplay
        }

        // Create content filter
        let filter: SCContentFilter

        if let bundleID = appBundleID,
           let targetApp = content.applications.first(where: { $0.bundleIdentifier == bundleID }) {
            // Capture from specific app
            filter = SCContentFilter(display: display, including: [targetApp], exceptingWindows: [])
            capturedAppName = targetApp.applicationName
            debugLog("SCK: Capturing from app: \(targetApp.applicationName)")
        } else {
            // Capture all system audio, excluding our own app
            let excludedApps = content.applications.filter {
                $0.bundleIdentifier == Bundle.main.bundleIdentifier
            }
            filter = SCContentFilter(display: display, excludingApplications: excludedApps, exceptingWindows: [])
            capturedAppName = "System Audio"
            debugLog("SCK: Capturing all system audio")
        }

        // Configure stream for audio capture
        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.sampleRate = 48000
        config.channelCount = 2
        config.excludesCurrentProcessAudio = true

        // Minimize video overhead (we only want audio)
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1) // 1 fps minimum
        config.width = 2
        config.height = 2

        debugLog("SCK: Config - sampleRate: 48000, channels: 2")

        // Create audio file for writing
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2)!

        do {
            audioState.audioFile = try AVAudioFile(forWriting: url, settings: audioFormat.settings)
            fileURL = url
        } catch {
            errorMessage = "Failed to create audio file: \(error.localizedDescription)"
            debugLog("SCK ERROR: Failed to create audio file - \(error)")
            throw error
        }

        // Create and configure stream
        stream = SCStream(filter: filter, configuration: config, delegate: self)

        do {
            // Must add screen output even for audio-only capture
            try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global())
            try stream?.addStreamOutput(self, type: .audio, sampleHandlerQueue: audioQueue)
        } catch {
            errorMessage = "Failed to add stream output: \(error.localizedDescription)"
            debugLog("SCK ERROR: Failed to add stream output - \(error)")
            throw error
        }

        // Start capture
        do {
            try await stream?.startCapture()
            isRecording = true
            logger.info("ScreenCaptureKit recording started successfully")
            debugLog("SCK: Recording started successfully")
        } catch {
            errorMessage = "Failed to start capture: \(error.localizedDescription)"
            debugLog("SCK ERROR: Failed to start capture - \(error)")
            audioState.audioFile = nil
            stream = nil
            throw error
        }
    }

    /// Stop recording and finalize the audio file
    func stopRecording() async {
        guard isRecording else { return }

        logger.info("Stopping ScreenCaptureKit recording")
        debugLog("SCK: Stopping recording - \(audioState.bufferCount) buffers, maxAmp: \(audioState.maxAmplitude)")

        do {
            try await stream?.stopCapture()
        } catch {
            logger.error("Error stopping capture: \(error.localizedDescription)")
        }

        // Close audio file
        audioState.audioFile = nil
        stream = nil
        isRecording = false
        capturedAppName = nil

        logger.info("ScreenCaptureKit recording stopped")
    }

    // MARK: - Error Types

    enum RecorderError: LocalizedError {
        case noDisplay
        case noAudioFormat
        case captureNotAuthorized

        var errorDescription: String? {
            switch self {
            case .noDisplay:
                return "No display available for capture"
            case .noAudioFormat:
                return "Failed to create audio format"
            case .captureNotAuthorized:
                return "Screen capture not authorized. Please enable in System Settings > Privacy & Security > Screen Recording"
            }
        }
    }
}

// MARK: - SCStreamOutput

extension ScreenCaptureAudioRecorder: SCStreamOutput {

    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid else { return }

        switch type {
        case .screen:
            // Ignore video frames - we only want audio
            break

        case .audio:
            processAudioBuffer(sampleBuffer)

        case .microphone:
            // We handle microphone separately with AVAudioRecorder
            break

        @unknown default:
            break
        }
    }

    private nonisolated func processAudioBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let formatDescription = sampleBuffer.formatDescription,
              let audioFile = audioState.audioFile else { return }

        let numSamples = AVAudioFrameCount(sampleBuffer.numSamples)
        guard numSamples > 0 else { return }

        let format = AVAudioFormat(cmAudioFormatDescription: formatDescription)

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: numSamples) else { return }
        pcmBuffer.frameLength = numSamples

        let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer,
            at: 0,
            frameCount: Int32(numSamples),
            into: pcmBuffer.mutableAudioBufferList
        )

        guard status == noErr else {
            debugLog("SCK ERROR: Failed to copy PCM data - status \(status)")
            return
        }

        // Track amplitude for debugging
        var localMaxAmp = audioState.maxAmplitude
        if let channelData = pcmBuffer.floatChannelData {
            for i in 0..<min(Int(numSamples), 1000) {
                let sample = abs(channelData[0][i])
                if sample > localMaxAmp {
                    localMaxAmp = sample
                }
            }
        }
        audioState.maxAmplitude = localMaxAmp

        audioState.bufferCount += 1
        let currentCount = audioState.bufferCount

        // Log periodically
        if currentCount % 50 == 0 {
            debugLog("SCK: \(currentCount) buffers, maxAmp: \(localMaxAmp)")
        }

        // Write to file
        do {
            try audioFile.write(from: pcmBuffer)
        } catch {
            debugLog("SCK ERROR: Failed to write audio - \(error)")
        }
    }
}

// MARK: - SCStreamDelegate

extension ScreenCaptureAudioRecorder: SCStreamDelegate {

    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        debugLog("SCK: Stream stopped with error - \(error.localizedDescription)")

        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.isRecording = false
        }
    }
}

// MARK: - Debug Logging

private func debugLog(_ message: String) {
    let logFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("processtap_debug.log")
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let logMessage = "[\(timestamp)] \(message)\n"
    if let data = logMessage.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: logFile.path) {
            if let handle = try? FileHandle(forWritingTo: logFile) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            try? data.write(to: logFile)
        }
    }
}
