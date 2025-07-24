//
//  WaveEffect.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 20/07/25.
//

import SwiftUI

class WaveEffect: ObservableObject {
    @Published var phase: Double = 0
    @Published var surfaceDistortion: CGFloat = 0
    private var timer: Timer?
    
    func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.phase = Date().timeIntervalSinceReferenceDate
            self.surfaceDistortion = CGFloat(sin(self.phase * 1.5)) * 0.5 + 0.5
        }
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    func wavePath(in size: CGSize, progressHeight: CGFloat, waveHeight: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: progressHeight))
            
            for x in stride(from: 0, through: size.width, by: 1) {
                let relativeX = x / 100
                let wave1 = sin(Double(relativeX) * .pi * 2 + phase) * waveHeight
                let wave2 = cos(Double(relativeX) * .pi * 1.5 + phase + 2) * waveHeight * 0.7
                let wave3 = sin(Double(relativeX) * .pi * 0.7 + phase + 4) * waveHeight * 0.4
                let agitation = sin(surfaceDistortion * .pi * 2) * 2
                let y = progressHeight + wave1 + wave2 + wave3 + agitation
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }
    }
}
