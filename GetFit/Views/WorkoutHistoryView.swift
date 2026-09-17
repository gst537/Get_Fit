import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true }, sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @StateObject private var weightUnit = WeightUnitManager.shared
    
    @State private var selectedSegment = 0
    @State private var selectedSession: WorkoutSession?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.15), PremiumColors.deepBlack]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Workout History")
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.starkWhite)
                    Spacer()
                }
                .padding()
                
                // Custom Segmented Control
                HStack(spacing: 0) {
                    Button {
                        selectedSegment = 0
                    } label: {
                        Text("Logs")
                            .font(PremiumFonts.headline)
                            .foregroundStyle(selectedSegment == 0 ? PremiumColors.deepBlack : PremiumColors.starkWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedSegment == 0 ? PremiumColors.neonCyan : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        selectedSegment = 1
                    } label: {
                        Text("Analytics")
                            .font(PremiumFonts.headline)
                            .foregroundStyle(selectedSegment == 1 ? PremiumColors.deepBlack : PremiumColors.starkWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedSegment == 1 ? PremiumColors.neonCyan : Color.clear)
                            .clipShape(Capsule())
                    }
                }
                .padding(4)
                .background(PremiumColors.glassBackground)
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                if selectedSegment == 0 {
                    logsView
                } else {
                    MuscleVolumeAnalyticsView()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session)
        }
    }
    
    private var logsView: some View {
        VStack(spacing: 0) {
            if sessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(PremiumColors.midGray)
                    
                    Text("No Workout Data")
                        .font(PremiumFonts.headline)
                        .foregroundStyle(PremiumColors.starkWhite)
                    
                    Text("Complete a session to see your history.")
                        .font(PremiumFonts.caption)
                        .foregroundStyle(PremiumColors.midGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(sessions) { session in
                            Button(action: {
                                selectedSession = session
                            }) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(session.splitName)
                                            .font(PremiumFonts.headline)
                                            .foregroundColor(PremiumColors.starkWhite)
                                        
                                        Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                            .font(PremiumFonts.caption)
                                            .foregroundColor(PremiumColors.midGray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("\(Int(session.duration / 60)) min")
                                            .font(PremiumFonts.caption)
                                            .foregroundColor(PremiumColors.starkWhite)
                                        
                                        let tonnage = totalTonnage(for: session)
                                        if tonnage > 0 {
                                            Text(weightUnit.formatWeight(tonnage))
                                                .font(PremiumFonts.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(PremiumColors.neonCyan)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(PremiumColors.midGray)
                                }
                                .padding(16)
                                .glassmorphic(cornerRadius: 16)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(session)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete Record", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private func totalTonnage(for session: WorkoutSession) -> Double {
        session.setLogs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}

struct SessionDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession
    @StateObject private var weightUnit = WeightUnitManager.shared
    @State private var showSummaryGraphic = false
    
    var body: some View {
        ZStack {
            // Background
            PremiumColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                HStack {
                    Text(session.splitName)
                        .font(PremiumFonts.title)
                        .foregroundStyle(PremiumColors.starkWhite)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(PremiumColors.midGray)
                    }
                }
                .padding()
                
                HStack(spacing: 16) {
                    Spacer()
                    Button {
                        showSummaryGraphic = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Share")
                        }
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(PremiumColors.neonCyan.opacity(0.2))
                        .foregroundStyle(PremiumColors.neonCyan)
                        .clipShape(Capsule())
                    }
                    
                    Button {
                        modelContext.delete(session)
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                            Text("Delete")
                        }
                        .font(PremiumFonts.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(Color.red)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Date & Time")
                                        .font(PremiumFonts.caption)
                                        .foregroundColor(PremiumColors.midGray)
                                    Text(session.date, format: .dateTime.month().day().year().hour().minute())
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(PremiumColors.starkWhite)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("Duration")
                                        .font(PremiumFonts.caption)
                                        .foregroundColor(PremiumColors.midGray)
                                    Text("\(Int(session.duration / 60)) min")
                                        .font(PremiumFonts.headline)
                                        .foregroundStyle(PremiumColors.starkWhite)
                                }
                            }
                            
                            Divider().background(PremiumColors.glassBorder)
                            
                            HStack {
                                Text("Total Volume")
                                    .font(PremiumFonts.headline)
                                    .foregroundStyle(PremiumColors.starkWhite)
                                Spacer()
                                Text(weightUnit.formatWeight(totalTonnage))
                                    .font(PremiumFonts.title)
                                    .foregroundColor(PremiumColors.neonCyan)
                            }
                        }
                        .padding(16)
                        .glassmorphic(cornerRadius: 16)
                        .padding(.horizontal)
                        
                        let groupedSets = Dictionary(grouping: session.setLogs, by: { $0.machineName })
                        ForEach(groupedSets.keys.sorted(), id: \.self) { machineName in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(machineName)
                                    .font(PremiumFonts.headline)
                                    .foregroundColor(PremiumColors.starkWhite)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    let sets = groupedSets[machineName]!.sorted(by: { $0.setNumber < $1.setNumber })
                                    ForEach(sets) { setLog in
                                        HStack {
                                            Text("Set \(setLog.setNumber)")
                                                .font(PremiumFonts.caption)
                                                .fontWeight(.bold)
                                                .foregroundStyle(PremiumColors.midGray)
                                            Spacer()
                                            Text("\(weightUnit.formatNumber(setLog.weight)) \(weightUnit.unitLabel) × \(setLog.reps)")
                                                .font(PremiumFonts.body)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(PremiumColors.starkWhite)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        if setLog.id != sets.last?.id {
                                            Divider().background(PremiumColors.glassBorder)
                                        }
                                    }
                                }
                                .background(PremiumColors.glassBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showSummaryGraphic) {
            WorkoutSummaryCardView(session: session)
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
