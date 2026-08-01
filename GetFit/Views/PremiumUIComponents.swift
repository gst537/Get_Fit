import SwiftUI

// MARK: - iOS 18 Liquid Glass Texture Modifier

struct LiquidGlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let accentColor: Color
    let liquidOpacity: Double
    
    init(cornerRadius: CGFloat = 20, accentColor: Color = Color(red: 0.40, green: 0.70, blue: 1.00), liquidOpacity: Double = 0.12) {
        self.cornerRadius = cornerRadius
        self.accentColor = accentColor
        self.liquidOpacity = liquidOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. Deep Fluid Base Layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.11, green: 0.13, blue: 0.18),
                                    Color(red: 0.06, green: 0.07, blue: 0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 2. Liquid Glass Blur & Material Sheen
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.regularMaterial)
                        .environment(\.colorScheme, .dark)
                        .opacity(0.7)
                    
                    // 3. Fluid Specular Reflection Highlight (Top Shine)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.14),
                                    accentColor.opacity(liquidOpacity),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            // 4. Prismatic Liquid Glass Edge Refraction Border
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.40),
                                accentColor.opacity(0.45),
                                Color.white.opacity(0.10),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 4)
    }
}

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 20,
        accentColor: Color = Color(red: 0.40, green: 0.70, blue: 1.00),
        liquidOpacity: Double = 0.12
    ) -> some View {
        self.modifier(LiquidGlassCard(cornerRadius: cornerRadius, accentColor: accentColor, liquidOpacity: liquidOpacity))
    }
    
    // Backwards compatibility alias for glassmorphic
    func glassmorphic(
        cornerRadius: CGFloat = 20,
        glowColor: Color = Color(red: 0.40, green: 0.70, blue: 1.00),
        glowOpacity: Double = 0.12
    ) -> some View {
        self.modifier(LiquidGlassCard(cornerRadius: cornerRadius, accentColor: glowColor, liquidOpacity: glowOpacity))
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
            ? [Color(red: 0.20, green: 0.85, blue: 1.00), Color(red: 0.00, green: 0.55, blue: 1.00)]
            : gradient
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            
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
                .shadow(color: gradient.first?.opacity(0.5) ?? .clear, radius: 6, x: 0, y: 0)
            
            // Glow dot at tip
            if animatedProgress > 0.02 {
                Circle()
                    .fill(gradient.last ?? .blue)
                    .frame(width: lineWidth * 1.1, height: lineWidth * 1.1)
                    .shadow(color: gradient.last?.opacity(0.8) ?? .clear, radius: 8)
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

// MARK: - Vibrant High-Contrast Muscle Group Badge

struct MuscleGroupBadge: View {
    let muscle: String
    let color: Color
    
    init(muscle: String, color: Color? = nil) {
        self.muscle = muscle
        self.color = color ?? MuscleGroupBadge.colorForMuscle(muscle)
    }
    
    static func colorForMuscle(_ muscle: String) -> Color {
        switch muscle.lowercased() {
        case "quads", "quadriceps":
            return Color(red: 0.20, green: 0.85, blue: 1.00) // Electric Cyan
        case "glutes":
            return Color(red: 1.00, green: 0.35, blue: 0.65) // Neon Rose Pink
        case "hamstrings":
            return Color(red: 0.90, green: 0.40, blue: 0.95) // Vivid Purple
        case "chest":
            return Color(red: 1.00, green: 0.30, blue: 0.40) // Neon Crimson
        case "back", "lats":
            return Color(red: 0.25, green: 0.65, blue: 1.00) // Deep Azure
        case "shoulders", "delts":
            return Color(red: 1.00, green: 0.55, blue: 0.15) // Electric Amber
        case "biceps":
            return Color(red: 0.25, green: 0.90, blue: 0.55) // Emerald Green
        case "triceps":
            return Color(red: 0.75, green: 0.45, blue: 1.00) // Bright Violet
        case "core", "abs":
            return Color(red: 1.00, green: 0.78, blue: 0.20) // Glowing Gold
        case "calves":
            return Color(red: 0.15, green: 0.90, blue: 0.85) // Neon Teal
        case "forearms":
            return Color(red: 0.70, green: 0.75, blue: 1.00) // Light Indigo
        case "traps":
            return Color(red: 1.00, green: 0.45, blue: 0.30) // Sunset Coral
        default:
            return Color(red: 0.40, green: 0.70, blue: 1.00)
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.9)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.28))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.70), lineWidth: 1.0)
            )
            .shadow(color: color.opacity(0.35), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Body Part Activation Card & Instructions

struct BodyPartActivationCard: View {
    let machineName: String
    let targetMuscles: [String]
    let instructions: String
    let equipmentType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.20, green: 0.85, blue: 1.00))
                
                Text("Body Part Activation & Form Guide")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(equipmentType.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }
            
            // Targeted Muscle Activation Gauges
            if !targetMuscles.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(targetMuscles.enumerated()), id: \.offset) { index, muscle in
                        let isPrimary = index == 0
                        let percentage = isPrimary ? 90 : max(40, 75 - (index * 20))
                        let color = MuscleGroupBadge.colorForMuscle(muscle)
                        
                        HStack(spacing: 10) {
                            Text(isPrimary ? "🎯" : "⚡")
                                .font(.caption2)
                            
                            Text(muscle.capitalized)
                                .font(.caption)
                                .fontWeight(isPrimary ? .medium : .regular)
                                .foregroundStyle(.white)
                                .frame(width: 80, alignment: .leading)
                            
                            // Activation Bar Gauge
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [color, color.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: CGFloat(percentage) * 1.2, height: 6)
                                    .shadow(color: color.opacity(0.4), radius: 3)
                            }
                            
                            Spacer()
                            
                            Text("\(percentage)%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(color)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Colorful Step-by-Step Form & Instructions
            if !instructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Execution Tips:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 1.00, green: 0.78, blue: 0.20))
                    
                    let steps = parseInstructions(instructions)
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 16, height: 16)
                                .background(Color(red: 0.20, green: 0.85, blue: 1.00))
                                .clipShape(Circle())
                            
                            Text(step)
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 16, accentColor: Color(red: 0.20, green: 0.85, blue: 1.00))
    }
    
    private func parseInstructions(_ text: String) -> [String] {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(sentences.prefix(3))
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
                .foregroundStyle(Color(red: 1.00, green: 0.85, blue: 0.20))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Color(red: 1.00, green: 0.80, blue: 0.20).opacity(isGlowing ? 0.30 : 0.15)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(red: 1.00, green: 0.85, blue: 0.20).opacity(0.80), lineWidth: 1.0)
        )
        .shadow(color: Color(red: 1.00, green: 0.80, blue: 0.20).opacity(0.5), radius: 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
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
                    .fill(isCompleted ? accentColor.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? accentColor.opacity(0.40) : Color.clear, lineWidth: 0.8)
            )
            .scaleEffect(isCompleted ? 1.0 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isCompleted)
    }
}

extension View {
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = Color(red: 0.20, green: 0.85, blue: 1.00)) -> some View {
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
                        color.opacity(0.12),
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
    func shimmerGlow(color: Color = Color(red: 0.40, green: 0.70, blue: 1.00)) -> some View {
        self.modifier(ShimmerEffect(color: color))
    }
}
