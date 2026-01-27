//
//  PurchaseView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/01/26.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @StateObject private var premiumManager = PremiumManager()
    @State private var selectedProductId: String = "com.bebaagua.annual"
    @State private var showAlert = false
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss

    let benefits = [
        "Acesso ao HealthKit",
        "Integração com o Clima da Cidade",
        "Sem Anúncios",
        "Widgets Exclusivos",
        "Notificações Avançadas com IA"
    ]

    var body: some View {
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
        .standardScreenStyle()
        .alert("Aviso", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { premiumManager.errorMessage = nil }
        }, message: {
            Text(premiumManager.errorMessage ?? "Erro desconhecido")
        })
        .onChange(of: premiumManager.errorMessage) {
            if premiumManager.errorMessage != nil { showAlert = true }
        }
    }

    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Mantenha-se hidratado com todos os recursos")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
        }.padding(.top, 40)
    }

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(benefits, id: \.self) { benefit in
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cyan)
                    Text(benefit)
                }
            }
        }
        .padding(.horizontal, 10)
    }

    private var planCardList: some View {
        VStack(spacing: 12) {
            PlanCard(plan: .monthly, isSelected: selectedProductId == PurchasePlan.monthly.productId) {
                selectedProductId = PurchasePlan.monthly.productId
            }
            PlanCard(plan: .annual, isSelected: selectedProductId == PurchasePlan.annual.productId) {
                selectedProductId = PurchasePlan.annual.productId
            }
            PlanCard(plan: .lifetime, isSelected: selectedProductId == PurchasePlan.lifetime.productId) {
                selectedProductId = PurchasePlan.lifetime.productId
            }
        }
        .padding(.horizontal)
    }

    private var purchaseButton: some View {
        Button(action: {
            purchaseSelectedProduct()
        }) {
            ZStack {
                Text(selectedProductId == "com.bebaagua.lifetime" ? "COMPRAR AGORA" : "ASSINAR AGORA")
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
            Text("Assinatura Confirmada!")
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text("Agora você é um usuário Premium.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color(.systemBackground)).shadow(radius: 20))
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }

    private func purchaseSelectedProduct() {
        if let product = premiumManager.products.first(where: { $0.id == selectedProductId }) {
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
