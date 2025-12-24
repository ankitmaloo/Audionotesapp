import SwiftUI
import AppKit

// MARK: - Analog Warmth Design System
extension Color {
    // Deep atmospheric backgrounds
    static let deepCharcoal = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let richMidnight = Color(red: 0.08, green: 0.09, blue: 0.13)
    static let warmBlack = Color(red: 0.09, green: 0.08, blue: 0.10)

    // Warm accents
    static let burntAmber = Color(red: 0.85, green: 0.52, blue: 0.28)
    static let softGold = Color(red: 0.92, green: 0.76, blue: 0.48)
    static let warmIvory = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let mutedCopper = Color(red: 0.72, green: 0.45, blue: 0.29)

    // Atmospheric grays
    static let mistGray = Color(red: 0.58, green: 0.58, blue: 0.60)
    static let smokeGray = Color(red: 0.42, green: 0.42, blue: 0.44)
}

// MARK: - Atmospheric Background with Grain
struct AtmosphericBackground: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Base gradient mesh
            MeshGradient(
                width: 3,
                height: 3,
                points: animateGradient ?
                    [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                     [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                     [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]] :
                    [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                     [0.0, 0.4], [0.6, 0.5], [1.0, 0.6],
                     [0.0, 1.0], [0.4, 1.0], [1.0, 1.0]],
                colors: [
                    .richMidnight, .deepCharcoal, .warmBlack,
                    .deepCharcoal, .richMidnight.opacity(0.8), .deepCharcoal,
                    .warmBlack, .deepCharcoal, .richMidnight
                ]
            )

            // Subtle grain texture overlay
            GrainTextureView()
                .opacity(0.15)
                .blendMode(.overlay)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Grain Texture
struct GrainTextureView: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for _ in 0..<1000 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.1...0.4)

                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Glow Effect Modifier
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glowEffect(color: Color, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject private var permission: AudioRecordingPermission
    @EnvironmentObject private var appState: AppState
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Atmospheric background
            AtmosphericBackground()
                .ignoresSafeArea()

            // Content with transition
            Group {
                switch permission.status {
                case .unknown:
                    requestPermissionView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.1).combined(with: .opacity)
                        ))
                case .authorized:
                    recordingView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                case .denied:
                    permissionDeniedView
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                showContent = true
            }
        }
    }

    // MARK: - Request Permission View
    @ViewBuilder
    private var requestPermissionView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Asymmetric layout with generous negative space
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)

                    // Dramatic header with serif typography
                    VStack(alignment: .leading, spacing: 24) {
                        // Icon with glow
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 72, weight: .ultraLight))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.softGold, .burntAmber],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .glowEffect(color: .burntAmber, radius: 30)
                            .offset(x: -8)
                            .scaleEffect(showContent ? 1 : 0.5)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: showContent)

                        // Title with dramatic serif font
                        Text("Your Voice,\nPreserved")
                            .font(.custom("Didot", size: 64))
                            .fontWeight(.medium)
                            .foregroundColor(.warmIvory)
                            .lineSpacing(8)
                            .offset(x: showContent ? 0 : -50)
                            .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)

                        // Decorative divider
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.burntAmber, .burntAmber.opacity(0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 120, height: 2)
                            .offset(y: -8)
                            .scaleEffect(x: showContent ? 1 : 0, anchor: .leading)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)

                        // Subtitle
                        Text("To capture and immortalize your audio notes,\nwe require access to your microphone.")
                            .font(.custom("Palatino", size: 17))
                            .foregroundColor(.mistGray)
                            .lineSpacing(6)
                            .frame(maxWidth: 480, alignment: .leading)
                            .offset(x: showContent ? 0 : -30)
                            .animation(.easeOut(duration: 0.8).delay(1.0), value: showContent)

                        Spacer()
                            .frame(height: 48)

                        // CTA Button with atmospheric styling
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                permission.request()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Text("Grant Permission")
                                    .font(.custom("Baskerville", size: 18))
                                    .fontWeight(.semibold)

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.warmBlack)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 18)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [.softGold, .burntAmber],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.warmIvory.opacity(0.3), lineWidth: 1)
                                }
                            )
                            .glowEffect(color: .burntAmber.opacity(0.5), radius: 25)
                        }
                        .buttonStyle(AtmosphericButtonStyle())
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: showContent)
                    }
                    .padding(.leading, geometry.size.width * 0.12)

                    Spacer()
                }

                // Floating decorative element
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.burntAmber.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 40)
                    .offset(x: geometry.size.width * 0.65, y: geometry.size.height * 0.25)
                    .opacity(showContent ? 0.6 : 0)
                    .animation(.easeOut(duration: 2).delay(0.5), value: showContent)
            }
        }
    }

    // MARK: - Permission Denied View
    @ViewBuilder
    private var permissionDeniedView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    Spacer()

                    // Centered dramatic layout
                    VStack(alignment: .center, spacing: 32) {
                        // Warning icon with atmospheric glow
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.85, green: 0.35, blue: 0.35).opacity(0.2),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .blur(radius: 20)

                            Image(systemName: "mic.slash.circle.fill")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.95, green: 0.55, blue: 0.55),
                                            Color(red: 0.85, green: 0.35, blue: 0.35)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .scaleEffect(showContent ? 1 : 0.7)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: showContent)

                        // Title
                        Text("Access Declined")
                            .font(.custom("Didot", size: 56))
                            .foregroundColor(.warmIvory)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.8).delay(0.5), value: showContent)

                        // Description with generous spacing
                        Text("The microphone remains silent.\nTo proceed, kindly enable access within\nyour System Settings.")
                            .font(.custom("Palatino", size: 17))
                            .foregroundColor(.mistGray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .frame(maxWidth: 520)
                            .offset(y: showContent ? 0 : 15)
                            .animation(.easeOut(duration: 0.8).delay(0.7), value: showContent)

                        Spacer()
                            .frame(height: 24)

                        // Settings button
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16))

                                Text("Open System Settings")
                                    .font(.custom("Baskerville", size: 17))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.warmBlack)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.warmIvory)

                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.softGold.opacity(0.4), lineWidth: 1)
                                }
                            )
                            .shadow(color: .warmIvory.opacity(0.3), radius: 20)
                        }
                        .buttonStyle(AtmosphericButtonStyle())
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.9), value: showContent)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Recording View
    @ViewBuilder
    private var recordingView: some View {
        ZStack {
            // Tab content with atmospheric overlay
            TabView(selection: $appState.activeTab) {
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
                    .tag(AppState.Tab.notes)

                RecordingView()
                    .tabItem {
                        Label("Record", systemImage: "mic.fill")
                    }
                    .tag(AppState.Tab.recording)
            }
            .background(.clear)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

// MARK: - Atmospheric Button Style
struct AtmosphericButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    let permission = AudioRecordingPermission()
    let appState = AppState()
    let notesManager = NotesManager()
    let audioCapService = AudioCapService()
    let detection = CallDetectionService(audioCapService: audioCapService, monitoringEnabled: false)

    return ContentView()
        .environmentObject(permission)
        .environmentObject(appState)
        .environmentObject(notesManager)
        .environmentObject(audioCapService)
        .environmentObject(detection)
}
