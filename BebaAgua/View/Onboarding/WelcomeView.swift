//
//  Welcome.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 31/03/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
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
                
                Button(action: { path.append(RouteScreensEnum.gender)}) {
                    Text("Próximo")
                        .customButton()
                }
                .padding(.bottom, 40)

                .navigationDestination(for: RouteScreensEnum.self) { route in
                    RouteScreen.destination(for: route, path: $path)
                }
            }
        }
        .standardScreenStyle()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

