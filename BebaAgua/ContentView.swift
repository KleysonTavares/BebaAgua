//
//  ContentView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @State private var selectedGender = "Masculino"
    @State private var birthYear = 2000
    @State private var weight = 70.0
    @State private var dailyGoal = 2000.0
    @State private var reminderInterval = 60.0
    @State private var isOnboardingComplete = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sexo")) {
                    Picker("Sexo", selection: $selectedGender) {
                        Text("Masculino").tag("Masculino")
                        Text("Feminino").tag("Feminino")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                 
                Section(header: Text("Ano de nascimento")) {
                    HStack {
                        Picker("Ano de Nascimento", selection: $birthYear) {
                            ForEach(1900...2025, id: \ .self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                    }
                }
                    
                Section(header: Text("Peso")) {
                    HStack {
                        Picker("Peso", selection: $weight) {
                            ForEach(1...200, id: \ .self) { value in
                                Text("\(Int(value))").tag(Double(value))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                        Text("kg")
                    }
                }
                
                Section(header: Text("Meta diária")) {
                    Slider(value: $dailyGoal, in: 500...5000, step: 100)
                    Text("\(Int(dailyGoal)) ml")
                }
                
                Section(header: Text("Intervalo das notificações")) {
                    Slider(value: $reminderInterval, in: 15...180, step: 15)
                    Text("\(Int(reminderInterval)) min")
                }
                
                Button("Salvar e Continuar") {
                    isOnboardingComplete = true
                    UserDefaults.standard.set(selectedGender, forKey: "gender")
                    UserDefaults.standard.set(birthYear, forKey: "birthYear")
                    UserDefaults.standard.set(weight, forKey: "weight")
                    UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
                    UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval")
                }
            }
            .navigationTitle("Configuração Inicial")
            .fullScreenCover(isPresented: $isOnboardingComplete) {
                ContentView()
            }
        }
    }
}

struct ContentView: View {
    @State private var waterIntake: Double = 0.0
    @State private var dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
    @State private var reminderInterval = UserDefaults.standard.double(forKey: "reminderInterval")
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Seu Consumo Diário")
                    .font(.title)
                    .padding()
                
                CircularProgressView(progress: waterIntake / dailyGoal)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("\(Int(waterIntake)) ml de \(Int(dailyGoal)) ml")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    addWater(amount: 250)
                }) {
                    Text("+250 ml")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Text("Configurações")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Lembrete de Água")
            .onAppear {
                requestNotificationPermission()
                scheduleWaterReminder()
            }
        }
    }
    
    func addWater(amount: Double) {
        withAnimation {
            waterIntake += amount
            if waterIntake > dailyGoal {
                waterIntake = dailyGoal
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão de notificação: \(error)")
            }
        }
    }
    
    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Hora de beber água!"
        content.body = "Lembre-se de se manter hidratado!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderInterval * 60, repeats: true)
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error)")
            }
        }
    }
}

struct SettingsView: View {
    @State private var dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
    @State private var reminderInterval = UserDefaults.standard.double(forKey: "reminderInterval")
    
    var body: some View {
        Form {
            Section(header: Text("Meta Diária de Água (ml)")) {
                Slider(value: $dailyGoal, in: 500...5000, step: 100)
                Text("Meta: \(Int(dailyGoal)) ml")
            }
            
            Section(header: Text("Intervalo de Notificações (minutos)")) {
                Slider(value: $reminderInterval, in: 15...180, step: 15)
                Text("Intervalo: \(Int(reminderInterval)) min")
            }
        }
        .navigationTitle("Configurações")
    }
}

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeOut, value: progress)
        }
    }
}
