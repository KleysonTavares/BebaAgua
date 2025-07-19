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

    @State private var wavePhase: Double = 0
    @State private var bubbles: [Bubble] = []
    @State private var lastBubbleTime = Date.now

    @State private var lightReflectionPosition = UnitPoint(x: 0.3, y: 0.2)
    @State private var causticsOffset = CGFloat(0)
    @State private var surfaceDistortion = CGFloat(0)

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

            GeometryReader { geometry in
                let size = geometry.size
                let progressHeight = size.height * (1 - CGFloat(progress))
                let waveHeight = size.height * 0.03

                waterLayer(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
                    .overlay(
                        causticsPattern(size: size)
                            .mask(Circle().frame(width: size.width, height: size.height).offset(y: -size.height * 0.1))
                            .opacity(0.3)
                            .offset(y: causticsOffset)
                    )

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
                        )
                }

                lightReflection(size: size, progressHeight: progressHeight)
            }
            .mask(Circle().padding(2))

            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 5)
                .animation(.easeOut(duration: 1.0), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                .offset(y: -surfaceDistortion * 2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever()) {
                lightReflectionPosition = UnitPoint(x: CGFloat.random(in: 0.1...0.9), y: CGFloat.random(in: 0.05...0.3))
            }

            withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                causticsOffset = 100
            }
        }
        .onReceive(timer) { time in
            wavePhase = time.timeIntervalSinceReferenceDate
            updateBubbles(time: time)
            surfaceDistortion = CGFloat(sin(wavePhase * 1.5)) * 0.5 + 0.5
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
                    waveShape(size: size, progressHeight: progressHeight, waveHeight: waveHeight)
                )

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

            for x in stride(from: 0, through: size.width, by: 1) {
                let relativeX = x / 100

                let wave1 = sin(Double(relativeX) * .pi * 2 + wavePhase) * waveHeight
                let wave2 = cos(Double(relativeX) * .pi * 1.5 + wavePhase + 2) * waveHeight * 0.7
                let wave3 = sin(Double(relativeX) * .pi * 0.7 + wavePhase + 4) * waveHeight * 0.4

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
                    endRadius: reflectionSize / 2
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
        bubbles.removeAll { time.timeIntervalSince($0.creationTime) > 8 }

        guard let size = UIApplication.shared.windows.first?.frame.size else { return }

        if time.timeIntervalSince(lastBubbleTime) > 0.2 && bubbles.count < 20 {
            lastBubbleTime = time

            let newBubble = Bubble(
                position: CGPoint(
                    x: CGFloat.random(in: 20...(size.width - 20)),
                    y: size.height - CGFloat.random(in: 0...20)
                ),
                size: CGFloat.random(in: 1...5),
                speed: CGFloat.random(in: 0.3...1.2),
                opacity: CGFloat.random(in: 0.4...0.8)
            )

            bubbles.append(newBubble)
        }

        for index in bubbles.indices {
            bubbles[index].position.y -= bubbles[index].speed
            bubbles[index].position.x += CGFloat.random(in: -0.5...0.5)
            if bubbles[index].size < 8 {
                bubbles[index].size *= 1.002
            }
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
