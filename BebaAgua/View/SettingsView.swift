//
//  OnboardingView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("gender") var gender: Gender = .male
    @AppStorage("age") var age: Int = 18
    @AppStorage("weight") var weight: Int = 70
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    @AppStorage("reminderInterval") var reminderInterval: Double = 60
    @AppStorage("wakeUpTime") var wakeUpTime: String = "06:00"
    @AppStorage("bedTime") var bedTime: String = "22:00"
    
    @State private var isOnboardingComplete = false
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false // Remove separador de milhar
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Perfil").font(.title2)
                VStack(spacing: 20) {
                    Section(header: Text("Gênero").font(.headline)) {
                        Picker("Genero", selection: $gender) {
                            Text("Masculino").tag("Masculino")
                            Text("Feminino").tag("Feminino")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue))
                    }
                    Divider().colorInvert()
                    
                    HStack(spacing: 80) {
                        VStack {
                            Text("Idade")
                                .font(.headline)
                            
                            Picker("Idade", selection: $age) {
                                ForEach(1...100, id: \.self) { year in
                                    Text("\(numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)")").tag(year)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 120)
                            .onChange(of: age) { _ in
                                dailyGoal = WaterCalculator.calculateDailyGoal(age: age, weight: weight)
                            } // Atualiza a meta diária
                        }
                        
                        VStack {
                            Text("Peso (kg)")
                                .font(.headline)
                            
                            Picker("Peso", selection: $weight) {
                                ForEach(1...200, id: \.self) { value in
                                    Text("\(Int(value))").tag(Double(value))
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 120)
                            .onChange(of: weight) { _ in
                                dailyGoal = WaterCalculator.calculateDailyGoal(age: age, weight: weight)
                            } // Atualiza a meta diária
                        }
                    }
                    Divider().colorInvert()
                    
                    Section(header: Text("Meta diária").font(.headline)) {
                        Slider(value: $dailyGoal, in: 500...5000, step: 100)
                        Text("\(Int(dailyGoal)) ml")
                    }
                    Divider().colorInvert()
                    
                    Section(header: Text("Intervalo das notificações").font(.headline)) {
                        Slider(value: $reminderInterval, in: 15...180, step: 15)
                        Text("\(Int(reminderInterval)) min")
                    }
                }
                .padding()
            }
            
            Spacer()
            
            Button("Salvar") {
                isOnboardingComplete = true
                UserDefaults.standard.set(gender, forKey: "gender")
                UserDefaults.standard.set(age, forKey: "age")
                UserDefaults.standard.set(weight, forKey: "weight")
                UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
                UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval")
            }
            .customButton()
            Spacer()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { // atualiza ao abrir a tela
            dailyGoal = WaterCalculator.calculateDailyGoal(age: age, weight: weight)
        }
        .standardScreenStyle()
    }
}

    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
