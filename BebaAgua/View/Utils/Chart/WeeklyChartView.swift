//
//  WeeklyChartView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/07/25.
//

import Charts
import SwiftUI

struct WeeklyChartView: View {
    let data: [WaterIntakeDay]

    var body: some View {
        Chart(data) { day in
            BarMark(
                x: .value("Dia", day.dateString),
                y: .value("ml", day.amount)
            )
            .foregroundStyle(Color.cyan)
        }
        .frame(height: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding()
    }
}
