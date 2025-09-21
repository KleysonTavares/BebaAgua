//
//  HistoryView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 21/09/25.
//

import SwiftUI
import Charts
import CoreData

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let progress: Double
}

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DailyIntake.date, ascending: true)]) var dailyIntakeHistory: FetchedResults<DailyIntake>
    
    @State private var selectedPeriod: Period = .month
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    
    enum Period: String, CaseIterable {
        case month = "Mês"
        case year = "Ano"
    }

    private var chartData: [ChartData] {
        dailyIntakeHistory.map { intake in
            let progress = (intake.waterConsumed / dailyGoal) * 100
            return ChartData(date: intake.date ?? Date(), progress: progress)
        }
    }
    
    private var currentMonthAndYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: Date()).capitalized
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Histórico")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Picker("Período", selection: $selectedPeriod) {
                    ForEach(Period.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Spacer()
                
                chartSection
                
                Spacer()
                
                weeklyCompletion
                
                Spacer()
                
                reportSection
                
                Spacer()
            }
        }
    }
    
    var chartSection: some View {
        VStack(alignment: .leading) {
            Text(currentMonthAndYear)
                .font(.headline)
            
            Chart(chartData) { data in
                BarMark(
                    x: .value("Dia", data.date, unit: .day),
                    y: .value("Água (%)", data.progress)
                )
                .foregroundStyle(data.progress >= 100 ? .blue : .gray)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    AxisTick()
                    AxisValueLabel("\(Int(value.as(Double.self) ?? 0))%")
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day(.defaultDigits))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    var weeklyCompletion: some View {
        VStack(alignment: .leading) {
            Text("Conclusão semanal")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(weeklyCompletionData(), id: \.day) { data in
                    VStack {
                        Circle()
                            .fill(data.didMeetGoal ? Color.blue : Color.gray)
                            .frame(width: 40, height: 40)
                        Text(data.day)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    var reportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Relatório de consumo de água")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                Text("Média semanal")
                Spacer()
                Text("\(Int(weeklyAverage())) ml / dia")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
                Text("Média mensal")
                Spacer()
                Text("\(Int(monthlyAverage())) ml / dia")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func weeklyCompletionData() -> [(day: String, didMeetGoal: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        var completions: [(day: String, didMeetGoal: Bool)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let day = calendar.component(.weekday, from: date)
            let dailyIntake = dailyIntakeHistory.first(where: { calendar.isDate($0.date ?? Date(), inSameDayAs: date) })
            let didMeetGoal = (dailyIntake?.waterConsumed ?? 0.0) >= dailyGoal
            
            completions.append((day: weekdayString(for: day), didMeetGoal: didMeetGoal))
        }
        return completions.reversed()
    }
    
    private func weekdayString(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        guard weekday >= 1, weekday <= formatter.weekdaySymbols.count else { return "" }
        return formatter.weekdaySymbols[weekday - 1].prefix(3).capitalized
    }
    
    private func weeklyAverage() -> Double {
        let lastWeek = dailyIntakeHistory.filter { $0.date ?? Date() >= Calendar.current.date(byAdding: .day, value: -7, to: Date())! }
        guard !lastWeek.isEmpty else { return 0 }
        let total = lastWeek.reduce(0) { $0 + ($1.waterConsumed) }
        return total / Double(lastWeek.count)
    }
    
    private func monthlyAverage() -> Double {
        let lastMonth = dailyIntakeHistory.filter { $0.date ?? Date() >= Calendar.current.date(byAdding: .month, value: -1, to: Date())! }
        guard !lastMonth.isEmpty else { return 0 }
        let total = lastMonth.reduce(0) { $0 + ($1.waterConsumed) }
        return total / Double(lastMonth.count)
    }
}
