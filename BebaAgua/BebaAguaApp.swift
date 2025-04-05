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
            if UserDefaults.standard.string(forKey: "dailyGoal") == nil {
                WelcomeView()
            } else {
                HomeView()
            }
        }
    }
}
