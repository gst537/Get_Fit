import SwiftUI

// MARK: - Premium Palette
public struct PremiumColors {
    public static let neonCyan = Color(red: 0/255, green: 251/255, blue: 251/255) // True Bright Cyan (#00FBFB)
    public static let deepBlack = Color(red: 13/255, green: 13/255, blue: 20/255) // #0D0D14
    public static let starkWhite = Color.white
    public static let glassBackground = Color(red: 27/255, green: 27/255, blue: 36/255) // #1B1B24
    public static let glassBorder = Color(red: 53/255, green: 52/255, blue: 62/255) // #35343E
    public static let midGray = Color(red: 161/255, green: 161/255, blue: 170/255) // #A1A1AA
}

// MARK: - Premium Fonts
public struct PremiumFonts {
    public static let title = Font.system(.title, design: .rounded).weight(.bold)
    public static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    public static let body = Font.system(.body, design: .rounded)
    public static let caption = Font.system(.caption, design: .rounded)
}

// MARK: - Glassmorphic Card
struct GlassmorphicModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(PremiumColors.glassBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

@MainActor
extension View {
    func glassmorphic(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlassmorphicModifier(cornerRadius: cornerRadius))
    }
    
    // Backwards compatibility alias
    func monochromeCard(cornerRadius: CGFloat = 16) -> some View {
        self.glassmorphic(cornerRadius: cornerRadius)
    }
    
    func matteBlack(cornerRadius: CGFloat = 16, accentColor: Color = .white) -> some View {
        self.glassmorphic(cornerRadius: cornerRadius)
    }
}

// MARK: - Animated Ring View (Premium Style)
struct AnimatedRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 8, gradient: [Color] = [], size: CGFloat = 100) {
        self.progress = min(progress, 1.0)
        self.lineWidth = lineWidth
        self.gradient = gradient.isEmpty ? [PremiumColors.neonCyan] : gradient
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(PremiumColors.glassBorder, lineWidth: lineWidth)
            
            // Animated Progress Arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradient + [gradient.first ?? .white]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

// MARK: - Premium Muscle Group Badge
struct MuscleGroupBadge: View {
    let muscle: String
    let color: Color
    
    init(muscle: String, color: Color? = nil) {
        self.muscle = muscle
        self.color = color ?? MuscleGroupBadge.colorForMuscle(muscle)
    }
    
    static func colorForMuscle(_ muscle: String) -> Color {
        switch muscle.lowercased() {
        case "quads", "legs", "glutes", "hamstrings", "calves":
            return Color.teal
        case "chest", "back", "lats", "shoulders", "delts", "traps":
            return PremiumColors.neonCyan
        case "biceps", "triceps", "core", "abs", "forearms":
            return Color.mint
        default:
            return PremiumColors.starkWhite
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(1.0)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(PremiumColors.deepBlack)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Premium Body Part Activation Card
struct BodyPartActivationCard: View {
    let machineName: String
    let targetMuscles: [String]
    let instructions: String
    let equipmentType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            HStack {
                Text("Form Guide")
                    .font(PremiumFonts.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(PremiumColors.neonCyan)
                
                Spacer()
                
                Text(equipmentType.capitalized)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(PremiumColors.starkWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PremiumColors.glassBorder)
                    .clipShape(Capsule())
            }
            
            // Targeted Muscle Activation Gauges
            if !targetMuscles.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(targetMuscles.enumerated()), id: \.offset) { index, muscle in
                        let isPrimary = index == 0
                        let percentage = isPrimary ? 90 : max(40, 75 - (index * 20))
                        
                        HStack(spacing: 10) {
                            Text(muscle.capitalized)
                                .font(PremiumFonts.caption)
                                .fontWeight(isPrimary ? .bold : .regular)
                                .foregroundStyle(PremiumColors.starkWhite)
                                .frame(width: 80, alignment: .leading)
                            
                            // Activation Bar Gauge
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(PremiumColors.glassBorder)
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(isPrimary ? PremiumColors.neonCyan : PremiumColors.midGray)
                                        .frame(width: geo.size.width * (CGFloat(percentage) / 100.0), height: 8)
                                        .shadow(color: isPrimary ? PremiumColors.neonCyan.opacity(0.5) : .clear, radius: 4)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(percentage)%")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(PremiumColors.starkWhite)
                                .frame(width: 32, alignment: .trailing)
                        }
                    }
                }
                .padding(14)
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Instructions
            let steps = parseInstructions(instructions, machineName: machineName, equipmentType: equipmentType)
            if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Execution Tips")
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(PremiumColors.midGray)
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(PremiumFonts.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(PremiumColors.neonCyan)
                                .frame(width: 16)
                            
                            Text(step)
                                .font(PremiumFonts.caption)
                                .foregroundStyle(PremiumColors.starkWhite)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassmorphic(cornerRadius: 16)
    }
    
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
            return [
                "Setup with proper posture and engage your core.",
                "Execute movement through complete range of motion.",
                "Control eccentric phase and breathe out."
            ]
        }
        
        return Array(cleanedSteps.prefix(3))
    }
}

// MARK: - Premium PR Badge
struct PRBadge: View {
    let weight: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 10))
                .foregroundStyle(PremiumColors.deepBlack)
            Text(weight)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(PremiumColors.deepBlack)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(PremiumColors.neonCyan)
        .clipShape(Capsule())
        .shadow(color: PremiumColors.neonCyan.opacity(0.4), radius: 4)
    }
}

// MARK: - Set Completion Animation Modifier
struct SetCompletionEffect: ViewModifier {
    let isCompleted: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isCompleted ? PremiumColors.neonCyan.opacity(0.2) : PremiumColors.glassBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isCompleted ? PremiumColors.neonCyan : PremiumColors.glassBorder, lineWidth: 1)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
    }
}

extension View {
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = .white) -> some View {
        self.modifier(SetCompletionEffect(isCompleted: isCompleted))
    }
}

// MARK: - Shimmer/Glow Animation
struct ShimmerModifier: ViewModifier {
    let color: Color
    @State private var phase: CGFloat = -0.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    color
                        .opacity(0.2)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: 0),
                                            .init(color: .white, location: 0.5),
                                            .init(color: .clear, location: 1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .offset(x: geo.size.width * phase * 2, y: geo.size.height * phase * 2)
                        )
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

extension View {
    func shimmerGlow(color: Color = PremiumColors.neonCyan) -> some View {
        self.modifier(ShimmerModifier(color: color))
    }
}

// MARK: - Haptic Feedback
@MainActor
public struct Haptics {
    public static func playLightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func playMediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func playHeavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    public static func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    public static func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
