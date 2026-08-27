import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }, sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    @State private var selectedSegment = 0
    @State private var selectedSession: WorkoutSession?
    
    let slateBlue = MutedEarth.slateBlue
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedSegment) {
                Text("Logs").tag(0)
                Text("Volume Analytics").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedSegment == 0 {
                logsView
            } else {
                MuscleVolumeAnalyticsView()
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session)
        }
    }
    
    private var logsView: some View {
        VStack(spacing: 0) {
            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color.gray.opacity(0.5))
                    
                    Text("No Completed Workouts Yet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Start a workout from the dashboard to track your history.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sessions) { session in
                            Button(action: {
                                selectedSession = session
                            }) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.splitName)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(Int(session.duration / 60)) min")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white)
                                        
                                        let tonnage = totalTonnage(for: session)
                                        if tonnage > 0 {
                                            Text(weightUnit.formatWeight(tonnage))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(slateBlue)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.gray.opacity(0.4))
                                }
                                .padding()
                                .background(Color.black)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                        }
                    }
                }
            }
        }
    }
    
    private func totalTonnage(for session: WorkoutSession) -> Double {
        session.setLogs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
        try? modelContext.save()
    }
}

struct SessionDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession
    let slateBlue = MutedEarth.slateBlue
    @StateObject private var weightUnit = WeightUnitManager.shared
    @State private var showSummaryGraphic = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Duration")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("\(Int(session.duration / 60)) min")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        HStack {
                            Text("Total Tonnage")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text(weightUnit.formatWeight(totalTonnage))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(slateBlue)
                        }
                    }
                    .padding()
                    .monochromeCard()
                    .padding(.horizontal)
                    
                    let groupedSets = Dictionary(grouping: session.setLogs, by: { $0.machineName })
                    ForEach(groupedSets.keys.sorted(), id: \.self) { machineName in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(machineName.uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(slateBlue)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                let sets = groupedSets[machineName]!.sorted(by: { $0.setNumber < $1.setNumber })
                                ForEach(sets) { setLog in
                                    HStack {
                                        Text("Set \(setLog.setNumber)")
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                        Text("\(weightUnit.formatNumber(setLog.weight)) \(weightUnit.unitLabel) × \(setLog.reps)")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding()
                                    .background(Color.black)
                                    
                                    if setLog.id != sets.last?.id {
                                        Divider().background(Color.white.opacity(0.2))
                                    }
                                }
                            }
                            .border(Color.white.opacity(0.2), width: 1.0)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(session.splitName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(slateBlue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: 16) {
                        Button {
                            modelContext.delete(session)
                            try? modelContext.save()
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(MutedEarth.terracotta)
                        }
                        
                        Button {
                            showSummaryGraphic = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(slateBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSummaryGraphic) {
                WorkoutSummaryCardView(session: session)
            }
            .background(Color(uiColor: .systemBackground))
        }
    }
    
    private var totalTonnage: Double {
        session.setLogs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutSession.self, SetLog.self, GymMachine.self, configurations: config)
        return NavigationStack {
            WorkoutHistoryView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    } catch {
        fatalError("Failed to create model container.")
    }
}
