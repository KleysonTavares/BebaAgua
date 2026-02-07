//
//  WaterProvider.swift
//  WaterWidgetExtension
//
//  Created by Kleyson Tavares on 31/01/26.
//

import WidgetKit

struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> ()) {
        let entry = WaterEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> ()) {
        var entries: [WaterEntry] = [] // Começa vazio
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 1. Primeiro adicione as entradas ao array
        entries.append(WaterEntry(date: currentDate))
        
        let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        entries.append(WaterEntry(date: nextMidnight, waterIntake: 0))
        
        // 2. Agora sim, crie a timeline com o array preenchido
        let reloadDate = calendar.date(byAdding: .minute, value: 1, to: nextMidnight)!
        let timeline = Timeline(entries: entries, policy: .after(reloadDate))
        
        // 3. Devolva a timeline completa
        completion(timeline)
    }
}
