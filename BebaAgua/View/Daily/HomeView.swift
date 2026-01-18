//
//  ContentView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI
import UserNotifications
import WidgetKit

struct HomeView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager

    @AppStorage("lastResetDate") var lastResetDate: String = ""
    @AppStorage("waterIntake") var waterIntake: Double = 0.0
    @AppStorage("drinkAmount") var drinkAmount: Double = 200
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    @AppStorage("adjustedGoal") var adjustedGoal: Double = 2000
    @AppStorage("wakeUpTime") var wakeUpTime: String = "06:00"
    @AppStorage("bedTime") var bedTime: String = "22:00"
    @AppStorage("reminderInterval") var reminderInterval: Double = 60
    @AppStorage("showingAuthAlert") var showingAuthAlert: Bool = false
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var premiumManager = PremiumManager()
    @StateObject private var weatherManager = WeatherManager()

    @State var dailyGoalAdjust = 0.0

    var body: some View {
        VStack {
            Spacer()
            let goal = adjustedGoal > dailyGoal ? adjustedGoal : dailyGoal
            MotivationalMessageView(progress: waterIntake / goal)

            WaterProgressView(progress: waterIntake / goal)
                .frame(width: 200, height: 200)
                .padding()
                .animation(.easeInOut(duration: 0.5), value: waterIntake)
            Text("\(Int(waterIntake)) / \(Int(goal)) ml")
                .font(.headline)
                .padding()
            Spacer()

            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 0) {    // Slider + Label
                    Text(LocalizedStringKey("cupSize"))
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Slider(value: $drinkAmount, in: 100...500, step: 50)
                        .accentColor(.cyan)
                        .onChange(of: drinkAmount) { _ in
                            SoundManager.shared.playSound(named: "water")
                        }

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
            Spacer()
        }
        .alert(LocalizedStringKey("notice"), isPresented: $healthKitManager.showAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(healthKitManager.alertMessage) }
        .onAppear {
            NotificationManager.shared.syncAndResetIfNeeded()
            NotificationManager.shared.requestNotificationPermission()
            NotificationManager.shared.scheduleDailyNotifications(wakeUpTime: wakeUpTime, bedTime: bedTime, interval: reminderInterval)
            SoundManager.shared.prepare(sounds: ["drink", "water"])
            isPremiumUser()
        }
        .standardScreenStyle()
    }

    func addWater(amount: Double) {
        withAnimation { waterIntake += amount }

        DispatchQueue.global(qos: .userInitiated).async {
            coreDataManager.saveDailyIntake(date: Date(), waterConsumed: amount)
            healthKitManager.saveWaterConsumption(amount: amount)
            syncWithAppGroup()
            NotificationManager.shared.scheduleDailyNotifications(wakeUpTime: wakeUpTime, bedTime: bedTime, interval: reminderInterval)
        }
            SoundManager.shared.playSound(named: "drink")
    }

    func syncWithAppGroup() {
        UserDefaults.shared.set(adjustedGoal, forKey: UserDefaults.Keys.adjustedGoal)
        UserDefaults.shared.set(dailyGoal, forKey: UserDefaults.Keys.dailyGoal)
        UserDefaults.shared.set(lastResetDate, forKey: UserDefaults.Keys.lastResetDate)
        UserDefaults.shared.set(waterIntake, forKey: UserDefaults.Keys.waterIntake)
        UserDefaults.shared.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func isPremiumUser() {
        if premiumManager.isPremiumUser {
            healthKitManager.requestAuthorization { _ in }
            Task {
                let locationManager = LocationManager()
                if let city = await locationManager.getCityName() {
                    await weatherManager.adjustedGoalStorage(city: city)
                } else {
                    return
                }
            }
        }
    }
}
