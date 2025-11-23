//
//  DesignSystem.swift
//  AudionotesApp
//
//  Design Vision: "Analog Warmth" - Vintage Recording Studio Aesthetic
//  A comprehensive design system inspired by classic recording studios
//

import SwiftUI

// MARK: - Color Extensions

extension Color {

    // MARK: - Background Colors

    /// Deep charcoal background - primary surface
    static let dsBackgroundPrimary = Color(hex: "1a1614")

    /// Secondary dark - elevated surfaces
    static let dsBackgroundSecondary = Color(hex: "2d2521")

    /// Tertiary dark - subtle elevation
    static let dsBackgroundTertiary = Color(hex: "3d3531")

    // MARK: - Accent Colors

    /// Warm amber - primary accent
    static let dsAccentPrimary = Color(hex: "f59e0b")

    /// Deep amber - pressed/active states
    static let dsAccentDeep = Color(hex: "d97706")

    /// Burgundy - dramatic accents
    static let dsBurgundy = Color(hex: "9f1239")

    // MARK: - Text Colors

    /// Soft cream - primary text
    static let dsTextPrimary = Color(hex: "fef3c7")

    /// Warm white - secondary text
    static let dsTextSecondary = Color(hex: "fafaf9")

    /// Muted gray - tertiary text
    static let dsTextTertiary = Color(hex: "a8a29e")

    // MARK: - Semantic Colors

    /// Warm green - success states
    static let dsSuccess = Color(hex: "84cc16")

    /// Coral - warning states
    static let dsWarning = Color(hex: "fb923c")

    /// Deep red - error states
    static let dsError = Color(hex: "dc2626")

    // MARK: - Opacity Variants

    /// Accent with subtle opacity
    static let dsAccentSubtle = Color.dsAccentPrimary.opacity(0.1)

    /// Accent with medium opacity
    static let dsAccentMedium = Color.dsAccentPrimary.opacity(0.3)

    /// Glass overlay opacity
    static let dsGlassOverlay = Color.white.opacity(0.05)

    /// Divider color
    static let dsDivider = Color.white.opacity(0.1)

    /// Shadow color
    static let dsShadow = Color.black.opacity(0.3)

    // MARK: - Gradient Presets

    /// Warm gradient - primary to deep amber
    static let dsGradientWarm = LinearGradient(
        colors: [dsAccentPrimary, dsAccentDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Burgundy gradient
    static let dsGradientBurgundy = LinearGradient(
        colors: [dsBurgundy, dsAccentDeep],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Background atmospheric gradient
    static let dsGradientAtmosphere = LinearGradient(
        colors: [
            dsBackgroundPrimary,
            dsBackgroundSecondary.opacity(0.8),
            dsBackgroundPrimary
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Helper Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography System

enum DSFont {

    // MARK: - Font Sizes

    /// Caption - 11pt
    static let sizeCaption: CGFloat = 11

    /// Footnote - 13pt
    static let sizeFootnote: CGFloat = 13

    /// Body - 15pt
    static let sizeBody: CGFloat = 15

    /// Callout - 17pt
    static let sizeCallout: CGFloat = 17

    /// Subheadline - 19pt
    static let sizeSubheadline: CGFloat = 19

    /// Headline - 22pt
    static let sizeHeadline: CGFloat = 22

    /// Title 3 - 26pt
    static let sizeTitle3: CGFloat = 26

    /// Title 2 - 32pt
    static let sizeTitle2: CGFloat = 32

    /// Title 1 - 40pt
    static let sizeTitle1: CGFloat = 40

    /// Large Title - 48pt
    static let sizeLargeTitle: CGFloat = 48

    /// Display - 64pt
    static let sizeDisplay: CGFloat = 64

    // MARK: - Font Functions

    /// Caption text - system rounded
    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(size: sizeCaption, weight: weight, design: .rounded)
    }

    /// Footnote text - system default
    static func footnote(_ weight: Font.Weight = .regular) -> Font {
        .system(size: sizeFootnote, weight: weight, design: .default)
    }

    /// Body text - system default
    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(size: sizeBody, weight: weight, design: .default)
    }

    /// Callout text - system default
    static func callout(_ weight: Font.Weight = .regular) -> Font {
        .system(size: sizeCallout, weight: weight, design: .default)
    }

    /// Subheadline text - system rounded
    static func subheadline(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: sizeSubheadline, weight: weight, design: .rounded)
    }

    /// Headline text - system rounded
    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: sizeHeadline, weight: weight, design: .rounded)
    }

    /// Title 3 - system rounded
    static func title3(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: sizeTitle3, weight: weight, design: .rounded)
    }

    /// Title 2 - system serif
    static func title2(_ weight: Font.Weight = .bold) -> Font {
        .system(size: sizeTitle2, weight: weight, design: .serif)
    }

    /// Title 1 - system serif
    static func title1(_ weight: Font.Weight = .bold) -> Font {
        .system(size: sizeTitle1, weight: weight, design: .serif)
    }

    /// Large title - system serif
    static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
        .system(size: sizeLargeTitle, weight: weight, design: .serif)
    }

    /// Display - system serif for dramatic headings
    static func display(_ weight: Font.Weight = .heavy) -> Font {
        .system(size: sizeDisplay, weight: weight, design: .serif)
    }

    /// Monospaced - for time codes and technical info
    static func mono(_ size: CGFloat = sizeBody, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Spacing System

enum DSSpacing {

    /// 4pt - minimum spacing
    static let xxs: CGFloat = 4

    /// 8pt - compact spacing
    static let xs: CGFloat = 8

    /// 12pt - small spacing
    static let sm: CGFloat = 12

    /// 16pt - base spacing
    static let md: CGFloat = 16

    /// 24pt - comfortable spacing
    static let lg: CGFloat = 24

    /// 32pt - generous spacing
    static let xl: CGFloat = 32

    /// 48pt - dramatic spacing
    static let xxl: CGFloat = 48

    /// 64pt - hero spacing
    static let xxxl: CGFloat = 64

    /// Corner radius - small (4pt)
    static let radiusSmall: CGFloat = 4

    /// Corner radius - medium (8pt)
    static let radiusMedium: CGFloat = 8

    /// Corner radius - large (12pt)
    static let radiusLarge: CGFloat = 12

    /// Corner radius - extra large (16pt)
    static let radiusXL: CGFloat = 16

    /// Corner radius - pill (999pt)
    static let radiusPill: CGFloat = 999
}

// MARK: - Animation Constants

enum DSAnimation {

    // MARK: - Durations

    /// Quick interaction - 0.2s
    static let durationQuick: Double = 0.2

    /// Standard transition - 0.4s
    static let durationStandard: Double = 0.4

    /// Dramatic reveal - 0.8s
    static let durationDramatic: Double = 0.8

    /// Slow, atmospheric - 1.2s
    static let durationAtmospheric: Double = 1.2

    // MARK: - Timing Curves

    /// Ease out - natural deceleration
    static let easeOut = Animation.easeOut(duration: durationStandard)

    /// Ease in out - smooth both ways
    static let easeInOut = Animation.easeInOut(duration: durationStandard)

    /// Spring - bouncy, playful
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    /// Snappy spring - quick and responsive
    static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8)

    /// Smooth spring - gentle, refined
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.9)

    /// Dramatic spring - for hero moments
    static let springDramatic = Animation.spring(response: 0.8, dampingFraction: 0.7)

    // MARK: - Stagger Delays

    /// Stagger delay for sequential animations - 0.05s
    static let staggerShort: Double = 0.05

    /// Medium stagger - 0.1s
    static let staggerMedium: Double = 0.1

    /// Long stagger - 0.15s
    static let staggerLong: Double = 0.15

    // MARK: - Helper Functions

    /// Quick animation with ease out
    static var quick: Animation {
        .easeOut(duration: durationQuick)
    }

    /// Standard animation with spring
    static var standard: Animation {
        spring
    }

    /// Dramatic animation
    static var dramatic: Animation {
        springDramatic
    }
}

// MARK: - Shadow and Effect Presets

enum DSShadow {

    /// Subtle elevation - barely visible
    static let subtle = (color: Color.dsShadow, radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))

    /// Medium elevation
    static let medium = (color: Color.dsShadow, radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))

    /// Prominent elevation
    static let prominent = (color: Color.dsShadow, radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))

    /// Dramatic depth
    static let dramatic = (color: Color.dsShadow, radius: CGFloat(24), x: CGFloat(0), y: CGFloat(12))

    /// Warm glow - amber accent
    static let warmGlow = (color: Color.dsAccentPrimary.opacity(0.3), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(0))

    /// Burgundy glow
    static let burgundyGlow = (color: Color.dsBurgundy.opacity(0.5), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(0))

    /// Inner shadow effect (using overlay)
    static let innerShadow = (color: Color.black.opacity(0.2), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
}

// MARK: - Custom View Modifiers

// MARK: Glassmorphism Effect

struct GlassmorphismModifier: ViewModifier {
    var tintColor: Color = .dsGlassOverlay
    var blur: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Subtle background tint
                    tintColor

                    // Blur effect layer
                    Color.dsBackgroundSecondary.opacity(0.3)
                }
            )
            .background(.ultraThinMaterial)
            .cornerRadius(DSSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusMedium)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: Grain Texture Overlay

struct GrainTextureModifier: ViewModifier {
    var opacity: Double = 0.03

    func body(content: Content) -> some View {
        content
            .overlay(
                // Simulated grain using noise pattern
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(opacity),
                                Color.clear,
                                Color.white.opacity(opacity * 0.5),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            )
    }
}

// MARK: Gradient Background

struct GradientBackgroundModifier: ViewModifier {
    var gradient: LinearGradient = Color.dsGradientAtmosphere

    func body(content: Content) -> some View {
        content
            .background(gradient)
    }
}

// MARK: Staggered Fade In Animation

struct StaggeredFadeInModifier: ViewModifier {
    let index: Int
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                withAnimation(
                    DSAnimation.springSmooth
                        .delay(Double(index) * delay)
                ) {
                    isVisible = true
                }
            }
    }
}

// MARK: Hover Effect

struct HoverEffectModifier: ViewModifier {
    @State private var isHovered = false
    var scaleAmount: CGFloat = 1.05
    var brightness: Double = 0.1

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scaleAmount : 1.0)
            .brightness(isHovered ? brightness : 0)
            .animation(DSAnimation.springSnappy, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: Warm Glow Effect

struct WarmGlowModifier: ViewModifier {
    var intensity: Double = 0.3

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.dsAccentPrimary.opacity(intensity),
                radius: DSShadow.warmGlow.radius,
                x: DSShadow.warmGlow.x,
                y: DSShadow.warmGlow.y
            )
    }
}

// MARK: Card Style

struct CardStyleModifier: ViewModifier {
    var padding: CGFloat = DSSpacing.md
    var shadowLevel: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = DSShadow.medium

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.dsBackgroundSecondary)
            .cornerRadius(DSSpacing.radiusMedium)
            .shadow(
                color: shadowLevel.color,
                radius: shadowLevel.radius,
                x: shadowLevel.x,
                y: shadowLevel.y
            )
    }
}

// MARK: Recording Pulse Animation

struct RecordingPulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - View Extension for Easy Access

extension View {

    /// Apply glassmorphism effect
    func glassmorphism(tint: Color = .dsGlassOverlay, blur: CGFloat = 10) -> some View {
        modifier(GlassmorphismModifier(tintColor: tint, blur: blur))
    }

    /// Apply grain texture overlay
    func grainTexture(opacity: Double = 0.03) -> some View {
        modifier(GrainTextureModifier(opacity: opacity))
    }

    /// Apply gradient background
    func gradientBackground(_ gradient: LinearGradient = Color.dsGradientAtmosphere) -> some View {
        modifier(GradientBackgroundModifier(gradient: gradient))
    }

    /// Apply staggered fade-in animation
    func staggeredFadeIn(index: Int, delay: Double = DSAnimation.staggerMedium) -> some View {
        modifier(StaggeredFadeInModifier(index: index, delay: delay))
    }

    /// Apply hover effect
    func hoverEffect(scale: CGFloat = 1.05, brightness: Double = 0.1) -> some View {
        modifier(HoverEffectModifier(scaleAmount: scale, brightness: brightness))
    }

    /// Apply warm glow
    func warmGlow(intensity: Double = 0.3) -> some View {
        modifier(WarmGlowModifier(intensity: intensity))
    }

    /// Apply card style
    func cardStyle(padding: CGFloat = DSSpacing.md, shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = DSShadow.medium) -> some View {
        modifier(CardStyleModifier(padding: padding, shadowLevel: shadow))
    }

    /// Apply recording pulse animation
    func recordingPulse() -> some View {
        modifier(RecordingPulseModifier())
    }

    /// Apply standard shadow
    func dsShadow(_ level: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = DSShadow.medium) -> some View {
        shadow(color: level.color, radius: level.radius, x: level.x, y: level.y)
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct DesignSystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {

                // Colors
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Color Palette")
                        .font(DSFont.title2())
                        .foregroundColor(.dsTextPrimary)

                    HStack(spacing: DSSpacing.sm) {
                        colorSwatch("Primary", .dsAccentPrimary)
                        colorSwatch("Deep", .dsAccentDeep)
                        colorSwatch("Burgundy", .dsBurgundy)
                    }

                    HStack(spacing: DSSpacing.sm) {
                        colorSwatch("Success", .dsSuccess)
                        colorSwatch("Warning", .dsWarning)
                        colorSwatch("Error", .dsError)
                    }
                }

                // Typography
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Typography")
                        .font(DSFont.title2())
                        .foregroundColor(.dsTextPrimary)

                    Text("Display Text")
                        .font(DSFont.display())
                        .foregroundColor(.dsTextPrimary)

                    Text("Large Title")
                        .font(DSFont.largeTitle())
                        .foregroundColor(.dsTextPrimary)

                    Text("Headline Text")
                        .font(DSFont.headline())
                        .foregroundColor(.dsTextSecondary)

                    Text("Body text for general content")
                        .font(DSFont.body())
                        .foregroundColor(.dsTextTertiary)
                }

                // Effects
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Effects")
                        .font(DSFont.title2())
                        .foregroundColor(.dsTextPrimary)

                    Text("Glassmorphism")
                        .font(DSFont.headline())
                        .foregroundColor(.dsTextPrimary)
                        .padding()
                        .glassmorphism()

                    Text("Card Style")
                        .font(DSFont.headline())
                        .foregroundColor(.dsTextPrimary)
                        .cardStyle()

                    Text("Warm Glow")
                        .font(DSFont.headline())
                        .foregroundColor(.dsTextPrimary)
                        .padding()
                        .background(Color.dsBackgroundSecondary)
                        .cornerRadius(DSSpacing.radiusMedium)
                        .warmGlow()
                }
            }
            .padding(DSSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dsBackgroundPrimary)
    }

    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: DSSpacing.radiusSmall)
                .fill(color)
                .frame(width: 60, height: 60)

            Text(name)
                .font(DSFont.caption())
                .foregroundColor(.dsTextTertiary)
        }
    }
}

struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        DesignSystemPreview()
    }
}
#endif
