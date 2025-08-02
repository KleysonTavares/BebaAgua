//
//  PersistenceController.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 27/07/25.
//

import CoreData
import SwiftUI

class PersistenceController {
    static let shared = PersistenceController()
    @AppStorage("reminderInterval") var reminderInterval: Double = 120
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WaterModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Erro ao carregar o Core Data: \(error)")
            }
        }
    }

    func saveToCoreData(amount: Double) {
        let date = Date()
        let context = container.viewContext
        let record = WaterLog(context: context)
        record.date = date
        record.amount = amount

        do {
            try context.save()
        } catch {
            print("Erro ao salvar no Core Data: \(error)")
        }
    }

    func lastWaterIntakeDate() -> Date? {
        let context = container.viewContext
        let request: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1

        do {
            let result = try context.fetch(request)
            return result.first?.date
        } catch {
            print("Erro ao buscar último consumo: \(error)")
            return nil
        }
    }

    func shouldSendReminder() -> Bool {
        guard let lastDate = lastWaterIntakeDate() else {
            return true
        }
        let elapsed = Date().timeIntervalSince(lastDate)
        return elapsed > reminderInterval * 60
    }
}
