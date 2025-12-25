import Foundation
import AVFoundation
import AudioToolbox
import OSLog

/// A service that provides dual audio recording capabilities (system audio + microphone)
/// Can be used by any interface to record audio from system processes and microphone simultaneously
@MainActor
final class AudioCapService: ObservableObject {

    private let logger = Logger(subsystem: kAppSubsystem, category: String(describing: AudioCapService.self))

    // MARK: - Public Properties

    /// Whether the service is currently recording
    @Published private(set) var isRecording = false

    /// Current active process being recorded (for system audio)
    @Published private(set) var activeProcess: AudioProcess?

    /// Error message if something goes wrong
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private let processController = AudioProcessController()
    private var screenCaptureRecorder: ScreenCaptureAudioRecorder?
    private var microphoneRecorder: AVAudioRecorder?

    // MARK: - Initialization

    init() {
        processController.activate()
    }
    
    // MARK: - Public API

    /// Start recording both system audio and microphone to separate files
    /// - Parameters:
    ///   - systemAudioURL: URL where system audio will be saved
    ///   - microphoneURL: URL where microphone audio will be saved
    /// - Returns: True if recording started successfully
    func startRecording(systemAudioURL: URL, microphoneURL: URL) async throws {
        guard !isRecording else {
            logger.warning("Already recording")
            return
        }

        errorMessage = nil

        // Setup system audio recording using ScreenCaptureKit
        try await setupSystemAudioRecording(fileURL: systemAudioURL)

        // Setup microphone recording
        try setupMicrophoneRecording(fileURL: microphoneURL)

        // Start microphone recording (system audio already started in setup)
        _ = microphoneRecorder?.record()

        processController.isRecording = true
        isRecording = true

        // Set active process info for display (ScreenCaptureKit captures all system audio)
        self.activeProcess = processController.activeProcess

        logger.info("Started dual recording with ScreenCaptureKit")
    }
    
    /// Stop recording both tracks
    func stopRecording() async {
        guard isRecording else { return }

        logger.info("Stopping dual recording")

        // Stop system audio recording
        await screenCaptureRecorder?.stopRecording()
        screenCaptureRecorder = nil

        // Stop microphone recording
        microphoneRecorder?.stop()
        microphoneRecorder = nil

        processController.isRecording = false
        isRecording = false
        activeProcess = nil
    }
    
    /// Get the current active audio process
    func getCurrentActiveProcess() -> AudioProcess? {
        return processController.activeProcess
    }

    /// Check if there's any audio playing
    func isAnyAudioPlaying() -> Bool {
        return processController.isAnyAudioPlaying
    }

    // MARK: - Private Methods

    private func setupSystemAudioRecording(fileURL: URL) async throws {
        let recorder = ScreenCaptureAudioRecorder()
        self.screenCaptureRecorder = recorder

        // Start recording all system audio (no specific app bundle ID)
        try await recorder.startRecording(to: fileURL, appBundleID: nil)
    }

    private func setupMicrophoneRecording(fileURL: URL) throws {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]

        let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.prepareToRecord()

        self.microphoneRecorder = recorder
    }
}

// MARK: - Error Types

enum AudioCapServiceError: LocalizedError {
    case screenCaptureSetupFailed
    case microphoneSetupFailed

    var errorDescription: String? {
        switch self {
        case .screenCaptureSetupFailed:
            return "Failed to setup system audio recording. Please enable Screen Recording permission in System Settings > Privacy & Security."
        case .microphoneSetupFailed:
            return "Failed to setup microphone recording."
        }
    }
}

// MARK: - Recording Result

struct AudioCapRecordingResult {
    let systemAudioURL: URL
    let microphoneURL: URL
    let process: AudioProcess
    let startTime: Date
    let endTime: Date
}