//
//  WaterWidget.swift
//  WaterWidget
//
//  Created by Kleyson Tavares on 24/07/25.
//

import WidgetKit
import SwiftUI

struct WaterEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let dailyGoal: Double
    let adjustedGoal: Double

    init(date: Date) {
        self.date = date
        let sharedDefaults = UserDefaults(suiteName: "group.com.kleysontavares.bebaagua")
        WaterEntry.checkAndResetDailyIntake(sharedDefaults: sharedDefaults)
        self.waterIntake = sharedDefaults?.double(forKey: "waterIntake") ?? 0
        self.dailyGoal = sharedDefaults?.double(forKey: "dailyGoal") ?? 2000
        self.adjustedGoal = sharedDefaults?.double(forKey: "adjustedGoal") ?? 2000
    }

    private static func checkAndResetDailyIntake(sharedDefaults: UserDefaults?) {
        guard let sharedDefaults = sharedDefaults else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let today = dateFormatter.string(from: Date())
        let lastResetDate = sharedDefaults.string(forKey: "lastResetDate") ?? ""

        if lastResetDate != today {
            sharedDefaults.set(0.0, forKey: "waterIntake")
            sharedDefaults.set(0.0, forKey: "adjustedGoal")
            sharedDefaults.set(today, forKey: "lastResetDate")
            sharedDefaults.synchronize()
        }
    }
}

struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> ()) {
        let entry = WaterEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> ()) {
        let currentDate = Date()
        let entry = WaterEntry(date: currentDate)
        let calendar = Calendar.current
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: currentDate)) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct WaterWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WaterProvider.Entry
    let dailyGoal = NSLocalizedString("dailyGoal", bundle: .main, comment: "")
    let consumed = NSLocalizedString("consumed", bundle: .main, comment: "")
    var goal: Double {
        entry.adjustedGoal > entry.dailyGoal ? entry.adjustedGoal : entry.dailyGoal
    }
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(entry.waterIntake / goal, 1.0)
    }

    var body: some View {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            default:
                smallView
            }
        }

    var smallView: some View {
        VStack(spacing: 12) {
            // Progresso circular
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.cyan)

                Circle()
                    .trim(from: 0.0, to: min(entry.waterIntake / goal, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: entry.waterIntake)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .frame(width: 70, height: 70)

            // Quantidade
            Text("\(Int(entry.waterIntake)) / \(Int(goal))ml")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var mediumView: some View {
            HStack {
                smallView
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(dailyGoal))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(goal)) ml")
                        .font(.headline)

                    Text(LocalizedStringKey(consumed))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(entry.waterIntake)) ml")
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
        }
}

@main
struct WaterWidget: Widget {
    let kind: String = "WaterWidget"
    let waterProgress = NSLocalizedString("waterProgress", bundle: .main, comment: "")
    let description = NSLocalizedString("description", bundle: .main, comment: "")

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            WaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey(waterProgress))
        .description(LocalizedStringKey(description))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now)
}

#Preview(as: .systemMedium) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now)
}
