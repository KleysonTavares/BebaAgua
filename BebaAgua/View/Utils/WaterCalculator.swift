//
//  WaterCalculator.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 08/04/25.
//

import Foundation

class WaterCalculator {
    /// Calcula a meta diária de ingestão de água com base na idade e no peso.
    static func calculateDailyGoal(age: Int, weight: Double) -> Double {
        let mlPerKg: Double
        
        switch age {
        case 1...17:
            mlPerKg = 40.0
        case 18...55:
            mlPerKg = 35.0
        case 56...65:
            mlPerKg = 30.0
        default:
            mlPerKg = 25.0
        }
        
        return weight * mlPerKg
    }
}
