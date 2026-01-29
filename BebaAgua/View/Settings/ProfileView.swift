//
//  Profile.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 30/03/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage("gender", store: UserDefaults.shared) var gender: Gender = .male
    @AppStorage("age", store: UserDefaults.shared) var age: Int = 18
    @AppStorage("weight", store: UserDefaults.shared) var weight: Int = 70
    @AppStorage("dailyGoal", store: UserDefaults.shared) var dailyGoal: Double = 2000
    @AppStorage("reminderInterval", store: UserDefaults.shared) var reminderInterval: Double = 60
    @AppStorage("wakeUpTime", store: UserDefaults.shared) var wakeUpTime: String = "06:00"
    @AppStorage("bedTime", store: UserDefaults.shared) var bedTime: String = "22:00"
    
    @State private var tempGender: Gender = .male
    @State private var tempAge: Int = 18
    @State private var tempWeight: Int = 70
    @State private var tempDailyGoal: Double = 2000
    @State private var tempReminderInterval: Double = 60
    @State private var tempWakeUpDate: Date = Date()
    @State private var tempBedTimeDate: Date = Date()

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false // Remove separador de milhar
        formatter.numberStyle = .none
        return formatter
    }()

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Section(header: Text(LocalizedStringKey("gender")).font(.headline)) {
                            Picker(LocalizedStringKey("gender"), selection: $tempGender) {
                                Text(LocalizedStringKey("male")).tag(Gender.male)
                                Text(LocalizedStringKey("female")).tag(Gender.female)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue))
                        }
                        Divider().colorInvert()
                        Spacer()

                        HStack(spacing: 80) {
                            VStack {
                                Text(LocalizedStringKey("age"))
                                    .font(.headline)

                                Picker(LocalizedStringKey("age"), selection: $tempAge) {
                                    ForEach(1...100, id: \.self) { year in
                                        Text("\(numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)")").tag(year)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 120, height: 120)
                                .onChange(of: tempAge) { _ in
                                    tempDailyGoal = WaterCalculator.calculateDailyGoal(age: tempAge, weight: tempWeight)
                                } // Atualiza a meta diária
                            }

                            VStack {
                                Text(LocalizedStringKey("weightKg"))
                                    .font(.headline)
                                
                                Picker(LocalizedStringKey("weight"), selection: $tempWeight) {
                                    ForEach(1...200, id: \.self) { value in
                                        Text("\(Int(value))").tag(Int(value))
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 120, height: 120)
                                .onChange(of: tempWeight) { _ in
                                    tempDailyGoal = WaterCalculator.calculateDailyGoal(age: tempAge, weight: tempWeight)
                                } // Atualiza a meta diária
                            }
                        }
                        Divider().colorInvert()
                        Spacer()

                        Section(header: Text(LocalizedStringKey("dailyGoal")).font(.headline)) {
                            Slider(value: $tempDailyGoal, in: 500...5000, step: 100)
                            Text("\(Int(tempDailyGoal)) ml")
                        }
                        Divider().colorInvert()
                        Spacer()

                        Section(header: Text(LocalizedStringKey("notificationInterval")).font(.headline)) {
                            Slider(value: $tempReminderInterval, in: 15...180, step: 15)
                            Text("\(Int(tempReminderInterval)) min")
                        }
                        Divider().colorInvert()
                        Spacer()

                        HStack(spacing: 40) {
                            VStack {
                                Text(LocalizedStringKey("wakeUpTime"))
                                    .font(.headline)

                                DatePicker("", selection: $tempWakeUpDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(width: 160, height: 100)
                                    .labelsHidden()
                                    .clipped()
                            }
                            .padding()

                            VStack {
                                Text(LocalizedStringKey("bedTime"))
                                    .font(.headline)

                                DatePicker("", selection: $tempBedTimeDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(width: 160, height: 100)
                                    .labelsHidden()
                                    .clipped()
                            }
                        }
                    }
                    .padding()
                    Divider().colorInvert()
                }
                
                Spacer()
                
                Button(action: {
                    saveProfile()
                    NotificationManager.shared.scheduleDailyNotifications(wakeUpTime: wakeUpTime, bedTime: bedTime, interval: reminderInterval)
                    dismiss()
                }) {
                    Text(LocalizedStringKey("save"))
                        .customButton()
                }
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                setupInitialValues()
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
    
    func saveProfile() {
        gender = tempGender
        age = tempAge
        weight = tempWeight
        dailyGoal = tempDailyGoal
        reminderInterval = tempReminderInterval
        wakeUpTime = timeFormatter.string(from: tempWakeUpDate)
        bedTime = timeFormatter.string(from: tempBedTimeDate)
    }

    func setupInitialValues() {
        tempGender = gender
        tempAge = age
        tempWeight = weight
        tempDailyGoal = dailyGoal
        tempReminderInterval = reminderInterval
        tempWakeUpDate = timeFormatter.date(from: wakeUpTime) ?? Date()
        tempBedTimeDate = timeFormatter.date(from: bedTime) ?? Date()
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
