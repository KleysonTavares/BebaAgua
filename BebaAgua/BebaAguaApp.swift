//
//  BebaAguaApp.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

@main
struct WaterTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.string(forKey: "gender") == nil {
                OnboardingView()
            } else {
                ContentView()
            }
        }
    }
}
