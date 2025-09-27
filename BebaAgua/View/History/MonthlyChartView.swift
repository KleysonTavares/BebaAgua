//
//  MonthlyChartView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 22/09/25.
//

import Charts
import Foundation
import SwiftUI

struct MonthlyChartView: View {
    let data: [ChartDataPoint]
    let monthLabels: [Date]
    let monthStart: Date
    let monthEnd: Date

    init(history: FetchedResults<DailyIntake>, date: Date, dailyGoal: Double) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            self.data = []
            self.monthLabels = []
            self.monthStart = Date()
            self.monthEnd = Date()
            return
        }

        let start = calendar.startOfDay(for: monthInterval.start)
        self.monthStart = start

        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        self.monthEnd = calendar.date(byAdding: .day, value: daysInMonth - 1, to: start)!

        var points: [ChartDataPoint] = []
        for i in 0..<daysInMonth {
            let day = calendar.date(byAdding: .day, value: i, to: start)!
            let intake = history.first { calendar.isDate($0.date ?? .now, inSameDayAs: day) }
            let progress = ((intake?.waterConsumed ?? 0) / dailyGoal) * 100
            points.append(ChartDataPoint(date: calendar.startOfDay(for: day), value: max(0, progress)))
        }
        self.data = points

        var labels: [Date] = []
        for day in [1, 5, 10, 15, 20, 25] {
            if day <= daysInMonth {
                let labelDate = calendar.date(byAdding: .day, value: day - 1, to: start)!
                labels.append(calendar.startOfDay(for: labelDate))
            }
        }
        let lastDay = calendar.date(byAdding: .day, value: daysInMonth - 1, to: start)!
        labels.append(calendar.startOfDay(for: lastDay))

        self.monthLabels = labels
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value(LocalizedStringKey("day"), point.date),
                y: .value(LocalizedStringKey("progress"), point.value)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                startPoint: .top, endPoint: .bottom
            ))

            PointMark(x: .value(LocalizedStringKey("day"), point.date), y: .value(LocalizedStringKey("progress"), point.value))
                .symbolSize(12)
                .foregroundStyle(Color.white)

            PointMark(x: .value(LocalizedStringKey("day"), point.date), y: .value(LocalizedStringKey("progress"), point.value))
                .symbolSize(8)
                .foregroundStyle(Color.blue)
        }
        .chartXScale(domain: monthStart...monthEnd)

        .chartYAxis {
            AxisMarks(values: [0,20,40,60,80,100]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3,3]))
                AxisValueLabel("\(value.as(Int.self) ?? 0)%")
            }
        }

        .chartXAxis {
            AxisMarks(values: monthLabels) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3,3]))
                AxisTick()
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        Text("\(Calendar.current.component(.day, from: d))")
                    }
                }
            }
        }
        .padding()
    }
}
