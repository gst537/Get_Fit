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
    var baseCalories: Int
    var baseProtein: Int
    var baseCarbs: Int
    var baseFats: Int
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats, icon, quantity, baseCalories, baseProtein, baseCarbs, baseFats
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
        
        let qty = quantity > 0 ? quantity : 1.0
        self.baseCalories = max(1, Int(round(Double(calories) / qty)))
        self.baseProtein = max(0, Int(round(Double(protein) / qty)))
        self.baseCarbs = max(0, Int(round(Double(carbs) / qty)))
        self.baseFats = max(0, Int(round(Double(fats) / qty)))
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
    
    // MARK: - Ultra-Fast Google Gemini Vision API
    
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
            "gemini-1.5-pro",
            "gemini-2.0-flash"
        ]
        
        let promptText = """
        You are an expert nutritionist and food vision AI.
        Analyze this meal photo carefully.
        Identify every specific food item on the plate (e.g. Masala Dosa, Filter Coffee, Sambar, Kothu Parotta, Chana Sundal, Coconut Chutney, Fried Eggs, Chicken Biryani, Roti, Dal, Rice).
        Estimate realistic portion sizes, calories, and macros (protein, carbs, fats) for each item.
        
        You MUST return ONLY a raw valid JSON object with NO markdown formatting, NO ```json backticks, and NO extra text.
        JSON Structure:
        {
          "plateTitle": "Summary Title of Plate (e.g. Dosa & Coffee Breakfast)",
          "items": [
            {
              "name": "Crispy Dosa (2 pcs)",
              "calories": 240,
              "protein": 6,
              "carbs": 48,
              "fats": 6,
              "icon": "🥞",
              "quantity": 2.0
            },
            {
              "name": "Filter Coffee (1 cup)",
              "calories": 80,
              "protein": 2,
              "carbs": 12,
              "fats": 3,
              "icon": "☕",
              "quantity": 1.0
            }
          ]
        }
        """
        
        let requestBody: [String: Any] = [
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
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return FoodAnalysisResult(
                plateTitle: "Payload Error",
                totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                detectedItems: [], confidence: 0.0,
                errorMessage: "Could not format API request payload."
            )
        }
        
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedKey = cleanKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleanKey
        var lastErrorMessage = "Could not connect to Gemini API."
        
        for model in modelCandidates {
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(encodedKey)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(cleanKey, forHTTPHeaderField: "x-goog-api-key")
            request.httpBody = httpBody
            request.timeoutInterval = 25
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                
                if statusCode == 200 {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = jsonObj["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let textResponse = parts.first?["text"] as? String {
                        
                        let cleanedJSON = textResponse
                            .replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if let jsonData = cleanedJSON.data(using: .utf8) {
                            struct GeminiPayloadItem: Codable {
                                let name: String
                                let calories: Int
                                let protein: Int
                                let carbs: Int
                                let fats: Int
                                let icon: String
                                let quantity: Double?
                            }
                            
                            struct GeminiPayload: Codable {
                                let plateTitle: String
                                let items: [GeminiPayloadItem]
                            }
                            
                            let decoder = JSONDecoder()
                            if let payload = try? decoder.decode(GeminiPayload.self, from: jsonData), !payload.items.isEmpty {
                                let convertedItems = payload.items.map { item in
                                    DetectedFoodItem(
                                        name: item.name,
                                        calories: item.calories,
                                        protein: item.protein,
                                        carbs: item.carbs,
                                        fats: item.fats,
                                        icon: item.icon,
                                        quantity: item.quantity ?? 1.0
                                    )
                                }
                                
                                let totalCals = convertedItems.reduce(0) { $0 + $1.calories }
                                let totalP = convertedItems.reduce(0) { $0 + $1.protein }
                                let totalC = convertedItems.reduce(0) { $0 + $1.carbs }
                                let totalF = convertedItems.reduce(0) { $0 + $1.fats }
                                
                                return FoodAnalysisResult(
                                    plateTitle: payload.plateTitle,
                                    totalCalories: totalCals,
                                    totalProtein: totalP,
                                    totalCarbs: totalC,
                                    totalFats: totalF,
                                    detectedItems: convertedItems,
                                    confidence: 0.99,
                                    errorMessage: nil
                                )
                            }
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
