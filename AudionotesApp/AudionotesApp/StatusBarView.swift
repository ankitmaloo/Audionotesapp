import SwiftUI
import AppKit

struct StatusBarView: View {
    @EnvironmentObject private var callDetectionService: CallDetectionService
    @EnvironmentObject private var audioCapService: AudioCapService
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusHeader
            activityDetails
            Divider()
            actionButtons
        }
        .padding(14)
        .frame(minWidth: 240)
    }

    private var statusHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(primaryStatus)
                    .font(.headline)
                Text(secondaryStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var activityDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(microphoneStatus, systemImage: callDetectionService.isMicrophoneActive ? "mic.fill" : "mic.slash")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(callDetectionService.isMicrophoneActive ? .blue : .gray)

            Label(systemAudioStatus, systemImage: callDetectionService.isSystemAudioActive ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(callDetectionService.isSystemAudioActive ? .green : .gray)

            if let process = callDetectionService.activeProcess {
                Label("Active: \(process.name)", systemImage: "app.badge")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
            }
        }
        .font(.caption)
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(audioCapService.isRecording ? "Show Recorder" : "Open Recorder") {
                focusRecorder()
            }

            Button("View Notes") {
                appState.activeTab = .notes
                bringAppToFront()
            }

            if callDetectionService.isCallActive && !audioCapService.isRecording {
                Button("Start a Note for this Call") {
                    focusRecorder()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .buttonStyle(.bordered)
    }

    private var iconName: String {
        if audioCapService.isRecording { return "record.circle" }
        if callDetectionService.isCallActive { return "phone.fill" }
        return "waveform"
    }

    private var iconColor: Color {
        if audioCapService.isRecording { return .red }
        if callDetectionService.isCallActive { return .green }
        return .accentColor
    }

    private var primaryStatus: String {
        if audioCapService.isRecording { return "Recording" }
        if callDetectionService.isCallActive { return "Call Detected" }
        return "Standing By"
    }

    private var secondaryStatus: String {
        if audioCapService.isRecording {
            return "Capturing microphone and system audio"
        }
        if callDetectionService.isCallActive {
            return "Microphone and speakers active"
        }
        return "Monitoring audio activity"
    }

    private var microphoneStatus: String {
        callDetectionService.isMicrophoneActive ? "Microphone activity detected" : "Microphone idle"
    }

    private var systemAudioStatus: String {
        callDetectionService.isSystemAudioActive ? "System audio playing" : "System audio idle"
    }

    private func focusRecorder() {
        appState.activeTab = .recording
        bringAppToFront()
    }

    private func bringAppToFront() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showAllWindows:")), to: nil, from: nil)
        if let window = NSApp.windows.first(where: { $0.isVisible }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
