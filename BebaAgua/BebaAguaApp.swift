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
    private let reminderManager = ReminderManager.shared
    
    init() {
        MobileAds.shared.start(completionHandler: { _ in })
        configureBackgroundTasks()
        ReminderManager.shared.scheduleAppRefresh()
    }

    private func configureBackgroundTasks() {
            let manager = ReminderManager.shared

            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.kleysontavares.bebaagua.refresh",
                using: nil
            ) { task in
                guard let task = task as? BGAppRefreshTask else {
                    task.setTaskCompleted(success: false)
                    return
                }
                manager.handleAppRefresh(task: task)
            }
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
