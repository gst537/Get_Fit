import SwiftUI

struct PlateCalculatorSheet: View {
    @State private var targetWeight: Double
    let barWeight: Double = 20
    @Environment(\.dismiss) private var dismiss
    
    init(targetWeight: Double = 60.0) {
        _targetWeight = State(initialValue: targetWeight)
    }
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var weightPerSide: Double {
        (targetWeight - barWeight) / 2
    }
    
    var plates: [(plateWeight: Double, count: Int)] {
        var remaining = weightPerSide
        let availablePlates: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]
        var result: [(Double, Int)] = []
        
        for p in availablePlates {
            let count = Int(remaining / p)
            if count > 0 {
                result.append((p, count))
                remaining -= Double(count) * p
            }
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 1. Header
            Text("Plate Calculator")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.white)
            
            // 2. Target Weight Input
            HStack {
                Text("Target")
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    if targetWeight > barWeight { targetWeight -= 2.5 }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .light))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
                
                Text(String(format: "%.1f", targetWeight))
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .frame(minWidth: 70)
                
                Button(action: {
                    targetWeight += 2.5
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
                
                Text("kg")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            // 3. Bar Weight Display
            Text("Bar: \(String(format: "%.0f", barWeight)) kg")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            // 4. Plate Breakdown
            Text("Each Side")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            if targetWeight <= barWeight {
                Text("No plates needed")
                    .foregroundColor(.gray)
            } else {
                ForEach(plates, id: \.plateWeight) { plateInfo in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(paleBlue.opacity(opacityForPlate(plateInfo.plateWeight)))
                            .frame(width: widthForPlate(plateInfo.plateWeight), height: 44)
                        
                        Text("× \(plateInfo.count)")
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                        
                        Text(String(format: "%g kg", plateInfo.plateWeight))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
            
            // 5. Total Check
            let calculatedTotal = barWeight + plates.reduce(0) { $0 + $1.plateWeight * Double($1.count) } * 2
            Text(String(format: "Total: %.1f kg", calculatedTotal))
                .font(.body)
                .fontWeight(.light)
                .foregroundColor(.white)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func widthForPlate(_ weight: Double) -> CGFloat {
        let minWidth: CGFloat = 20
        let maxWidth: CGFloat = 80
        let maxWeight: Double = 25
        
        return minWidth + CGFloat(weight / maxWeight) * (maxWidth - minWidth)
    }
    
    func opacityForPlate(_ weight: Double) -> Double {
        if weight == 25 { return 1.0 }
        if weight == 20 { return 0.9 }
        if weight == 15 { return 0.75 }
        if weight == 10 { return 0.6 }
        if weight == 5 { return 0.45 }
        return 0.3
    }
}

#Preview {
    PlateCalculatorSheet()
}
