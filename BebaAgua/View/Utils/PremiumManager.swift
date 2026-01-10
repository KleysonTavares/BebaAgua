//
//  PremiumManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 23/07/25.
//

import StoreKit

class PremiumManager: ObservableObject {
    @Published var isPremiumUser = false
    
    func checkSubscriptionStatus() {
        Task {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if transaction.productType == Product.ProductType.autoRenewable {                    DispatchQueue.main.async {
                        self.isPremiumUser = true
                    }
                        return
                    }
                default:
                    DispatchQueue.main.async {
                        self.isPremiumUser = false
                    }
                }
            }
        }
    }
}
