//
//  MainTabView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 08/04/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Diário", systemImage: "drop")
                }

            ProfileView()
                .tabItem {
                    Label("Configurar", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
