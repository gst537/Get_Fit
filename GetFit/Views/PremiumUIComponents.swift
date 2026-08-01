import SwiftUI

// MARK: - Matte Black Card Finish

struct MatteBlackCard: ViewModifier {
    let cornerRadius: CGFloat
    let accentColor: Color
    
    init(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.55, green: 0.88, blue: 1.00)) {
        self.cornerRadius = cornerRadius
        self.accentColor = accentColor
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.07, green: 0.07, blue: 0.09)) // Stealth Pure Matte Black
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(red: 0.16, green: 0.16, blue: 0.22), lineWidth: 1.0)
            )
            .shadow(color: Color.black.opacity(0.7), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func matteBlack(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.55, green: 0.88, blue: 1.00)) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    // Backwards compatibility aliases
    func liquidGlass(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.55, green: 0.88, blue: 1.00), liquidOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    func glassmorphic(cornerRadius: CGFloat = 18, glowColor: Color = Color(red: 0.55, green: 0.88, blue: 1.00), glowOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: glowColor))
    }
}

// MARK: - Realistic Neutral 3D Male Body Visualizer (No Neon Body, Direct Muscle Area Highlighting)

struct HolographicBodyVisualizer: View {
    let targetMuscles: [String]
    @State private var viewSelection: Int = 0 // 0: Front, 1: Rear
    @State private var isGlowPulsing = false
    
    let iceBlue = Color(red: 0.55, green: 0.88, blue: 1.00)
    
    private var isRearFocus: Bool {
        let lower = targetMuscles.map { $0.lowercased() }
        return lower.contains("back") || lower.contains("lats") || lower.contains("glutes") || lower.contains("hamstrings") || lower.contains("traps")
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Front / Rear View Selector
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "figure.arms.open")
                        .font(.caption)
                        .foregroundStyle(iceBlue)
                    
                    Text("3D Athletic Male Model")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    Button {
                        withAnimation { viewSelection = 0 }
                    } label: {
                        Text("FRONT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(viewSelection == 0 ? .black : Color.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewSelection == 0 ? iceBlue : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        withAnimation { viewSelection = 1 }
                    } label: {
                        Text("REAR")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(viewSelection == 1 ? .black : Color.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewSelection == 1 ? iceBlue : Color.clear)
                            .clipShape(Capsule())
                    }
                }
                .padding(2)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            
            // Realistic 3D Model Canvas with Direct Muscle Area Highlighting (No Text Labels)
            ZStack {
                // Background Tech Grid
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.05, green: 0.05, blue: 0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1.0)
                    )
                
                // Realistic Neutral 3D Athletic Male Body Asset
                if viewSelection == 0 {
                    Image("MaleBodyFront")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                } else {
                    Image("MaleBodyBack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                }
                
                // Direct Muscle Area Highlight Overlays (Pure Color Highlighting, Zero Text Overlays)
                muscleAreaHighlightOverlays(isFrontView: viewSelection == 0)
            }
            .frame(height: 250)
            
            // Muscle Legend Pills (Bottom Legend)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(targetMuscles, id: \.self) { muscle in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(MuscleGroupBadge.colorForMuscle(muscle))
                                .frame(width: 8, height: 8)
                                .shadow(color: MuscleGroupBadge.colorForMuscle(muscle), radius: 4)
                            
                            Text(muscle.capitalized)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .onAppear {
            if isRearFocus {
                viewSelection = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isGlowPulsing = true
            }
        }
    }
    
    // MARK: - Direct Muscle Area Highlight Overlays (No Text Labels over Body)
    
    @ViewBuilder
    private func muscleAreaHighlightOverlays(isFrontView: Bool) -> some View {
        ZStack {
            ForEach(targetMuscles, id: \.self) { muscle in
                let color = MuscleGroupBadge.colorForMuscle(muscle)
                
                switch (muscle.lowercased(), isFrontView) {
                // FRONT MUSCLE HIGHLIGHTS
                case ("quads", true), ("quadriceps", true), ("legs", true):
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 22, height: 50)
                            .shadow(color: color, radius: 10)
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 22, height: 50)
                            .shadow(color: color, radius: 10)
                    }
                    .offset(y: 42)
                    
                case ("chest", true), ("pectorals", true):
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 24, height: 22)
                            .shadow(color: color, radius: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 24, height: 22)
                            .shadow(color: color, radius: 10)
                    }
                    .offset(y: -44)
                    
                case ("core", true), ("abs", true):
                    VStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                                    .frame(width: 12, height: 8)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                                    .frame(width: 12, height: 8)
                            }
                        }
                    }
                    .shadow(color: color, radius: 8)
                    .offset(y: -18)
                    
                case ("shoulders", true), ("delts", true):
                    HStack(spacing: 50) {
                        Circle()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 18, height: 18)
                            .shadow(color: color, radius: 8)
                        Circle()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 18, height: 18)
                            .shadow(color: color, radius: 8)
                    }
                    .offset(y: -52)
                    
                case ("biceps", true), ("arms", true):
                    HStack(spacing: 54) {
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 12, height: 26)
                            .shadow(color: color, radius: 8)
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 12, height: 26)
                            .shadow(color: color, radius: 8)
                    }
                    .offset(y: -26)
                    
                // REAR MUSCLE HIGHLIGHTS
                case ("glutes", false):
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 24, height: 24)
                            .shadow(color: color, radius: 10)
                        Circle()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 24, height: 24)
                            .shadow(color: color, radius: 10)
                    }
                    .offset(y: -5)
                    
                case ("back", false), ("lats", false):
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 22, height: 32)
                            .shadow(color: color, radius: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 22, height: 32)
                            .shadow(color: color, radius: 10)
                    }
                    .offset(y: -36)
                    
                case ("traps", false):
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                        .frame(width: 40, height: 20)
                        .shadow(color: color, radius: 8)
                        .offset(y: -58)
                    
                case ("hamstrings", false):
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 20, height: 46)
                            .shadow(color: color, radius: 10)
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 20, height: 46)
                            .shadow(color: color, radius: 10)
                    }
                    .offset(y: 30)
                    
                case ("calves", false), ("calves", true):
                    HStack(spacing: 14) {
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 14, height: 36)
                            .shadow(color: color, radius: 8)
                        Capsule()
                            .fill(color.opacity(isGlowPulsing ? 0.55 : 0.40))
                            .frame(width: 14, height: 36)
                            .shadow(color: color, radius: 8)
                    }
                    .offset(y: 68)
                    
                default:
                    EmptyView()
                }
            }
        }
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
            ? [Color(red: 0.55, green: 0.88, blue: 1.00), Color(red: 0.20, green: 0.70, blue: 1.00)]
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

// MARK: - Vibrant High-Contrast Muscle Group Badge (Soft Ice Blue Accent)

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
            return Color(red: 0.55, green: 0.88, blue: 1.00) // Soft Ice Blue
        case "glutes":
            return Color(red: 1.00, green: 0.45, blue: 0.70) // Soft Neon Rose
        case "hamstrings":
            return Color(red: 0.90, green: 0.50, blue: 0.95) // Vivid Purple
        case "chest":
            return Color(red: 1.00, green: 0.40, blue: 0.48) // Crimson Rose
        case "back", "lats":
            return Color(red: 0.40, green: 0.75, blue: 1.00) // Soft Azure
        case "shoulders", "delts":
            return Color(red: 1.00, green: 0.65, blue: 0.25) // Warm Amber
        case "biceps":
            return Color(red: 0.35, green: 0.90, blue: 0.60) // Soft Emerald
        case "triceps":
            return Color(red: 0.80, green: 0.55, blue: 1.00) // Light Violet
        case "core", "abs":
            return Color(red: 1.00, green: 0.82, blue: 0.30) // Soft Gold
        case "calves":
            return Color(red: 0.30, green: 0.90, blue: 0.85) // Light Teal
        case "forearms":
            return Color(red: 0.75, green: 0.80, blue: 1.00) // Ice Indigo
        case "traps":
            return Color(red: 1.00, green: 0.55, blue: 0.40) // Sunset Coral
        default:
            return Color(red: 0.55, green: 0.88, blue: 1.00)
        }
    }
    
    var body: some View {
        Text(muscle.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.9)
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.16))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.45), lineWidth: 1.0)
            )
    }
}

// MARK: - Body Part Activation Card & Instructions

struct BodyPartActivationCard: View {
    let machineName: String
    let targetMuscles: [String]
    let instructions: String
    let equipmentType: String
    
    @State private var selectedTab: Int = 0 // 0: Gauges, 1: 3D Model
    let iceBlue = Color(red: 0.55, green: 0.88, blue: 1.00)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header & Segment Toggle
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.subheadline)
                    .foregroundStyle(iceBlue)
                
                Text("Body Part Activation & Form Guide")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Toggle between Gauges and 3D Hologram Model
                HStack(spacing: 2) {
                    Button {
                        withAnimation { selectedTab = 0 }
                    } label: {
                        Text("Gauges")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(selectedTab == 0 ? .black : Color.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedTab == 0 ? iceBlue : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        withAnimation { selectedTab = 1 }
                    } label: {
                        Text("3D Model")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(selectedTab == 1 ? .black : Color.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedTab == 1 ? iceBlue : Color.clear)
                            .clipShape(Capsule())
                    }
                }
                .padding(2)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            
            if selectedTab == 0 {
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
                                            .frame(width: geo.size.width * (CGFloat(percentage) / 100.0), height: 6)
                                            .shadow(color: color.opacity(0.4), radius: 3)
                                    }
                                }
                                .frame(height: 6)
                                
                                Text("\(percentage)%")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(color)
                                    .frame(width: 32, alignment: .trailing)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.05, green: 0.05, blue: 0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Realistic 3D Athletic Male Model Visualizer
                HolographicBodyVisualizer(targetMuscles: targetMuscles)
            }
            
            // Clean Step-by-Step Form & Execution Instructions
            let steps = parseInstructions(instructions, machineName: machineName, equipmentType: equipmentType)
            if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 Execution Tips:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 1.00, green: 0.82, blue: 0.30))
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 18, height: 18)
                                .background(iceBlue)
                                .clipShape(Circle())
                            
                            Text(step)
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(14)
        .matteBlack(cornerRadius: 16)
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
    func setCompletionEffect(isCompleted: Bool, accentColor: Color = Color(red: 0.55, green: 0.88, blue: 1.00)) -> some View {
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
    func shimmerGlow(color: Color = Color(red: 0.55, green: 0.88, blue: 1.00)) -> some View {
        self.modifier(ShimmerEffect(color: color))
    }
}
