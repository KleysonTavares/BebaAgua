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
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Oi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Para fornecer conselhos de hidratação personalizados, preciso obter algumas informações básicas.")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                NavigationLink(destination: OnboardingView()) {
                    Text("Vamos começar")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)
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

