//
//  OnboardingView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selectedGender = "Masculino"
    @State private var age = 18
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
                ZStack {
                    VStack {
                        ScrollView {
                            Text("Perfil").font(.title2)
                            VStack(spacing: 20) {
                                Section(header: Text("Sexo").font(.headline)) {
                                    Picker("Sexo", selection: $selectedGender) {
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
                                        .onChange(of: age) { _ in updateDailyGoal() } // Atualiza a meta diária
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
                                        .onChange(of: weight) { _ in updateDailyGoal() } // Atualiza a meta diária
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
                        
                        Button("Salvar e Continuar") {
                            isOnboardingComplete = true
                            UserDefaults.standard.set(selectedGender, forKey: "gender")
                            UserDefaults.standard.set(age, forKey: "age")
                            UserDefaults.standard.set(weight, forKey: "weight")
                            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
                            UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .foregroundColor(.white).bold()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .fullScreenCover(isPresented: $isOnboardingComplete) {
                    ContentView()
                }
            }
            .onAppear {
                updateDailyGoal() // Atualiza a meta ao abrir a tela
            }
            .customBackButton()
        }
    /// Atualiza a meta diária de água com base na idade e no peso
        private func updateDailyGoal() {
            let mlPerKg: Double

            switch age {
            case 1...17:
                mlPerKg = 40.0
            case 18...55:
                mlPerKg = 35.0
            case 56...65:
                mlPerKg = 30.0
            default:
                mlPerKg = 25.0
            }

            dailyGoal = weight * mlPerKg
        }
    }

    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingView()
        }
    }
