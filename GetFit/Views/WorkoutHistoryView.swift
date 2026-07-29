import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }, sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    
    @State private var selectedSegment = 0
    @State private var selectedSession: WorkoutSession?
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
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
                        .font(.system(size: 44))
                        .fontWeight(.ultraLight)
                        .foregroundStyle(Color.gray.opacity(0.5))
                    
                    Text("No Completed Workouts Yet")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    Text("Start a workout from the dashboard to track your history.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sessions) { session in
                        Button(action: {
                            selectedSession = session
                        }) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.splitName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                        .font(.caption)
                                        .fontWeight(.light)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(Int(session.duration / 60)) min")
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                        .foregroundColor(.white)
                                    
                                    let tonnage = totalTonnage(for: session)
                                    if tonnage > 0 {
                                        Text(String(format: "%.1f kg", tonnage))
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundColor(paleBlue)
                                    }
                                }
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.gray.opacity(0.4))
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(uiColor: .systemBackground))
                        .listRowSeparatorTint(Color.gray.opacity(0.25))
                    }
                    .onDelete(perform: deleteSessions)
                }
                .listStyle(.plain)
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
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    @State private var showSummaryGraphic = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Date")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                            Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                .font(.body)
                                .fontWeight(.regular)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Duration")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                            Text("\(Int(session.duration / 60)) min")
                                .font(.body)
                                .fontWeight(.regular)
                        }
                    }
                    HStack {
                        Text("Total Tonnage")
                            .font(.body)
                            .fontWeight(.light)
                        Spacer()
                        Text(String(format: "%.1f kg", totalTonnage))
                            .font(.headline)
                            .foregroundColor(paleBlue)
                    }
                }
                .listRowBackground(Color(uiColor: .secondarySystemBackground))
                
                let groupedSets = Dictionary(grouping: session.setLogs, by: { $0.machineName })
                ForEach(groupedSets.keys.sorted(), id: \.self) { machineName in
                    Section(header: Text(machineName).font(.subheadline).fontWeight(.medium).foregroundColor(paleBlue)) {
                        let sets = groupedSets[machineName]!.sorted(by: { $0.setNumber < $1.setNumber })
                        ForEach(sets) { setLog in
                            HStack {
                                Text("Set \(setLog.setNumber)")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                Spacer()
                                Text("\(formatWeight(setLog.weight)) kg × \(setLog.reps)")
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                            }
                            .listRowBackground(Color(uiColor: .systemBackground))
                            .listRowSeparatorTint(Color.gray.opacity(0.25))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(session.splitName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(paleBlue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showSummaryGraphic = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(paleBlue)
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
