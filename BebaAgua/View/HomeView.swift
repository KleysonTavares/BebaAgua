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
    @StateObject private var adViewModel = AdInterstitialViewModel()
    @StateObject private var weatherManager = WeatherManager()

    @State private var adShown = false
    @State var dailyGoalAdjust = 0.0

    var body: some View {
            VStack {
                Spacer()
                
                MotivationalMessageView(progress: waterIntake / adjustedGoal)

                WaterProgressView(progress: waterIntake / adjustedGoal)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("\(Int(waterIntake)) / \(Int(adjustedGoal)) ml")
                    .font(.headline)
                    .padding()
                Spacer()
                
                HStack(spacing: 20) {
                    VStack(alignment: .center, spacing: 0) {     // Slider + Label
                        Text(LocalizedStringKey("cupSize"))
                            .font(.headline)
                        
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
                premiumManager.checkSubscriptionStatus()
                checkAndResetDailyIntake()
                NotificationManager.shared.requestNotificationPermission()
                NotificationManager.shared.scheduleDailyNotifications(wakeUpTime: wakeUpTime, bedTime: bedTime, interval: reminderInterval)
                isPremiumUser()
                syncWithAppGroup()
            }
            .onReceive(adViewModel.$isAdReady) { isReady in
                if isReady && !premiumManager.isPremiumUser && !adShown {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let root = UIApplication.shared.connectedScenes
                            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                            .first?.rootViewController {
                            adViewModel.showAd(from: root)
                            adShown = true
                        }
                    }
                }
            }
            .standardScreenStyle()
    }
    
    func addWater(amount: Double) {
        withAnimation {
            waterIntake += amount
            syncWithAppGroup()
            SoundManager.shared.playSound(named: "drink")
        }
            healthKitManager.saveWaterConsumption(amount: amount)
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

    func syncWithAppGroup() {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.kleysontavares.bebaagua") {
            sharedDefaults.set(waterIntake, forKey: "waterIntake")
            sharedDefaults.set(dailyGoal, forKey: "dailyGoal")
            sharedDefaults.synchronize()
        }
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
