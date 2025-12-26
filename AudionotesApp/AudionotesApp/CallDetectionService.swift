import Foundation
import Combine
import OSLog
import AVFoundation

@MainActor
final class CallDetectionService: ObservableObject {

    @Published private(set) var isCallActive = false
    @Published private(set) var isMicrophoneActive = false
    @Published private(set) var isSystemAudioActive = false
    @Published private(set) var activeProcess: AudioProcess?
    @Published var shouldPromptForRecording = false

    private let logger = Logger(subsystem: kAppSubsystem, category: String(describing: CallDetectionService.self))
    private let microphoneMonitor = MicrophoneActivityMonitor()
    private let processController = AudioProcessController()
    private let audioCapService: AudioCapService
    private let monitoringEnabled: Bool

    private var cancellables = Set<AnyCancellable>()
    private var pendingPromptTask: Task<Void, Never>?
    private var hasPromptedForCurrentCall = false
    private var promptCooldownAnchor: Date?

    private let promptCooldown: TimeInterval = 120
    private let confirmationDelay: TimeInterval = 1.0

    init(audioCapService: AudioCapService, monitoringEnabled: Bool = true) {
        self.audioCapService = audioCapService
        self.monitoringEnabled = monitoringEnabled

        processController.activate()
        bind()

        if monitoringEnabled {
            startMonitoringIfPossible()
        }
    }

    func updatePermissionStatus(_ status: AudioRecordingPermission.Status) {
        guard monitoringEnabled else { return }
        switch status {
        case .authorized:
            startMonitoringIfPossible()
        case .denied, .unknown:
            stopMonitoring()
        }
    }

    func markPromptHandled() {
        shouldPromptForRecording = false
    }

    private func bind() {
        microphoneMonitor.$isActive
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                self?.isMicrophoneActive = active
                self?.evaluateCallState()
            }
            .store(in: &cancellables)

        processController.$isAnyAudioPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                self?.isSystemAudioActive = active
                self?.evaluateCallState()
            }
            .store(in: &cancellables)

        processController.$activeProcess
            .receive(on: RunLoop.main)
            .sink { [weak self] process in
                self?.activeProcess = process
            }
            .store(in: &cancellables)

        audioCapService.$isRecording
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isRecording in
                guard let self else { return }
                self.processController.isRecording = isRecording
                if isRecording {
                    self.cancelPendingPrompt()
                    self.hasPromptedForCurrentCall = true
                    self.stopMonitoring()
                } else {
                    // Delay monitoring restart after stopping to avoid false positives
                    self.promptCooldownAnchor = Date()
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 second delay
                        self.startMonitoringIfPossible()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func evaluateCallState() {
        let combinedActive = isMicrophoneActive && isSystemAudioActive

        if combinedActive {
            guard !audioCapService.isRecording else { return }
            if !isCallActive {
                logger.info("Potential call detected")
                isCallActive = true
                schedulePromptIfNeeded()
            }
        } else {
            if isCallActive {
                logger.info("Call activity ended")
            }
            isCallActive = false
            hasPromptedForCurrentCall = false
            cancelPendingPrompt()
            shouldPromptForRecording = false
        }
    }

    private func schedulePromptIfNeeded() {
        guard !hasPromptedForCurrentCall else { return }
        if let anchor = promptCooldownAnchor, Date().timeIntervalSince(anchor) < promptCooldown {
            return
        }

        cancelPendingPrompt()
        pendingPromptTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(confirmationDelay * 1_000_000_000))
            await self?.finalizePrompt()
        }
    }

    private func finalizePrompt() async {
        guard !Task.isCancelled else { return }
        guard !audioCapService.isRecording else { return }
        guard isCallActive else { return }

        hasPromptedForCurrentCall = true
        promptCooldownAnchor = Date()
        shouldPromptForRecording = true
        logger.info("Prompting user to start recording")
    }

    private func cancelPendingPrompt() {
        pendingPromptTask?.cancel()
        pendingPromptTask = nil
    }

    private func startMonitoringIfPossible() {
        guard monitoringEnabled else { return }
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
            logger.debug("Microphone permission not granted; monitoring skipped")
            return
        }

        do {
            try microphoneMonitor.start()
        } catch {
            logger.error("Unable to start microphone monitor: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func stopMonitoring() {
        guard monitoringEnabled else { return }
        microphoneMonitor.stop()
    }
}
