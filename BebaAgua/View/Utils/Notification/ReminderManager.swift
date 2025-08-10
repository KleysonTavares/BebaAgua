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

    init() {}

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

    func configureBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.kleysontavares.bebaagua.refresh",
            using: nil
        ) { task in
            guard let task = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleAppRefresh(task: task)
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
