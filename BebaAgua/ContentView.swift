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
    @State private var dailyGoal: Double = 2000 // Meta diária em ml
    @State private var reminderInterval: Double = 60 // Intervalo em minutos
    
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
                
                NavigationLink(destination: SettingsView(dailyGoal: $dailyGoal, reminderInterval: $reminderInterval)) {
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

struct SettingsView: View {
    @Binding var dailyGoal: Double
    @Binding var reminderInterval: Double
    
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

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeOut, value: progress)
        }
    }
}
