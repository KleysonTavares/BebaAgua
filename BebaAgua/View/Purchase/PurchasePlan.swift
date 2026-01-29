//
//  PurchasePlan.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/01/26.
//

import SwiftUI

enum PurchasePlan: String, CaseIterable {
    case monthly, annual, lifetime

    var title: LocalizedStringKey {
        switch self {
        case .monthly: return LocalizedStringKey("purchaseMonthlyTitle")
        case .annual: return LocalizedStringKey("purchaseAnnualTitle")
        case .lifetime: return LocalizedStringKey("purchaseLifetimeTitle")
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .monthly: return LocalizedStringKey("purchaseMonthlySubtitle")
        case .annual: return LocalizedStringKey("purchaseAnnualSubtitle")
        case .lifetime: return LocalizedStringKey("purchaseLifetimeSubtitle")
        }
    }

    var price: LocalizedStringKey {
        switch self {
        case .monthly: return LocalizedStringKey("purchaseMonthlyPrice")
        case .annual: return LocalizedStringKey("purchaseAnnualPrice")
        case .lifetime: return LocalizedStringKey("purchaseLifetimePrice")
        }
    }

    var productId: String {
        switch self {
        case .monthly: return "com.bebaagua.monthly"
        case .annual: return "com.bebaagua.annual"
        case .lifetime: return "com.bebaagua.lifetime"
        }
    }
}
