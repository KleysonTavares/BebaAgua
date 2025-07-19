//
//  HealthKitManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 09/06/25.
//

import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var authStatus: HKAuthorizationStatus = .notDetermined
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            setAlert(message: "HealthKit não está disponível neste dispositivo")
            return
        }
        
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            setAlert(message: "Tipo de dado de água não disponível no HealthKit")
            return
        }
        
        healthStore.requestAuthorization(toShare: [waterType], read: nil) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.setAlert(message: "Erro na autorização: \(error.localizedDescription)")
                    return
                }
                if success {
                    self.checkAuthorizationStatus()
                } else {
                    self.setAlert(message: "Autorização negada pelo usuário")
                }
            }
        }
    }
    
    // Salvar consumo de água
    func saveWaterConsumption(amount: Double) {
        let quantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: amount)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: Date(), end: Date())
        
        if authStatus != .sharingAuthorized {
            return
        }
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                if !success {
                    self.setAlert(message: "Erro ao salvar no app saúde: \(error?.localizedDescription ?? "Erro desconhecido")")
                }
            }
        }
    }

    private func setAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }

    internal func checkAuthorizationStatus() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            authStatus = .notDetermined
            return
        }

        self.authStatus = healthStore.authorizationStatus(for: waterType)
    }
}
