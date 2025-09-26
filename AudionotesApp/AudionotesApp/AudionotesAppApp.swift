import SwiftUI

@main
struct AudionotesAppApp: App {
    @AppStorage("geminiAPIKey") private var geminiAPIKey: String = ""
    @State private var showingAPIKeyInput = false

    @StateObject private var notesManager: NotesManager
    @StateObject private var audioCapService: AudioCapService
    @StateObject private var callDetectionService: CallDetectionService
    @StateObject private var appState: AppState
    @StateObject private var permission: AudioRecordingPermission
    @StateObject private var promptCoordinator: CallPromptCoordinator

    init() {
        let notesManager = NotesManager()
        let audioCapService = AudioCapService()
        let appState = AppState()
        let permission = AudioRecordingPermission()
        let callDetectionService = CallDetectionService(audioCapService: audioCapService)

        _notesManager = StateObject(wrappedValue: notesManager)
        _audioCapService = StateObject(wrappedValue: audioCapService)
        _appState = StateObject(wrappedValue: appState)
        _permission = StateObject(wrappedValue: permission)
        _callDetectionService = StateObject(wrappedValue: callDetectionService)
        _promptCoordinator = StateObject(wrappedValue: CallPromptCoordinator(callDetectionService: callDetectionService, appState: appState))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesManager)
                .environmentObject(audioCapService)
                .environmentObject(callDetectionService)
                .environmentObject(appState)
                .environmentObject(permission)
                .onAppear {
                    if geminiAPIKey.isEmpty {
                        showingAPIKeyInput = true
                    }
                    callDetectionService.updatePermissionStatus(permission.status)
                }
                .onChange(of: permission.status) { newValue in
                    callDetectionService.updatePermissionStatus(newValue)
                }
                .sheet(isPresented: $showingAPIKeyInput) {
                    APIKeyInputView()
                        .environmentObject(permission)
                }
        }

        MenuBarExtra("AudioNotes", systemImage: menuIconName) {
            StatusBarView()
                .environmentObject(callDetectionService)
                .environmentObject(audioCapService)
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuIconName: String {
        if audioCapService.isRecording { return "record.circle" }
        if callDetectionService.isCallActive { return "phone.fill" }
        return "waveform"
    }
}
