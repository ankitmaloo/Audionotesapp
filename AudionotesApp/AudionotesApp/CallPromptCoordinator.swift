import Foundation
import Combine
import AppKit

@MainActor
final class CallPromptCoordinator: ObservableObject {

    private let callDetectionService: CallDetectionService
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    init(callDetectionService: CallDetectionService, appState: AppState) {
        self.callDetectionService = callDetectionService
        self.appState = appState
        observePrompts()
    }

    private func observePrompts() {
        callDetectionService.$shouldPromptForRecording
            .removeDuplicates()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.presentPrompt()
            }
            .store(in: &cancellables)
    }

    private func presentPrompt() {
        callDetectionService.markPromptHandled()

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Looks like you're on a call"
        alert.informativeText = "Microphone and speakers are both active. Want to capture notes?"
        alert.addButton(withTitle: "Start Recording")
        alert.addButton(withTitle: "Not Now")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            appState.activeTab = .recording
            NSApp.sendAction(Selector(("showAllWindows:")), to: nil, from: nil)
            if let window = NSApp.windows.first(where: { $0.isVisible }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}
