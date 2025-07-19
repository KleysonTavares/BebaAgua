//
//  CustomButton.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 01/04/25.
//

import SwiftUI

struct CustomButton: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding(.horizontal, 24)
    }
}

extension View {
    func customButton() -> some View {
        self.modifier(CustomButton())
    }
}
