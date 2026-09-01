import Foundation
import UIKit

struct DetectedMachine: Identifiable, Codable {
    var id = UUID()
    let name: String
    let equipmentType: String
    let category: String
    let targetMuscles: [String]
    let instructions: String
}

struct MachineAnalysisResult {
    let machine: DetectedMachine?
    let errorMessage: String?
}

final class AIMachineVisionService: @unchecked Sendable {
    static let shared = AIMachineVisionService()
    
    private let apiKeyDefaultsKey = "GeminiAPIKey_Preference"
    
    var savedAPIKey: String? {
        UserDefaults.standard.string(forKey: apiKeyDefaultsKey)
    }
    
    private init() {}
    
    func analyzeMachineImage(_ image: UIImage) async -> MachineAnalysisResult {
        guard let key = savedAPIKey, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return MachineAnalysisResult(machine: nil, errorMessage: "No API Key provided. Set it in Profile settings.")
        }
        
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return await callGeminiVision(image: image, apiKey: cleanKey)
    }
    
    private func callGeminiVision(image: UIImage, apiKey: String) async -> MachineAnalysisResult {
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else {
            return MachineAnalysisResult(machine: nil, errorMessage: "Could not process image data.")
        }
        let base64Image = jpegData.base64EncodedString()
        
        let promptText = """
        You are an expert personal trainer and gym equipment AI.
        Analyze this photo of gym equipment. Identify exactly what machine or equipment it is.
        Return ONLY a raw JSON object with NO markdown, NO ```json backticks.
        
        Format exactly like this:
        {
          "name": "Machine Name (e.g. Seated Cable Row, Hammer Strength Chest Press)",
          "equipmentType": "Equipment category (e.g. Machine, Cable, Barbell, Bodyweight, Dumbbell)",
          "category": "Broad muscle group (Push, Pull, Legs, or Core)",
          "targetMuscles": ["Lats", "Mid Back", "Biceps"],
          "instructions": "1. Seat setup step\\n2. Hand grip step\\n3. Execution step\\n4. Squeeze step\\n5. Return step"
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
            return MachineAnalysisResult(machine: nil, errorMessage: "Could not format API request.")
        }
        
        let encodedKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? apiKey
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(encodedKey)"
        guard let url = URL(string: urlString) else {
            return MachineAnalysisResult(machine: nil, errorMessage: "Invalid URL.")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 15
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            
            if statusCode == 200 {
                if let result = parseGeminiResponse(data) {
                    return result
                }
                return MachineAnalysisResult(machine: nil, errorMessage: "Could not understand the AI response format.")
            } else {
                return MachineAnalysisResult(machine: nil, errorMessage: "AI API error (HTTP \(statusCode)). Check your API Key or rate limits.")
            }
        } catch {
            return MachineAnalysisResult(machine: nil, errorMessage: "Network error: \(error.localizedDescription)")
        }
    }
    
    private func parseGeminiResponse(_ data: Data) -> MachineAnalysisResult? {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = jsonObject["candidates"] as? [[String: Any]],
                  let firstCandidate = candidates.first,
                  let content = firstCandidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let firstPart = parts.first,
                  let text = firstPart["text"] as? String else {
                return nil
            }
            
            var cleanJSON = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanJSON.hasPrefix("```json") { cleanJSON.removeFirst("```json".count) }
            if cleanJSON.hasPrefix("```") { cleanJSON.removeFirst("```".count) }
            if cleanJSON.hasSuffix("```") { cleanJSON.removeLast("```".count) }
            cleanJSON = cleanJSON.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = cleanJSON.data(using: .utf8) else { return nil }
            let detected = try JSONDecoder().decode(DetectedMachine.self, from: jsonData)
            return MachineAnalysisResult(machine: detected, errorMessage: nil)
        } catch {
            print("Failed to parse machine JSON: \(error)")
            return nil
        }
    }
}
