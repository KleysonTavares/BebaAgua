//
//  CoreDataManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 21/09/25.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "DailyIntakeModel")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Falha ao carregar o Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    // Salva um registro de consumo de água
    func saveDailyIntake(date: Date, waterConsumed: Double) {
        let fetchRequest: NSFetchRequest<DailyIntake> = DailyIntake.fetchRequest()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, calendar.date(byAdding: .day, value: 1, to: today)! as NSDate)

        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            let dailyIntake: DailyIntake
            if let existingIntake = results.first {
                dailyIntake = existingIntake
            } else {
                dailyIntake = DailyIntake(context: persistentContainer.viewContext)
                dailyIntake.date = today
            }
            
            dailyIntake.waterConsumed += waterConsumed
            try persistentContainer.viewContext.save()
        } catch {
            print("Falha ao salvar registro diário: \(error.localizedDescription)")
        }
    }
    
    // Busca registros de consumo de água
    func fetchDailyIntake(for period: String) -> [DailyIntake] {
        let fetchRequest: NSFetchRequest<DailyIntake> = DailyIntake.fetchRequest()
        
        // Retorna todos os dados para simplificar, mas você pode usar o `period` para filtrar
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyIntake.date, ascending: true)]
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Falha ao buscar registros: \(error.localizedDescription)")
            return []
        }
    }
}

