//
//  YearlyChartView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 22/09/25.
//

import Charts
import Foundation
import SwiftUI

struct YearlyChartView: View {
    let data: [ChartDataPoint]
    let yearLabels: [Date]

    init(history: FetchedResults<DailyIntake>, date: Date, dailyGoal: Double) {
        let calendar = Calendar.current
        
        var points: [ChartDataPoint] = []
        for month in 1...12 {
            let monthDateComponents = DateComponents(year: calendar.component(.year, from: date), month: month)
            guard let monthDate = calendar.date(from: monthDateComponents),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { continue }
            
            let monthData = history.filter { $0.date ?? .now >= monthInterval.start && $0.date ?? .now < monthInterval.end }
            let totalProgress = monthData.reduce(0) { $0 + (($1.waterConsumed / dailyGoal) * 100) }
            let avgProgress = monthData.isEmpty ? 0 : totalProgress / Double(monthData.count)
            points.append(ChartDataPoint(date: monthDate, value: max(0, avgProgress)))
        }
        self.data = points
        
        var labels: [Date] = []
        for month in [1, 3, 5, 7, 9, 11] {
            if let dateForLabel = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: month)) {
                labels.append(dateForLabel)
            }
        }
        self.yearLabels = labels
    }
    
    var body: some View {
        Chart(data) { point in
            LineMark(x: .value(LocalizedStringKey("month"), point.date, unit: .month), y: .value("progress", point.value))
                .interpolationMethod(.monotone)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            
            PointMark(x: .value(LocalizedStringKey("month"), point.date, unit: .month), y: .value("progress", point.value))
                .foregroundStyle(Color.white)
                .symbolSize(CGSize(width: 8, height: 8))

            PointMark(x: .value(LocalizedStringKey("month"), point.date, unit: .month), y: .value("progress", point.value))
                .foregroundStyle(Color.blue)
                .symbolSize(CGSize(width: 6, height: 6))
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 20, 40, 60, 80, 100]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                AxisValueLabel("\(value.as(Int.self) ?? 0)%")
            }
        }
        .chartXAxis {
            AxisMarks(values: yearLabels) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated))
                            .frame(width: 20, alignment: .leading)
                    }
                }
            }
        }
        .padding()
    }
}
