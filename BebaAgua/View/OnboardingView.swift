//
//  OnboardingView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selectedGender = "Masculino"
    @State private var birthYear = 2000
    @State private var weight = 70.0
    @State private var dailyGoal = 2000.0
    @State private var reminderInterval = 60.0
    @State private var isOnboardingComplete = false
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false // Remove separador de milhar
        formatter.numberStyle = .none
        return formatter
    }()
    
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
                                Text("\(numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)")").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                    }
                }
                
                Section(header: Text("Peso em kg")) {
                    HStack {
                        Picker("Peso", selection: $weight) {
                            ForEach(1...200, id: \ .self) { value in
                                Text("\(Int(value))").tag(Double(value))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                    }
                }
                
                Section(header: Text("Meta diária")) {
                    Slider(value: $dailyGoal, in: 1000...5000, step: 100)
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
