import SwiftUI

struct OpenAISettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""

    @State private var baseURL: String = "https://api.openai.com/v1"
    @State private var transcriptionModel: String = "whisper-1"
    @State private var textModel: String = "gpt-5"
    @State private var apiKey: String = ""

    // Animation states
    @State private var isVisible = false

    // Field focus states for enhanced interactions
    @State private var focusedField: FocusField? = nil

    enum FocusField {
        case baseURL, transcriptionModel, textModel, apiKey
    }

    var body: some View {
        ZStack {
            // Atmospheric background
            Color.dsBackgroundPrimary
                .ignoresSafeArea()

            // Subtle gradient overlay
            Color.dsGradientAtmosphere
                .ignoresSafeArea()
                .opacity(0.5)

            // Main content
            VStack(spacing: 0) {
                // Header
                headerSection
                    .staggeredFadeIn(index: 0, delay: DSAnimation.staggerShort)

                Divider()
                    .background(Color.dsDivider)
                    .padding(.horizontal, DSSpacing.lg)

                // Form content
                ScrollView {
                    VStack(spacing: DSSpacing.lg) {
                        // API Configuration Section
                        apiConfigurationSection
                            .staggeredFadeIn(index: 1, delay: DSAnimation.staggerMedium)

                        // Models Section
                        modelsSection
                            .staggeredFadeIn(index: 2, delay: DSAnimation.staggerMedium)

                        // Credentials Section
                        credentialsSection
                            .staggeredFadeIn(index: 3, delay: DSAnimation.staggerMedium)

                        // Quick Link
                        quickLinkSection
                            .staggeredFadeIn(index: 4, delay: DSAnimation.staggerMedium)
                    }
                    .padding(DSSpacing.xl)
                }

                Divider()
                    .background(Color.dsDivider)
                    .padding(.horizontal, DSSpacing.lg)

                // Footer with actions
                footerSection
                    .staggeredFadeIn(index: 5, delay: DSAnimation.staggerMedium)
            }
        }
        .frame(width: 580, height: 520)
        .grainTexture(opacity: 0.02)
        .onAppear {
            baseURL = openAIBaseURL
            transcriptionModel = openAITranscriptionModel
            textModel = openAITextModel
            apiKey = openAIAPIKey

            withAnimation(DSAnimation.springSmooth) {
                isVisible = true
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: DSSpacing.md) {
            // Icon with warm glow
            ZStack {
                Circle()
                    .fill(Color.dsAccentPrimary.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: "gear.circle.fill")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.dsAccentPrimary, .dsAccentDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .warmGlow(intensity: 0.4)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text("OpenAI Settings")
                    .font(DSFont.title3(.bold))
                    .foregroundColor(.dsTextPrimary)
                    .tracking(0.5)

                Text("Configure your API connection and model preferences")
                    .font(DSFont.footnote(.regular))
                    .foregroundColor(.dsTextTertiary)
            }

            Spacer()
        }
        .padding(DSSpacing.lg)
    }

    // MARK: - API Configuration Section

    private var apiConfigurationSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionLabel(
                icon: "network",
                title: "API Configuration",
                subtitle: "Base URL endpoint"
            )

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                fieldLabel("Base URL")

                TextField("https://api.openai.com/v1", text: $baseURL)
                    .textFieldStyle(AnalogTextFieldStyle(isFocused: focusedField == .baseURL))
                    .font(DSFont.mono(DSFont.sizeBody, .regular))
                    .foregroundColor(.dsTextSecondary)
                    .onTapGesture {
                        focusedField = .baseURL
                    }
            }
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .fill(Color.dsBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .dsShadow(DSShadow.medium)
    }

    // MARK: - Models Section

    private var modelsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionLabel(
                icon: "cpu.fill",
                title: "Model Selection",
                subtitle: "Choose models for different tasks"
            )

            VStack(spacing: DSSpacing.md) {
                // Transcription Model
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack {
                        fieldLabel("Transcription Model")
                        Spacer()
                        modelBadge("Audio", color: .dsAccentPrimary)
                    }

                    TextField("whisper-1", text: $transcriptionModel)
                        .textFieldStyle(AnalogTextFieldStyle(isFocused: focusedField == .transcriptionModel))
                        .font(DSFont.body(.regular))
                        .foregroundColor(.dsTextSecondary)
                        .onTapGesture {
                            focusedField = .transcriptionModel
                        }
                }

                // Divider
                Rectangle()
                    .fill(Color.dsDivider)
                    .frame(height: 1)

                // Text Model
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack {
                        fieldLabel("Text Model")
                        Spacer()
                        modelBadge("Intelligence", color: .dsSuccess)
                    }

                    TextField("gpt-5", text: $textModel)
                        .textFieldStyle(AnalogTextFieldStyle(isFocused: focusedField == .textModel))
                        .font(DSFont.body(.regular))
                        .foregroundColor(.dsTextSecondary)
                        .onTapGesture {
                            focusedField = .textModel
                        }

                    Text("Used for summaries and action items")
                        .font(DSFont.caption(.regular))
                        .foregroundColor(.dsTextTertiary)
                        .padding(.top, DSSpacing.xxs)
                }
            }
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .fill(Color.dsBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .dsShadow(DSShadow.medium)
    }

    // MARK: - Credentials Section

    private var credentialsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionLabel(
                icon: "key.fill",
                title: "API Credentials",
                subtitle: "Secure authentication key"
            )

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                fieldLabel("API Key")

                SecureField("Enter your OpenAI API key", text: $apiKey)
                    .textFieldStyle(AnalogTextFieldStyle(isFocused: focusedField == .apiKey))
                    .font(DSFont.mono(DSFont.sizeBody, .regular))
                    .foregroundColor(.dsTextSecondary)
                    .onTapGesture {
                        focusedField = .apiKey
                    }

                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.dsTextTertiary)

                    Text("Your API key is stored securely in app preferences")
                        .font(DSFont.caption(.regular))
                        .foregroundColor(.dsTextTertiary)
                }
                .padding(.top, DSSpacing.xs)
            }
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .fill(Color.dsBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.dsAccentPrimary.opacity(0.2),
                            Color.dsAccentPrimary.opacity(0.05),
                            Color.dsAccentPrimary.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .dsShadow(DSShadow.medium)
        .warmGlow(intensity: 0.15)
    }

    // MARK: - Quick Link Section

    private var quickLinkSection: some View {
        Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.dsAccentPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Manage API Keys")
                        .font(DSFont.callout(.semibold))
                        .foregroundColor(.dsTextPrimary)

                    Text("platform.openai.com")
                        .font(DSFont.caption(.regular))
                        .foregroundColor(.dsTextTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dsTextTertiary)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                    .fill(Color.dsBackgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect(scale: 1.02, brightness: 0.05)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        HStack(spacing: DSSpacing.md) {
            // Cancel button
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(DSFont.body(.medium))
                    .foregroundColor(.dsTextSecondary)
                    .frame(minWidth: 100)
                    .padding(.vertical, DSSpacing.sm)
                    .padding(.horizontal, DSSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                            .fill(Color.dsBackgroundTertiary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .hoverEffect(scale: 1.03, brightness: 0.08)

            Spacer()

            // Save button
            Button(action: saveSettings) {
                HStack(spacing: DSSpacing.xs) {
                    Text("Save Settings")
                        .font(DSFont.body(.semibold))
                        .foregroundColor(.dsBackgroundPrimary)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.dsBackgroundPrimary)
                }
                .frame(minWidth: 140)
                .padding(.vertical, DSSpacing.sm)
                .padding(.horizontal, DSSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                        .fill(
                            LinearGradient(
                                colors: [.dsAccentPrimary, .dsAccentDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .dsShadow(DSShadow.warmGlow)
            }
            .buttonStyle(PlainButtonStyle())
            .hoverEffect(scale: 1.03, brightness: 0.1)
        }
        .padding(DSSpacing.lg)
    }

    // MARK: - Helper Views

    private func sectionLabel(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.dsAccentPrimary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.subheadline(.semibold))
                    .foregroundColor(.dsTextPrimary)

                Text(subtitle)
                    .font(DSFont.caption(.regular))
                    .foregroundColor(.dsTextTertiary)
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(DSFont.footnote(.medium))
            .foregroundColor(.dsTextSecondary)
            .tracking(0.3)
    }

    private func modelBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(DSFont.caption(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                    .fill(color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }

    // MARK: - Actions

    private func saveSettings() {
        openAIBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITranscriptionModel = transcriptionModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITextModel = textModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAIAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        // Subtle haptic feedback on save
        withAnimation(DSAnimation.springSnappy) {
            dismiss()
        }
    }
}

// MARK: - Custom Text Field Style

struct AnalogTextFieldStyle: TextFieldStyle {
    let isFocused: Bool
    @State private var isHovered = false

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                    .fill(Color.dsBackgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                    .stroke(
                        isFocused
                            ? Color.dsAccentPrimary.opacity(0.5)
                            : (isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.08)),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(DSAnimation.springSnappy, value: isHovered)
            .animation(DSAnimation.springSnappy, value: isFocused)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Preview

#Preview {
    OpenAISettingsView()
}
