//
//  BebaAguaApp.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import BackgroundTasks
import GoogleMobileAds
import SwiftUI

@main
struct WaterTrackerApp: App {
    @AppStorage("completedOnboarding") var completedOnboarding: Bool = false
    
    init() {
        MobileAds.shared.start(completionHandler: { _ in })
        ReminderManager.shared.configureBackgroundTasks()
        ReminderManager.shared.scheduleAppRefresh()
    }

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
