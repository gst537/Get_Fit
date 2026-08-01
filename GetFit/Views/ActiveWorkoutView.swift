import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    let session: WorkoutSession
    let split: WorkoutSplit
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer?
    @State private var weightInputs: [UUID: Double] = [:]
    @State private var weightStrings: [UUID: String] = [:]
    @State private var repInputs: [UUID: Int] = [:]
    @State private var showRestTimer = false
    @State private var restDuration = 90
    @State private var showPlateCalculator = false
    @State private var calculatorTargetWeight: Double = 60.0
    
    // Interactive Progressive Overload Acceptance state
    @State private var acceptedOverloads: [UUID: Bool] = [:]
    
    @State private var showCardioFinisherSheet = false
    @State private var loggedCardioMinutes: Double? = nil
    @State private var loggedCardioDistance: Double? = nil
    @State private var showSummaryCard = false

    @Query(filter: #Predicate<SetLog> { $0.session != nil }) private var allSetLogs: [SetLog]
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted }) private var completedSessions: [WorkoutSession]

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
                .font(.body)
                .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                HStack(spacing: 8) {
                    ForEach(["Treadmill Run", "Stairmaster", "Rowing", "Cycling"], id: \.self) { act in
                        Text(act)
                            .font(.caption)
                            .fontWeight(finisherActivity == act ? .medium : .regular)
                            .foregroundStyle(finisherActivity == act ? .black : Color.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(finisherActivity == act ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                            .onTapGesture {
                                finisherActivity = act
                            }
                    }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (mins)")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    TextField("25", text: $finisherDuration)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Distance (km)")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    TextField("3.0", text: $finisherDistance)
                        .keyboardType(.decimalPad)
                        .font(.title3)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium])
    }
    
    private func exerciseCard(for entry: SplitMachineEntry, machine: GymMachine) -> some View {
        let rec = ProgressiveOverloadService.shared.calculateRecommendation(
            for: machine.name,
            equipmentType: machine.equipmentType,
            category: machine.category,
            defaultWeight: entry.defaultWeight,
            defaultReps: entry.defaultReps,
            completedSessions: completedSessions
        )
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(machine.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    if let muscles = entry.machine?.targetMuscles, !muscles.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(muscles.prefix(3), id: \.self) { muscle in
                                MuscleGroupBadge(muscle: muscle, color: MuscleGroupBadge.colorForMuscle(muscle))
                            }
                        }
                    }
                }
                Spacer()
                if machine.equipmentType.lowercased() == "barbell" {
                    Button(action: {
                        calculatorTargetWeight = weightInputs[machine.id] ?? weightUnit.displayWeight(entry.defaultWeight)
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
                HStack(spacing: 8) {
                    Text("Previous Best: \(weightUnit.formatNumber(weightUnit.displayWeight(best.weight))) \(weightUnit.unitLabel) × \(best.reps)")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                    
                    let currentInputWeight = weightUnit.toKg(weightInputs[machine.id] ?? 0)
                    if isPR(machineName: machine.name, currentWeight: currentInputWeight, allSessions: completedSessions) {
                        PRBadge(weight: "\(weightUnit.formatNumber(weightUnit.displayWeight(currentInputWeight))) \(weightUnit.unitLabel)")
                    }
                }
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
                            Text("\(weightUnit.formatNumber(weightUnit.displayWeight(log.weight))) \(weightUnit.unitLabel) × \(log.reps)")
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
                        .setCompletionEffect(isCompleted: true)
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // MARK: - Interactive Overload Banner
            if rec.isOverloadTriggered || rec.isDeloadTriggered {
                let isAccepted = acceptedOverloads[machine.id] ?? true
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: rec.isOverloadTriggered ? "sparkles" : "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundStyle(rec.isOverloadTriggered ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color.orange)
                        
                        Text(rec.isOverloadTriggered ? "Progressive Overload Target" : "Form & Recovery Reset")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(rec.isOverloadTriggered ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color.orange)
                    }
                    
                    Text(rec.reason)
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 10) {
                        Button {
                            // Accept Overload
                            acceptedOverloads[machine.id] = true
                            let displayRec = weightUnit.displayWeight(rec.recommendedWeight)
                            weightInputs[machine.id] = displayRec
                            weightStrings[machine.id] = weightUnit.formatNumber(displayRec)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isAccepted ? "checkmark.circle.fill" : "circle")
                                Text("Accept \(weightUnit.formatNumber(weightUnit.displayWeight(rec.recommendedWeight))) \(weightUnit.unitLabel)")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(isAccepted ? .black : Color(red: 0.68, green: 0.78, blue: 0.90))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isAccepted ? Color(red: 0.68, green: 0.78, blue: 0.90) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.68, green: 0.78, blue: 0.90), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            // Decline / Revert to original
                            acceptedOverloads[machine.id] = false
                            let displayPrev = weightUnit.displayWeight(rec.previousWeight)
                            weightInputs[machine.id] = displayPrev
                            weightStrings[machine.id] = weightUnit.formatNumber(displayPrev)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: !isAccepted ? "arrow.uturn.backward.circle.fill" : "arrow.uturn.backward")
                                Text("Keep \(weightUnit.formatNumber(weightUnit.displayWeight(rec.previousWeight))) \(weightUnit.unitLabel)")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(!isAccepted ? .white : Color.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(!isAccepted ? Color.gray.opacity(0.3) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.68, green: 0.78, blue: 0.90))
                    Text(rec.reason)
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
                    step: weightUnit.stepSize(for: machine.equipmentType)
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
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
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
        .glassmorphic(cornerRadius: 20)
    }
    
    private func incrementStep(for equipmentType: String) -> Double {
        return weightUnit.stepSize(for: equipmentType)
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
                    textValue.wrappedValue = weightUnit.formatNumber(cur - step)
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
                
                Text(weightUnit.unitLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                let cur = value.wrappedValue
                value.wrappedValue = cur + step
                textValue.wrappedValue = weightUnit.formatNumber(cur + step)
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
                let rec = ProgressiveOverloadService.shared.calculateRecommendation(
                    for: machine.name,
                    equipmentType: machine.equipmentType,
                    category: machine.category,
                    defaultWeight: entry.defaultWeight,
                    defaultReps: entry.defaultReps,
                    completedSessions: completedSessions
                )
                
                let initialWeightKg = rec.isOverloadTriggered ? rec.recommendedWeight : (rec.previousWeight > 0 ? rec.previousWeight : (entry.defaultWeight > 0 ? entry.defaultWeight : 20.0))
                let displayWeight = weightUnit.displayWeight(initialWeightKg)
                weightInputs[machine.id] = displayWeight
                weightStrings[machine.id] = weightUnit.formatNumber(displayWeight)
                repInputs[machine.id] = entry.defaultReps
                acceptedOverloads[machine.id] = rec.isOverloadTriggered
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
        let displayWeight = weightInputs[machine.id] ?? weightUnit.displayWeight(entry.defaultWeight)
        let weightInKg = weightUnit.toKg(displayWeight)
        let reps = repInputs[machine.id] ?? entry.defaultReps
        
        let newSet = SetLog(
            setNumber: loggedSetsCount + 1,
            reps: reps,
            weight: weightInKg,
            machineName: machine.name,
            machineId: machine.id,
            equipmentType: machine.equipmentType
        )
        
        newSet.session = session
        modelContext.insert(newSet)
        try? modelContext.save()
        
        // Trigger rest timer
        restDuration = 90
        showRestTimer = true
    }
    
    private func deleteSet(_ setLog: SetLog) {
        modelContext.delete(setLog)
        try? modelContext.save()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1.0
        }
    }

    private func finishWorkout() {
        session.isCompleted = true
        session.duration = elapsedTime
        try? modelContext.save()
        showSummaryCard = true
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatWeight(_ w: Double) -> String {
        w.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", w) : String(format: "%.1f", w)
    }
    
    // Check if current weight is a PR
    private func isPR(machineName: String, currentWeight: Double, allSessions: [WorkoutSession]) -> Bool {
        let previousMax = allSessions
            .flatMap { $0.setLogs }
            .filter { $0.machineName == machineName }
            .map { $0.weight }
            .max() ?? 0
        return currentWeight > previousMax && currentWeight > 0
    }
}
