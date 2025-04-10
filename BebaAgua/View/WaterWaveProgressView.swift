//
//  WaterWaveProgressView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 09/04/25.
//

import SwiftUI

struct UltraRealisticWaterProgressView: View {
    var progress: Double // 0.0 a 1.0
    var color: Color = .blue
    
    // Parâmetros das ondas
    @State private var waveOffset1 = Angle(degrees: 0)
    @State private var waveOffset2 = Angle(degrees: 120)
    @State private var waveOffset3 = Angle(degrees: 240)
    
    // Sistema de bolhas
    @State private var bubbles: [Bubble] = []
    @State private var lastBubbleTime = Date.now
    
    // Reflexos de luz
    @State private var lightReflectionPosition = UnitPoint(x: 0.3, y: 0.2)
    @State private var causticsOffset = CGFloat(0)
    
    // Movimento da superfície
    @State private var surfaceDistortion = CGFloat(0)
    
    // Timer para animações contínuas
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    struct Bubble: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGFloat
        var speed: CGFloat
        var opacity: CGFloat
        var creationTime = Date.now
    }
    
    var body: some View {
        ZStack {
            // Fundo do círculo com gradiente
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
            
            // Água com múltiplas camadas e efeitos
            GeometryReader { geometry in
                let size = geometry.size
                let progressHeight = size.height * (1 - CGFloat(progress))
                let waveHeight = size.height * 0.03
                
                // Camada principal de água com gradiente de profundidade
                waterLayer(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
                    .overlay(
                        // Efeito de caustics (padrões de luz no fundo)
                        causticsPattern(size: size)
                            .mask(
                                Circle()
                                    .frame(width: size.width, height: size.height)
                                    .offset(y: -size.height * 0.1)
                            )
                            .opacity(0.3)
                            .offset(y: causticsOffset)
                    )
                
                // Bolhas com física mais realista
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.white, .white.opacity(0.1)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: bubble.size * 0.8
                            )
                        )
                        .frame(width: bubble.size, height: bubble.size)
                        .position(bubble.position)
                        .opacity(bubble.opacity)
                        .blur(radius: bubble.size * 0.3)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 0.5)
                                .frame(width: bubble.size, height: bubble.size)
                        )
                }
                
                // Reflexo de luz principal
                lightReflection(size: size, progressHeight: progressHeight)
            }
            .mask(
                Circle()
                    .padding(2) // Suaviza as bordas
            )
            
            // Borda do progresso com efeito molhado
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 5)
                .animation(.easeOut(duration: 1.0), value: progress)
            
            // Texto central com efeito de refração
            Text("\(Int(progress * 100))%")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                .offset(y: -surfaceDistortion * 2) // Efeito de flutuação
        }
        .onAppear {
            // Animar as ondas com diferentes velocidades
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                waveOffset1 = Angle(degrees: 360)
            }
            
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                waveOffset2 = Angle(degrees: 360)
            }
            
            withAnimation(.linear(duration: 7.0).repeatForever(autoreverses: false)) {
                waveOffset3 = Angle(degrees: 360)
            }
            
            // Animar reflexos e padrões
            withAnimation(.easeInOut(duration: 8.0).repeatForever()) {
                lightReflectionPosition = UnitPoint(x: CGFloat.random(in: 0.1...0.9),
                                              y: CGFloat.random(in: 0.05...0.3))
            }
            
            withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                causticsOffset = 100
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
                surfaceDistortion = 1
            }
        }
        .onReceive(timer) { time in
            updateBubbles(time: time)
            updateSurfaceDistortion()
        }
    }
    
    private func waterLayer(size: CGSize, progressHeight: CGFloat, waveHeight: CGFloat) -> some View {
        ZStack {
            // Gradiente de profundidade
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
                    // Forma da água com três camadas de onda sobrepostas
                    waveShape(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
                )
            
            // Efeito de espuma na superfície
            waveShape(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
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
    
    private func waveShape(size: CGSize, progressHeight: CGFloat, waveHeight: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: progressHeight))
            
            // Combinar três padrões de onda para maior realismo
            for x in stride(from: 0, through: size.width, by: 1) {
                let relativeX = x / 100
                
                let wave1 = sin(Double(relativeX) * .pi * 2 + waveOffset1.radians) * waveHeight
                let wave2 = cos(Double(relativeX) * .pi * 1.5 + waveOffset2.radians) * waveHeight * 0.7
                let wave3 = sin(Double(relativeX) * .pi * 0.7 + waveOffset3.radians) * waveHeight * 0.4
                
                let agitation = sin(surfaceDistortion * .pi * 2) * 2
                let y = progressHeight + wave1 + wave2 + wave3 + agitation
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }
    }
    
    private func lightReflection(size: CGSize, progressHeight: CGFloat) -> some View {
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
                    endRadius: reflectionSize/2
                )
            )
            .frame(width: reflectionSize, height: reflectionSize * 0.4)
            .position(
                x: size.width * lightReflectionPosition.x,
                y: progressHeight * lightReflectionPosition.y
            )
            .blur(radius: 8)
            .blendMode(.plusLighter)
    }
    
    private func causticsPattern(size: CGSize) -> some View {
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
    
    private func updateBubbles(time: Date) {
        // Remover bolhas muito antigas
        bubbles.removeAll { bubble in
            time.timeIntervalSince(bubble.creationTime) > 8.0
        }
        
        // Adicionar novas bolhas ocasionalmente
        if time.timeIntervalSince(lastBubbleTime) > 0.2 && bubbles.count < 20 {
            lastBubbleTime = time
            
            let newBubble = Bubble(
                position: CGPoint(
                    x: CGFloat.random(in: 20...(200-20)),
                    y: 200 - CGFloat.random(in: 0...20)
                ),
                size: CGFloat.random(in: 1...5),
                speed: CGFloat.random(in: 0.3...1.2),
                opacity: CGFloat.random(in: 0.4...0.8)
            )
            
            bubbles.append(newBubble)
        }
        
        // Atualizar posição das bolhas
        for index in bubbles.indices {
            bubbles[index].position.y -= bubbles[index].speed
            
            // Adicionar movimento horizontal aleatório leve
            bubbles[index].position.x += CGFloat.random(in: -0.5...0.5)
            
            // Aumentar bolhas que estão subindo
            if bubbles[index].size < 8 {
                bubbles[index].size *= 1.002
            }
        }
    }
    
    private func updateSurfaceDistortion() {
        // Atualizar distorção da superfície para efeito de ondulação aleatória
        surfaceDistortion = CGFloat(sin(Date.now.timeIntervalSince1970 * 1.5)) * 0.5 + 0.5
    }
}

struct UltraRealisticWaterProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                UltraRealisticWaterProgressView(progress: 0.25)
                    .frame(width: 200, height: 200)
                
                UltraRealisticWaterProgressView(progress: 0.65, color: Color(red: 0.1, green: 0.5, blue: 0.8))
                    .frame(width: 200, height: 200)
                
                UltraRealisticWaterProgressView(progress: 0.9, color: .teal)
                    .frame(width: 200, height: 200)
            }
        }
    }
}
