//
//  ContentView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI
import UserNotifications

struct HomeView: View {
    @AppStorage("lastResetDate") var lastResetDate: String = ""
    @AppStorage("waterIntake") var waterIntake: Double = 0.0
    @AppStorage("drinkAmount") var drinkAmount: Double = 200
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    @AppStorage("reminderInterval") var reminderInterval: Double = 60

    var body: some View {
            VStack {
                Spacer()
                
                Text("Progresso hoje")
                    .font(.title)
                    .padding()
                    Spacer()

                WaterProgressView(progress: waterIntake / dailyGoal)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("\(Int(waterIntake)) / \(Int(dailyGoal)) ml")
                    .font(.headline)
                    .padding()
                Spacer()
                
                HStack(spacing: 20) {
                    VStack(alignment: .center, spacing: 0) {     // Slider + Label
                        Text("tamanho copo")
                            .font(.headline)
                        
                        Slider(value: $drinkAmount, in: 100...500, step: 50)
                            .accentColor(.cyan)
                        
                        Text("\(Int(drinkAmount)) ml")
                            .foregroundColor(.cyan)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(width: 250, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    
               
                    Button(action: {      // Button with image
                        addWater(amount: drinkAmount)
                    }) {
                        Image("addWater")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 80)
                            .cornerRadius(20)
                    }
                }
                .padding()
            }
            .onAppear {
                checkAndResetDailyIntake()
                requestNotificationPermission()
                scheduleWaterReminder()
            }
            .standardScreenStyle()
    }
    
    func addWater(amount: Double) {
        withAnimation {
            waterIntake += amount
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
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder"])

        let content = UNMutableNotificationContent()
        content.title = "Hora de beber água!"
        content.body = "Lembre-se de se manter hidratado!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderInterval * 60, repeats: true)
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error)")
            }
        }
    }

    func checkAndResetDailyIntake() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        let today = dateFormatter.string(from: Date())

        if lastResetDate != today {
            waterIntake = 0
            lastResetDate = today
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
