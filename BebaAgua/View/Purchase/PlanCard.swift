//
//  PlanCard.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/01/26.
//

import Foundation
import SwiftUI

struct PlanCard: View {
    let plan: PurchasePlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title).font(.headline).foregroundColor(.primary)
                    Text(plan.subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(plan.price).font(.title3.bold()).foregroundColor(.cyan)
            }
            .padding()
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.cyan : Color.gray.opacity(0.2), lineWidth: 2)
                    .background(isSelected ? Color.cyan.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

