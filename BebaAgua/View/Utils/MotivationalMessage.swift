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
        (0...0.05, "Beba seu primeiro copo para começar o dia!"),
        (0.06...0.49, "Continue! Seu corpo já sente a diferença"),
        (0.5...0.74, "Metade do caminho! Você está indo bem"),
        (0.75...0.99, "Quase lá! Mais um pouco para a meta"),
        (1.0...2.0, "Meta alcançada! Você está hidratado")
    ]

    var body: some View {
        VStack(spacing: 16) {
            let currentMessage = messages.first { $0.range.contains(progress) }
            Text(currentMessage?.message ?? "Acompanhe sua hidratação")
                .font(.title)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .id("message-\(progress)")
        }
        .animation(.spring, value: progress)
    }
}
