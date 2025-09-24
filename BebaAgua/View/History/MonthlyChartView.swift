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

    init(history: FetchedResults<DailyIntake>, date: Date, dailyGoal: Double) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            self.data = []; self.monthLabels = []
            return
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        var points: [ChartDataPoint] = []
        for i in 0..<daysInMonth {
            let day = calendar.date(byAdding: .day, value: i, to: monthInterval.start)!
            let intake = history.first { calendar.isDate($0.date ?? .now, inSameDayAs: day) }
            let progress = ((intake?.waterConsumed ?? 0) / dailyGoal) * 100
            points.append(ChartDataPoint(date: day, value: max(0, progress)))
        }
        self.data = points
        
        var labels: [Date] = []
        for day in [1, 7, 14, 21, 28] {
            if let dateForLabel = calendar.date(bySetting: .day, value: day, of: date) {
                labels.append(dateForLabel)
            }
        }
        self.monthLabels = labels
    }
    
    var body: some View {
        Chart(data) { point in
            LineMark(x: .value("Dia", point.date, unit: .day), y: .value("Progresso", point.value))
                .interpolationMethod(.monotone)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            
            PointMark(x: .value("Dia", point.date, unit: .day), y: .value("Progresso", point.value))
                .foregroundStyle(Color.white)
                .symbolSize(CGSize(width: 8, height: 8))
            
            PointMark(x: .value("Dia", point.date, unit: .day), y: .value("Progresso", point.value))
                .foregroundStyle(Color.blue)
                .symbolSize(CGSize(width: 6, height: 6))
        }
        .chartYAxis {
            AxisMarks(values: [0, 20, 40, 60, 80, 100]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                AxisValueLabel("\(value.as(Int.self) ?? 0)%")
            }
        }
        .chartXAxis {
            AxisMarks(values: monthLabels) { value in
                AxisValueLabel(format: .dateTime.day(), centered: true)
            }
        }
        .padding()
    }
}
