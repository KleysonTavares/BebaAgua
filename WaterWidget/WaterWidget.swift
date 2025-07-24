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

    init(date: Date) {
        self.date = date
        let sharedDefaults = UserDefaults(suiteName: "group.com.kleysontavares.bebaagua")
        self.waterIntake = sharedDefaults?.double(forKey: "waterIntake") ?? 0
        self.dailyGoal = sharedDefaults?.double(forKey: "dailyGoal") ?? 2000
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
        let entry = WaterEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct WaterWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WaterProvider.Entry
    var progress: Double {
        guard entry.dailyGoal > 0 else { return 0 }
        return min(entry.waterIntake / entry.dailyGoal, 1.0)
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
                    .trim(from: 0.0, to: min(entry.waterIntake / entry.dailyGoal, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: entry.waterIntake)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .frame(width: 70, height: 70)

            // Quantidade
            Text("\(Int(entry.waterIntake)) / \(Int(entry.dailyGoal))ml")
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
                    Text("Meta diária:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(entry.dailyGoal)) ml")
                        .font(.headline)

                    Text("Consumido:")
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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            WaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Progresso de Água")
        .description("Veja seu progresso e beba água com um toque.")
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
