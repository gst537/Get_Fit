import SwiftUI
import SwiftData

struct WorkoutSummaryCardView: View {
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    let darkCardBg = Color(red: 0.07, green: 0.09, blue: 0.13)
    
    private var totalTonnage: Double {
        session.setLogs.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    private var totalSets: Int {
        session.setLogs.count
    }
    
    private var groupedSets: [(name: String, topWeight: Double, totalReps: Int, setSetsCount: Int)] {
        let dict = Dictionary(grouping: session.setLogs, by: { $0.machineName })
        return dict.keys.sorted().map { name in
            let sets = dict[name]!
            let maxWeight = sets.map({ $0.weight }).max() ?? 0.0
            let reps = sets.reduce(0) { $0 + $1.reps }
            return (name: name, topWeight: maxWeight, totalReps: reps, setSetsCount: sets.count)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // The Shareable Card Component
                    cardContent
                        .padding(24)
                        .background(darkCardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(paleBlue.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: paleBlue.opacity(0.12), radius: 20, x: 0, y: 10)
                    
                    // Share / Save Action Button
                    if let renderedImage = renderCardImage() {
                        ShareLink(item: renderedImage, preview: SharePreview("Workout Summary", image: renderedImage)) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Share Workout Graphic")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(paleBlue)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(paleBlue)
                }
            }
        }
    }
    
    // MARK: - Card View Content
    
    private var cardContent: some View {
        VStack(spacing: 24) {
            // Header Logo & Title
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(paleBlue)
                    Text("GET FIT")
                        .font(.system(size: 16, weight: .light))
                        .tracking(4.0)
                        .foregroundStyle(.white)
                }
                
                Text("\(session.splitName.uppercased()) COMPLETED")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(session.date.formatted(.dateTime.month().day().year().hour().minute()))
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Hero Metrics (3 Cards)
            HStack(spacing: 12) {
                // Duration
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(paleBlue)
                    Text("\(Int(session.duration / 60))")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(.white)
                    Text("MIN")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Total Tonnage
                VStack(spacing: 4) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(paleBlue)
                    Text(formatTonnage(totalTonnage))
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("TOTAL TONNAGE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Total Sets
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(paleBlue)
                    Text("\(totalSets)")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(.white)
                    Text("SETS LOGGED")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Exercise Breakdown List
            VStack(alignment: .leading, spacing: 14) {
                ForEach(groupedSets, id: \.name) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                            
                            Text("\(item.setSetsCount) sets × \(item.totalReps) total reps")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                        
                        Text(formatWeight(item.topWeight) + " kg")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(paleBlue)
                    }
                }
            }
        }
    }
    
    // MARK: - Image Renderer
    
    @MainActor
    private func renderCardImage() -> Image? {
        let renderer = ImageRenderer(content: cardContent.frame(width: 340).padding(24).background(darkCardBg))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    private func formatTonnage(_ weight: Double) -> String {
        if weight >= 1000 {
            return String(format: "%.1ft", weight / 1000.0)
        } else {
            return String(format: "%.0f kg", weight)
        }
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
    let session = WorkoutSession(splitName: "Push Day")
    session.duration = 2700
    return WorkoutSummaryCardView(session: session)
        .preferredColorScheme(.dark)
}
