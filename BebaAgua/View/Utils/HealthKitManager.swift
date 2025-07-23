//
//  HealthKitManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 09/06/25.
//

import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var authStatus: HKAuthorizationStatus = .notDetermined
    
    func requestAuthorization(completion: @escaping (HKAuthorizationStatus) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            setAlert(message: "\(LocalizedStringKey("healthUnavailable"))")
            completion(.notDetermined)
            return
        }
        
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            setAlert(message: "\(LocalizedStringKey("healthWaterUnavailable"))")
            completion(.notDetermined)
            return
        }
        
        healthStore.requestAuthorization(toShare: [waterType], read: nil) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.setAlert(message: "\(LocalizedStringKey("healthErrorAuthorization")) \(error.localizedDescription)")
                    completion(.notDetermined)
                    return
                }
                self.checkAuthorizationStatus()
                completion(self.authStatus)
            }
        }
    }
    
    func saveWaterConsumption(amount: Double) {
        let quantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: amount)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: Date(), end: Date())
        
        if authStatus != .sharingAuthorized {
            return
        }
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                let healthErrorSave = NSLocalizedString("healthErrorSave", comment: "")
                let healthErrorUnknown = NSLocalizedString("healthErrorUnknown", comment: "")
                let fullMessage = "\(healthErrorSave) \(error?.localizedDescription ?? healthErrorUnknown)"

                if !success {
                    self.setAlert(message: fullMessage)
                }
            }
        }
    }

    func setAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }

    func checkAuthorizationStatus() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            authStatus = .notDetermined
            return
        }

        self.authStatus = healthStore.authorizationStatus(for: waterType)
    }
}
