//
//  Profile.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss  // Adiciona isso no início da View

    @AppStorage("gender") var gender: Gender = .male
    @AppStorage("age") var age: Int = 18
    @AppStorage("weight") var weight: Int = 70
    @AppStorage("dailyGoal") var dailyGoal: Double = 2000
    @AppStorage("reminderInterval") var reminderInterval: Double = 120
    @AppStorage("wakeUpTime") var wakeUpTime: String = "06:00"
    @AppStorage("bedTime") var bedTime: String = "22:00"

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false // Remove separador de milhar
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Section(header: Text(LocalizedStringKey("gender")).font(.headline)) {
                            Picker(LocalizedStringKey("gender"), selection: $gender) {
                                Text(LocalizedStringKey("male")).tag(Gender.male)
                                Text(LocalizedStringKey("female")).tag(Gender.female)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue))
                        }
                        Divider().colorInvert()
                        
                        HStack(spacing: 80) {
                            VStack {
                                Text(LocalizedStringKey("age"))
                                    .font(.headline)
                                
                                Picker(LocalizedStringKey("age"), selection: $age) {
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
                                Text(LocalizedStringKey("weightKg"))
                                    .font(.headline)
                                
                                Picker(LocalizedStringKey("weight"), selection: $weight) {
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
                        
                        Section(header: Text(LocalizedStringKey("dailyGoal")).font(.headline)) {
                            Slider(value: $dailyGoal, in: 500...5000, step: 100)
                            Text("\(Int(dailyGoal)) ml")
                        }
                        Divider().colorInvert()
                        
                        Section(header: Text(LocalizedStringKey("notificationInterval")).font(.headline)) {
                            Slider(value: $reminderInterval, in: 15...180, step: 15)
                            Text("\(Int(reminderInterval)) min")
                        }
                    }
                    .padding()
                }
                
                Spacer()

                Button(action: {
                    UserDefaults.standard.set(gender.rawValue, forKey: "gender")
                    UserDefaults.standard.set(age, forKey: "age")
                    UserDefaults.standard.set(weight, forKey: "weight")
                    UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
                    UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval")
                    NotificationManager.shared.evaluateSmartReminder()
                    dismiss()
                }) {
                    Text(LocalizedStringKey("save"))
                        .frame(maxWidth: .infinity)
                }
                .customButton()
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear { // atualiza ao abrir a tela
                dailyGoal = WaterCalculator.calculateDailyGoal(age: age, weight: weight)
                configureSegmentedPicker()
            }
            .standardScreenStyle()
            .navigationBarTitle(LocalizedStringKey("editProfile"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .standardScreenStyle()
    }
    
    func configureSegmentedPicker() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.systemBlue],
            for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
    }
}

    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView()
        }
    }
