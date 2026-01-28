//
//  SettingsView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 26/04/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @State private var showMailView = false
    @State private var showMailError = false
    @State private var isShareSheetPresented = false
    @State private var showingPurchaseView = false
    @ObservedObject private var premiumManager = PremiumManager.shared

    @AppStorage("gender") var gender: String = "Male"
    @AppStorage("age") var age: Int = 18
    @AppStorage("weight") var weight: Int = 70
    @AppStorage("dailyGoal") var goal: Int = 2000
    @AppStorage("reminderInterval") var reminderInterval: Double = 60
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if !premiumManager.isPremiumUser {
                        purchaseSection
                    }
                    profileSection
                    advanceSection
                    developerSection
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

    var purchaseSection: some View {
        Section {
            Button(action: {
                showingPurchaseView = true
            }) {
                HStack(spacing: 15) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Seja PRO")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Desbloqueie os recursos exclusivos")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.bold())
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .listRowBackground(Color.blue.opacity(0.6))
        .animation(.default, value: premiumManager.isPremiumUser)
        .sheet(isPresented: $showingPurchaseView) {
            PurchaseView()
        }
    }

    
    var profileSection: some View {
        Section(header: sectionHeader("profile")) {
            NavigationLink(destination: ProfileView()) {
                VStack(alignment: .leading, spacing: 8) {
                    settingsRow(icon: "person.fill", iconColor: .pink, title: "gender", value: gender)
                    settingsRow(icon: "calendar", iconColor: .green, title: "age", value: "\(age)")
                    settingsRow(icon: "scalemass", iconColor: .red, title: "weight", value: "\(weight) kg")
                    settingsRow(icon: "target", iconColor: .purple, title: "goal", value: "\(goal) ml")
                    settingsRow(icon: "clock", iconColor: .blue, title: "reminderInterval", value: "\(Int(reminderInterval)) min")
                }
                .padding(.vertical, 8)
            }
        }
    }

    var advanceSection: some View {
        Section(header: sectionHeader("advanced")) {
            NavigationLink(destination: HealthAppView()) {
                settingsNavigationRow(icon: "heart.fill", iconColor: .pink, title: "healthApp", isIconButton: false)
            }
        }
    }
    
    var developerSection: some View {
        Section(header: sectionHeader("developer")) {
            feedbackButton()
            rateAppButton()
            shareAppButton()
        }
    }
    
    func settingsRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            Text(LocalizedStringKey(title))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .light))
        }
        .padding(.vertical, 8)
    }
    
    func settingsNavigationRow(icon: String, iconColor: Color, title: String, isIconButton: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            Text(LocalizedStringKey(title))
                .foregroundColor(.primary)
            
            Spacer()

            if isIconButton {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 8)
    }
    
    func sectionHeader(_ title: String) -> some View {
        Text(LocalizedStringKey(title))
            .font(.headline)
            .foregroundColor(.cyan)
    }

    func feedbackButton() -> some View {
        Button(action: {
            if MFMailComposeViewController.canSendMail() {
                showMailView = true
            } else {
                showMailError = true
            }
        }) {
            settingsNavigationRow(icon: "bubble.left.fill", iconColor: .blue, title: "feedback", isIconButton: true)
        }
        .sheet(isPresented: $showMailView) {
            MailView(
                recipient: "kleyson.tavares@icloud.com",
                subject: "Beba Agua Feedback",
                body: ""
            )
        }
        .alert(LocalizedStringKey("emailNotAvailable"), isPresented: $showMailError) {
            Button("OK", role: .cancel) { }
        }
    }

    func rateAppButton() -> some View {
        Button(action: {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1478980974?action=write-review") {
                UIApplication.shared.open(url)
            }
        }) {
            settingsNavigationRow(icon: "star.fill", iconColor: .yellow, title: "rateApp", isIconButton: true)
        }
    }

    func shareAppButton() -> some View {
        Button(action: {
            isShareSheetPresented = true
        }) {
            settingsNavigationRow(icon: "square.and.arrow.up", iconColor: .purple, title: "shareApp", isIconButton: true)
        }
        .sheet(isPresented: $isShareSheetPresented) {
            let messageShare = NSLocalizedString("messageShare", comment: "")
            let fullMessage = "\(messageShare) https://apps.apple.com/app/id1478980974"
            ActivityView(activityItems: [fullMessage])
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
