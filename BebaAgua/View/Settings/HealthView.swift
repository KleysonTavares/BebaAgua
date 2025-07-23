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

    var body: some View {
        VStack {
            Spacer()
            
            let message = isWaterEnabled ? LocalizedStringKey("messageAllowed") : LocalizedStringKey("messageNotAllowed")
            Text(message)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()

            HStack {
                Text(LocalizedStringKey("healthApp"))
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
            .navigationBarTitle(LocalizedStringKey("healthApp"), displayMode: .inline)
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
            Alert(title: Text(LocalizedStringKey("attention")), message: Text(healthKitManager.alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showHealthPermissionAlert) {
            Alert(
                title: Text(LocalizedStringKey("permissionRequired")),
                message: Text(LocalizedStringKey("messagePermission")),
                primaryButton: .default(Text("OK"), action: {
                    openHealthAppSettings()
                }),
                secondaryButton: .cancel(Text(LocalizedStringKey("cancel")))
            )
        }
    }
    
    private func openHealthAppSettings() {
        guard let url = URL(string: "x-apple-health://") else {
            healthKitManager.setAlert(message: "\(LocalizedStringKey("messageUnableHealth"))")
            isWaterEnabled = false
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
