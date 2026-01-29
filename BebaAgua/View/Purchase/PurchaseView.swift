//
//  PurchaseView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/01/26.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showAlert = false
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss

    let benefits = [
        "purchaseBenefits1",
        "purchaseBenefits2",
        "purchaseBenefits3",
        "purchaseBenefits4",
        "purchaseBenefits5"
    ]

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    headerView
                    benefitsList
                    planCardList
                    purchaseButton
                }
                .blur(radius: showSuccess ? 10 : 0)
                .disabled(showSuccess)
                if showSuccess {
                    successOverlay
                }
            }
        }
        .standardScreenStyle()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                }
            }
        }
        .alert(LocalizedStringKey("purchaseAlertTitle"), isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { premiumManager.errorMessage = nil }
        }, message: {
            if let message = premiumManager.errorMessage {
                Text(verbatim: message)
            } else {
                Text(LocalizedStringKey("alertUnknownError"))
            }
        })
        .onChange(of: premiumManager.errorMessage) {
            if premiumManager.errorMessage != nil { showAlert = true }
        }
    }

    private var headerView: some View {
        VStack(spacing: 10) {
            Text(LocalizedStringKey("purchaseTitle"))
                .font(.title.bold())
                .multilineTextAlignment(.center)
        }.padding(.top, 40)
    }

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(benefits, id: \.self) { benefit in
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cyan)
                    Text(LocalizedStringKey(benefit))
                }
            }
        }
        .padding(.horizontal, 10)
    }

    private var planCardList: some View {
        VStack(spacing: 12) {
            PlanCard(plan: .monthly, isSelected: premiumManager.selectedProductId == PurchasePlan.monthly.productId) {
                withAnimation {
                                premiumManager.selectedProductId = PurchasePlan.monthly.productId
                            }
            }
            PlanCard(plan: .annual, isSelected: premiumManager.selectedProductId == PurchasePlan.annual.productId) {
                withAnimation {
                                premiumManager.selectedProductId = PurchasePlan.annual.productId
                            }
            }
            PlanCard(plan: .lifetime, isSelected: premiumManager.selectedProductId == PurchasePlan.lifetime.productId) {
                withAnimation {
                                premiumManager.selectedProductId = PurchasePlan.lifetime.productId
                            }
            }
        }
        .padding(.horizontal)
        .disabled(premiumManager.isPurchasing)
    }

    private var purchaseButton: some View {
        Button(action: {
            purchaseSelectedProduct()
        }) {
            ZStack {
                Text(premiumManager.selectedProductId == PurchasePlan.lifetime.productId ? LocalizedStringKey("purchaseBuyNow") : LocalizedStringKey("purchaseSubscribeNow"))
                    .opacity(premiumManager.isPurchasing ? 0 : 1)
                if premiumManager.isPurchasing {
                    ProgressView().tint(.white)
                }
            }
            .customButton()
        }
        .disabled(premiumManager.isPurchasing || showSuccess)
        .padding(.bottom, 20)
    }

    private var successOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .scaleEffect(showSuccess ? 1.0 : 0.5)
                .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: showSuccess)
            Text(LocalizedStringKey("purchaseSuccessTitle"))
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text(LocalizedStringKey("purchaseSuccessSubtitle"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color(.systemBackground)).shadow(radius: 20))
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }

    private func purchaseSelectedProduct() {
        let currentSelection = premiumManager.selectedProductId
        if let product = premiumManager.products.first(where: { $0.id == currentSelection }) {
            Task {
                await premiumManager.purchase(product)
                if premiumManager.isPremiumUser {
                    withAnimation(.spring()) {
                        showSuccess = true
                    }
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    dismiss()
                }
            }
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
