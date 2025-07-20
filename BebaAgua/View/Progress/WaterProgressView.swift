//
//  WaterProgressView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 09/04/25.
//

import SwiftUI

struct WaterProgressView: View {
    var progress: Double // 0.0 a 1.0
    var color: Color = .blue

    // Efeitos
    @StateObject private var waveEffect = WaveEffect()
    @StateObject private var causticsEffect = CausticsEffect()

    var body: some View {
        ZStack {
            // Fundo do círculo
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0.2)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.5), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            // Água e efeitos
            GeometryReader { geometry in
                let size = geometry.size
                let progressHeight = size.height * (1 - CGFloat(progress))
                let waveHeight = size.height * 0.03

                // Camada de água
                waterLayer(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
                    .overlay(
                        causticsEffect.causticsView(size: size)
                            .mask(Circle().frame(width: size.width, height: size.height).offset(y: -size.height * 0.1))
                            .opacity(0.3)
                            .offset(y: causticsEffect.offset)
                    )
            }
            .mask(Circle().padding(2))

            // Texto de porcentagem
            Text("\(Int(progress * 100))%")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                .offset(y: -waveEffect.surfaceDistortion * 2)
        }
        .onAppear {
            waveEffect.startAnimation()
            causticsEffect.startAnimation()
        }
        .onDisappear {
            waveEffect.stopAnimation()
        }
    }

    private func waterLayer(size: CGSize, progressHeight: CGFloat, waveHeight: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.9),
                            color.opacity(0.7),
                            color.opacity(0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask(
                    waveEffect.wavePath(in: size, progressHeight: progressHeight, waveHeight: waveHeight)
                )

            waveEffect.wavePath(in: size, progressHeight: progressHeight, waveHeight: waveHeight)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.4), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .blur(radius: 0.5)
        }
    }
}

struct WaterProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                WaterProgressView(progress: 0.25)
                    .frame(width: 200, height: 200)
                
                WaterProgressView(progress: 0.65, color: Color(red: 0.1, green: 0.5, blue: 0.8))
                    .frame(width: 200, height: 200)
                
                WaterProgressView(progress: 0.9, color: .teal)
                    .frame(width: 200, height: 200)
            }
        }
    }
}
