//
//  File.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 22/09/25.
//

import Charts
import Foundation
import SwiftUI

struct WeeklyChartView: View {
    let data: [ChartDataPoint]

    init(history: FetchedResults<DailyIntake>, date: Date, dailyGoal: Double) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            self.data = []
            return
        }
        
        var points: [ChartDataPoint] = []
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start)!
            let intake = history.first { calendar.isDate($0.date ?? .now, inSameDayAs: day) }
            let progress = ((intake?.waterConsumed ?? 0) / dailyGoal) * 100
            let cappedProgress = min(progress, 100)
            points.append(ChartDataPoint(date: day, value: max(0, cappedProgress)))
        }
        self.data = points
    }

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value(LocalizedStringKey("day"), point.date, unit: .weekday),
                y: .value(LocalizedStringKey("progress"), point.value)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 20, 40, 60, 80, 100]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                AxisValueLabel("\(value.as(Int.self) ?? 0)%")
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 7)) { value in
                AxisValueLabel(format: .dateTime.weekday(.short), centered: true)
            }
        }
        .padding()
    }
}
