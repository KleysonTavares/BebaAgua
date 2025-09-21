//
//  BebaAguaApp.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import CoreData
import GoogleMobileAds
import SwiftUI

@main
struct WaterTrackerApp: App {
    @AppStorage("completedOnboarding") var completedOnboarding: Bool = false
    @StateObject private var coreDataManager = CoreDataManager()

    init() {
        MobileAds.shared.start(completionHandler: { _ in })
    }

    var body: some Scene {
        WindowGroup {
            if completedOnboarding {
                MainTabView()
                    .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
                    .environmentObject(coreDataManager) // Adicione esta linha
            } else {
                NavigationStack {
                    WelcomeView()
                        .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
                        .environmentObject(coreDataManager) // Adicione esta linha
                }
            }
        }
    }
}
