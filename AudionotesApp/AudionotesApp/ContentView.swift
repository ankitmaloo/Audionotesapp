import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var permission = AudioRecordingPermission()
    @StateObject private var notesManager = NotesManager()
    
    var body: some View {
        VStack(spacing: 15) {
            switch permission.status {
            case .unknown:
                requestPermissionView
            case .authorized:
                recordingView
            case .denied:
                permissionDeniedView
            }
        }
        .padding()
        .environmentObject(notesManager)
    }
    
    @ViewBuilder
    private var requestPermissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Audio Recording Permission")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("AudioNotes needs access to your microphone to record audio notes.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Allow Audio Recording") {
                permission.request()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: 400)
    }
    
    @ViewBuilder
    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Microphone Access Denied")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("AudioNotes requires microphone access to record audio notes. Please enable it in System Settings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Open System Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: 400)
    }
    
    @ViewBuilder
    private var recordingView: some View {
        TabView {
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            
            RecordingView()
                .tabItem {
                    Label("Record", systemImage: "mic.fill")
                }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
}