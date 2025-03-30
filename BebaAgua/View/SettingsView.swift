//
//  SettingsView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
    @State private var reminderInterval = UserDefaults.standard.double(forKey: "reminderInterval")
    
    var body: some View {
        Form {
            Section(header: Text("Meta Diária de Água (ml)")) {
                Slider(value: $dailyGoal, in: 500...5000, step: 100)
                Text("Meta: \(Int(dailyGoal)) ml")
            }
            
            Section(header: Text("Intervalo de Notificações (minutos)")) {
                Slider(value: $reminderInterval, in: 15...180, step: 15)
                Text("Intervalo: \(Int(reminderInterval)) min")
            }
        }
        .navigationTitle("Configurações")
    }
}

