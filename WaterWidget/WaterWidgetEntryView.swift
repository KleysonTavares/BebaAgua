//
//  WaterWidgetEntryView.swift
//  WaterWidgetExtension
//
//  Created by Kleyson Tavares on 31/01/26.
//

import WidgetKit
import SwiftUI

struct WaterWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let dailyGoal = NSLocalizedString("dailyGoal", bundle: .main, comment: "")
    let consumed = NSLocalizedString("consumed", bundle: .main, comment: "")
    var entry: WaterProvider.Entry
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
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.cyan)

                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .frame(width: 70, height: 70)

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
