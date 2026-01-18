//
//  ExtensionUserDefaults.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 17/01/26.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let name = "group.com.kleysontavares.bebaagua"
        guard let group = UserDefaults(suiteName: name) else {
            fatalError("App Group \(name) não pôde ser carregado. Verifique as Capabilities.")
        }
        return group
    }

    enum Keys {
        static let adjustedGoal = "adjustedGoal"
        static let age = "age"
        static let bedTime = "bedTime"
        static let completedOnboarding = "completedOnboarding"
        static let dailyGoal = "dailyGoal"
        static let gender = "gender"
        static let lastResetDate = "lastResetDate"
        static let reminderInterval = "reminderInterval"
        static let wakeUpTime = "wakeUpTime"
        static let waterIntake = "waterIntake"
        static let weight = "weight"
    }
}
