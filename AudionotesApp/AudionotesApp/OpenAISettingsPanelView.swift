import SwiftUI

struct OpenAISettingsPanelView: View {
    // Persisted settings
    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""

    // Working copies for editing
    @State private var baseURL: String = "https://api.openai.com/v1"
    @State private var transcriptionModel: String = "whisper-1"
    @State private var textModel: String = "gpt-5"
    @State private var apiKey: String = ""
    @State private var isTesting = false
    @State private var testMessage: String = ""
    @State private var testIsError = false

    var onDone: (() -> Void)?

    private let defaultBaseURL = "https://api.openai.com/v1"
    private let defaultTranscriptionModel = "whisper-1"
    private let defaultTextModel = "gpt-5"

    var body: some View {
        ZStack {
            // Atmospheric background
            Color.dsGradientAtmosphere
                .ignoresSafeArea()
                .grainTexture(opacity: 0.05)

            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    header
                        .staggeredFadeIn(index: 0, delay: DSAnimation.staggerMedium)

                    decorativeDivider
                        .staggeredFadeIn(index: 1, delay: DSAnimation.staggerMedium)

                    form

                    decorativeDivider
                        .staggeredFadeIn(index: 5, delay: DSAnimation.staggerMedium)

                    footer
                        .staggeredFadeIn(index: 6, delay: DSAnimation.staggerMedium)
                }
                .padding(DSSpacing.xl)
            }
        }
        .frame(minWidth: 540, minHeight: 600)
        .onAppear {
            baseURL = openAIBaseURL
            transcriptionModel = openAITranscriptionModel
            textModel = openAITextModel
            apiKey = openAIAPIKey
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.md) {
                // Icon with warm glow
                ZStack {
                    Circle()
                        .fill(Color.dsAccentPrimary.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.dsAccentPrimary)
                }
                .warmGlow(intensity: 0.4)

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("OpenAI Settings")
                        .font(DSFont.title2(.bold))
                        .foregroundColor(.dsTextPrimary)

                    Text("Premium Control Surface")
                        .font(DSFont.caption(.medium))
                        .foregroundColor(.dsAccentPrimary)
                        .tracking(2)
                        .textCase(.uppercase)
                }

                Spacer()
            }

            // Subtitle
            Text("Configure base URL, models, and your API key for transcription and summaries.")
                .font(DSFont.body())
                .foregroundColor(.dsTextTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DSSpacing.xxs)
        }
    }

    // MARK: - Decorative Divider

    @ViewBuilder
    private var decorativeDivider: some View {
        HStack(spacing: DSSpacing.sm) {
            Circle()
                .fill(Color.dsAccentPrimary)
                .frame(width: 4, height: 4)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.dsAccentPrimary.opacity(0.5),
                            Color.dsDivider,
                            Color.dsAccentPrimary.opacity(0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            Circle()
                .fill(Color.dsAccentPrimary)
                .frame(width: 4, height: 4)
        }
    }

    // MARK: - Form

    @ViewBuilder
    private var form: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // API Section
            FormSection(
                title: "API Configuration",
                icon: "network",
                index: 2
            ) {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Base URL")
                        .font(DSFont.subheadline(.semibold))
                        .foregroundColor(.dsTextSecondary)

                    GlassTextField(
                        placeholder: "https://api.openai.com/v1",
                        text: $baseURL,
                        isMonospaced: true
                    )
                }
            }

            // Models Section
            FormSection(
                title: "Model Selection",
                icon: "cpu",
                index: 3
            ) {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("Transcription Model")
                                .font(DSFont.subheadline(.semibold))
                                .foregroundColor(.dsTextSecondary)

                            Spacer()

                            Image(systemName: "waveform")
                                .font(.system(size: 12))
                                .foregroundColor(.dsAccentPrimary.opacity(0.6))
                        }

                        GlassTextField(
                            placeholder: "whisper-1",
                            text: $transcriptionModel
                        )
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("Text Model")
                                .font(DSFont.subheadline(.semibold))
                                .foregroundColor(.dsTextSecondary)

                            Spacer()

                            Image(systemName: "text.bubble")
                                .font(.system(size: 12))
                                .foregroundColor(.dsAccentPrimary.opacity(0.6))
                        }

                        Text("Summaries & Actions")
                            .font(DSFont.caption())
                            .foregroundColor(.dsTextTertiary)

                        GlassTextField(
                            placeholder: "gpt-5",
                            text: $textModel
                        )
                    }
                }
            }

            // Credentials Section
            FormSection(
                title: "Authentication",
                icon: "key.fill",
                index: 4
            ) {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("API Key")
                                .font(DSFont.subheadline(.semibold))
                                .foregroundColor(.dsTextSecondary)

                            Spacer()

                            Image(systemName: "lock.shield")
                                .font(.system(size: 12))
                                .foregroundColor(.dsAccentPrimary.opacity(0.6))
                        }

                        GlassSecureField(
                            placeholder: "sk-...",
                            text: $apiKey
                        )
                    }

                    // Test Connection Row
                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            testConnection()
                        } label: {
                            HStack(spacing: DSSpacing.xs) {
                                if isTesting {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 12))
                                }

                                Text(isTesting ? "Testing Connection…" : "Test Connection")
                                    .font(DSFont.callout(.medium))
                            }
                            .foregroundColor(.dsTextPrimary)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                    .fill(Color.dsAccentPrimary.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                            .stroke(Color.dsAccentPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTesting)
                        .opacity((apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTesting) ? 0.5 : 1.0)
                        .hoverEffect(scale: 1.03, brightness: 0.05)
                        .buttonStyle(.plain)

                        if !testMessage.isEmpty {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: testIsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(testIsError ? .dsError : .dsSuccess)

                                Text(testMessage)
                                    .font(DSFont.caption(.medium))
                                    .foregroundColor(testIsError ? .dsError : .dsSuccess)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                                    .fill((testIsError ? Color.dsError : Color.dsSuccess).opacity(0.1))
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(DSAnimation.springSmooth, value: testMessage)

                    // Get API Key Link
                    Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))

                            Text("Get an API key from OpenAI")
                                .font(DSFont.footnote(.medium))
                        }
                        .foregroundColor(.dsAccentPrimary)
                    }
                    .hoverEffect(scale: 1.02, brightness: 0.1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        HStack(spacing: DSSpacing.md) {
            // Reset Button
            Button {
                withAnimation(DSAnimation.springSmooth) {
                    baseURL = defaultBaseURL
                    transcriptionModel = defaultTranscriptionModel
                    textModel = defaultTextModel
                }
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))

                    Text("Reset Defaults")
                        .font(DSFont.callout(.medium))
                }
                .foregroundColor(.dsTextSecondary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                        .fill(Color.dsBackgroundTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                .stroke(Color.dsDivider, lineWidth: 1)
                        )
                )
            }
            .hoverEffect(scale: 1.03, brightness: 0.05)
            .buttonStyle(.plain)

            Spacer()

            // Cancel Button
            Button {
                onDone?()
            } label: {
                Text("Cancel")
                    .font(DSFont.callout(.medium))
                    .foregroundColor(.dsTextSecondary)
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.vertical, DSSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                            .fill(Color.dsBackgroundTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                    .stroke(Color.dsDivider, lineWidth: 1)
                            )
                    )
            }
            .hoverEffect(scale: 1.03, brightness: 0.05)
            .buttonStyle(.plain)

            // Save Button
            Button {
                saveAndClose()
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))

                    Text("Save Settings")
                        .font(DSFont.callout(.semibold))
                }
                .foregroundColor(.dsBackgroundPrimary)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                        .fill(
                            LinearGradient(
                                colors: [Color.dsAccentPrimary, Color.dsAccentDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.dsAccentPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .hoverEffect(scale: 1.05, brightness: 0.1)
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func saveAndClose() {
        openAIBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITranscriptionModel = transcriptionModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITextModel = textModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAIAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        onDone?()
    }

    private func testConnection() {
        testMessage = ""
        testIsError = false
        isTesting = true
        let cfg = OpenAIConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            transcriptionModel: transcriptionModel,
            textModel: textModel
        )
        Task { @MainActor in
            defer { isTesting = false }
            do {
                let text = try await OpenAIService().testConnection(config: cfg)
                let snippet = text.prefix(32)
                testMessage = "Connected (\(snippet)…)"
                testIsError = false
            } catch {
                testMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                testIsError = true
            }
        }
    }
}

// MARK: - Form Section Component

private struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    let index: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Section Header
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dsAccentPrimary)
                    .frame(width: 20)

                Text(title)
                    .font(DSFont.headline(.semibold))
                    .foregroundColor(.dsTextPrimary)

                Spacer()

                // Decorative accent
                Circle()
                    .fill(Color.dsAccentPrimary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }

            // Content
            content
                .padding(DSSpacing.md)
                .background(
                    ZStack {
                        // Glass background
                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                            .fill(Color.dsBackgroundSecondary.opacity(0.5))

                        // Grain texture
                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.02),
                                        Color.clear,
                                        Color.white.opacity(0.01)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.dsAccentPrimary.opacity(0.2),
                                    Color.dsDivider,
                                    Color.dsAccentPrimary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .staggeredFadeIn(index: index, delay: DSAnimation.staggerMedium)
    }
}

// MARK: - Glass Text Field

private struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isMonospaced: Bool = false
    @State private var isFocused = false

    var body: some View {
        TextField(placeholder, text: $text, onEditingChanged: { editing in
            withAnimation(DSAnimation.springSnappy) {
                isFocused = editing
            }
        })
        .font(isMonospaced ? DSFont.mono(DSFont.sizeBody) : DSFont.body())
        .foregroundColor(.dsTextPrimary)
        .textFieldStyle(.plain)
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                .fill(Color.dsBackgroundPrimary.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                .stroke(
                    isFocused ? Color.dsAccentPrimary.opacity(0.5) : Color.dsDivider,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(
            color: isFocused ? Color.dsAccentPrimary.opacity(0.2) : Color.clear,
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Glass Secure Field

private struct GlassSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isFocused = false

    var body: some View {
        SecureField(placeholder, text: $text, onCommit: {
            withAnimation(DSAnimation.springSnappy) {
                isFocused = false
            }
        })
        .font(DSFont.body())
        .foregroundColor(.dsTextPrimary)
        .textFieldStyle(.plain)
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                .fill(Color.dsBackgroundPrimary.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                .stroke(
                    isFocused ? Color.dsAccentPrimary.opacity(0.5) : Color.dsDivider,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(
            color: isFocused ? Color.dsAccentPrimary.opacity(0.2) : Color.clear,
            radius: 8,
            x: 0,
            y: 2
        )
        .onTapGesture {
            withAnimation(DSAnimation.springSnappy) {
                isFocused = true
            }
        }
    }
}
