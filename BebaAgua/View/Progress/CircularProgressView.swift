//
//  CircularProgressView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeOut, value: progress)
            
            Text("\(Int(progress * 100))%") // Texto central
                .font(.title)
                .bold()
                .foregroundColor(Color.cyan)
        }
    }
}

