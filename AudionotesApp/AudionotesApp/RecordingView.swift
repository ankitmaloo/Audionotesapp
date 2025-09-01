import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var notesManager: NotesManager
    @StateObject private var audioCapService = AudioCapService()
    
    @State private var noteTitle = ""
    @State private var selectedFolder = "General"
    @State private var recordingStartTime: Date?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            if audioCapService.isRecording {
                recordingStatusView
            } else {
                setupView
            }
            
            recordingControlsView
            
            Spacer()
        }
        .padding()
        .alert("Recording Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(audioCapService.isRecording ? .red : .blue)
                .scaleEffect(audioCapService.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: audioCapService.isRecording)
            
            Text("Audio Notes")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    
    @ViewBuilder
    private var setupView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Note Title")
                    .font(.headline)
                
                TextField("Enter note title", text: $noteTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Folder")
                    .font(.headline)
                
                Picker("Folder", selection: $selectedFolder) {
                    ForEach(notesManager.folders, id: \.name) { folder in
                        Text(folder.name)
                            .tag(folder.name)
                    }
                }
                .pickerStyle(.menu)
            }
            
            VStack(spacing: 10) {
                // Microphone status (always available)
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.blue)
                    Text("Microphone recording ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // System audio status
                if let activeProcess = audioCapService.getCurrentActiveProcess() {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.green)
                        Text("System audio from: \(activeProcess.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    HStack {
                        Image(systemName: "speaker.slash.fill")
                            .foregroundColor(.orange)
                        Text("No system audio detected (microphone recording will still work)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    @ViewBuilder
    private var recordingStatusView: some View {
        VStack(spacing: 20) {
            Text("Recording...")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            if let activeProcess = audioCapService.activeProcess {
                HStack {
                    Image(systemName: "app.fill")
                        .foregroundColor(.blue)
                    Text("Recording from: \(activeProcess.name)")
                        .font(.headline)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let startTime = recordingStartTime {
                RecordingTimerView(startTime: startTime)
            }
            
            VStack(spacing: 8) {
                Text("Note: \(noteTitle.isEmpty ? "Untitled" : noteTitle)")
                    .font(.subheadline)
                Text("Folder: \(selectedFolder)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var recordingControlsView: some View {
        Button {
            if audioCapService.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            HStack {
                Image(systemName: audioCapService.isRecording ? "stop.fill" : "record.circle.fill")
                    .font(.title2)
                Text(audioCapService.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
            }
            .frame(maxWidth: 200)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(false) // Always allow recording - microphone should work independently
        .tint(audioCapService.isRecording ? .red : .blue)
    }
    
    private func startRecording() {
        guard !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter a note title")
            return
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let sanitizedTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        
        let systemFileName = "\(sanitizedTitle)-system-\(timestamp)"
        let micFileName = "\(sanitizedTitle)-mic-\(timestamp)"
        
        let systemURL = notesManager.getFileURL(for: systemFileName, in: selectedFolder)
        let micURL = notesManager.getFileURL(for: micFileName, in: selectedFolder)
        
        do {
            try audioCapService.startRecording(systemAudioURL: systemURL, microphoneURL: micURL)
            recordingStartTime = Date()
        } catch {
            showAlert("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioCapService.stopRecording()
        
        guard let startTime = recordingStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let timestamp = Int(startTime.timeIntervalSince1970)
        let sanitizedTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        
        let systemFileName = "\(sanitizedTitle)-system-\(timestamp)"
        let micFileName = "\(sanitizedTitle)-mic-\(timestamp)"
        
        let systemURL = notesManager.getFileURL(for: systemFileName, in: selectedFolder)
        let micURL = notesManager.getFileURL(for: micFileName, in: selectedFolder)
        
        let note = Note(
            title: noteTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            systemAudioURL: systemURL,
            microphoneURL: micURL,
            folderName: selectedFolder,
            createdAt: startTime,
            duration: duration,
            transcript: ""
        )
        
        notesManager.addNote(note)
        
        noteTitle = ""
        recordingStartTime = nil
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct RecordingTimerView: View {
    let startTime: Date
    @State private var elapsedTime: TimeInterval = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(formattedTime)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.red)
            .onReceive(timer) { _ in
                elapsedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingView()
        .environmentObject(NotesManager())
}