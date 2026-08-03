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
    // Base values per 1 unit — used for quantity scaling
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
        
        // Calculate per-unit base values
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
    
    func analyzeFoodImage(_ image: UIImage) async -> FoodAnalysisResult {
        guard let key = savedAPIKey, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return FoodAnalysisResult(
                plateTitle: "API Key Required",
                totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                detectedItems: [], confidence: 0.0,
                errorMessage: "Please paste your free Groq or Gemini API Key to enable AI food scanning."
            )
        }
        
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanKey.hasPrefix("gsk_") {
            // Groq Vision API (14,400 free calls/day)
            return await callGroqVision(image: image, apiKey: cleanKey)
        } else {
            // Google Gemini Vision API
            return await callGeminiVision(image: image, apiKey: cleanKey)
        }
    }
    
    // MARK: - Groq Vision API (14,400 Free Requests/Day — console.groq.com)
    
    private func callGroqVision(image: UIImage, apiKey: String) async -> FoodAnalysisResult {
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
        let dataURL = "data:image/jpeg;base64,\(base64Image)"
        
        let promptText = """
        You are an expert nutritionist and food vision AI.
        Analyze this meal photo carefully.
        Identify every specific food item visible (e.g. Masala Dosa, Filter Coffee, Sambar, Idli, Fried Eggs, Chicken Biryani, Roti, Dal, Rice).
        Estimate realistic portion sizes, calories, and macros (protein, carbs, fats) for each item.
        
        Return ONLY valid raw JSON with NO markdown formatting, NO ```json backticks.
        {
          "plateTitle": "Summary Title (e.g. Dosa & Coffee Breakfast)",
          "items": [
            {
              "name": "Crispy Dosa",
              "calories": 120,
              "protein": 3,
              "carbs": 24,
              "fats": 3,
              "icon": "🥞",
              "quantity": 2.0
            }
          ]
        }
        """
        
        let groqModels = [
            "llama-3.2-11b-vision-preview",
            "llama-3.2-90b-vision-preview"
        ]
        
        var lastGroqError = "Could not connect to Groq API."
        
        for model in groqModels {
            let requestBody: [String: Any] = [
                "model": model,
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            ["type": "text", "text": promptText],
                            ["type": "image_url", "image_url": ["url": dataURL]]
                        ]
                    ]
                ],
                "temperature": 0.2,
                "response_format": ["type": "json_object"]
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody),
                  let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = httpBody
            request.timeoutInterval = 20
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                
                if statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let first = choices.first,
                       let message = first["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        if let result = parseJSONString(content) {
                            return result
                        }
                    }
                } else if statusCode == 429 {
                    return FoodAnalysisResult(
                        plateTitle: "Rate Limited",
                        totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                        detectedItems: [], confidence: 0.0,
                        errorMessage: "Groq daily quota limit reached (429). Please wait 30s."
                    )
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let err = json["error"] as? [String: Any],
                       let msg = err["message"] as? String {
                        lastGroqError = "Groq (\(statusCode)): \(msg)"
                    } else {
                        lastGroqError = "Groq returned code \(statusCode)."
                    }
                }
            } catch {
                lastGroqError = "Groq network error: \(error.localizedDescription)"
            }
        }
        
        return FoodAnalysisResult(
            plateTitle: "Groq API Error",
            totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
            detectedItems: [], confidence: 0.0,
            errorMessage: lastGroqError
        )
    }
    
    private func parseJSONString(_ text: String) -> FoodAnalysisResult? {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleaned.data(using: .utf8) else { return nil }
        return parseGeminiResponse(jsonData)
    }
    
    // MARK: - Gemini Vision API Call
    
    private func callGeminiVision(image: UIImage, apiKey: String) async -> FoodAnalysisResult {
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
        
        let promptText = """
        You are an expert nutritionist and food vision AI.
        Analyze this meal photo carefully.
        Identify every specific food item visible (e.g. Masala Dosa, Filter Coffee, Sambar, Idli, Fried Eggs, Chicken Biryani, Roti, Dal, Rice, Chapati).
        Estimate realistic portion sizes, calories, and macros (protein, carbs, fats) for each item.
        
        IMPORTANT: Return ONLY raw valid JSON with NO markdown, NO ```json, NO extra text.
        {
          "plateTitle": "Summary Title (e.g. Dosa & Coffee Breakfast)",
          "items": [
            {
              "name": "Crispy Dosa",
              "calories": 120,
              "protein": 3,
              "carbs": 24,
              "fats": 3,
              "icon": "🥞",
              "quantity": 2.0
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
                plateTitle: "Error",
                totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
                detectedItems: [], confidence: 0.0,
                errorMessage: "Could not format API request."
            )
        }
        
        // Models to try in sequence — each model family has its own separate 15 RPM quota pool in Google AI Studio
        let models = [
            "gemini-2.0-flash",
            "gemini-1.5-flash",
            "gemini-1.5-flash-8b",
            "gemini-2.0-flash-lite"
        ]
        let encodedKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? apiKey
        var lastError = "Could not connect to Gemini API."
        
        for model in models {
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(encodedKey)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            request.timeoutInterval = 20
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                
                if statusCode == 200 {
                    if let result = parseGeminiResponse(data) {
                        return result // Success!
                    }
                    lastError = "Could not parse response from \(model)."
                } else if statusCode == 429 {
                    // Rate limit hit for THIS model — try the NEXT model in the list (different quota bucket)
                    lastError = "Model \(model) hit rate limit (429). Trying fallback model..."
                    continue
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let err = json["error"] as? [String: Any],
                       let msg = err["message"] as? String {
                        lastError = "Gemini (\(statusCode)): \(msg)"
                    } else {
                        lastError = "Gemini returned HTTP \(statusCode) for \(model)."
                    }
                }
            } catch {
                lastError = "Network error (\(model)): \(error.localizedDescription)"
            }
        }
        
        // If all models hit 429 or failed, wait 2 seconds and attempt 1 last retry on gemini-1.5-flash
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let retryUrlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(encodedKey)"
        if let retryUrl = URL(string: retryUrlString) {
            var request = URLRequest(url: retryUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            request.timeoutInterval = 20
            
            if let (data, response) = try? await URLSession.shared.data(for: request),
               ((response as? HTTPURLResponse)?.statusCode ?? 500) == 200,
               let result = parseGeminiResponse(data) {
                return result
            }
        }
        
        return FoodAnalysisResult(
            plateTitle: "API Error",
            totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0,
            detectedItems: [], confidence: 0.0,
            errorMessage: lastError
        )
    }
    
    // MARK: - Parse Gemini JSON Response
    
    private func parseGeminiResponse(_ data: Data) -> FoodAnalysisResult? {
        guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonObj["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            return nil
        }
        
        // Clean markdown fences if Gemini wrapped them
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleaned.data(using: .utf8) else { return nil }
        
        struct GItem: Codable {
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fats: Int
            let icon: String
            let quantity: Double?
        }
        struct GPayload: Codable {
            let plateTitle: String
            let items: [GItem]
        }
        
        guard let payload = try? JSONDecoder().decode(GPayload.self, from: jsonData),
              !payload.items.isEmpty else {
            return nil
        }
        
        let items = payload.items.map { i in
            DetectedFoodItem(
                name: i.name,
                calories: i.calories,
                protein: i.protein,
                carbs: i.carbs,
                fats: i.fats,
                icon: i.icon,
                quantity: i.quantity ?? 1.0
            )
        }
        
        return FoodAnalysisResult(
            plateTitle: payload.plateTitle,
            totalCalories: items.reduce(0) { $0 + $1.calories },
            totalProtein: items.reduce(0) { $0 + $1.protein },
            totalCarbs: items.reduce(0) { $0 + $1.carbs },
            totalFats: items.reduce(0) { $0 + $1.fats },
            detectedItems: items,
            confidence: 0.95,
            errorMessage: nil
        )
    }
    
    // MARK: - Image Storage
    
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

// MARK: - Image Resizing
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
