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
                    Label(LocalizedStringKey("daily"), systemImage: "drop")
                }

            SettingsView()
                .tabItem {
                    Label(LocalizedStringKey("settings"), systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
