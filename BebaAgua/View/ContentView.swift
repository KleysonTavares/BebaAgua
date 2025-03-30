//
//  ContentView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var waterIntake: Double = 0.0
    @State private var dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
    @State private var reminderInterval = UserDefaults.standard.double(forKey: "reminderInterval")
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Seu Consumo Diário")
                    .font(.title)
                    .padding()
                
                CircularProgressView(progress: waterIntake / dailyGoal)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("\(Int(waterIntake)) ml de \(Int(dailyGoal)) ml")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    addWater(amount: 250)
                }) {
                    Text("+250 ml")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Text("Configurações")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Lembrete de Água")
            .onAppear {
                requestNotificationPermission()
                scheduleWaterReminder()
            }
        }
    }
    
    func addWater(amount: Double) {
        withAnimation {
            waterIntake += amount
            if waterIntake > dailyGoal {
                waterIntake = dailyGoal
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão de notificação: \(error)")
            }
        }
    }
    
    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Hora de beber água!"
        content.body = "Lembre-se de se manter hidratado!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderInterval * 60, repeats: true)
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error)")
            }
        }
    }
}
