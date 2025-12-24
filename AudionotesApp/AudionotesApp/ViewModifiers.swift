import SwiftUI
import AppKit

// MARK: - Design System Constants
// Note: DesignSystem enum is defined in DesignSystem.swift

// MARK: - Grain Texture Modifier
// Note: GrainTextureModifier is defined in DesignSystem.swift

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
// Note: StaggeredFadeInModifier is defined in DesignSystem.swift

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
    // Note: grainTexture(opacity:) and staggeredFadeIn(index:delay:) are defined in DesignSystem.swift
    
    /// Applies soft outer glow effect
    func atmosphericGlow(color: Color = .white, intensity: CGFloat = 1.0) -> some View {
        modifier(AtmosphericGlowModifier(color: color, intensity: intensity))
    }

    /// Applies frosted glass effect
    func glassmorphic(tintColor: Color = .white, blurRadius: CGFloat = 10) -> some View {
        modifier(GlassmorphicModifier(tintColor: tintColor, blurRadius: blurRadius))
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
