//
//  PurchasePlan.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/01/26.
//

enum PurchasePlan: String, CaseIterable {
    case monthly, annual, lifetime

    var title: String {
        switch self {
        case .monthly: return "7 dias grátis, depois"
        case .annual: return "12 Meses"
        case .lifetime: return "Compre para sempre"
        }
    }

    var subtitle: String {
        switch self {
        case .monthly: return "Cobrado mensalmente"
        case .annual: return "Economize 30%"
        case .lifetime: return "Pagamento único"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "R$ 9,90"
        case .annual: return "R$ 79,90"
        case .lifetime: return "R$ 149,90"
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
