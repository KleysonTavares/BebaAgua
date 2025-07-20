//
//  HealthView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 19/06/25.
//

import SwiftUI
import HealthKit

struct HealthAppView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var isWaterEnabled: Bool = false
    @State private var showHealthPermissionAlert = false
    @Environment(\.dismiss) var dismiss
    let messagePermission = """
    1. Abra o app Saúde.
    2. Toque em Compartilhar.
    3. Toque em Apps.
    4. Selecione BebaAgua.
    """

    var body: some View {
        VStack {
            Spacer()
            
            let message = isWaterEnabled ? "Parabéns, você já permitiu o acesso ao HealthKit" : "Conecte-se ao aplicativo Saúde para que você possa salvar seu consumo de água"
            Text(message)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()

            HStack {
                Text("Water")
                    .foregroundColor(.white)
                    .padding(.leading)

                Spacer()

                Toggle("", isOn: $isWaterEnabled)
                    .labelsHidden()
                    .onChange(of: isWaterEnabled) { newValue in
                        if newValue {
                            healthKitManager.requestAuthorization { [self] status in
                                DispatchQueue.main.async {
                                    if status == .sharingDenied {
                                        self.showHealthPermissionAlert = true
                                        self.isWaterEnabled = false
                                    } else {
                                        self.isWaterEnabled = (status == .sharingAuthorized)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.trailing)
            }
            .customButton()
            .navigationBarTitle("Health app", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .standardScreenStyle()
        .onAppear {
            healthKitManager.checkAuthorizationStatus()
            isWaterEnabled = healthKitManager.authStatus == .sharingAuthorized
        }
        .alert(isPresented: $healthKitManager.showAlert) {
            Alert(title: Text("Atenção"), message: Text(healthKitManager.alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showHealthPermissionAlert) {
            Alert(
                title: Text("Permissão necessária"),
                message: Text(messagePermission),
                primaryButton: .default(Text("OK"), action: {
                    openHealthAppSettings()
                }),
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
    }
    
    private func openHealthAppSettings() {
        guard let url = URL(string: "x-apple-health://") else {
            healthKitManager.setAlert(message: "Não foi possível abrir o aplicativo Saúde")
            isWaterEnabled = false
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
