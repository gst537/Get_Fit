import Foundation

struct NutritionFacts {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
}

struct FoodDatabase {
    static let shared = FoodDatabase()
    
    // Maps the exact output of the AI (or manual search) to its macros
    let macros: [String: NutritionFacts] = [
        
        // --- 📸 THE 20 AI IMAGE CLASSES ---
        "burger": NutritionFacts(calories: 295, protein: 12, carbs: 30, fats: 14),
        "butter naan": NutritionFacts(calories: 317, protein: 9, carbs: 50, fats: 9),
        "chai": NutritionFacts(calories: 73, protein: 1.5, carbs: 11, fats: 2.5),
        "chapati": NutritionFacts(calories: 71, protein: 3, carbs: 15, fats: 0.4),
        "chole bhature": NutritionFacts(calories: 427, protein: 11, carbs: 55, fats: 18),
        "dal makhani": NutritionFacts(calories: 278, protein: 9, carbs: 22, fats: 17),
        "dhokla": NutritionFacts(calories: 152, protein: 5, carbs: 22, fats: 4),
        "fried rice": NutritionFacts(calories: 228, protein: 5, carbs: 33, fats: 8),
        "idli": NutritionFacts(calories: 39, protein: 1.2, carbs: 8, fats: 0.1),
        "jalebi": NutritionFacts(calories: 150, protein: 1, carbs: 29, fats: 4),
        "kaathi rolls": NutritionFacts(calories: 340, protein: 12, carbs: 35, fats: 15),
        "kadai paneer": NutritionFacts(calories: 280, protein: 14, carbs: 12, fats: 20),
        "kulfi": NutritionFacts(calories: 130, protein: 3, carbs: 15, fats: 7),
        "masala dosa": NutritionFacts(calories: 415, protein: 9, carbs: 63, fats: 14),
        "momos": NutritionFacts(calories: 35, protein: 1.5, carbs: 6, fats: 0.5),
        "paani puri": NutritionFacts(calories: 32, protein: 1, carbs: 4, fats: 1.5),
        "pakode": NutritionFacts(calories: 75, protein: 2, carbs: 6, fats: 5),
        "pav bhaji": NutritionFacts(calories: 400, protein: 10, carbs: 48, fats: 18),
        "pizza": NutritionFacts(calories: 285, protein: 12, carbs: 36, fats: 10),
        "samosa": NutritionFacts(calories: 262, protein: 3.5, carbs: 24, fats: 17),
        
        // --- 🍛 VIT CHENNAI HOSTEL MENU ADDITIONS ---
        "omelette": NutritionFacts(calories: 154, protein: 12, carbs: 1, fats: 11),
        "sprouted channa": NutritionFacts(calories: 118, protein: 8, carbs: 20, fats: 1.5),
        "corn flakes with milk": NutritionFacts(calories: 180, protein: 6, carbs: 30, fats: 3),
        "chicken biryani": NutritionFacts(calories: 360, protein: 18, carbs: 45, fats: 12),
        "paneer biryani": NutritionFacts(calories: 410, protein: 14, carbs: 45, fats: 18),
        "phulka": NutritionFacts(calories: 60, protein: 2.5, carbs: 12, fats: 0.2),
        "dal fry": NutritionFacts(calories: 120, protein: 6, carbs: 18, fats: 3),
        "raitha": NutritionFacts(calories: 45, protein: 2, carbs: 3, fats: 2),
        "mixed fruits": NutritionFacts(calories: 50, protein: 0.5, carbs: 13, fats: 0.2),
        "channa chat": NutritionFacts(calories: 150, protein: 7, carbs: 22, fats: 4),
        "rasam": NutritionFacts(calories: 30, protein: 1, carbs: 4, fats: 1),
        "kashmir pulav": NutritionFacts(calories: 320, protein: 5, carbs: 50, fats: 10),
        "methi mutter malai": NutritionFacts(calories: 350, protein: 8, carbs: 15, fats: 28),
        "white rice": NutritionFacts(calories: 130, protein: 2.5, carbs: 28, fats: 0.3)
    ]
    
    func getMacros(for foodName: String) -> NutritionFacts? {
        let cleanName = foodName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return macros[cleanName]
    }
}
