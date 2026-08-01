import SwiftUI

// MARK: - Matte Black Finish Card Modifier

struct MatteBlackCard: ViewModifier {
    let cornerRadius: CGFloat
    let accentColor: Color
    
    init(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.20, green: 0.85, blue: 1.00)) {
        self.cornerRadius = cornerRadius
        self.accentColor = accentColor
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.09, green: 0.09, blue: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(red: 0.18, green: 0.18, blue: 0.24), lineWidth: 1.0)
            )
            .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func matteBlack(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.20, green: 0.85, blue: 1.00)) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    // Backwards compatibility aliases
    func liquidGlass(cornerRadius: CGFloat = 18, accentColor: Color = Color(red: 0.20, green: 0.85, blue: 1.00), liquidOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: accentColor))
    }
    
    func glassmorphic(cornerRadius: CGFloat = 18, glowColor: Color = Color(red: 0.20, green: 0.85, blue: 1.00), glowOpacity: Double = 0.12) -> some View {
        self.modifier(MatteBlackCard(cornerRadius: cornerRadius, accentColor: glowColor))
    }
}

// MARK: - Holographic Human Body Visualizer

struct HolographicBodyVisualizer: View {
    let targetMuscles: [String]
    @State private var isPulseGlow = false
    
    private var normalizedMuscles: Set<String> {
        Set(targetMuscles.map { $0.lowercased() })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Holographic Background Grid & Glow
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.05, green: 0.07, blue: 0.11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.00, green: 0.70, blue: 1.00).opacity(0.25), lineWidth: 1.0)
                    )
                
                // Holographic Grid Lines
                VStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
                        Divider().background(Color(red: 0.00, green: 0.70, blue: 1.00).opacity(0.06))
                    }
                }
                
                // Cyber 2D Anatomical Body Silhouette
                HStack(spacing: 24) {
                    // Front View Silhouette
                    bodyFrontSilhouette
                    
                    // Rear View Silhouette
                    bodyRearSilhouette
                }
                .padding(.vertical, 16)
            }
            .frame(height: 210)
            
            // Target Muscle Legend Badges
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
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulseGlow = true
            }
        }
    }
    
    // MARK: - Front Body Silhouette
    
    private var bodyFrontSilhouette: some View {
        VStack(spacing: 3) {
            Text("FRONT")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Color(red: 0.00, green: 0.85, blue: 1.00).opacity(0.7))
            
            ZStack {
                // Head
                Circle()
                    .stroke(Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                    .offset(y: -75)
                
                // Shoulders / Delts
                let isDeltsActive = normalizedMuscles.contains("shoulders") || normalizedMuscles.contains("delts")
                HStack(spacing: 42) {
                    Circle()
                        .fill(isDeltsActive ? MuscleGroupBadge.colorForMuscle("shoulders") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 14, height: 14)
                        .shadow(color: isDeltsActive ? MuscleGroupBadge.colorForMuscle("shoulders") : .clear, radius: 6)
                    Circle()
                        .fill(isDeltsActive ? MuscleGroupBadge.colorForMuscle("shoulders") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 14, height: 14)
                        .shadow(color: isDeltsActive ? MuscleGroupBadge.colorForMuscle("shoulders") : .clear, radius: 6)
                }
                .offset(y: -52)
                
                // Chest / Pectorals
                let isChestActive = normalizedMuscles.contains("chest") || normalizedMuscles.contains("pectorals")
                RoundedRectangle(cornerRadius: 6)
                    .fill(isChestActive ? MuscleGroupBadge.colorForMuscle("chest") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                    .frame(width: 38, height: 18)
                    .shadow(color: isChestActive ? MuscleGroupBadge.colorForMuscle("chest") : .clear, radius: 8)
                    .offset(y: -44)
                
                // Biceps
                let isBicepsActive = normalizedMuscles.contains("biceps") || normalizedMuscles.contains("arms")
                HStack(spacing: 44) {
                    Capsule()
                        .fill(isBicepsActive ? MuscleGroupBadge.colorForMuscle("biceps") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 10, height: 22)
                        .shadow(color: isBicepsActive ? MuscleGroupBadge.colorForMuscle("biceps") : .clear, radius: 6)
                    Capsule()
                        .fill(isBicepsActive ? MuscleGroupBadge.colorForMuscle("biceps") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 10, height: 22)
                        .shadow(color: isBicepsActive ? MuscleGroupBadge.colorForMuscle("biceps") : .clear, radius: 6)
                }
                .offset(y: -30)
                
                // Core / Abs
                let isCoreActive = normalizedMuscles.contains("core") || normalizedMuscles.contains("abs")
                VStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isCoreActive ? MuscleGroupBadge.colorForMuscle("core") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                            .frame(width: 22, height: 6)
                            .shadow(color: isCoreActive ? MuscleGroupBadge.colorForMuscle("core") : .clear, radius: 6)
                    }
                }
                .offset(y: -22)
                
                // Quads / Quadriceps
                let isQuadsActive = normalizedMuscles.contains("quads") || normalizedMuscles.contains("quadriceps") || normalizedMuscles.contains("legs")
                HStack(spacing: 6) {
                    Capsule()
                        .fill(isQuadsActive ? MuscleGroupBadge.colorForMuscle("quads") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 16, height: 42)
                        .shadow(color: isQuadsActive ? MuscleGroupBadge.colorForMuscle("quads") : .clear, radius: 8)
                    Capsule()
                        .fill(isQuadsActive ? MuscleGroupBadge.colorForMuscle("quads") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 16, height: 42)
                        .shadow(color: isQuadsActive ? MuscleGroupBadge.colorForMuscle("quads") : .clear, radius: 8)
                }
                .offset(y: 10)
                
                // Calves
                let isCalvesActive = normalizedMuscles.contains("calves")
                HStack(spacing: 10) {
                    Capsule()
                        .fill(isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 11, height: 32)
                        .shadow(color: isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : .clear, radius: 6)
                    Capsule()
                        .fill(isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 11, height: 32)
                        .shadow(color: isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : .clear, radius: 6)
                }
                .offset(y: 52)
            }
            .frame(width: 90, height: 160)
        }
    }
    
    // MARK: - Rear Body Silhouette
    
    private var bodyRearSilhouette: some View {
        VStack(spacing: 3) {
            Text("REAR")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Color(red: 0.00, green: 0.85, blue: 1.00).opacity(0.7))
            
            ZStack {
                // Head
                Circle()
                    .stroke(Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                    .offset(y: -75)
                
                // Traps / Upper Back
                let isTrapsActive = normalizedMuscles.contains("traps") || normalizedMuscles.contains("back")
                RoundedRectangle(cornerRadius: 6)
                    .fill(isTrapsActive ? MuscleGroupBadge.colorForMuscle("traps") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                    .frame(width: 36, height: 16)
                    .shadow(color: isTrapsActive ? MuscleGroupBadge.colorForMuscle("traps") : .clear, radius: 6)
                    .offset(y: -52)
                
                // Lats / Back
                let isBackActive = normalizedMuscles.contains("back") || normalizedMuscles.contains("lats")
                RoundedRectangle(cornerRadius: 8)
                    .fill(isBackActive ? MuscleGroupBadge.colorForMuscle("back") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                    .frame(width: 38, height: 24)
                    .shadow(color: isBackActive ? MuscleGroupBadge.colorForMuscle("back") : .clear, radius: 8)
                    .offset(y: -36)
                
                // Triceps
                let isTricepsActive = normalizedMuscles.contains("triceps")
                HStack(spacing: 44) {
                    Capsule()
                        .fill(isTricepsActive ? MuscleGroupBadge.colorForMuscle("triceps") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 10, height: 22)
                        .shadow(color: isTricepsActive ? MuscleGroupBadge.colorForMuscle("triceps") : .clear, radius: 6)
                    Capsule()
                        .fill(isTricepsActive ? MuscleGroupBadge.colorForMuscle("triceps") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 10, height: 22)
                        .shadow(color: isTricepsActive ? MuscleGroupBadge.colorForMuscle("triceps") : .clear, radius: 6)
                }
                .offset(y: -30)
                
                // Glutes
                let isGlutesActive = normalizedMuscles.contains("glutes")
                HStack(spacing: 4) {
                    Circle()
                        .fill(isGlutesActive ? MuscleGroupBadge.colorForMuscle("glutes") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 18, height: 18)
                        .shadow(color: isGlutesActive ? MuscleGroupBadge.colorForMuscle("glutes") : .clear, radius: 8)
                    Circle()
                        .fill(isGlutesActive ? MuscleGroupBadge.colorForMuscle("glutes") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 18, height: 18)
                        .shadow(color: isGlutesActive ? MuscleGroupBadge.colorForMuscle("glutes") : .clear, radius: 8)
                }
                .offset(y: -14)
                
                // Hamstrings
                let isHamstringsActive = normalizedMuscles.contains("hamstrings") || normalizedMuscles.contains("legs")
                HStack(spacing: 6) {
                    Capsule()
                        .fill(isHamstringsActive ? MuscleGroupBadge.colorForMuscle("hamstrings") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 15, height: 38)
                        .shadow(color: isHamstringsActive ? MuscleGroupBadge.colorForMuscle("hamstrings") : .clear, radius: 8)
                    Capsule()
                        .fill(isHamstringsActive ? MuscleGroupBadge.colorForMuscle("hamstrings") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.25))
                        .frame(width: 15, height: 38)
                        .shadow(color: isHamstringsActive ? MuscleGroupBadge.colorForMuscle("hamstrings") : .clear, radius: 8)
                }
                .offset(y: 14)
                
                // Calves Rear
                let isCalvesActive = normalizedMuscles.contains("calves")
                HStack(spacing: 10) {
                    Capsule()
                        .fill(isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 11, height: 32)
                        .shadow(color: isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : .clear, radius: 6)
                    Capsule()
                        .fill(isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : Color(red: 0.00, green: 0.80, blue: 1.00).opacity(0.2))
                        .frame(width: 11, height: 32)
                        .shadow(color: isCalvesActive ? MuscleGroupBadge.colorForMuscle("calves") : .clear, radius: 6)
                }
                .offset(y: 52)
            }
            .frame(width: 90, height: 160)
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
    
    @State private var selectedTab: Int = 0 // 0: Gauges, 1: Hologram Model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header & Segment Toggle
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.20, green: 0.85, blue: 1.00))
                
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedTab == 0 ? Color(red: 0.20, green: 0.85, blue: 1.00) : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        withAnimation { selectedTab = 1 }
                    } label: {
                        Text("3D Model")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(selectedTab == 1 ? .black : Color.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedTab == 1 ? Color(red: 0.20, green: 0.85, blue: 1.00) : Color.clear)
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
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Holographic Cyber-Blue Human Body Visualizer
                HolographicBodyVisualizer(targetMuscles: targetMuscles)
            }
            
            // Clean Step-by-Step Form & Execution Instructions (Fixes incomplete lines bug!)
            let steps = parseInstructions(instructions, machineName: machineName, equipmentType: equipmentType)
            if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Execution Tips:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 1.00, green: 0.78, blue: 0.20))
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 18, height: 18)
                                .background(Color(red: 0.20, green: 0.85, blue: 1.00))
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
    
    // Clean instruction parsing logic that fixes single-digit fragments & provides smart fallbacks
    private func parseInstructions(_ text: String, machineName: String, equipmentType: String) -> [String] {
        var rawSentences: [String] = []
        
        // Split by lines or periods followed by spaces
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
            // Strip leading numbers/bullets like "1.", "1)", "(1)", "•", "-"
            if let range = str.range(of: #"^\(?\d+[\.\)\s\-]+"#, options: .regularExpression) {
                str.removeSubrange(range)
            }
            str = str.replacingOccurrences(of: "•", with: "")
                     .replacingOccurrences(of: "-", with: "")
                     .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Only keep meaningful sentences (> 6 characters)
            if str.count > 6 {
                if !str.hasSuffix(".") && !str.hasSuffix("!") {
                    str += "."
                }
                cleanedSteps.append(str)
            }
        }
        
        // Smart fallback guidelines if exercise instructions are missing or short
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
                    "Maintain a stable 3-point stance on the bench with core tight.",
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
