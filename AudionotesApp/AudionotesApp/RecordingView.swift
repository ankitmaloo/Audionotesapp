import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var audioCapService: AudioCapService
    private let openAIService = OpenAIService()

    @State private var noteTitle = ""
    @State private var selectedFolder = "General"
    @State private var recordingStartTime: Date?
    @State private var recordingTimestamp: Int?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showSettingsPopover = false
    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""
    @State private var isTranscribing = false

    // Animation states
    @State private var hasAppeared = false
    @State private var recordButtonHovered = false
    @State private var settingsButtonHovered = false

    var body: some View {
        ZStack {
            // Layered background with gradient mesh and vignette
            backgroundLayer

            // Main content with asymmetric layout
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    // Decorative accent line
                    decorativeAccent
                        .offset(x: geometry.size.width * 0.08, y: geometry.size.height * 0.12)
                        .opacity(hasAppeared ? 0.6 : 0)
                        .animation(.easeOut(duration: 1.2).delay(0.8), value: hasAppeared)

                    VStack(alignment: .leading, spacing: 0) {
                        // Asymmetric header with diagonal flow
                        asymmetricHeader
                            .padding(.top, 60)
                            .padding(.leading, 40)
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : -30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: hasAppeared)

                        Spacer()
                            .frame(height: 60)

                        // Main content area with offset for asymmetry
                        HStack(spacing: 40) {
                            Spacer()
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 32) {
                                if audioCapService.isRecording {
                                    recordingActiveView
                                } else {
                                    recordingSetupView
                                }

                                Spacer()
                                    .frame(minHeight: 40)

                                // Dramatic recording button
                                recordingControlSection
                            }
                            .frame(maxWidth: 600)

                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                hasAppeared = true
            }
        }
        .alert("Recording Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            // Base gradient mesh
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.15),
                    Color(red: 0.03, green: 0.03, blue: 0.09)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Radial gradient overlay for depth
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.08),
                    Color.blue.opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 600
            )

            // Noise texture simulation with pattern
            Canvas { context, size in
                let columns = Int(size.width / 4)
                let rows = Int(size.height / 4)

                for row in 0..<rows {
                    for col in 0..<columns {
                        let x = Double(col) * 4
                        let y = Double(row) * 4
                        let noise = Double.random(in: 0...1)

                        if noise > 0.7 {
                            let opacity = (noise - 0.7) * 0.15
                            context.fill(
                                Path(CGRect(x: x, y: y, width: 4, height: 4)),
                                with: .color(.white.opacity(opacity))
                            )
                        }
                    }
                }
            }
            .opacity(0.4)

            // Vignette overlay
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                center: .center,
                startRadius: 200,
                endRadius: 800
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Decorative Elements

    private var decorativeAccent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            audioCapService.isRecording ? Color.red : Color.blue,
                            audioCapService.isRecording ? Color.orange : Color.purple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 120, height: 3)

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 60, height: 1)
        }
        .animation(.easeInOut(duration: 0.6), value: audioCapService.isRecording)
    }

    // MARK: - Asymmetric Header

    private var asymmetricHeader: some View {
        HStack(alignment: .top, spacing: 24) {
            // VU Meter / Audio Visualizer
            VUMeterView(isRecording: audioCapService.isRecording)
                .frame(width: 80, height: 80)
                .shadow(color: audioCapService.isRecording ? Color.red.opacity(0.5) : Color.blue.opacity(0.4), radius: 20, x: 0, y: 10)
                .opacity(hasAppeared ? 1 : 0)
                .scaleEffect(hasAppeared ? 1 : 0.3)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: hasAppeared)

            VStack(alignment: .leading, spacing: 8) {
                Text("Audio Notes")
                    .font(.system(size: 48, weight: .light, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(1.2)

                Text(audioCapService.isRecording ? "Recording Session Active" : "Ready to Capture")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(2)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: hasAppeared)
            }

            Spacer()

            // Settings button with hover effect
            Button {
                showSettingsPopover.toggle()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(settingsButtonHovered ? 1 : 0.6))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(settingsButtonHovered ? 0.15 : 0.08))
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .scaleEffect(settingsButtonHovered ? 1.1 : 1.0)
                    .shadow(color: .white.opacity(settingsButtonHovered ? 0.3 : 0), radius: 10)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    settingsButtonHovered = hovering
                }
            }
            .popover(isPresented: $showSettingsPopover, arrowEdge: .top) {
                OpenAISettingsPanelView { showSettingsPopover = false }
                    .frame(width: 520)
            }
            .padding(.trailing, 40)
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: hasAppeared)
        }
    }

    // MARK: - Recording Setup View

    private var recordingSetupView: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Note title input with glass morphism
            VStack(alignment: .leading, spacing: 12) {
                Text("Note Title")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(1.5)

                TextField("", text: $noteTitle, prompt: Text("Enter a descriptive title...").foregroundColor(.white.opacity(0.3)))
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
                        }
                    )
                    .textFieldStyle(.plain)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.3), value: hasAppeared)

            // Folder picker with glass morphism
            VStack(alignment: .leading, spacing: 12) {
                Text("Destination Folder")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(1.5)

                Picker("", selection: $selectedFolder) {
                    ForEach(notesManager.folders, id: \.name) { folder in
                        Text(folder.name)
                            .tag(folder.name)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                )
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: hasAppeared)

            // Status indicators with glass morphism and animated icons
            VStack(spacing: 16) {
                // Microphone status
                StatusCard(
                    icon: "mic.fill",
                    iconColor: .blue,
                    title: "Microphone Ready",
                    subtitle: "High-quality voice capture enabled",
                    accentColor: .blue
                )
                .opacity(hasAppeared ? 1 : 0)
                .offset(x: hasAppeared ? 0 : -30)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.5), value: hasAppeared)

                // System audio status
                if let activeProcess = audioCapService.getCurrentActiveProcess() {
                    StatusCard(
                        icon: "speaker.wave.2.fill",
                        iconColor: .green,
                        title: "System Audio Connected",
                        subtitle: "Capturing from: \(activeProcess.name)",
                        accentColor: .green
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.6), value: hasAppeared)
                } else {
                    StatusCard(
                        icon: "speaker.slash.fill",
                        iconColor: .orange,
                        title: "System Audio Unavailable",
                        subtitle: "Microphone recording will proceed normally",
                        accentColor: .orange
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.6), value: hasAppeared)
                }
            }
        }
    }

    // MARK: - Recording Active View

    private var recordingActiveView: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Recording status with dramatic styling
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .shadow(color: .red, radius: 8, x: 0, y: 0)
                        .scaleEffect(hasAppeared ? 1 : 0.5)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: audioCapService.isRecording)

                    Text("Recording in Progress")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                        .textCase(.uppercase)
                        .tracking(2)
                }

                if let startTime = recordingStartTime {
                    EnhancedRecordingTimerView(startTime: startTime)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : -10)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: hasAppeared)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.4), Color.red.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .red.opacity(0.2), radius: 20, x: 0, y: 8)
            )
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: hasAppeared)

            // Session details
            VStack(alignment: .leading, spacing: 20) {
                SessionDetailRow(
                    label: "Note",
                    value: noteTitle.isEmpty ? "Untitled Recording" : noteTitle
                )

                SessionDetailRow(
                    label: "Folder",
                    value: selectedFolder
                )

                if let activeProcess = audioCapService.activeProcess {
                    SessionDetailRow(
                        label: "Source",
                        value: activeProcess.name,
                        icon: "app.fill"
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .animation(.easeOut(duration: 0.7).delay(0.4), value: hasAppeared)
        }
    }

    // MARK: - Recording Control Section

    private var recordingControlSection: some View {
        VStack(spacing: 20) {
            // Main recording button with dramatic effects
            Button {
                if audioCapService.isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: audioCapService.isRecording ? "stop.fill" : "record.circle.fill")
                        .font(.system(size: 24, weight: .semibold))

                    Text(audioCapService.isRecording ? (isTranscribing ? "Finalizing..." : "Stop Recording") : "Start Recording")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .tracking(0.5)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    ZStack {
                        // Base layer with gradient
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: audioCapService.isRecording ?
                                        [Color.red, Color.red.opacity(0.8)] :
                                        [Color.blue, Color.purple.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        // Glow layer
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: audioCapService.isRecording ?
                                        [Color.red.opacity(0.4), Color.clear] :
                                        [Color.blue.opacity(0.4), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .blur(radius: recordButtonHovered ? 10 : 0)
                            .opacity(recordButtonHovered ? 1 : 0)

                        // Border highlight
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(
                    color: audioCapService.isRecording ?
                        Color.red.opacity(recordButtonHovered ? 0.6 : 0.4) :
                        Color.blue.opacity(recordButtonHovered ? 0.6 : 0.4),
                    radius: recordButtonHovered ? 30 : 20,
                    x: 0,
                    y: recordButtonHovered ? 12 : 8
                )
                .scaleEffect(recordButtonHovered ? 1.03 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    recordButtonHovered = hovering
                }
            }
            .disabled(isTranscribing)
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.9)
            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.6), value: hasAppeared)

            // Transcription status indicator
            if isTranscribing {
                HStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white.opacity(0.7))

                    Text("Processing transcription...")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Recording Functions

    private func startRecording() {
        guard !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter a note title")
            return
        }

        let startTime = Date()
        let timestamp = Int(startTime.timeIntervalSince1970)
        let sanitizedTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()

        let systemFileName = "\(sanitizedTitle)-system-\(timestamp)"
        let micFileName = "\(sanitizedTitle)-mic-\(timestamp)"

        let systemURL = notesManager.getFileURL(for: systemFileName, in: selectedFolder)
        let micURL = notesManager.getFileURL(for: micFileName, in: selectedFolder)

        Task {
            do {
                try await audioCapService.startRecording(systemAudioURL: systemURL, microphoneURL: micURL)
                recordingStartTime = startTime
                recordingTimestamp = timestamp
            } catch {
                showAlert("Failed to start recording: \(error.localizedDescription)")
            }
        }
    }

    private func stopRecording() {
        Task {
            await audioCapService.stopRecording()
        }

        guard let startTime = recordingStartTime, let timestamp = recordingTimestamp else { return }

        let duration = Date().timeIntervalSince(startTime)
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
        recordingTimestamp = nil

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

// MARK: - VU Meter Visualizer Component

struct VUMeterView: View {
    let isRecording: Bool
    @State private var barHeights: [CGFloat] = Array(repeating: 0.3, count: 7)

    private let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientColors(for: index),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 8, height: barHeights[index] * 80)
                    .shadow(color: barColor(for: index).opacity(0.6), radius: 4, x: 0, y: 2)
            }
        }
        .onReceive(timer) { _ in
            if isRecording {
                withAnimation(.easeInOut(duration: 0.08)) {
                    updateBarHeights()
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    barHeights = Array(repeating: 0.3, count: 7)
                }
            }
        }
    }

    private func updateBarHeights() {
        for index in 0..<barHeights.count {
            // Simulate audio levels with some variation
            let baseLevel = CGFloat.random(in: 0.2...0.95)
            let smoothing: CGFloat = 0.7
            barHeights[index] = barHeights[index] * smoothing + baseLevel * (1 - smoothing)
        }
    }

    private func barColor(for index: Int) -> Color {
        if isRecording {
            switch index {
            case 0...2: return .green
            case 3...4: return .yellow
            default: return .red
            }
        } else {
            return .blue
        }
    }

    private func gradientColors(for index: Int) -> [Color] {
        let baseColor = barColor(for: index)
        return [baseColor, baseColor.opacity(0.6)]
    }
}

// MARK: - Status Card Component

struct StatusCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let accentColor: Color

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 16) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Circle()
                    .strokeBorder(iconColor.opacity(0.3), lineWidth: 1)
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)
            .shadow(color: iconColor.opacity(isHovered ? 0.4 : 0), radius: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(20)
        .background(
            ZStack {
                // Glass morphism effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(isHovered ? 0.12 : 0.08),
                                        accentColor.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                // Border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(isHovered ? 0.4 : 0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: accentColor.opacity(isHovered ? 0.2 : 0.1), radius: 12, x: 0, y: 6)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Enhanced Recording Timer

struct EnhancedRecordingTimerView: View {
    let startTime: Date
    @State private var elapsedTime: TimeInterval = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {
            Text(formattedTime)
                .font(.system(size: 56, weight: .light, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .monospacedDigit()
                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)

            VStack(alignment: .leading, spacing: 2) {
                Text("MIN")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1)

                Text("SEC")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1)
            }
            .offset(y: 2)
        }
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

// MARK: - Session Detail Row

struct SessionDetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.5)
                .frame(width: 80, alignment: .leading)

            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(value)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    RecordingView()
        .environmentObject(NotesManager())
        .environmentObject(AudioCapService())
}
