//
//  WaterIntakeDay.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/07/25.
//

import Foundation

struct WaterIntakeDay: Identifiable {
    var id: String { dateString } // Ex: "24/07"
    let dateString: String
    let amount: Double

    func saveDailyIntake(_ amount: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        let key = "intake_\(formatter.string(from: Date()))"

        let currentAmount = UserDefaults.standard.double(forKey: key)
        UserDefaults.standard.set(currentAmount + amount, forKey: key)
    }
}
