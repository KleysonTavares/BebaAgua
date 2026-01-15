//
//  BebaAguaApp.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import CoreData
import SwiftUI

@main
struct WaterTrackerApp: App {
    @AppStorage("completedOnboarding") var completedOnboarding: Bool = false
    @StateObject private var coreDataManager = CoreDataManager()

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
        .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
        .environmentObject(coreDataManager)
    }
}
