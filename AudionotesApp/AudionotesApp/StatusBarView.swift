import SwiftUI
import AppKit

struct StatusBarView: View {
    @EnvironmentObject private var callDetectionService: CallDetectionService
    @EnvironmentObject private var audioCapService: AudioCapService
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusHeader
                .staggeredFadeIn(index: 0, delay: 0)

            decorativeDivider
                .staggeredFadeIn(index: 1, delay: 0.1)

            activityDetails
                .staggeredFadeIn(index: 2, delay: 0.2)

            decorativeDivider
                .staggeredFadeIn(index: 3, delay: 0.3)

            actionButtons
                .staggeredFadeIn(index: 4, delay: 0.4)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(minWidth: 280)
        .warmGradient()
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .glassmorphic()
        .elegantBorder()
        .dramaticShadow()
        .grainTexture()
    }

    // MARK: - Status Header
    private var statusHeader: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Animated status icon with glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .symbolEffect(.pulse, options: .repeating, value: isActiveState)
            }
            .atmosphericGlow(color: iconColor, intensity: isActiveState ? 1.0 : 0.3)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(primaryStatus)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(secondaryStatus)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    // MARK: - Decorative Divider
    private var decorativeDivider: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0),
                        .white.opacity(0.15),
                        .white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, DesignSystem.Spacing.sm)
    }

    // MARK: - Activity Details
    @ViewBuilder
    private var activityDetails: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Microphone indicator
            StatusIndicator(
                label: microphoneStatus,
                icon: callDetectionService.isMicrophoneActive ? "mic.fill" : "mic.slash",
                isActive: callDetectionService.isMicrophoneActive,
                activeColor: DesignSystem.Colors.softBlue
            )

            // System audio indicator
            StatusIndicator(
                label: systemAudioStatus,
                icon: callDetectionService.isSystemAudioActive ? "speaker.wave.2.fill" : "speaker.slash.fill",
                isActive: callDetectionService.isSystemAudioActive,
                activeColor: .green
            )

            // Active process indicator
            if let process = callDetectionService.activeProcess {
                StatusIndicator(
                    label: "Active: \(process.name)",
                    icon: "app.badge",
                    isActive: true,
                    activeColor: DesignSystem.Colors.warmAmber
                )
            }
        }
        .padding(.bottom, DesignSystem.Spacing.xs)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            AtmosphericButton(
                title: audioCapService.isRecording ? "Show Recorder" : "Open Recorder",
                icon: "waveform.circle.fill",
                style: .secondary
            ) {
                focusRecorder()
            }

            AtmosphericButton(
                title: "View Notes",
                icon: "note.text",
                style: .secondary
            ) {
                appState.activeTab = .notes
                bringAppToFront()
            }

            if callDetectionService.isCallActive && !audioCapService.isRecording {
                AtmosphericButton(
                    title: "Start a Note for this Call",
                    icon: "mic.badge.plus",
                    style: .primary
                ) {
                    focusRecorder()
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var isActiveState: Bool {
        audioCapService.isRecording || callDetectionService.isCallActive
    }

    private var iconName: String {
        if audioCapService.isRecording { return "record.circle.fill" }
        if callDetectionService.isCallActive { return "phone.fill" }
        return "waveform"
    }

    private var iconColor: Color {
        if audioCapService.isRecording { return .red }
        if callDetectionService.isCallActive { return .green }
        return DesignSystem.Colors.warmAmber
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
        callDetectionService.isMicrophoneActive ? "Microphone active" : "Microphone idle"
    }

    private var systemAudioStatus: String {
        callDetectionService.isSystemAudioActive ? "System audio playing" : "System audio idle"
    }

    // MARK: - Helper Methods
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

// MARK: - Status Indicator Component
private struct StatusIndicator: View {
    let label: String
    let icon: String
    let isActive: Bool
    let activeColor: Color

    @State private var pulseAnimation = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                // Glow effect for active state
                if isActive {
                    Circle()
                        .fill(activeColor.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isActive ? activeColor : .white.opacity(0.4))
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 20, height: 20)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(isActive ? .white.opacity(0.9) : .white.opacity(0.5))
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                .fill(isActive ? activeColor.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                .strokeBorder(
                    isActive ? activeColor.opacity(0.3) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

// MARK: - Atmospheric Button Component
private struct AtmosphericButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
    }

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))

                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))

                Spacer()
            }
            .foregroundStyle(style == .primary ? .white : .white.opacity(0.9))
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                ZStack {
                    if style == .primary {
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.warmAmber.opacity(isHovered ? 0.8 : 0.6),
                                DesignSystem.Colors.warmOrange.opacity(isHovered ? 0.8 : 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white.opacity(isHovered ? 0.15 : 0.08)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                    .strokeBorder(
                        style == .primary
                            ? DesignSystem.Colors.warmAmber.opacity(0.5)
                            : Color.white.opacity(isHovered ? 0.3 : 0.2),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.97 : (isHovered ? 1.02 : 1.0))
            .shadow(
                color: style == .primary
                    ? DesignSystem.Colors.warmAmber.opacity(isHovered ? 0.4 : 0.2)
                    : Color.black.opacity(isHovered ? 0.2 : 0.1),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}
