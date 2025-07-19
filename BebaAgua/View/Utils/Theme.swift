//
//  Theme.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 11/04/25.
//

import SwiftUI

struct Theme: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
                   Color.white
                       .ignoresSafeArea() // Cobre toda a tela, inclusive as bordas
                   content
               }
               .navigationBarBackButtonHidden(true)
               .preferredColorScheme(.light)
           }
       }

extension View {
    func standardScreenStyle() -> some View {
        self.modifier(Theme())
    }
}
