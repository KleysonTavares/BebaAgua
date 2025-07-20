//
//  CausticsEffect.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 20/07/25.
//

import SwiftUI

class CausticsEffect: ObservableObject {
    @Published var offset: CGFloat = 0
    
    func startAnimation() {
        withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
            offset = 100
        }
    }
    
    func causticsView(size: CGSize) -> some View {
        let patternSize = size.width * 1.5
        
        return Rectangle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.05),
                        .clear,
                        .white.opacity(0.03),
                        .clear
                    ]),
                    center: .center,
                    angle: .degrees(45)
                )
            )
            .frame(width: patternSize, height: patternSize)
            .rotationEffect(.degrees(30))
            .blur(radius: 1)
    }
}
