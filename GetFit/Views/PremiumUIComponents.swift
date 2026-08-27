import SwiftUI

// MARK: - Muted Earth Palette
public struct MutedEarth {
    public static let slateBlue = Color(red: 0.45, green: 0.55, blue: 0.65)
    public static let softSage = Color(red: 0.55, green: 0.65, blue: 0.55)
    public static let terracotta = Color(red: 0.85, green: 0.45, blue: 0.35)
}

// MARK: - Monochrome Card

struct MonochromeCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 0) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
            )
    }
}

@MainActor
extension View {
    func monochromeCard(cornerRadius: CGFloat = 0) -> some View {
        self.modifier(MonochromeCardModifier(cornerRadius: cornerRadius))
    }
    
    // Backwards compatibility aliases to avoid breaking existing views before they are updated
    func matteBlack(cornerRadius: CGFloat = 0, accentColor: Color = .white) -> some View {
        self.modifier(MonochromeCardModifier(cornerRadius: cornerRadius))
    }
    
    func glassmorphic(cornerRadius: CGFloat = 0, glowColor: Color = .white, glowOpacity: Double = 0) -> some View {
        self.modifier(MonochromeCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Animated Ring View (Monochrome Style)

struct AnimatedRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 8, gradient: [Color] = [], size: CGFloat = 100) {
        self.progress = min(progress, 1.0)
        self.lineWidth = lineWidth
        self.gradient = gradient.isEmpty ? [MutedEarth.slateBlue, Color(white: 0.8)] : gradient
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
            
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
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
            
            // Dot at tip
            if animatedProgress > 0.02 {
                Circle()
                    .fill(gradient.last ?? .white)
                    .frame(width: lineWidth, height: lineWidth)
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

// MARK: - Monochrome Muscle Group Badge

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
            return MutedEarth.terracotta
        case "chest", "back", "lats", "shoulders", "delts", "traps":
            return MutedEarth.slateBlue
        case "biceps", "triceps", "core", "abs", "forearms":
            return MutedEarth.softSage
        default:
            return MutedEarth.slateBlue
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(Color.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Rectangle()) // Brutalist flat rectangle
    }
}

// MARK: - Monochrome Body Part Activation Card

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
                    .foregroundStyle(.white)
                
                Text("Body Part Activation & Form Guide")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(MutedEarth.slateBlue)
                
                Spacer()
                
                Text(equipmentType.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 8)
                    .background(MutedEarth.slateBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Targeted Muscle Activation Gauges
            if !targetMuscles.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(targetMuscles.enumerated()), id: \.offset) { index, muscle in
                        let isPrimary = index == 0
                        let percentage = isPrimary ? 90 : max(40, 75 - (index * 20))
                        
                        HStack(spacing: 10) {
                            Text(isPrimary ? "🎯" : "⚡")
                                .font(.caption2)
                            
                            Text(muscle.capitalized)
                                .font(.caption)
                                .fontWeight(isPrimary ? .bold : .regular)
                                .foregroundStyle(.white)
                                .frame(width: 80, alignment: .leading)
                            
                            // Activation Bar Gauge
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 4)
                                    
                                    Rectangle()
                                        .fill(MuscleGroupBadge.colorForMuscle(muscle))
                                        .frame(width: geo.size.width * (CGFloat(percentage) / 100.0), height: 4)
                                }
                            }
                            .frame(height: 4)
                            
                            Text("\(percentage)%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, alignment: .trailing)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Instructions
            let steps = parseInstructions(instructions, machineName: machineName, equipmentType: equipmentType)
            if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("EXECUTION TIPS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.gray)
                        .tracking(1.0)
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 20, height: 20)
                                .background(MutedEarth.slateBlue)
                                .clipShape(Circle())
                            
                            Text(step)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(14)
        .monochromeCard(cornerRadius: 12)
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
                "Setup with proper posture and engage your core before starting.",
                "Execute movement through a complete, smooth range of motion.",
                "Control the eccentric phase and breathe out on contraction."
            ]
        }
        
        return Array(cleanedSteps.prefix(3))
    }
}

// MARK: - Monochrome PR Badge

struct PRBadge: View {
    let weight: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text("PR")
                .font(.system(size: 10, weight: .black))
            Text(weight)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
    }
}

// MARK: - Set Completion Animation Modifier (Stripped down)

struct SetCompletionEffect: ViewModifier {
    let isCompleted: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(isCompleted ? Color.white.opacity(0.1) : Color.clear)
            )
            .overlay(
                Rectangle()
                    .stroke(isCompleted ? Color.white : Color.clear, lineWidth: 1.0)
            )
            .animation(.easeIn(duration: 0.1), value: isCompleted)
    }
}

extension View {
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = .white) -> some View {
        self.modifier(SetCompletionEffect(isCompleted: isCompleted))
    }
}

// MARK: - Shimmer/Glow Animation (Disabled for Brutalism)

extension View {
    func shimmerGlow(color: Color = .white) -> some View {
        // No-op for minimalist design
        self
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
