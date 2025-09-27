//
//  HistoryView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 21/09/25.
//

import SwiftUI
import Charts
import CoreData

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DailyIntake.date, ascending: true)]) var dailyIntakeHistory: FetchedResults<DailyIntake>
    
    @State private var currentDate: Date = .now
    @State private var selectedPeriod: Period = .week
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    
    enum Period: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                dateSelector
                
                Picker("period", selection: $selectedPeriod) {
                    ForEach(Period.allCases, id: \.self) { period in
                        Text(LocalizedStringKey(period.rawValue)).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch selectedPeriod {
                case .week:
                    WeeklyChartView(history: dailyIntakeHistory, date: currentDate, dailyGoal: dailyGoal)
                case .month:
                    MonthlyChartView(history: dailyIntakeHistory, date: currentDate, dailyGoal: dailyGoal)
                case .year:
                    YearlyChartView(history: dailyIntakeHistory, date: currentDate, dailyGoal: dailyGoal)
                }
                
                Spacer()
                
                reportSection
                
                Spacer()
            }
        }
    }
    
    // MARK: - Subviews

    private var dateSelector: some View {
        HStack {
            Button(action: {
                changeDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            
            Text(dateSelectorTitle)
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: {
                changeDate(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
   
    let day = LocalizedStringKey("day")
    var reportSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            let weeklyAverage = weeklyAverage()
            let percentWeek = Int((weeklyAverage/dailyGoal) * 100)
            HStack {
                Circle().fill(.green).frame(width: 10, height: 10)
                Text(LocalizedStringKey("weeklyAverage"))
                Spacer()
                Text("\(Int(weeklyAverage)) ml - \(percentWeek)%")
                    .foregroundColor(.secondary)
            }

            let monthlyAverage = monthlyAverage()
            let percentMonthly = Int((monthlyAverage/dailyGoal) * 100)
            HStack {
                Circle().fill(.blue).frame(width: 10, height: 10)
                Text(LocalizedStringKey("monthlyAverage"))
                Spacer()
                Text("\(Int(monthlyAverage)) ml - \(percentMonthly)%")
                    .foregroundColor(.secondary)
            }

            HStack {
                Circle().fill(.red).frame(width: 10, height: 10)
                Text(LocalizedStringKey("drinkingFrequency"))
                Spacer()
                Text("\(dailyFrequencyAverage()) - ")
                    .foregroundColor(.secondary)
                + Text(LocalizedStringKey("times"))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    // MARK: - Helper Properties & Functions

    private var dateSelectorTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        switch selectedPeriod {
        case .week:
            let week = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate)!
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: week.start)) - \(formatter.string(from: week.end.addingTimeInterval(-1)))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate).capitalized
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentDate)
        }
    }

    private func changeDate(by value: Int) {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
        case .year:
            currentDate = calendar.date(byAdding: .year, value: value, to: currentDate) ?? currentDate
        }
    }
    
    private func weeklyAverage() -> Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let lastWeek = dailyIntakeHistory.filter { $0.date ?? Date() >= weekAgo }
        guard !lastWeek.isEmpty else { return 0 }
        return lastWeek.reduce(0) { $0 + $1.waterConsumed } / Double(lastWeek.count)
    }
    
    private func monthlyAverage() -> Double {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let lastMonth = dailyIntakeHistory.filter { $0.date ?? Date() >= monthAgo }
        guard !lastMonth.isEmpty else { return 0 }
        return lastMonth.reduce(0) { $0 + $1.waterConsumed } / Double(lastMonth.count)
    }

    private func dailyFrequencyAverage() -> Int {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let lastMonthData = dailyIntakeHistory.filter { $0.date ?? Date() >= monthAgo }
        guard !lastMonthData.isEmpty else { return 0 }
        let totalDrinks = lastMonthData.reduce(0) { $0 + $1.drinkCount }
        return Int(totalDrinks)
        }
}
