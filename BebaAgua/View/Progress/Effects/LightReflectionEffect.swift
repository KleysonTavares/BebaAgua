//
//  LightReflectionEffect.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 20/07/25.
//

import SwiftUI

class LightReflectionEffect: ObservableObject {
    @Published var position: UnitPoint = .init(x: 0.3, y: 0.2)
    
    func startAnimation() {
        withAnimation(.easeInOut(duration: 8.0).repeatForever()) {
            position = UnitPoint(x: CGFloat.random(in: 0.1...0.9), y: CGFloat.random(in: 0.05...0.3))
        }
    }
    
    func reflectionView(size: CGSize, progressHeight: CGFloat) -> some View {
        let reflectionSize = min(size.width, size.height) * 0.4
        
        return Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.6), location: 0),
                        .init(color: .white.opacity(0.2), location: 0.3),
                        .init(color: .clear, location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: reflectionSize / 2
                )
            )
            .frame(width: reflectionSize, height: reflectionSize * 0.4)
            .position(
                x: size.width * position.x,
                y: progressHeight * position.y
            )
            .blur(radius: 8)
            .blendMode(.plusLighter)
    }
}
