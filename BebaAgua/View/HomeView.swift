//
//  ContentView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI
import UserNotifications

struct HomeView: View {
    @State private var path = NavigationPath()
    @State private var waterIntake: Double = 0.0
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    @AppStorage("reminderInterval") var reminderInterval: Double = 60

    var body: some View {
        NavigationStack(path: $path) {
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
                        .customButton()
                }
                
                Button(action: { path.append(RouteScreensEnum.settings)}) {
                    Text("Configurar")
                        .customButton()
                }
                .navigationDestination(for: RouteScreensEnum.self) { route in
                    RouteScreen.destination(for: route, path: $path)
                }
                Spacer()
            }
            .onAppear {
                requestNotificationPermission()
                scheduleWaterReminder()
            }
        }
        .navigationBarBackButtonHidden(true)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
