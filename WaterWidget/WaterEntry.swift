//
//  WaterEntry.swift
//  WaterWidgetExtension
//
//  Created by Kleyson Tavares on 31/01/26.
//

import WidgetKit

struct WaterEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let dailyGoal: Double
    let adjustedGoal: Double

    init(date: Date, waterIntake: Double? = nil) {
        self.date = date
        // Sempre buscamos as metas atualizadas
        self.dailyGoal = UserDefaults.shared.double(forKey: UserDefaults.Keys.dailyGoal)
        self.adjustedGoal = UserDefaults.shared.double(forKey: UserDefaults.Keys.adjustedGoal)
        
        if let intake = waterIntake {
            self.waterIntake = intake
        } else {
            // Se a data da entrada for HOJE, pega o que está no App
            // Se for uma data FUTURA (meia-noite), assume 0
            let isToday = Calendar.current.isDateInToday(date)
            self.waterIntake = isToday ? UserDefaults.shared.double(forKey: UserDefaults.Keys.waterIntake) : 0
        }
    }
}
