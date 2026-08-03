import SwiftUI
import SwiftData

struct NutritionTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.date, order: .reverse) private var allMeals: [MealLog]
    @Query private var nutritionGoals: [NutritionGoal]
    
    @State private var showAddFoodSheet = false
    @State private var selectedCategoryForAdd = "Breakfast"
    @State private var showEditGoalSheet = false
    @State private var selectedMealPhoto: UIImage? = nil
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    let warmGold = Color(red: 0.95, green: 0.75, blue: 0.40)
    let mintGreen = Color(red: 0.45, green: 0.85, blue: 0.65)
    
    private var activeGoal: NutritionGoal {
        if let existing = nutritionGoals.first {
            return existing
        } else {
            let newGoal = NutritionGoal(targetCalories: 2200, targetProtein: 160, targetCarbs: 220, targetFats: 70)
            modelContext.insert(newGoal)
            try? modelContext.save()
            return newGoal
        }
    }
    
    private var todayMeals: [MealLog] {
        let calendar = Calendar.current
        return allMeals.filter { calendar.isDateInToday($0.date) }
    }
    
    private var totalConsumedCalories: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }
    
    private var totalConsumedProtein: Int {
        todayMeals.reduce(0) { $0 + $1.proteinGrams }
    }
    
    private var totalConsumedCarbs: Int {
        todayMeals.reduce(0) { $0 + $1.carbsGrams }
    }
    
    private var totalConsumedFats: Int {
        todayMeals.reduce(0) { $0 + $1.fatsGrams }
    }
    
    private var isCalorieOverGoal: Bool {
        totalConsumedCalories > activeGoal.targetCalories
    }
    
    private var remainingCalories: Int {
        activeGoal.targetCalories - totalConsumedCalories
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Hero Calorie Card
                heroCalorieCard
                
                // 2. Macro Progress Bars
                macroProgressCard
                
                // 3. Meal Categories Logs
                mealCategoriesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showAddFoodSheet) {
            AddFoodSheet(initialMealType: selectedCategoryForAdd)
        }
        .sheet(isPresented: $showEditGoalSheet) {
            EditNutritionGoalSheet(goal: activeGoal)
        }
        .sheet(item: Binding<IdentifiableImage?>(
            get: { selectedMealPhoto.map { IdentifiableImage(image: $0) } },
            set: { selectedMealPhoto = $0?.image }
        )) { item in
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        selectedMealPhoto = nil
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(paleBlue)
                }
                .padding()
                
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
    
    // MARK: - Hero Calorie Card
    
    private var heroCalorieCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Calories")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                Spacer()
                Button {
                    showEditGoalSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("Edit Target")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(paleBlue.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            
            let progress = min(1.0, Double(totalConsumedCalories) / Double(max(1, activeGoal.targetCalories)))
            let ringGradients = isCalorieOverGoal
                ? [Color(red: 1.00, green: 0.45, blue: 0.45), Color(red: 1.00, green: 0.25, blue: 0.25)]
                : [paleBlue, Color(red: 0.45, green: 0.65, blue: 0.95)]
            
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 12,
                    gradient: ringGradients,
                    size: 140
                )
                
                VStack(spacing: 2) {
                    if isCalorieOverGoal {
                        Text("+\(abs(remainingCalories))")
                            .font(.system(size: 32, weight: .light, design: .rounded))
                            .foregroundStyle(Color(red: 1.00, green: 0.45, blue: 0.45))
                        Text("kcal over goal")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(red: 1.00, green: 0.45, blue: 0.45))
                    } else {
                        Text("\(remainingCalories)")
                            .font(.system(size: 32, weight: .light, design: .rounded))
                            .foregroundStyle(.white)
                        Text("kcal left")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(paleBlue)
                    }
                }
            }
            
            HStack {
                Text("\(totalConsumedCalories) consumed")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("Goal: \(activeGoal.targetCalories) kcal")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(20)
        .glassmorphic(cornerRadius: 20)
    }
    
    // MARK: - Macro Progress Card
    
    private var macroProgressCard: some View {
        HStack(spacing: 12) {
            macroRingItem(
                title: "Protein",
                consumed: totalConsumedProtein,
                target: activeGoal.targetProtein,
                unit: "g",
                gradient: [paleBlue, Color(red: 0.45, green: 0.65, blue: 0.95)]
            )
            
            macroRingItem(
                title: "Carbs",
                consumed: totalConsumedCarbs,
                target: activeGoal.targetCarbs,
                unit: "g",
                gradient: [warmGold, Color(red: 0.95, green: 0.85, blue: 0.50)]
            )
            
            macroRingItem(
                title: "Fats",
                consumed: totalConsumedFats,
                target: activeGoal.targetFats,
                unit: "g",
                gradient: [mintGreen, Color(red: 0.35, green: 0.90, blue: 0.70)]
            )
        }
    }
    
    private func macroRingItem(title: String, consumed: Int, target: Int, unit: String, gradient: [Color]) -> some View {
        let progress = min(1.0, Double(consumed) / Double(max(1, target)))
        
        return VStack(spacing: 8) {
            ZStack {
                AnimatedRingView(
                    progress: progress,
                    lineWidth: 5,
                    gradient: gradient,
                    size: 52
                )
                
                Text("\(consumed)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(gradient.first ?? .white)
            
            Text("\(consumed)/\(target)\(unit)")
                .font(.system(size: 9))
                .foregroundStyle(Color.gray)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassmorphic(cornerRadius: 16)
    }
    
    // MARK: - Meal Categories Section
    
    private var mealCategoriesSection: some View {
        VStack(spacing: 16) {
            mealCategoryBlock(title: "Breakfast", icon: "sunrise.fill", categoryName: "Breakfast")
            mealCategoryBlock(title: "Lunch", icon: "sun.max.fill", categoryName: "Lunch")
            mealCategoryBlock(title: "Dinner", icon: "moon.fill", categoryName: "Dinner")
            mealCategoryBlock(title: "Snacks", icon: "leaf.fill", categoryName: "Snack")
        }
    }
    
    private func mealCategoryBlock(title: String, icon: String, categoryName: String) -> some View {
        let categoryMeals = todayMeals.filter { $0.mealType.lowercased() == categoryName.lowercased() }
        let categoryCalories = categoryMeals.reduce(0) { $0 + $1.calories }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(paleBlue)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                if categoryCalories > 0 {
                    Text("\(categoryCalories) kcal")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.gray)
                }
                
                Button {
                    selectedCategoryForAdd = categoryName
                    showAddFoodSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                        Text("Add")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(paleBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(paleBlue.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            if categoryMeals.isEmpty {
                Text("No items logged for \(title.lowercased()).")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(categoryMeals) { meal in
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                if let path = meal.imagePath, let uiImg = AIFoodVisionService.shared.loadMealImage(from: path) {
                                    Button {
                                        selectedMealPhoto = uiImg
                                    } label: {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 44, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(meal.name)
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 8) {
                                        if meal.proteinGrams > 0 {
                                            Text("P: \(meal.proteinGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(paleBlue)
                                        }
                                        if meal.carbsGrams > 0 {
                                            Text("C: \(meal.carbsGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(warmGold)
                                        }
                                        if meal.fatsGrams > 0 {
                                            Text("F: \(meal.fatsGrams)g")
                                                .font(.caption2)
                                                .foregroundStyle(mintGreen)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Text("\(meal.calories) kcal")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                
                                Button {
                                    deleteMeal(meal)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.red.opacity(0.85))
                                        .padding(.leading, 8)
                                }
                            }
                            .padding(.vertical, 10)
                            
                            if meal.id != categoryMeals.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassmorphic(cornerRadius: 18)
    }
    
    private func deleteMeal(_ meal: MealLog) {
        modelContext.delete(meal)
        try? modelContext.save()
    }
}

// MARK: - Edit Nutrition Goal Sheet

struct EditNutritionGoalSheet: View {
    let goal: NutritionGoal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var calsText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    let paleBlue = Color(red: 0.68, green: 0.78, blue: 0.90)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Edit Daily Nutrition Goals")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Cancel") { dismiss() }
                    .font(.body)
                    .foregroundStyle(paleBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Target Calories (kcal)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                TextField("2200", text: $calsText)
                    .keyboardType(.numberPad)
                    .font(.body)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Protein (g)")
                        .font(.caption)
                        .foregroundStyle(paleBlue)
                    TextField("160", text: $proteinText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Carbs (g)")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.95, green: 0.75, blue: 0.40))
                    TextField("220", text: $carbsText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fats (g)")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.45, green: 0.85, blue: 0.65))
                    TextField("70", text: $fatsText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            Button("Save Targets") {
                goal.targetCalories = Int(calsText) ?? goal.targetCalories
                goal.targetProtein = Int(proteinText) ?? goal.targetProtein
                goal.targetCarbs = Int(carbsText) ?? goal.targetCarbs
                goal.targetFats = Int(fatsText) ?? goal.targetFats
                try? modelContext.save()
                dismiss()
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(paleBlue)
            .clipShape(Capsule())
            .padding(.top, 10)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
        .onAppear {
            calsText = "\(goal.targetCalories)"
            proteinText = "\(goal.targetProtein)"
            carbsText = "\(goal.targetCarbs)"
            fatsText = "\(goal.targetFats)"
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    NutritionTrackerView()
        .modelContainer(for: [MealLog.self, NutritionGoal.self], inMemory: true)
        .preferredColorScheme(.dark)
}
