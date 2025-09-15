//
//  ManagerNotification.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import UserNotifications
import SwiftUI
import WidgetKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let suiteName = "group.com.kleysontavares.bebaagua"

    private override init() {}

    // MARK: - Configuração Básica
    func requestNotificationPermission(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("\(LocalizedStringKey("errorNotificationPermission")) \(error)")
                completion?(false)
                return
            }
            completion?(granted)
        }
    }

    // MARK: - Agendamento de Notificações
    func scheduleDailyNotifications(wakeUpTime: String, bedTime: String, interval: Double) {
        removeAllWaterReminders()

        guard let wakeUpDate = convertTimeStringToDate(wakeUpTime),
              let bedTimeDate = convertTimeStringToDate(bedTime) else {
            print("Horários inválidos")
            return
        }

        let calendar = Calendar.current
        let now = Date()

        var startDate = calendar.date(bySettingHour: calendar.component(.hour, from: wakeUpDate),
                                          minute: calendar.component(.minute, from: wakeUpDate),
                                          second: 0,
                                          of: now) ?? now

        if startDate < now {
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        }

        let motivationalMessagesKeys = [
            "notificationBody1",
            "notificationBody2",
            "notificationBody3",
            "notificationBody4",
            "notificationBody5",
            "notificationBody6",
            "notificationBody7"
        ]

        let notificationTitle = NSLocalizedString("notificationTitle", comment: "")
        let notificationBody = NSLocalizedString(motivationalMessagesKeys.randomElement() ?? "notificationBody", comment: "")

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = UNNotificationSound(named: UNNotificationSoundName("water.caf"))
        
        let totalMinutes = calendar.dateComponents([.minute], from: wakeUpDate, to: bedTimeDate).minute ?? 0
        let numberOfNotifications = Int(Double(totalMinutes) / interval)

        for i in 0..<numberOfNotifications {
            let minutesToAdd = Int(interval * Double(i))
            if let triggerDate = calendar.date(byAdding: .minute, value: minutesToAdd, to: startDate),
               isWithinNotificationPeriod(wakeUpTime: wakeUpTime, bedTime: bedTime, for: triggerDate) {
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.hour, .minute], from: triggerDate),
                    repeats: true
                )
                
                let request = UNNotificationRequest(
                    identifier: "waterReminder_\(i)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("\(i): \(error)")
                    }
                }
            }
        }
    }
    
    func removeAllWaterReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Funções Auxiliares
    private func convertTimeStringToDate(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: timeString)
    }
    
    private func isWithinNotificationPeriod(wakeUpTime: String, bedTime: String, for date: Date = Date()) -> Bool {
        guard let wakeUpDate = convertTimeStringToDate(wakeUpTime),
              let bedTimeDate = convertTimeStringToDate(bedTime) else {
            return false
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        let wakeUpComponents = calendar.dateComponents([.hour, .minute], from: wakeUpDate)
        let bedTimeComponents = calendar.dateComponents([.hour, .minute], from: bedTimeDate)
        
        let dateMinutes = (dateComponents.hour ?? 0) * 60 + (dateComponents.minute ?? 0)
        let wakeUpMinutes = (wakeUpComponents.hour ?? 0) * 60 + (wakeUpComponents.minute ?? 0)
        let bedTimeMinutes = (bedTimeComponents.hour ?? 0) * 60 + (bedTimeComponents.minute ?? 0)
        
        if wakeUpMinutes < bedTimeMinutes {
            return dateMinutes >= wakeUpMinutes && dateMinutes <= bedTimeMinutes
        } else {
            return dateMinutes >= wakeUpMinutes || dateMinutes <= bedTimeMinutes
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "dailyReset" {
            syncAndResetIfNeeded()
        }
        completionHandler()
    }

    func syncAndResetIfNeeded() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let today = dateFormatter.string(from: Date())
        let appDefaults = UserDefaults.standard
        let widgetDefaults = UserDefaults(suiteName: suiteName)
        var needsReset = false
        let appLastResetDate = appDefaults.string(forKey: "lastResetDate") ?? ""
        let widgetLastResetDate = widgetDefaults?.string(forKey: "lastResetDate") ?? ""

        if appLastResetDate != today || widgetLastResetDate != today {
            needsReset = true
        }

        if needsReset {
            appDefaults.set(0.0, forKey: "waterIntake")
            appDefaults.set(0.0, forKey: "adjustedGoal")
            appDefaults.set(today, forKey: "lastResetDate")

            widgetDefaults?.set(0.0, forKey: "waterIntake")
            widgetDefaults?.set(0.0, forKey: "adjustedGoal")
            widgetDefaults?.set(today, forKey: "lastResetDate")
            widgetDefaults?.synchronize()

            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
