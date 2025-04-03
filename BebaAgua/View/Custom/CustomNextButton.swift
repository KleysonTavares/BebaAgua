//
//  CustomNextButton.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 02/04/25.
//

import SwiftUI

struct CustomNextButton: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 100)
            .background(Color.blue)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension View {
    func customNextButton() -> some View {
        self.modifier(CustomNextButton())
    }
}

