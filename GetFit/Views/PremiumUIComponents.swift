import SwiftUI

// MARK: - Glassmorphic Card Modifier

struct GlassmorphicCard: ViewModifier {
    let cornerRadius: CGFloat
    let glowColor: Color
    let glowOpacity: Double
    
    init(cornerRadius: CGFloat = 20, glowColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90), glowOpacity: Double = 0.08) {
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.glowOpacity = glowOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    glowColor.opacity(glowOpacity),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                glowColor.opacity(0.3),
                                glowColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
    }
}

extension View {
    func glassmorphic(
        cornerRadius: CGFloat = 20,
        glowColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90),
        glowOpacity: Double = 0.08
    ) -> some View {
        self.modifier(GlassmorphicCard(cornerRadius: cornerRadius, glowColor: glowColor, glowOpacity: glowOpacity))
    }
}

// MARK: - Animated Ring View (Apple Fitness Style)

struct AnimatedRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 10, gradient: [Color] = [], size: CGFloat = 100) {
        self.progress = min(progress, 1.0)
        self.lineWidth = lineWidth
        self.gradient = gradient.isEmpty
            ? [Color(red: 0.68, green: 0.78, blue: 0.90), Color(red: 0.45, green: 0.65, blue: 0.95)]
            : gradient
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
            
            // Animated Progress Arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradient + [gradient.first ?? .blue]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: 4, x: 0, y: 0)
            
            // Glow dot at tip
            if animatedProgress > 0.02 {
                Circle()
                    .fill(gradient.last ?? .blue)
                    .frame(width: lineWidth * 1.1, height: lineWidth * 1.1)
                    .shadow(color: gradient.last?.opacity(0.6) ?? .clear, radius: 6)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

// MARK: - Muscle Group Badge

struct MuscleGroupBadge: View {
    let muscle: String
    let color: Color
    
    init(muscle: String, color: Color = Color(red: 0.68, green: 0.78, blue: 0.90)) {
        self.muscle = muscle
        self.color = color
    }
    
    static func colorForMuscle(_ muscle: String) -> Color {
        switch muscle.lowercased() {
        case "chest": return Color(red: 0.95, green: 0.45, blue: 0.45)
        case "back": return Color(red: 0.45, green: 0.75, blue: 0.95)
        case "shoulders": return Color(red: 0.95, green: 0.65, blue: 0.30)
        case "biceps": return Color(red: 0.55, green: 0.85, blue: 0.55)
        case "triceps": return Color(red: 0.75, green: 0.55, blue: 0.95)
        case "legs", "quads", "hamstrings", "glutes": return Color(red: 0.90, green: 0.50, blue: 0.70)
        case "core", "abs": return Color(red: 0.95, green: 0.80, blue: 0.35)
        case "calves": return Color(red: 0.50, green: 0.85, blue: 0.80)
        case "forearms": return Color(red: 0.70, green: 0.70, blue: 0.90)
        case "traps": return Color(red: 0.85, green: 0.60, blue: 0.50)
        default: return Color(red: 0.68, green: 0.78, blue: 0.90)
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 0.6)
            )
    }
}

// MARK: - PR Badge

struct PRBadge: View {
    let weight: String
    @State private var isGlowing = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text("🏆")
                .font(.caption2)
            Text("PR \(weight)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.35))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Color(red: 0.95, green: 0.80, blue: 0.35).opacity(isGlowing ? 0.20 : 0.10)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(red: 0.95, green: 0.80, blue: 0.35).opacity(0.4), lineWidth: 0.6)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Set Completion Animation Modifier

struct SetCompletionEffect: ViewModifier {
    let isCompleted: Bool
    let accentColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? accentColor.opacity(0.06) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? accentColor.opacity(0.15) : Color.clear, lineWidth: 0.6)
            )
            .scaleEffect(isCompleted ? 1.0 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isCompleted)
    }
}

extension View {
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = Color(red: 0.45, green: 0.85, blue: 0.65)) -> some View {
        self.modifier(SetCompletionEffect(isCompleted: isCompleted, accentColor: accentColor))
    }
}

// MARK: - Shimmer/Glow Animation

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        color.opacity(0.08),
                        .clear
                    ],
                    startPoint: .init(x: phase - 0.5, y: 0),
                    endPoint: .init(x: phase + 0.5, y: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .onAppear {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmerGlow(color: Color = Color(red: 0.68, green: 0.78, blue: 0.90)) -> some View {
        self.modifier(ShimmerEffect(color: color))
    }
}
