//
//  PremiumManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 23/07/25.
//

import StoreKit

@MainActor
class PremiumManager: ObservableObject {
    @Published var isPremiumUser = false
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var isPurchasing = false

    private let productIds = [
        PurchasePlan.monthly.productId,
        PurchasePlan.annual.productId,
        PurchasePlan.lifetime.productId
    ]

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }

        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
        }
    }

    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            handleStoreError(error)
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleTransactionResult(verification)
                isPurchasing = false
            case .userCancelled:
                isPurchasing = false
            case .pending:
                errorMessage = "Sua compra está pendente de aprovação pela App Store."
                isPurchasing = false
            @unknown default:
                isPurchasing = false
            }
        } catch {
            handleStoreError(error)
            isPurchasing = false
        }
    }

    func checkSubscriptionStatus() async {
        var hasActiveEntitlement = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    hasActiveEntitlement = true
                    break
                }
            }
        }

        let status = hasActiveEntitlement
        await MainActor.run {
            self.isPremiumUser = status
        }
    }

    private func handleStoreError(_ error: Error) {
        if let storeError = error as? StoreKitError {
            switch storeError {
            case .networkError(_):
                errorMessage = "Erro de conexão. Verifique sua internet."
            case .systemError(_):
                errorMessage = "O sistema da App Store está temporariamente indisponível."
            case .notEntitled:
                errorMessage = "Você não tem permissão para realizar esta compra."
            default:
                errorMessage = "Ocorreu um erro inesperado com a App Store."
            }
        } else {
            errorMessage = "Não foi possível completar a transação."
        }
    }

    private func handleTransactionResult(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await MainActor.run {
                self.isPremiumUser = true
                self.isPurchasing = false
            }
            await transaction.finish()

        case .unverified(_, let error):
            print("Transação não verificada: \(error.localizedDescription)")
            await MainActor.run {
                self.isPurchasing = false
            }
        }
    }
}
