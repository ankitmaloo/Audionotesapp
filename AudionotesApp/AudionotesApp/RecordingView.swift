import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var audioCapService: AudioCapService
    private let openAIService = OpenAIService()
    
    @State private var noteTitle = ""
    @State private var selectedFolder = "General"
    @State private var recordingStartTime: Date?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showSettingsPopover = false
    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""
    @State private var isTranscribing = false
    
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
        VStack(spacing: 12) {
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
                    Text(audioCapService.isRecording ? (isTranscribing ? "Stopping..." : "Stop Recording") : "Start Recording")
                        .font(.headline)
                }
                .frame(maxWidth: 220)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(false)
            .tint(audioCapService.isRecording ? .red : .blue)

            HStack(spacing: 8) {
                if isTranscribing {
                    ProgressView().controlSize(.small)
                    Text("Transcribing...").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button { showSettingsPopover.toggle() } label: {
                    Label("Transcription Settings", systemImage: "gearshape")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .popover(isPresented: $showSettingsPopover, arrowEdge: .top) {
                    OpenAISettingsPanelView { showSettingsPopover = false }
                        .frame(width: 520)
                }
            }
            .frame(maxWidth: 400)
        }
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
        
        var note = Note(
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

        // Kick off transcription for available audio sources (with timestamps)
        let config = OpenAIConfig(
            baseURL: openAIBaseURL,
            apiKey: openAIAPIKey,
            transcriptionModel: openAITranscriptionModel,
            textModel: openAITextModel
        )
        isTranscribing = true
        Task { @MainActor in
            do {
                let fm = FileManager.default
                func fileExistsNonEmpty(_ url: URL) -> Bool {
                    guard fm.fileExists(atPath: url.path) else { return false }
                    if let attrs = try? fm.attributesOfItem(atPath: url.path), let size = attrs[.size] as? NSNumber {
                        return size.intValue > 0
                    }
                    return true
                }

                let hasMic = fileExistsNonEmpty(micURL)
                let hasSys = fileExistsNonEmpty(systemURL)

                var mic: TranscriptionResult?
                var sys: TranscriptionResult?

                if hasMic && hasSys {
                    async let micResult = openAIService.transcribeAudioDetailed(at: micURL, config: config, prompt: "Transcribe the speech clearly with timestamps per segment.")
                    async let sysResult = openAIService.transcribeAudioDetailed(at: systemURL, config: config, prompt: "Transcribe the audio clearly with timestamps per segment.")
                    do {
                        (mic, sys) = try await (micResult, sysResult)
                    } catch {
                        // Handle partial failures by trying serially and storing error
                        // Mic
                        do { mic = try await openAIService.transcribeAudioDetailed(at: micURL, config: config, prompt: "Transcribe the speech clearly with timestamps per segment.") } catch {
                            notesManager.updateNoteTranscriptionError(noteID: note.id, message: "Transcription (Mic) failed: \(error.localizedDescription)")
                        }
                        // System
                        do { sys = try await openAIService.transcribeAudioDetailed(at: systemURL, config: config, prompt: "Transcribe the audio clearly with timestamps per segment.") } catch {
                            notesManager.updateNoteTranscriptionError(noteID: note.id, message: "Transcription (System) failed: \(error.localizedDescription)")
                        }
                    }
                } else if hasMic {
                    do {
                        mic = try await openAIService.transcribeAudioDetailed(at: micURL, config: config, prompt: "Transcribe the speech clearly with timestamps per segment.")
                    } catch {
                        notesManager.updateNoteTranscriptionError(noteID: note.id, message: "Transcription (Mic) failed: \(error.localizedDescription)")
                    }
                } else if hasSys {
                    do {
                        sys = try await openAIService.transcribeAudioDetailed(at: systemURL, config: config, prompt: "Transcribe the audio clearly with timestamps per segment.")
                    } catch {
                        notesManager.updateNoteTranscriptionError(noteID: note.id, message: "Transcription (System) failed: \(error.localizedDescription)")
                    }
                } else {
                    notesManager.updateNoteTranscript(noteID: note.id, transcript: "No audio files found to transcribe.")
                    isTranscribing = false
                    return
                }

                // Update timestamped transcripts on the note if present
                if let mic { notesManager.updateNoteMicTimestamped(noteID: note.id, transcriptTS: mic.timestampedText) }
                if let sys { notesManager.updateNoteSystemTimestamped(noteID: note.id, transcriptTS: sys.timestampedText) }

                var combinedForModel = ""
                if let mic { combinedForModel += "Microphone Transcript (Timestamped):\n\(mic.timestampedText)\n\n" }
                if let sys { combinedForModel += "System Audio Transcript (Timestamped):\n\(sys.timestampedText)\n\n" }
                combinedForModel = combinedForModel.trimmingCharacters(in: .whitespacesAndNewlines)

                // If there is no transcript content (both failed), bail
                guard !combinedForModel.isEmpty else {
                    notesManager.updateNoteTranscript(noteID: note.id, transcript: "Transcription failed or produced no content.")
                    isTranscribing = false
                    return
                }

                do {
                    let extracted = try await openAIService.extractActionItems(from: combinedForModel, config: config)
                    let combinedForNote = """
                    Summary:\n\(extracted.summary)\n\nAction Items:\n\(extracted.actionItems.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))\n\n\(combinedForModel)
                    """
                    notesManager.updateNoteTranscript(noteID: note.id, transcript: combinedForNote)
                } catch {
                    notesManager.updateNoteSummaryError(noteID: note.id, message: "Summary extraction failed: \(error.localizedDescription)")
                    // Still store raw transcripts for reference
                    notesManager.updateNoteTranscript(noteID: note.id, transcript: combinedForModel)
                }
            } catch {
                // Preserve baseline transcript state and surface an unobtrusive message
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                notesManager.updateNoteTranscriptionError(noteID: note.id, message: msg)
                alertMessage = msg
                showingAlert = true
            }
            isTranscribing = false
        }
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
        .environmentObject(AudioCapService())
}
