//
//  ManagerNotification.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                completion?(false)
                return
            }
            completion?(granted)
        }
    }

    func scheduleDailyNotifications(wakeUpTime: String, bedTime: String, interval: Double) {
        removeAllWaterReminders()
        
        guard let wakeUpDate = convertTimeStringToDate(wakeUpTime),
              let bedTimeDate = convertTimeStringToDate(bedTime) else {
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
        
        let totalMinutes = calendar.dateComponents([.minute], from: wakeUpDate, to: bedTimeDate).minute ?? 0
        let numberOfNotifications = max(1, Int(Double(totalMinutes) / interval))
        
        for i in 0..<numberOfNotifications {
            let minutesToAdd = Int(interval * Double(i))
            if let triggerDate = calendar.date(byAdding: .minute, value: minutesToAdd, to: startDate) {
                
                if isWithinNotificationPeriod(wakeUpTime: wakeUpTime, bedTime: bedTime, for: triggerDate) {
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: calendar.dateComponents([.hour, .minute], from: triggerDate),
                        repeats: true
                    )
                    let content = createNotificationContent()
                    let request = UNNotificationRequest(
                        identifier: "waterReminder_\(i)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Erro ao agendar notificação \(i): \(error)")
                        }
                    }
                }
            }
        }
    }

    func removeAllWaterReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func createNotificationContent() -> UNMutableNotificationContent {
        let motivationalMessagesKeys = [
            "notificationBody1",
            "notificationBody2", 
            "notificationBody3",
            "notificationBody4",
            "notificationBody5",
            "notificationBody6",
            "notificationBody7"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notificationTitle", comment: "")
        content.body = NSLocalizedString(motivationalMessagesKeys.randomElement() ?? "notificationBody", comment: "")
        content.sound = UNNotificationSound(named: UNNotificationSoundName("water.caf"))
        
        return content
    }
    
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
}
