//
//  SmartReminderManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 27/07/25.
//

import BackgroundTasks
import Foundation
import UserNotifications

class ReminderManager {
    static let shared = ReminderManager()
    
    private init() {}

    let positiveMessages = [
        "Seu corpo agradece ❤️",
        "Hora de se hidratar 💧",
        "Um gole faz a diferença!",
        "Cuide-se com um pouco de água 💙",
        "Beba água e fique bem!",
        "Mais um copo, mais saúde!",
        "Seu corpo vai amar isso 💦"
    ]

    func evaluateAndNotifyIfNeeded() {
        guard PersistenceController.shared.shouldSendReminder() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Lembrete de Hidratação"
        content.body = positiveMessages.randomElement() ?? "Hora de beber água"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    // Agendar nova execução
        func scheduleAppRefresh() {
            let request = BGAppRefreshTaskRequest(identifier: "com.kleysontavares.bebaagua.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutos

            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Erro ao agendar BGAppRefresh: \(error)")
            }
        }

        // Lógica da tarefa
        func handleAppRefresh(task: BGAppRefreshTask) {
            scheduleAppRefresh() // Reagenda após execução

            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1

            let operation = BlockOperation {
                NotificationManager.shared.evaluateSmartReminder()
            }

            task.expirationHandler = {
                queue.cancelAllOperations()
            }

            operation.completionBlock = {
                task.setTaskCompleted(success: !operation.isCancelled)
            }

            queue.addOperation(operation)
        }
}
