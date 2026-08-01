import SwiftUI
import SwiftData
import PhotosUI

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
    
    // Photo & AI Recognition state
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var isScanningWithAI = false
    @State private var aiSuccessMessage: String? = nil
    @State private var detectedItems: [DetectedFoodItem] = []
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                
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
                
                // Photo Picker & AI Scanner Banner
                photoScanSection
                
                // Detected Items Breakdown Card (if AI scanned items)
                if !detectedItems.isEmpty {
                    detectedItemsBreakdownCard
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
                
                // Macro Inputs Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Macros (Optional)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                    
                    HStack(spacing: 12) {
                        macroInputField(title: "Protein", color: paleBlue, text: $proteinText)
                        macroInputField(title: "Carbs", color: Color(red: 0.95, green: 0.75, blue: 0.40), text: $carbsText)
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            selectedMealType = initialMealType
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    selectedUIImage = image
                    scanMealWithAI(image)
                }
            }
        }
    }
    
    // MARK: - Detected Items Breakdown Card
    
    private var detectedItemsBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🍽️ Identified Plate Items (\(detectedItems.count))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(paleBlue)
                Spacer()
                Text("Macro Breakdown")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
            
            VStack(spacing: 8) {
                ForEach(detectedItems) { item in
                    HStack(spacing: 10) {
                        Text(item.icon)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 6) {
                                Text("\(item.calories) kcal")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                                Text("·")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                                Text("P: \(item.protein)g")
                                    .font(.caption2)
                                    .foregroundStyle(paleBlue)
                                Text("C: \(item.carbs)g")
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.95, green: 0.75, blue: 0.40))
                                Text("F: \(item.fats)g")
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.45, green: 0.85, blue: 0.65))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Photo & AI Scanner UI
    
    private var photoScanSection: some View {
        VStack(spacing: 12) {
            if let image = selectedUIImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button {
                        selectedUIImage = nil
                        selectedItem = nil
                        aiSuccessMessage = nil
                        detectedItems = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, Color.black.opacity(0.6))
                            .padding(8)
                    }
                }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(paleBlue.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 20))
                                .foregroundStyle(paleBlue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Snap or Upload Food Photo")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            
                            Text("AI will scan all plate items & macros")
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(paleBlue)
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            if isScanningWithAI {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(paleBlue)
                    Text("AI scanning plate items & macro breakdown...")
                        .font(.caption)
                        .foregroundStyle(paleBlue)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(paleBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let msg = aiSuccessMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                    Text(msg)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func scanMealWithAI(_ image: UIImage) {
        isScanningWithAI = true
        aiSuccessMessage = nil
        detectedItems = []
        
        Task {
            let result = await AIFoodVisionService.shared.analyzeFoodImage(image)
            
            isScanningWithAI = false
            foodName = result.plateTitle
            caloriesText = "\(result.totalCalories)"
            proteinText = "\(result.totalProtein)"
            carbsText = "\(result.totalCarbs)"
            fatsText = "\(result.totalFats)"
            detectedItems = result.detectedItems
            aiSuccessMessage = "Identified \(result.detectedItems.count) items on plate!"
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
        
        var localImagePath: String? = nil
        if let image = selectedUIImage {
            localImagePath = AIFoodVisionService.shared.saveMealImageLocally(image)
        }
        
        let newMeal = MealLog(
            name: name,
            mealType: selectedMealType,
            calories: calories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatsGrams: fats,
            imagePath: localImagePath
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
