import SwiftUI
import SwiftData

struct AddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var initialMealType: String = "Breakfast"
    
    @State private var foodName = ""
    @State private var selectedMealType = "Breakfast"
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                HStack {
                    Text("Log Food & Calories")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(paleBlue)
                }
                
                // Meal Type Category Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Category")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 8) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type)
                                .font(.subheadline)
                                .fontWeight(selectedMealType == type ? .medium : .regular)
                                .foregroundStyle(selectedMealType == type ? .black : Color.gray)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedMealType == type ? paleBlue : Color(UIColor.secondarySystemBackground))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    selectedMealType = type
                                }
                        }
                    }
                }
                
                // Food Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food / Dish Name")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    TextField("e.g., Grilled Chicken & Rice", text: $foodName)
                        .font(.body)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calories Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories (kcal)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack {
                        TextField("0", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        
                        Text("kcal")
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Macro Inputs Grid (Protein, Carbs, Fats)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Macros (Optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 12) {
                        // Protein
                        macroInputField(title: "Protein", color: paleBlue, text: $proteinText)
                        
                        // Carbs
                        macroInputField(title: "Carbs", color: Color(red: 0.95, green: 0.75, blue: 0.40), text: $carbsText)
                        
                        // Fats
                        macroInputField(title: "Fats", color: Color(red: 0.45, green: 0.85, blue: 0.65), text: $fatsText)
                    }
                }
                
                // Save Button
                Button {
                    saveMeal()
                } label: {
                    Text("Save Food Entry")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(paleBlue)
                        .clipShape(Capsule())
                        .opacity(foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(caloriesText) ?? 0) <= 0 ? 0.5 : 1.0)
                }
                .disabled(foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(caloriesText) ?? 0) <= 0)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            selectedMealType = initialMealType
        }
    }
    
    private func macroInputField(title: String, color: Color, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(color)
            
            HStack(spacing: 2) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Text("g")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func saveMeal() {
        let name = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        let calories = Int(caloriesText) ?? 0
        let protein = Int(proteinText) ?? 0
        let carbs = Int(carbsText) ?? 0
        let fats = Int(fatsText) ?? 0
        
        guard !name.isEmpty, calories > 0 else { return }
        
        let newMeal = MealLog(
            name: name,
            mealType: selectedMealType,
            calories: calories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatsGrams: fats
        )
        
        modelContext.insert(newMeal)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            AddFoodSheet()
                .preferredColorScheme(.dark)
        }
}
