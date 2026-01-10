//
//  MotivationalMessage.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import SwiftUI

struct MotivationalMessageView: View {
    let progress: Double

    private let messages: [(range: ClosedRange<Double>, message: String)] = [
        (0...0.05, "motivationalMessage1"),
        (0.06...0.49, "motivationalMessage2"),
        (0.5...0.74, "motivationalMessage3"),
        (0.75...0.99, "motivationalMessage4"),
        (1.0...2.0, "motivationalMessage5")
    ]

    var body: some View {
        VStack(spacing: 16) {
            let currentMessage = messages.first { $0.range.contains(progress) }
            Text(LocalizedStringKey(currentMessage?.message ?? "motivationalMessageDefault"))
                .font(.title)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .id("message-\(progress)")
        }
        .animation(.spring, value: progress)
    }
}
