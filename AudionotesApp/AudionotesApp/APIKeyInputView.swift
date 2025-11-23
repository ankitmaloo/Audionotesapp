import SwiftUI

struct APIKeyInputView: View {
    @AppStorage("geminiAPIKey") private var geminiAPIKey: String = ""
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey = ""
    @State private var hasAppeared = false
    @State private var saveButtonHovered = false
    @State private var skipButtonHovered = false
    @State private var linkButtonHovered = false

    var body: some View {
        ZStack {
            // Atmospheric gradient background
            Color.dsGradientAtmosphere
                .ignoresSafeArea()

            // Grain texture overlay
            Color.clear
                .grainTexture(opacity: 0.05)
                .ignoresSafeArea()

            // Radial accent glow
            RadialGradient(
                colors: [
                    Color.dsAccentPrimary.opacity(0.12),
                    Color.dsBurgundy.opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .opacity(hasAppeared ? 1 : 0)

            // Main content
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.12)

                    // Header section
                    VStack(spacing: DSSpacing.lg) {
                        // Icon with warm glow
                        Image(systemName: "key.fill")
                            .font(.system(size: 64, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.dsAccentPrimary, Color.dsAccentDeep],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .warmGlow(intensity: 0.4)
                            .staggeredFadeIn(index: 0, delay: DSAnimation.staggerMedium)

                        // Title with elegant serif typography
                        Text("Gemini API Key")
                            .font(DSFont.title1())
                            .foregroundColor(.dsTextPrimary)
                            .tracking(0.5)
                            .staggeredFadeIn(index: 1, delay: DSAnimation.staggerMedium)

                        // Decorative divider
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.dsAccentPrimary,
                                        Color.dsAccentPrimary.opacity(0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 100, height: 2)
                            .staggeredFadeIn(index: 2, delay: DSAnimation.staggerMedium)

                        // Subtitle
                        Text("Enter your Gemini API key to enable\ntranscription features")
                            .font(DSFont.body())
                            .foregroundColor(.dsTextTertiary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .staggeredFadeIn(index: 3, delay: DSAnimation.staggerMedium)
                    }
                    .padding(.horizontal, DSSpacing.xl)

                    Spacer()
                        .frame(height: DSSpacing.xl)

                    // Input section
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {
                        // API Key input
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("API KEY")
                                .font(DSFont.caption(.semibold))
                                .foregroundColor(.dsTextTertiary)
                                .tracking(1.5)

                            SecureField("", text: $apiKey, prompt: Text("Enter your Gemini API key").foregroundColor(.dsTextTertiary.opacity(0.5)))
                                .font(DSFont.body())
                                .foregroundColor(.dsTextPrimary)
                                .textFieldStyle(.plain)
                                .padding(DSSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                        .fill(Color.dsBackgroundSecondary.opacity(0.6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.dsAccentPrimary.opacity(0.3),
                                                            Color.dsAccentPrimary.opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .glassmorphism()
                                .dsShadow(DSShadow.subtle)

                            Text("You can get your API key from the Google AI Studio")
                                .font(DSFont.caption())
                                .foregroundColor(.dsTextTertiary.opacity(0.7))
                        }
                        .staggeredFadeIn(index: 4, delay: DSAnimation.staggerMedium)

                        // Link button
                        Link(destination: URL(string: "https://makersuite.google.com/app/apikey")!) {
                            HStack(spacing: DSSpacing.sm) {
                                Image(systemName: "link")
                                    .font(DSFont.caption(.semibold))

                                Text("Get API Key from Google AI Studio")
                                    .font(DSFont.body(.medium))
                            }
                            .foregroundColor(.dsTextSecondary)
                            .padding(.horizontal, DSSpacing.lg)
                            .padding(.vertical, DSSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                    .fill(Color.dsBackgroundTertiary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                            .strokeBorder(Color.dsDivider, lineWidth: 1)
                                    )
                            )
                            .dsShadow(DSShadow.subtle)
                            .scaleEffect(linkButtonHovered ? 1.02 : 1.0)
                            .brightness(linkButtonHovered ? 0.05 : 0)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(DSAnimation.quick) {
                                linkButtonHovered = hovering
                            }
                        }
                        .staggeredFadeIn(index: 5, delay: DSAnimation.staggerMedium)
                    }
                    .frame(maxWidth: 400)
                    .padding(.horizontal, DSSpacing.xl)

                    Spacer()

                    // Footer note
                    Text("You can skip this step and add the API key later in Settings")
                        .font(DSFont.caption())
                        .foregroundColor(.dsTextTertiary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .staggeredFadeIn(index: 6, delay: DSAnimation.staggerMedium)

                    Spacer()
                        .frame(height: DSSpacing.lg)

                    // Action buttons
                    HStack(spacing: DSSpacing.md) {
                        // Skip button
                        Button(action: {
                            withAnimation(DSAnimation.springSnappy) {
                                dismiss()
                            }
                        }) {
                            Text("Skip")
                                .font(DSFont.body(.semibold))
                                .foregroundColor(.dsTextSecondary)
                                .padding(.horizontal, DSSpacing.xl)
                                .padding(.vertical, DSSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                        .fill(Color.dsBackgroundSecondary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                                .strokeBorder(Color.dsDivider, lineWidth: 1)
                                        )
                                )
                                .scaleEffect(skipButtonHovered ? 1.02 : 1.0)
                                .brightness(skipButtonHovered ? 0.05 : 0)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(DSAnimation.quick) {
                                skipButtonHovered = hovering
                            }
                        }
                        .staggeredFadeIn(index: 7, delay: DSAnimation.staggerMedium)

                        // Save button
                        Button(action: {
                            withAnimation(DSAnimation.springSnappy) {
                                geminiAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                dismiss()
                            }
                        }) {
                            HStack(spacing: DSSpacing.xs) {
                                Text("Save")
                                    .font(DSFont.body(.semibold))

                                Image(systemName: "arrow.right")
                                    .font(DSFont.caption(.semibold))
                            }
                            .foregroundColor(Color.dsBackgroundPrimary)
                            .padding(.horizontal, DSSpacing.xl)
                            .padding(.vertical, DSSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.dsAccentPrimary, Color.dsAccentDeep],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                                            .strokeBorder(
                                                Color.dsTextPrimary.opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .warmGlow(intensity: saveButtonHovered ? 0.5 : 0.3)
                            .dsShadow(DSShadow.medium)
                            .scaleEffect(saveButtonHovered ? 1.05 : 1.0)
                            .brightness(saveButtonHovered ? 0.1 : 0)
                        }
                        .buttonStyle(.plain)
                        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                        .onHover { hovering in
                            withAnimation(DSAnimation.springSnappy) {
                                saveButtonHovered = hovering
                            }
                        }
                        .staggeredFadeIn(index: 8, delay: DSAnimation.staggerMedium)
                    }
                    .padding(.horizontal, DSSpacing.xl)

                    Spacer()
                        .frame(height: DSSpacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 560, height: 520)
        .onAppear {
            apiKey = geminiAPIKey
            withAnimation(DSAnimation.easeOut.delay(0.1)) {
                hasAppeared = true
            }
        }
    }
}