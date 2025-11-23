import SwiftUI
import AppKit

// MARK: - Design System Constants
enum DesignSystem {
    // Colors
    enum Colors {
        static let warmAmber = Color(red: 0.98, green: 0.76, blue: 0.52)
        static let warmOrange = Color(red: 0.95, green: 0.61, blue: 0.38)
        static let deepPurple = Color(red: 0.38, green: 0.29, blue: 0.52)
        static let softBlue = Color(red: 0.45, green: 0.62, blue: 0.85)
        static let warmBackground = Color(red: 0.15, green: 0.13, blue: 0.17)
        static let warmBackgroundLight = Color(red: 0.20, green: 0.18, blue: 0.22)
    }

    // Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // Radius
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
        static let xl: CGFloat = 20
    }

    // Shadows
    enum Shadow {
        static let subtle = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.25), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let dramatic = (color: Color.black.opacity(0.35), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
    }
}

// MARK: - Grain Texture Modifier
struct GrainTextureModifier: ViewModifier {
    @State private var grainOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Canvas { context, size in
                        let grainDensity = 0.015
                        let grainCount = Int(size.width * size.height * grainDensity)

                        for _ in 0..<grainCount {
                            let x = CGFloat.random(in: 0...size.width)
                            let y = CGFloat.random(in: 0...size.height)
                            let opacity = Double.random(in: 0.05...0.15)

                            context.fill(
                                Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                                with: .color(.white.opacity(opacity))
                            )
                        }
                    }
                }
                .allowsHitTesting(false)
                .blendMode(.overlay)
            )
    }
}

// MARK: - Atmospheric Glow Modifier
struct AtmosphericGlowModifier: ViewModifier {
    let color: Color
    let intensity: CGFloat

    init(color: Color, intensity: CGFloat = 1.0) {
        self.color = color
        self.intensity = intensity
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3 * intensity), radius: 8, x: 0, y: 0)
            .shadow(color: color.opacity(0.2 * intensity), radius: 16, x: 0, y: 0)
            .shadow(color: color.opacity(0.1 * intensity), radius: 24, x: 0, y: 0)
    }
}

// MARK: - Glassmorphic Modifier
struct GlassmorphicModifier: ViewModifier {
    let tintColor: Color
    let blurRadius: CGFloat

    init(tintColor: Color = .white, blurRadius: CGFloat = 10) {
        self.tintColor = tintColor
        self.blurRadius = blurRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Frosted glass effect
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)

                    // Subtle tint overlay
                    tintColor.opacity(0.05)

                    // Border highlight
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    .white.opacity(0.05),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
    }
}

// Visual Effect Blur helper
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Staggered Fade In Modifier
struct StaggeredFadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    opacity = 1
                    offset = 0
                }
            }
    }
}

// MARK: - Hover Lift Modifier
struct HoverLiftModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: .black.opacity(isHovered ? 0.3 : 0.15),
                radius: isHovered ? 16 : 8,
                x: 0,
                y: isHovered ? 6 : 2
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Dramatic Shadow Modifier
struct DramaticShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
    }
}

// MARK: - Warm Gradient Modifier
struct WarmGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.warmBackground,
                        DesignSystem.Colors.warmBackgroundLight
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Elegant Border Modifier
struct ElegantBorderModifier: ViewModifier {
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = DesignSystem.Radius.md) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - View Extension
extension View {
    /// Applies subtle noise overlay for texture
    func grainTexture() -> some View {
        modifier(GrainTextureModifier())
    }

    /// Applies soft outer glow effect
    func atmosphericGlow(color: Color = .white, intensity: CGFloat = 1.0) -> some View {
        modifier(AtmosphericGlowModifier(color: color, intensity: intensity))
    }

    /// Applies frosted glass effect
    func glassmorphic(tintColor: Color = .white, blurRadius: CGFloat = 10) -> some View {
        modifier(GlassmorphicModifier(tintColor: tintColor, blurRadius: blurRadius))
    }

    /// Applies delayed fade-in animation
    func staggeredFadeIn(delay: Double = 0) -> some View {
        modifier(StaggeredFadeInModifier(delay: delay))
    }

    /// Applies lift effect on hover with shadow
    func hoverLift() -> some View {
        modifier(HoverLiftModifier())
    }

    /// Applies layered dramatic shadow effect
    func dramaticShadow() -> some View {
        modifier(DramaticShadowModifier())
    }

    /// Applies warm background gradient
    func warmGradient() -> some View {
        modifier(WarmGradientModifier())
    }

    /// Applies refined border styling
    func elegantBorder(cornerRadius: CGFloat = DesignSystem.Radius.md) -> some View {
        modifier(ElegantBorderModifier(cornerRadius: cornerRadius))
    }
}
