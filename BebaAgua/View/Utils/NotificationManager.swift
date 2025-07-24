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
        
        // Calcular data de início (hoje no wakeUpTime ou amanhã se já passou)
        var startDate = calendar.date(bySettingHour: calendar.component(.hour, from: wakeUpDate),
                                         minute: calendar.component(.minute, from: wakeUpDate),
                                         second: 0,
                                         of: now) ?? now
        
        if startDate < now {
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        }
        
        // Conteúdo da notificação
        let notificationTitle = NSLocalizedString("notificationTitle", comment: "")
        let notificationBody = NSLocalizedString("notificationBody", comment: "")

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default
        
        // Calcular notificações no período
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
                        print("\(LocalizedStringKey("ErrorNotificationScheduling")) \(i): \(error)")
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
}
