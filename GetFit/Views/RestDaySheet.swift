import SwiftUI
import SwiftData

struct RestDaySheet: View {
    let scheduleEntry: WeeklySchedule?
    @Environment(\.dismiss) private var dismiss
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon & Title
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(paleBlue.opacity(0.12))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(paleBlue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rest Day")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    
                    Text("Scheduled Recovery")
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            // Reassign Split Dropdown Menu
            if let scheduleEntry {
                HStack {
                    Text("Reassign Split:")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    Spacer()
                    
                    QuickSwapSplitMenu(scheduleEntry: scheduleEntry)
                }
                .padding(.horizontal, 4)
            }
            
            Button("Done") {
                dismiss()
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(paleBlue)
            .clipShape(Capsule())
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            RestDaySheet(scheduleEntry: nil)
                .preferredColorScheme(.dark)
        }
}
