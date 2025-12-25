//
//  NoteDetailView.swift
//  AudionotesApp
//
//  Expanded view for a note showing full transcript and audio playback
//

import SwiftUI
import AVFoundation

// MARK: - Note Detail View

struct NoteDetailView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Atmospheric background
            DesignSystem.Colors.atmosphericBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with close button
                headerView

                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        // Metadata section
                        metadataSection

                        // Transcript section
                        transcriptSection
                    }
                    .padding(DesignSystem.Spacing.lg)
                }

                // Audio player at the bottom
                AudioPlayerView(note: note)
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        Rectangle()
                            .fill(Color.dsBackgroundSecondary)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
                    )
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    // MARK: - Header View

    @ViewBuilder
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(note.displayTitle)
                    .font(DesignSystem.Typography.titleLarge(weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(note.formattedDate)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(DesignSystem.Spacing.lg)
        .background(Color.dsBackgroundSecondary.opacity(0.5))
    }

    // MARK: - Metadata Section

    @ViewBuilder
    private var metadataSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Folder badge
            HStack(spacing: 4) {
                Image(systemName: "folder.fill")
                    .font(DesignSystem.Typography.caption())
                Text(note.folderName)
                    .font(DesignSystem.Typography.caption(weight: .medium))
            }
            .foregroundColor(folderColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(folderColor.opacity(0.15))
            )

            // Duration badge
            HStack(spacing: 4) {
                Image(systemName: "waveform")
                    .font(DesignSystem.Typography.caption())
                Text(note.formattedDuration)
                    .font(DesignSystem.Typography.mono(size: 11))
            }
            .foregroundColor(DesignSystem.Colors.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )

            Spacer()
        }
    }

    // MARK: - Transcript Section

    @ViewBuilder
    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section header
            HStack {
                Image(systemName: "text.alignleft")
                    .font(DesignSystem.Typography.bodyMedium(weight: .semibold))
                Text("Transcript")
                    .font(DesignSystem.Typography.titleSmall(weight: .semibold))
            }
            .foregroundColor(DesignSystem.Colors.primaryText)

            // Error messages if any
            if let err = note.transcriptionError, !err.isEmpty {
                Label("Transcription Error: \(err)", systemImage: "xmark.octagon.fill")
                    .font(DesignSystem.Typography.bodySmall())
                    .foregroundColor(.red)
                    .padding(DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(Color.red.opacity(0.1))
                    )
            }

            if let err = note.summaryError, !err.isEmpty {
                Label("Summary Error: \(err)", systemImage: "exclamationmark.triangle.fill")
                    .font(DesignSystem.Typography.bodySmall())
                    .foregroundColor(.orange)
                    .padding(DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(Color.orange.opacity(0.1))
                    )
            }

            // Full transcript content
            if note.transcript.isEmpty {
                Text("No transcript available")
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .italic()
                    .padding(DesignSystem.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(note.transcript)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineSpacing(8)
                    .textSelection(.enabled)
                    .padding(DesignSystem.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(Color.dsBackgroundSecondary)
                    )
            }
        }
    }

    private var folderColor: Color {
        if let colors = DesignSystem.Colors.folderColors[note.folderName] {
            return colors.idle
        }
        return DesignSystem.Colors.primaryAccent
    }
}

// MARK: - Audio Player View

struct AudioPlayerView: View {
    let note: Note

    @StateObject private var playerManager = AudioPlayerManager()
    @State private var selectedSource: AudioSource = .system
    @State private var availableSources: [AudioSource] = []

    enum AudioSource: String, CaseIterable {
        case microphone = "Microphone"
        case system = "System Audio"

        var icon: String {
            switch self {
            case .microphone: return "mic.fill"
            case .system: return "speaker.wave.2.fill"
            }
        }
    }

    private var currentURL: URL {
        switch selectedSource {
        case .microphone: return note.microphoneURL
        case .system: return note.systemAudioURL
        }
    }

    /// Check if an audio file exists and has content (more than just a header)
    private func isValidAudioFile(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return false }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            // WAV files have a 44-byte header minimum, so we check for > 1KB to ensure actual content
            if let fileSize = attributes[.size] as? Int, fileSize > 1024 {
                return true
            }
        } catch {
            print("Error checking file: \(error)")
        }
        return false
    }

    /// Determine which audio sources have valid files
    private func detectAvailableSources() -> [AudioSource] {
        var sources: [AudioSource] = []

        if isValidAudioFile(note.systemAudioURL) {
            sources.append(.system)
        }
        if isValidAudioFile(note.microphoneURL) {
            sources.append(.microphone)
        }

        return sources
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if availableSources.isEmpty {
                // No audio files available
                noAudioView
            } else {
                // Audio source selector (only if multiple sources)
                if availableSources.count > 1 {
                    audioSourcePicker
                } else {
                    // Single source indicator
                    singleSourceIndicator
                }

                // Player controls
                HStack(spacing: DesignSystem.Spacing.lg) {
                    // Time display
                    Text(formatTime(playerManager.currentTime))
                        .font(DesignSystem.Typography.mono(size: 13, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .frame(width: 50, alignment: .trailing)

                    // Progress slider
                    progressSlider

                    // Duration display
                    Text(formatTime(playerManager.duration))
                        .font(DesignSystem.Typography.mono(size: 13, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                        .frame(width: 50, alignment: .leading)
                }

                // Playback controls
                playbackControls
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.dsBackgroundTertiary)
        )
        .onAppear {
            // Detect available sources and set default
            availableSources = detectAvailableSources()
            if let firstSource = availableSources.first {
                selectedSource = firstSource
                playerManager.loadAudio(from: currentURL)
            }
        }
        .onChange(of: selectedSource) { _ in
            playerManager.stop()
            playerManager.loadAudio(from: currentURL)
        }
        .onDisappear {
            playerManager.stop()
        }
    }

    // MARK: - No Audio View

    @ViewBuilder
    private var noAudioView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "waveform.slash")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.tertiaryText)
            Text("No audio recordings available")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.lg)
    }

    // MARK: - Single Source Indicator

    @ViewBuilder
    private var singleSourceIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: selectedSource.icon)
                    .font(DesignSystem.Typography.caption())
                Text(selectedSource.rawValue)
                    .font(DesignSystem.Typography.caption(weight: .medium))
            }
            .foregroundColor(DesignSystem.Colors.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.primaryAccent.opacity(0.2))
            )

            Spacer()

            // Audio file status indicator
            statusIndicator
        }
    }

    // MARK: - Audio Source Picker

    @ViewBuilder
    private var audioSourcePicker: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(availableSources, id: \.self) { source in
                Button(action: { selectedSource = source }) {
                    HStack(spacing: 6) {
                        Image(systemName: source.icon)
                            .font(DesignSystem.Typography.caption())
                        Text(source.rawValue)
                            .font(DesignSystem.Typography.caption(weight: .medium))
                    }
                    .foregroundColor(selectedSource == source ? DesignSystem.Colors.primaryText : DesignSystem.Colors.tertiaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(selectedSource == source ? DesignSystem.Colors.primaryAccent.opacity(0.2) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .strokeBorder(selectedSource == source ? DesignSystem.Colors.primaryAccent.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Audio file status indicator
            statusIndicator
        }
    }

    // MARK: - Status Indicator

    @ViewBuilder
    private var statusIndicator: some View {
        if playerManager.isLoaded {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.dsSuccess)
                    .frame(width: 6, height: 6)
                Text("Ready")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        } else if let error = playerManager.error {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.dsError)
                    .frame(width: 6, height: 6)
                Text(error)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(Color.dsError)
                    .lineLimit(1)
            }
        } else {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Loading...")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
    }

    // MARK: - Progress Slider

    @ViewBuilder
    private var progressSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                // Progress fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primaryAccent, DesignSystem.Colors.secondaryAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * progressRatio), height: 4)

                // Draggable thumb
                Circle()
                    .fill(DesignSystem.Colors.primaryAccent)
                    .frame(width: 12, height: 12)
                    .shadow(color: DesignSystem.Colors.primaryAccent.opacity(0.5), radius: 4)
                    .offset(x: max(0, min(geometry.size.width - 12, geometry.size.width * progressRatio - 6)))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let ratio = max(0, min(1, value.location.x / geometry.size.width))
                        playerManager.seek(to: ratio * playerManager.duration)
                    }
            )
        }
        .frame(height: 20)
    }

    private var progressRatio: CGFloat {
        guard playerManager.duration > 0 else { return 0 }
        return CGFloat(playerManager.currentTime / playerManager.duration)
    }

    // MARK: - Playback Controls

    @ViewBuilder
    private var playbackControls: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            // Skip backward 10s
            Button(action: { playerManager.skipBackward(seconds: 10) }) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(!playerManager.isLoaded)

            // Play/Pause button
            Button(action: { playerManager.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primaryAccent, DesignSystem.Colors.secondaryAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: DesignSystem.Colors.primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .offset(x: playerManager.isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            .disabled(!playerManager.isLoaded)

            // Skip forward 10s
            Button(action: { playerManager.skipForward(seconds: 10) }) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(!playerManager.isLoaded)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Player Manager

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoaded = false
    @Published var error: String?

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    func loadAudio(from url: URL) {
        isLoaded = false
        error = nil
        currentTime = 0
        duration = 0

        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            error = "File not found"
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            isLoaded = true
        } catch {
            self.error = "Cannot load audio"
            print("Audio loading error: \(error)")
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        isPlaying = player.isPlaying
    }

    func stop() {
        audioPlayer?.stop()
        stopTimer()
        isPlaying = false
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = max(0, min(time, duration))
        currentTime = audioPlayer?.currentTime ?? 0
    }

    func skipForward(seconds: TimeInterval) {
        seek(to: currentTime + seconds)
    }

    func skipBackward(seconds: TimeInterval) {
        seek(to: currentTime - seconds)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }

            DispatchQueue.main.async {
                self.currentTime = player.currentTime

                // Check if playback finished
                if !player.isPlaying && self.isPlaying {
                    self.isPlaying = false
                    self.currentTime = 0
                    player.currentTime = 0
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
    }
}

#Preview {
    NoteDetailView(note: Note(
        title: "Sample Note",
        systemAudioURL: URL(fileURLWithPath: "/tmp/test-system.wav"),
        microphoneURL: URL(fileURLWithPath: "/tmp/test-mic.wav"),
        folderName: "General",
        createdAt: Date(),
        duration: 125,
        transcript: "This is a sample transcript that would contain the full text of the recording. It can be quite long and will be scrollable in the detail view."
    ))
}
