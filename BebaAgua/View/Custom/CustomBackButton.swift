//
//  CustomBackButton.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 01/04/25.
//

import SwiftUI

struct CustomBackButton: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 100)
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .fontWeight(.bold)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButton())
    }
}
