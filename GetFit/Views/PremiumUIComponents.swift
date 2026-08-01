import SwiftUI

// MARK: - Minimalist Dark Card with Glowing Border & Subtle Background Hint

struct MatteBlackCard: ViewModifier {
    let cornerRadius: CGFloat
    let accentColor: Color
    
    init(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90)) {
        self.cornerRadius = cornerRadius
        self.accentColor = accentColor
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Dark Base
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                    
                    // Side Hint of Accent Color
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.08),
                            accentColor.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                // Crisp Glowing Border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.50),
                                accentColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
            .shadow(color: accentColor.opacity(0.08), radius: 10, x: 0, y: 2)
    }
}

extension View {
    func matteBlack(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90)) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    // Backwards compatibility aliases
    func liquidGlass(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90), liquidOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    func glassmorphic(cornerRadius: CGFloat = 18, glowColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90), glowOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: glowColor))
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
            ? [Color(red: 0.68, green: 0.78, blue: 0.90), Color(red: 0.45, green: 0.65, blue: 0.85)]
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
                .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 0)
            
            // Dot at tip
            if animatedProgress > 0.02 {
                Circle()
                    .fill(gradient.last ?? .blue)
                    .frame(width: lineWidth * 1.1, height: lineWidth * 1.1)
                    .shadow(color: gradient.last?.opacity(0.5) ?? .clear, radius: 4)
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

// MARK: - Minimalist Muscle Group Badge (Soft Pastel Palette, Zero Eye Strain)

struct MuscleGroupBadge: View {
    let muscle: String
    let color: Color
    
    init(muscle: String, color: Color? = nil) {
        self.muscle = muscle
        self.color = color ?? MuscleGroupBadge.colorForMuscle(muscle)
    }
    
    static func colorForMuscle(_ muscle: String) -> Color {
        switch muscle.lowercased() {
        case "quads", "quadriceps", "legs":
            return Color(red: 0.68, green: 0.78, blue: 0.90) // Soft Pastel Blue
        case "glutes":
            return Color(red: 0.90, green: 0.60, blue: 0.75) // Muted Rose
        case "hamstrings":
            return Color(red: 0.80, green: 0.65, blue: 0.88) // Soft Lavender
        case "chest":
            return Color(red: 0.90, green: 0.55, blue: 0.55) // Muted Coral
        case "back", "lats":
            return Color(red: 0.55, green: 0.75, blue: 0.90) // Soft Steel Blue
        case "shoulders", "delts":
            return Color(red: 0.92, green: 0.70, blue: 0.50) // Muted Amber
        case "biceps":
            return Color(red: 0.55, green: 0.82, blue: 0.68) // Soft Sage
        case "triceps":
            return Color(red: 0.78, green: 0.65, blue: 0.90) // Soft Violet
        case "core", "abs":
            return Color(red: 0.90, green: 0.80, blue: 0.55) // Soft Gold
        case "calves":
            return Color(red: 0.55, green: 0.82, blue: 0.80) // Soft Teal
        case "forearms":
            return Color(red: 0.70, green: 0.75, blue: 0.90) // Soft Slate
        case "traps":
            return Color(red: 0.88, green: 0.65, blue: 0.55) // Soft Peach
        default:
            return Color(red: 0.68, green: 0.78, blue: 0.90)
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.9)
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.08))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.35), lineWidth: 0.8)
            )
    }
}

// MARK: - Minimalist Body Part Activation Card & Instructions

struct BodyPartActivationCard: View {
    let machineName: String
    let targetMuscles: [String]
    let instructions: String
    let equipmentType: String
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.subheadline)
                    .foregroundStyle(paleBlue)
                
                Text("Body Part Activation & Form Guide")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(equipmentType.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
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
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 5)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [color.opacity(0.9), color.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * (CGFloat(percentage) / 100.0), height: 5)
                                }
                            }
                            .frame(height: 5)
                            
                            Text("\(percentage)%")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(color)
                                .frame(width: 32, alignment: .trailing)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Minimalist Step-by-Step Form & Execution Instructions
            let steps = parseInstructions(instructions, machineName: machineName, equipmentType: equipmentType)
            if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 Execution Tips:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(paleBlue)
                                .frame(width: 20, height: 20)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(paleBlue.opacity(0.3), lineWidth: 0.8)
                                )
                            
                            Text(step)
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.white.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(14)
        .matteBlack(cornerRadius: 16, accentColor: paleBlue)
    }
    
    // Clean instruction parser
    private func parseInstructions(_ text: String, machineName: String, equipmentType: String) -> [String] {
        var rawSentences: [String] = []
        
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            let splitByPeriod = line.components(separatedBy: ". ")
            for segment in splitByPeriod {
                let trimmed = segment.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    rawSentences.append(trimmed)
                }
            }
        }
        
        var cleanedSteps: [String] = []
        for sentence in rawSentences {
            var str = sentence
            if let range = str.range(of: #"^\(?\d+[\.\)\s\-]+"#, options: .regularExpression) {
                str.removeSubrange(range)
            }
            str = str.replacingOccurrences(of: "•", with: "")
                     .replacingOccurrences(of: "-", with: "")
                     .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if str.count > 6 {
                if !str.hasSuffix(".") && !str.hasSuffix("!") {
                    str += "."
                }
                cleanedSteps.append(str)
            }
        }
        
        if cleanedSteps.isEmpty {
            switch machineName.lowercased() {
            case let s where s.contains("squat"):
                return [
                    "Position the bar on your upper traps with feet shoulder-width apart.",
                    "Lower your hips back and down until thighs are parallel to the floor.",
                    "Drive firmly through your heels to return to standing position."
                ]
            case let s where s.contains("press"):
                return [
                    "Maintain a stable stance on the bench with core tight.",
                    "Lower the weight smoothly to mid-chest level under full control.",
                    "Press upward powerfully without locking out elbows abruptly."
                ]
            case let s where s.contains("curl"):
                return [
                    "Keep elbows pinned close to your torso throughout the motion.",
                    "Curl the weight up while squeezing your biceps at peak tension.",
                    "Lower slowly for a 2-second negative stretch phase."
                ]
            default:
                return [
                    "Setup with proper posture and engage your core before starting.",
                    "Execute movement through a complete, smooth range of motion.",
                    "Control the eccentric phase and breathe out on contraction."
                ]
            }
        }
        
        return Array(cleanedSteps.prefix(3))
    }
}

// MARK: - PR Badge

struct PRBadge: View {
    let weight: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text("🏆")
                .font(.caption2)
            Text("PR \(weight)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.45))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.92, green: 0.78, blue: 0.45).opacity(0.10))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(red: 0.92, green: 0.78, blue: 0.45).opacity(0.35), lineWidth: 0.8)
        )
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
                    .fill(isCompleted ? accentColor.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? accentColor.opacity(0.25) : Color.clear, lineWidth: 0.8)
            )
            .scaleEffect(isCompleted ? 1.0 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isCompleted)
    }
}

extension View {
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = Color(red: 0.68, green: 0.78, blue: 0.90)) -> some View {
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
                        color.opacity(0.06),
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
