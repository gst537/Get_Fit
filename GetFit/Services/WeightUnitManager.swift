import Foundation
import SwiftUI

/// Global weight unit manager. All weights are stored internally in kg in SwiftData.
/// Conversion to/from lb happens only at the display/input layer.
@MainActor
final class WeightUnitManager: ObservableObject {
    static let shared = WeightUnitManager()
    
    private let unitKey = "WeightUnit_Preference"
    
    enum WeightUnit: String, CaseIterable {
        case kg = "kg"
        case lb = "lb"
    }
    
    @Published var unit: WeightUnit {
        didSet {
            UserDefaults.standard.set(unit.rawValue, forKey: unitKey)
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: unitKey) ?? "kg"
        self.unit = WeightUnit(rawValue: saved) ?? .kg
    }
    
    // MARK: - Conversion Helpers
    
    /// 1 kg = 2.20462 lb
    private let kgToLbFactor: Double = 2.20462
    
    /// Convert kg (stored value) → display value in current unit
    func displayWeight(_ kgValue: Double) -> Double {
        switch unit {
        case .kg: return kgValue
        case .lb: return kgValue * kgToLbFactor
        }
    }
    
    /// Convert display value (in current unit) → kg for storage
    func toKg(_ displayValue: Double) -> Double {
        switch unit {
        case .kg: return displayValue
        case .lb: return displayValue / kgToLbFactor
        }
    }
    
    /// Format a kg value for display in current unit (e.g. "69.2 kg" or "152.6 lb")
    func formatWeight(_ kgValue: Double) -> String {
        let display = displayWeight(kgValue)
        if display.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f %@", display, unit.rawValue)
        } else {
            return String(format: "%.1f %@", display, unit.rawValue)
        }
    }
    
    /// Format just the number (no unit suffix)
    func formatNumber(_ kgValue: Double) -> String {
        let display = displayWeight(kgValue)
        if display.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", display)
        } else {
            return String(format: "%.1f", display)
        }
    }
    
    /// Unit label string
    var unitLabel: String {
        unit.rawValue
    }
    
    /// Standard barbell bar weight in current unit
    var barWeight: Double {
        switch unit {
        case .kg: return 20.0
        case .lb: return 45.0
        }
    }
    
    /// Standard plates available in current unit
    var availablePlates: [Double] {
        switch unit {
        case .kg: return [25, 20, 15, 10, 5, 2.5, 1.25]
        case .lb: return [45, 35, 25, 10, 5, 2.5]
        }
    }
    
    /// Default weight step for stepper buttons
    func stepSize(for equipmentType: String) -> Double {
        switch unit {
        case .kg:
            switch equipmentType {
            case "Barbell", "Machine": return 5.0
            default: return 2.5
            }
        case .lb:
            switch equipmentType {
            case "Barbell", "Machine": return 10.0
            default: return 5.0
            }
        }
    }
    
    /// Plate calculator step size
    var plateStep: Double {
        switch unit {
        case .kg: return 2.5
        case .lb: return 5.0
        }
    }
    
    /// Body weight stepper step
    var bodyWeightStep: Double {
        switch unit {
        case .kg: return 0.5
        case .lb: return 1.0
        }
    }
}
