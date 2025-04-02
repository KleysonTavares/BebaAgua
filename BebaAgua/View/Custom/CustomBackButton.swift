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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Voltar")
                }
            })
    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButton())
    }
}
