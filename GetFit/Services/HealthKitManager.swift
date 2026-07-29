import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    @Published var stepCount: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    @Published var errorMessage: String? = nil
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        guard isAvailable, let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let status = healthStore.authorizationStatus(for: stepType)
        isAuthorized = (status == .sharingAuthorized)
    }
    
    func requestAuthorizationAndFetch(completion: (@Sendable @MainActor (Int) -> Void)? = nil) {
        guard isAvailable, let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            self.errorMessage = "HealthKit is not available on this device."
            return
        }
        
        let typesToRead: Set<HKObjectType> = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            Task { @MainActor in
                if success {
                    self?.isAuthorized = true
                    self?.errorMessage = nil
                    self?.fetchTodaySteps(completion: completion)
                } else {
                    self?.isAuthorized = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        print("[HealthKit] Authorization error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func fetchTodaySteps(completion: (@Sendable @MainActor (Int) -> Void)? = nil) {
        guard isAvailable, let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("[HealthKit] Query error: \(error.localizedDescription)")
                }
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            Task { @MainActor in
                self?.stepCount = steps
                completion?(steps)
            }
        }
        
        healthStore.execute(query)
    }
}
