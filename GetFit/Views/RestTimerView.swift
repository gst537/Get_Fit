import SwiftUI

struct RestTimerView: View {
    let duration: Int  // seconds
    let onComplete: () -> Void
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var selectedDuration: Int
    @Environment(\.dismiss) private var dismiss

    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        _timeRemaining = State(initialValue: duration)
        _selectedDuration = State(initialValue: duration)
    }
    
    var progress: Double {
        return Double(timeRemaining) / Double(selectedDuration)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Rest")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(red: 0.68, green: 0.78, blue: 0.90), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: progress)
                    
                    Text(String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.system(size: 56))
                        .monospacedDigit()
                        .fontWeight(.ultraLight)
                        .foregroundColor(.white)
                }
                .frame(width: 200, height: 200)
                
                HStack(spacing: 16) {
                    ForEach([60, 90, 120], id: \.self) { sec in
                        Button(action: {
                            selectedDuration = sec
                            timeRemaining = sec
                            RestTimerActivityManager.shared.startActivity(duration: sec)
                        }) {
                            Text("\(sec)s")
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDuration == sec ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(selectedDuration == sec ? .black : .gray)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Button(action: {
                    timer?.invalidate()
                    RestTimerActivityManager.shared.endActivity()
                    dismiss()
                    onComplete()
                }) {
                    Text("Skip")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color(red: 0.68, green: 0.78, blue: 0.90))
                }
            }
        }
        .onAppear {
            startCountdown()
            RestTimerActivityManager.shared.startActivity(duration: timeRemaining)
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
