import SwiftUI

struct RestTimerView: View {
    let duration: Int  // seconds
    let exerciseName: String
    let currentSet: Int
    let totalSets: Int
    let onComplete: () -> Void
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var selectedDuration: Int
    @Environment(\.dismiss) private var dismiss

    init(duration: Int, exerciseName: String = "Rest", currentSet: Int = 0, totalSets: Int = 0, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.exerciseName = exerciseName
        self.currentSet = currentSet
        self.totalSets = totalSets
        self.onComplete = onComplete
        _timeRemaining = State(initialValue: duration)
        _selectedDuration = State(initialValue: duration)
    }
    
    var progress: Double {
        return Double(timeRemaining) / Double(selectedDuration)
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.15), PremiumColors.deepBlack]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("Rest Timer")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.starkWhite)
                    
                    Text("\(exerciseName) • Set \(currentSet)/\(totalSets)")
                        .font(PremiumFonts.body)
                        .foregroundStyle(PremiumColors.midGray)
                }
                
                ZStack {
                    Circle()
                        .stroke(PremiumColors.glassBorder.opacity(0.5), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [PremiumColors.neonCyan, PremiumColors.neonCyan.opacity(0.5)]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: progress)
                        .shadow(color: PremiumColors.neonCyan.opacity(0.6), radius: 10)
                    
                    Text(String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(PremiumColors.starkWhite)
                }
                .frame(width: 240, height: 240)
                
                HStack(spacing: 16) {
                    ForEach([60, 90, 120], id: \.self) { sec in
                        Button(action: {
                            selectedDuration = sec
                            timeRemaining = sec
                            RestTimerActivityManager.shared.startActivity(duration: sec, exerciseName: exerciseName, currentSet: currentSet, totalSets: totalSets, isResting: true)
                        }) {
                            Text("\(sec)s")
                                .font(PremiumFonts.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(selectedDuration == sec ? PremiumColors.neonCyan : PremiumColors.glassBackground)
                                .foregroundStyle(selectedDuration == sec ? PremiumColors.deepBlack : PremiumColors.starkWhite)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(selectedDuration == sec ? PremiumColors.neonCyan : PremiumColors.glassBorder, lineWidth: 1))
                                .shadow(color: selectedDuration == sec ? PremiumColors.neonCyan.opacity(0.4) : .clear, radius: 4)
                        }
                    }
                }
                
                Button(action: {
                    timer?.invalidate()
                    RestTimerActivityManager.shared.endActivity()
                    dismiss()
                    onComplete()
                }) {
                    Text("Skip Timer")
                        .font(PremiumFonts.headline)
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            startCountdown()
            RestTimerActivityManager.shared.startActivity(duration: timeRemaining, exerciseName: exerciseName, currentSet: currentSet, totalSets: totalSets, isResting: true)
        }
        .onDisappear {
            RestTimerActivityManager.shared.endActivity()
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    RestTimerActivityManager.shared.endActivity()
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    dismiss()
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    RestTimerView(duration: 90, onComplete: {})
}
