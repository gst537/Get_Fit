import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    let session: WorkoutSession
    let split: WorkoutSplit
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer?
    @State private var weightInputs: [UUID: Double] = [:]
    @State private var weightStrings: [UUID: String] = [:]
    @State private var repInputs: [UUID: Int] = [:]
    @State private var showRestTimer = false
    @State private var restDuration = 90
    @State private var showPlateCalculator = false
    @State private var calculatorTargetWeight: Double = 60.0
    
    @State private var showCardioFinisherSheet = false
    @State private var loggedCardioMinutes: Double? = nil
    @State private var loggedCardioDistance: Double? = nil
    @State private var showSummaryCard = false

    @Query(filter: #Predicate<SetLog> { $0.session != nil }) private var allSetLogs: [SetLog]

    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    let sortedEntries = split.entries.sorted { $0.order < $1.order }
                    ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        if let machine = entry.machine {
                            VStack(spacing: 16) {
                                exerciseCard(for: entry, machine: machine)
                                
                                if index < sortedEntries.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.25))
                                        .frame(height: 0.5)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    
                    // Optional Cardio Finisher Card
                    cardioFinisherCard
                        .padding(.top, 12)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            startTimer()
            initializeInputs()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .fullScreenCover(isPresented: $showRestTimer) {
            RestTimerView(duration: restDuration, onComplete: {
                showRestTimer = false
            })
        }
        .sheet(isPresented: $showPlateCalculator) {
            PlateCalculatorSheet(targetWeight: calculatorTargetWeight)
        }
        .sheet(isPresented: $showCardioFinisherSheet) {
            cardioFinisherSheet
        }
        .sheet(isPresented: $showSummaryCard, onDismiss: {
            dismiss()
        }) {
            WorkoutSummaryCardView(session: session)
        }
    }
    
    // MARK: - Cardio Finisher Card & Sheet
    
    private var cardioFinisherCard: some View {
        Button {
            showCardioFinisherSheet = true
        } label: {
            HStack {
                Image(systemName: "figure.run")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                
                VStack(alignment: .leading, spacing: 2) {
                    if let mins = loggedCardioMinutes {
                        Text("Cardio Finisher Logged ✓")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                        Text("\(Int(mins)) min · \(String(format: "%.1f km", loggedCardioDistance ?? 0))")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    } else {
                        Text("Add Cardio Finisher")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        Text("Optional 20-30 min Treadmill, Stairmaster, or Run")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: loggedCardioMinutes != nil ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        }
    }
    
    @State private var finisherActivity = "Treadmill Run"
    @State private var finisherDuration = "25"
    @State private var finisherDistance = "3.0"
    
    private var cardioFinisherSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Cardio Finisher")
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                Spacer()
                Button("Done") {
                    let dur = Double(finisherDuration) ?? 25.0
                    let dist = Double(finisherDistance) ?? 0.0
                    loggedCardioMinutes = dur
                    loggedCardioDistance = dist
                    
                    let log = CardioLog(
                        activityType: finisherActivity,
                        durationMinutes: dur,
                        distanceKm: dist,
                        date: session.date
                    )
                    modelContext.insert(log)
                    try? modelContext.save()
                    showCardioFinisherSheet = false
                }
                .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Treadmill Run", "Stairmaster", "Cycling", "Rowing", "Outdoor Run"], id: \.self) { type in
                            Text(type)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(finisherActivity == type ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                                .foregroundStyle(finisherActivity == type ? .black : .gray)
                                .clipShape(Capsule())
                                .onTapGesture { finisherActivity = type }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration (Minutes)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                TextField("Duration", text: $finisherDuration)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Distance (km)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                TextField("Distance", text: $finisherDistance)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium])
    }
    
    private func exerciseCard(for entry: SplitMachineEntry, machine: GymMachine) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(machine.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                if machine.equipmentType.lowercased() == "barbell" {
                    Button(action: {
                        calculatorTargetWeight = weightInputs[machine.id] ?? entry.defaultWeight
                        showPlateCalculator = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.forwardslash.minus")
                            Text("Plates")
                        }
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    }
                    .padding(.trailing, 8)
                }
                Text(machine.equipmentType)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let best = previousBest(for: machine.id) {
                Text("Previous Best: \(formatWeight(best.weight)) kg × \(best.reps)")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            }
            
            let loggedSets = loggedSets(for: machine.id)
            if !loggedSets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(loggedSets.indices, id: \.self) { idx in
                        let log = loggedSets[idx]
                        HStack {
                            Text("Set \(idx + 1)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(formatWeight(log.weight)) kg × \(log.reps)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Button(action: {
                                deleteSet(log)
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if let suggestion = progressiveOverloadSuggestion(for: machine, entry: entry) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    Text(suggestion)
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.68, green: 0.78, blue: 0.90).opacity(0.12))
                .clipShape(Capsule())
            }
            
            HStack {
                stepperControl(
                    value: Binding(
                        get: { weightInputs[machine.id] ?? 0.0 },
                        set: { weightInputs[machine.id] = $0 }
                    ),
                    textValue: Binding(
                        get: { weightStrings[machine.id] ?? "" },
                        set: { newValue in
                            weightStrings[machine.id] = newValue
                            if let parsed = Double(newValue) {
                                weightInputs[machine.id] = parsed
                            }
                        }
                    ),
                    step: incrementStep(for: machine.equipmentType)
                )
                
                Text("×")
                    .foregroundColor(.gray)
                
                stepperControlInt(
                    value: Binding(
                        get: { repInputs[machine.id] ?? 0 },
                        set: { repInputs[machine.id] = $0 }
                    ),
                    step: 1
                )
                
                Spacer()
                
                Button(action: {
                    logSet(for: entry, machine: machine, loggedSetsCount: loggedSets.count)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color(red: 0.68, green: 0.78, blue: 0.90))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
    }
    
    private func progressiveOverloadSuggestion(for machine: GymMachine, entry: SplitMachineEntry) -> String? {
        if let best = previousBest(for: machine.id) {
            if machine.equipmentType.lowercased() == "bodyweight" {
                return "✨ Overload Target: \(best.reps + 1) reps"
            } else {
                return "✨ Overload Target: \(formatWeight(best.weight + 2.5)) kg"
            }
        } else if entry.defaultWeight > 0 {
            return "✨ Overload Target: \(formatWeight(entry.defaultWeight)) kg"
        }
        return nil
    }
    
    private func incrementStep(for equipmentType: String) -> Double {
        switch equipmentType.lowercased() {
        case "barbell": return 5.0
        case "dumbbell": return 2.5
        case "cable": return 2.5
        case "machine": return 5.0
        default: return 2.5
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(split.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(formatTime(elapsedTime))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
            
            Spacer()
            
            Button(action: {
                finishWorkout()
            }) {
                Text("Finish")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func stepperControl(value: Binding<Double>, textValue: Binding<String>, step: Double) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                let cur = value.wrappedValue
                if cur >= step {
                    value.wrappedValue = cur - step
                    textValue.wrappedValue = formatWeight(cur - step)
                } else if cur > 0 {
                    value.wrappedValue = 0
                    textValue.wrappedValue = "0"
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
            
            HStack(spacing: 2) {
                TextField("0", text: textValue)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 44)
                
                Text("kg")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                let cur = value.wrappedValue
                value.wrappedValue = cur + step
                textValue.wrappedValue = formatWeight(cur + step)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .frame(width: 28, height: 28)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
    
    private func stepperControlInt(value: Binding<Int>, step: Int) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if value.wrappedValue >= step {
                    value.wrappedValue -= step
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
            
            Text("\(value.wrappedValue) reps")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 60)
            
            Button(action: {
                value.wrappedValue += step
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.68, green: 0.78, blue: 0.90))
                    .frame(width: 28, height: 28)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
    
    private func initializeInputs() {
        for entry in split.entries {
            if let machine = entry.machine {
                let defaultW = entry.defaultWeight > 0 ? entry.defaultWeight : (previousBest(for: machine.id)?.weight ?? 0.0)
                weightInputs[machine.id] = defaultW
                weightStrings[machine.id] = formatWeight(defaultW)
                repInputs[machine.id] = entry.defaultReps
            }
        }
    }

    private func loggedSets(for machineId: UUID) -> [SetLog] {
        return session.setLogs.filter { $0.machineId == machineId }.sorted { $0.setNumber < $1.setNumber }
    }

    private func previousBest(for machineId: UUID) -> SetLog? {
        let matching = allSetLogs.filter { $0.machineId == machineId && $0.session?.id != session.id }
        return matching.max(by: { $0.weight < $1.weight })
    }

    private func logSet(for entry: SplitMachineEntry, machine: GymMachine, loggedSetsCount: Int) {
        let weight = weightInputs[machine.id] ?? 0.0
        let reps = repInputs[machine.id] ?? entry.defaultReps
        
        let newSet = SetLog(
            setNumber: loggedSetsCount + 1,
            reps: reps,
            weight: weight,
            machineName: machine.name,
            machineId: machine.id,
            equipmentType: machine.equipmentType
        )
        newSet.session = session
        modelContext.insert(newSet)
        try? modelContext.save()

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        restDuration = 90
        showRestTimer = true
    }

    private func deleteSet(_ setLog: SetLog) {
        modelContext.delete(setLog)
        try? modelContext.save()
    }

    private func finishWorkout() {
        session.isCompleted = true
        session.duration = elapsedTime
        try? modelContext.save()
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        showSummaryCard = true
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                elapsedTime += 1
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}
