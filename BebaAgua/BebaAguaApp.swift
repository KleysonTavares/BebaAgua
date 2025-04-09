//
//  BebaAguaApp.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

@main
struct WaterTrackerApp: App {
    @AppStorage("completedOnboarding") var completedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if completedOnboarding {
                MainTabView()
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
    }
}
