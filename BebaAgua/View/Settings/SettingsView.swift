//
//  SettingsView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("gender") var gender: String = "Male"
    @AppStorage("age") var age: Int = 18
    @AppStorage("weight") var weight: Int = 70
    @AppStorage("dailyGoal") var goal: Int = 2000
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    profileSection
                    advanceSection
                    developerSection
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

    var profileSection: some View {
        Section(header: sectionHeader("PERFIL")) {
            NavigationLink(destination: ProfileView()) {
                VStack(alignment: .leading, spacing: 8) {
                    settingsRow(icon: "person.fill", iconColor: .pink, title: "Gênero", value: gender)
                    settingsRow(icon: "calendar", iconColor: .green, title: "Idade", value: "\(age)")
                    settingsRow(icon: "scalemass", iconColor: .red, title: "Peso", value: "\(weight) kg")
                    settingsRow(icon: "target", iconColor: .purple, title: "Meta", value: "\(goal) ml")
                }
                .padding(.vertical, 8)
            }
        }
    }

    var advanceSection: some View {
        Section(header: sectionHeader("AVANÇADO")) {
            NavigationLink(destination: HealthAppIntegrationView()) {
                settingsNavigationRow(icon: "heart.fill", iconColor: .pink, title: "App saúde")
            }
        }
    }
    
    var developerSection: some View {
        Section(header: sectionHeader("DESENVOLVEDOR")) {
            Button(action: {
                // Feedback
            }) {
                settingsNavigationRow(icon: "bubble.left.fill", iconColor: .blue, title: "Feedback")
            }
            
            Button(action: {
                // Rate App
            }) {
                settingsNavigationRow(icon: "star.fill", iconColor: .yellow, title: "Avaliar app")
            }
            
            Button(action: {
                // Share App
            }) {
                settingsNavigationRow(icon: "square.and.arrow.up", iconColor: .purple, title: "Compartilhar app")
            }
        }
    }
    
    func settingsRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .light))
        }
        .padding(.vertical, 8)
    }
    
    func settingsNavigationRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
    }
    
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.cyan)
    }
}

// Telas fictícias pra navegação
struct AchievementView: View {
    var body: some View {
        Text("Achievements")
            .foregroundColor(.white)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

struct HealthAppIntegrationView: View {
    var body: some View {
        Text("Health App Integration")
            .foregroundColor(.white)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
