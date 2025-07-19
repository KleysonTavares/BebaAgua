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
    @Environment(\.dismiss) var dismiss

    var body: some View {
            VStack {
                Spacer()

                Text("Conecte-se ao aplicativo Saúde para que você possa salvar seu consumo de água")
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
                                healthKitManager.requestAuthorization()
                            }
                        }
                        .onChange(of: healthKitManager.authStatus) { status in
                            if status == .sharingAuthorized {
                                isWaterEnabled = true
                            } else {
                                isWaterEnabled = false
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
            Alert(title: Text("Atenção"), message: Text(healthKitManager.alertMessage), dismissButton: .default(Text("OK")) {
                isWaterEnabled = false
            })
        }
    }
}
