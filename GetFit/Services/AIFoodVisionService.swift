import Foundation
import UIKit

struct DetectedFoodItem: Identifiable, Sendable, Codable {
    var id = UUID()
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int
    var icon: String
    var quantity: Double = 1.0
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats, icon, quantity
    }
    
    init(id: UUID = UUID(), name: String, calories: Int, protein: Int, carbs: Int, fats: Int, icon: String, quantity: Double = 1.0) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.icon = icon
        self.quantity = quantity
    }
}

struct FoodAnalysisResult: Sendable {
    let plateTitle: String
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFats: Int
    let detectedItems: [DetectedFoodItem]
    let confidence: Double
    let errorMessage: String?
}

final class AIFoodVisionService: @unchecked Sendable {
    static let shared = AIFoodVisionService()
    
    private let apiKeyDefaultsKey = "GeminiAPIKey_Preference"
    
    var savedAPIKey: String? {
        get { UserDefaults.standard.string(forKey: apiKeyDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: apiKeyDefaultsKey) }
    }
    
    private init() {}
    
    /// Main entry point: Analyzes food image using Google Gemini Vision AI
    func analyzeFoodImage(_ image: UIImage) async -> FoodAnalysisResult {
        guard let key = savedAPIKey, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return FoodAnalysisResult(
                plateTitle: "Gemini API Key Required",
                totalCalories: 0,
                totalProtein: 0,
                totalCarbs: 0,
                totalFats: 0,
                detectedItems: [],
                confidence: 0.0,
                errorMessage: "Please paste your free Google Gemini API Key above to unlock AI food recognition!"
            )
        }
        
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return await analyzeWithGeminiVision(image: image, apiKey: cleanKey)
    }
    
    /// AI Meal Assistant Chatbot: Modifies meal items using natural language commands (e.g. "swap dosa for 2 chapathi", "remove rice", "make 1 dosa")
    func modifyMealWithAI(instruction: String, currentItems: [DetectedFoodItem]) async -> FoodAnalysisResult {
        guard let key = savedAPIKey, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallbackModifyMealLocally(instruction: instruction, currentItems: currentItems)
        }
        
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return await modifyWithGeminiText(instruction: instruction, currentItems: currentItems, apiKey: cleanKey)
    }
    
    // MARK: - Google Gemini Vision API
    
    private func analyzeWithGeminiVision(image: UIImage, apiKey: String) async -> FoodAnalysisResult {
        let resized = image.resizedForVision(maxDimension: 512)
        guard let jpegData = resized.jpegData(compressionQuality: 0.4) else {
            return FoodAnalysisResult(
                plateTitle: "Image Error",
                totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                detectedItems: [], confidence: 0.0,
                errorMessage: "Could not process image data."
            )
        }
        let base64Image = jpegData.base64EncodedString()
        
        let modelCandidates = [
            "gemini-1.5-flash",
            "gemini-1.5-pro"
        ]
        
        let promptText = """
        You are an expert nutritionist and food vision AI.
        Analyze this meal photo carefully.
        Identify every specific food item on the plate (e.g. Biryani Portion, Raita, Masala Dosa, Sambar, Chicken Curry, Chapathi, Dal, Rice, Boiled Egg, Salad).
        Estimate realistic portion sizes, calories, and macros (protein, carbs, fats) for each item.
        
        You MUST return ONLY a raw valid JSON object with NO markdown formatting, NO ```json backticks, and NO extra text.
        JSON Structure:
        {
          "plateTitle": "Summary Title of Plate (e.g. Chicken Biryani & Raita Plate)",
          "items": [
            {
              "name": "Exact Item Name with Portion (e.g., Chicken Biryani Portion)",
              "calories": 570,
              "protein": 35,
              "carbs": 69,
              "fats": 16,
              "icon": "🍛",
              "quantity": 1.0
            }
          ]
        }
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "response_mime_type": "application/json"
            ]
        ]
        
        return await executeGeminiRequest(payload: payload, apiKey: apiKey, modelCandidates: modelCandidates)
    }
    
    // MARK: - Gemini Natural Language Meal Assistant Modifier
    
    private func modifyWithGeminiText(instruction: String, currentItems: [DetectedFoodItem], apiKey: String) async -> FoodAnalysisResult {
        let itemsSummary = currentItems.map { "name: \($0.name), calories: \($0.calories), P: \($0.protein)g, C: \($0.carbs)g, F: \($0.fats)g, icon: \($0.icon)" }.joined(separator: "\n")
        
        let promptText = """
        You are an expert AI meal assistant.
        The user currently has these food items logged for their meal:
        \(itemsSummary)
        
        User's requested modification: "\(instruction)"
        Examples of modifications: "remove dosa and add 2 chapathi", "make it 1 dosa instead of 2", "swap biryani for tandoori chicken", "reduce rice portion by half".
        
        Apply the user's requested swaps, removals, or quantity changes. Calculate accurate calories and macros for the modified meal items.
        
        You MUST return ONLY a raw valid JSON object with NO markdown formatting and NO ```json backticks.
        JSON Structure:
        {
          "plateTitle": "Updated Plate Title",
          "items": [
            {
              "name": "Exact Item Name (e.g. Chapathi 2 pcs)",
              "calories": 180,
              "protein": 6,
              "carbs": 36,
              "fats": 2,
              "icon": "🫓",
              "quantity": 1.0
            }
          ]
        }
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "response_mime_type": "application/json"
            ]
        ]
        
        let candidates = ["gemini-1.5-flash", "gemini-1.5-pro"]
        let result = await executeGeminiRequest(payload: payload, apiKey: apiKey, modelCandidates: candidates)
        if result.detectedItems.isEmpty && result.errorMessage != nil {
            return fallbackModifyMealLocally(instruction: instruction, currentItems: currentItems)
        }
        return result
    }
    
    // MARK: - Offline Smart Local Rule Fallback (Works even without API key!)
    
    private func fallbackModifyMealLocally(instruction: String, currentItems: [DetectedFoodItem]) -> FoodAnalysisResult {
        var updated = currentItems
        let query = instruction.lowercased()
        
        if query.contains("remove") || query.contains("delete") {
            if query.contains("dosa") {
                updated.removeAll { $0.name.lowercased().contains("dosa") }
            } else if query.contains("rice") {
                updated.removeAll { $0.name.lowercased().contains("rice") }
            } else if query.contains("chutney") {
                updated.removeAll { $0.name.lowercased().contains("chutney") }
            } else if query.contains("egg") {
                updated.removeAll { $0.name.lowercased().contains("egg") }
            }
        }
        
        if query.contains("chapathi") || query.contains("chappati") || query.contains("roti") {
            if !updated.contains(where: { $0.name.lowercased().contains("chapathi") || $0.name.lowercased().contains("roti") }) {
                updated.append(DetectedFoodItem(name: "Whole Wheat Chapathi (2 pcs)", calories: 180, protein: 6, carbs: 36, fats: 2, icon: "🫓", quantity: 1.0))
            }
        }
        
        if query.contains("1 dosa") || query.contains("half dosa") || query.contains("reduce dosa") {
            if let idx = updated.firstIndex(where: { $0.name.lowercased().contains("dosa") }) {
                updated[idx].name = "Single Crispy Dosa (1 pc)"
                updated[idx].calories = 120
                updated[idx].protein = 3
                updated[idx].carbs = 24
                updated[idx].fats = 3
                updated[idx].quantity = 0.5
            }
        }
        
        if query.contains("egg") && !updated.contains(where: { $0.name.lowercased().contains("egg") }) {
            updated.append(DetectedFoodItem(name: "Boiled Eggs (2 pcs)", calories: 140, protein: 12, carbs: 1, fats: 10, icon: "🥚", quantity: 1.0))
        }
        
        let totalCals = updated.reduce(0) { $0 + $1.calories }
        let totalP = updated.reduce(0) { $0 + $1.protein }
        let totalC = updated.reduce(0) { $0 + $1.carbs }
        let totalF = updated.reduce(0) { $0 + $1.fats }
        
        return FoodAnalysisResult(
            plateTitle: "Updated Meal",
            totalCalories: totalCals,
            totalProtein: totalP,
            totalCarbs: totalC,
            totalFats: totalF,
            detectedItems: updated,
            confidence: 0.9,
            errorMessage: nil
        )
    }
    
    // MARK: - Execute Gemini API Request
    
    private func executeGeminiRequest(payload: [String: Any], apiKey: String, modelCandidates: [String]) async -> FoodAnalysisResult {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            return FoodAnalysisResult(
                plateTitle: "Payload Error",
                totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                detectedItems: [], confidence: 0.0,
                errorMessage: "Failed to construct JSON payload."
            )
        }
        
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedKey = cleanKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleanKey
        var lastErrorMessage = "Failed to connect to Gemini API."
        
        for model in modelCandidates {
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(encodedKey)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(cleanKey, forHTTPHeaderField: "x-goog-api-key")
            request.httpBody = jsonData
            request.timeoutInterval = 15.0
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResp = response as? HTTPURLResponse else { continue }
                
                let statusCode = httpResp.statusCode
                if statusCode == 200 {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = jsonObj["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let jsonText = firstPart["text"] as? String {
                        
                        if let parsed = parseGeminiJsonText(jsonText) {
                            let totalCals = parsed.items.reduce(0) { $0 + $1.calories }
                            let totalP = parsed.items.reduce(0) { $0 + $1.protein }
                            let totalC = parsed.items.reduce(0) { $0 + $1.carbs }
                            let totalF = parsed.items.reduce(0) { $0 + $1.fats }
                            
                            return FoodAnalysisResult(
                                plateTitle: parsed.title,
                                totalCalories: totalCals,
                                totalProtein: totalP,
                                totalCarbs: totalC,
                                totalFats: totalF,
                                detectedItems: parsed.items,
                                confidence: 0.99,
                                errorMessage: nil
                            )
                        }
                    }
                } else {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorObj = jsonObj["error"] as? [String: Any],
                       let message = errorObj["message"] as? String {
                        lastErrorMessage = "Gemini Error (\(statusCode)): \(message)"
                    } else {
                        lastErrorMessage = "Gemini API returned code \(statusCode)."
                    }
                }
            } catch {
                lastErrorMessage = "Network error: \(error.localizedDescription)"
            }
        }
        
        return FoodAnalysisResult(
            plateTitle: "API Connection Error",
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFats: 0,
            detectedItems: [],
            confidence: 0.0,
            errorMessage: lastErrorMessage
        )
    }
    
    private func parseGeminiJsonText(_ text: String) -> (title: String, items: [DetectedFoodItem])? {
        var cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let firstBrace = cleaned.firstIndex(of: "{"),
           let lastBrace = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[firstBrace...lastBrace])
        }
        
        guard let data = cleaned.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        let title = dict["plateTitle"] as? String ?? dict["title"] as? String ?? "Custom Meal Plate"
        var items: [DetectedFoodItem] = []
        
        if let itemsArray = dict["items"] as? [[String: Any]] {
            for itemDict in itemsArray {
                let name = itemDict["name"] as? String ?? "Food Item"
                let cals = itemDict["calories"] as? Int ?? 0
                let p = itemDict["protein"] as? Int ?? 0
                let c = itemDict["carbs"] as? Int ?? 0
                let f = itemDict["fats"] as? Int ?? 0
                let icon = itemDict["icon"] as? String ?? "🍲"
                let qty = itemDict["quantity"] as? Double ?? 1.0
                
                items.append(DetectedFoodItem(name: name, calories: cals, protein: p, carbs: c, fats: f, icon: icon, quantity: qty))
            }
        }
        
        return (title, items)
    }
    
    func saveMealImageLocally(_ image: UIImage) -> String? {
        let prepImage = image.resizedForVision(maxDimension: 800)
        guard let data = prepImage.jpegData(compressionQuality: 0.7) else { return nil }
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let photosDir = docsURL.appendingPathComponent("MealPhotos")
        if !fileManager.fileExists(atPath: photosDir.path) {
            try? fileManager.createDirectory(at: photosDir, withIntermediateDirectories: true)
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = photosDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            return nil
        }
    }
    
    func loadMealImage(from path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - Performance Image Resizing Helper
extension UIImage {
    func resizedForVision(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
