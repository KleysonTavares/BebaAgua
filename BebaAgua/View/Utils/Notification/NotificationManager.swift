//
//  ManagerNotification.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import CoreData
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    @AppStorage("wakeUpTime") var wakeUpTime: String = "06:00"
    @AppStorage("bedTime") var bedTime: String = "22:00"
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000

    private init() {}

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
    func sendNotification(title: String, body: String) {
        removeAllWaterReminders()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName("water.caf"))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "waterReminder",
            content: content,
            trigger: trigger
        )
    }
    
    func evaluateSmartReminder() {
        let currentHour = Calendar.current.component(.hour, from: Date())

        let motivationalMessagesKeys = [
            "notificationBody1",
            "notificationBody2",
            "notificationBody3",
            "notificationBody4",
            "notificationBody5",
            "notificationBody6",
            "notificationBody7"
        ]
        
        guard let wakeUpDate = getHourFromTimeString(wakeUpTime),
              let bedTimeDate = getHourFromTimeString(bedTime) else {
            print("Horários inválidos")
            return
        }

        guard currentHour >= wakeUpDate && currentHour <= bedTimeDate else { return }

        let persistence = PersistenceController.shared
        let shouldNotify = persistence.shouldSendReminder()

        if shouldNotify {
            let notificationTitle = NSLocalizedString("notificationTitle", comment: "")
            let notificationBody = NSLocalizedString(motivationalMessagesKeys.randomElement() ?? "notificationBody", comment: "")
            self.sendNotification(title: notificationTitle, body: notificationBody)
        } else {
            print("Usuário já consumiu água recentemente. Nenhuma notificação enviada.")
        }
    }

    func removeAllWaterReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func getHourFromTimeString(_ timeString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return Calendar.current.component(.hour, from: formatter.date(from: timeString) ?? .now)
    }
    
}
