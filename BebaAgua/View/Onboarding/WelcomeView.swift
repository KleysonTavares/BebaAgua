//
//  Welcome.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 31/03/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .background(Color.white)
                VStack(alignment: .leading, spacing: 20) {
                    Text("Oi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Para fornecer conselhos de hidratação personalizados, preciso de algumas informações básicas.")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                NavigationLink(destination: GenderSelectionView()) {
                    Text("Vamos começar")
                        .customButton()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

