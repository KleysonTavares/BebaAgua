//
//  WakeUpSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 05/04/25.
//

import SwiftUI

struct WakeUpSelectionView: View {
    @AppStorage("gender") var gender: Gender = .male
    @AppStorage("weight") var weight: Int = 70
    @AppStorage("age") var age: Int = 18
    @State private var wakeUpTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()

    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            // Barra de progresso
            HStack {
                progressStep(icon: "person.2.fill", text: gender.rawValue, isSelected: true)
                progressStep(icon: "scalemass", text: "\(weight) kg", isSelected: true)
                progressStep(icon: "calendar", text: "\(age)", isSelected: true)
                progressStep(icon: "alarm", text: "\(formattedTime)", isSelected: true)
                progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
            }
            .padding(.top, 40)
            
            Text(LocalizedStringKey("wakeUpTime"))
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Spacer()

            DatePicker(LocalizedStringKey("wakeUpTime"), selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                           .datePickerStyle(WheelDatePickerStyle())
                           .labelsHidden()
                           .frame(width: 200, height: 100)
                           .clipped()
                           .padding()

            Spacer()
            
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    Text(LocalizedStringKey("back"))
                        .customBackButton()
                }
                
                Spacer()
                
                Button(action: {
                    saveWakeUpTime()
                    path.append(RouteScreensEnum.bedTime)
                }) {
                    Text(LocalizedStringKey("next"))
                        .customNextButton()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            
            .navigationDestination(for: RouteScreensEnum.self) { route in
                RouteScreen.destination(for: route, path: $path)
            }
        }
        .standardScreenStyle()
    }
    
    var formattedTime: String {
           let formatter = DateFormatter()
           formatter.timeStyle = .short
           return formatter.string(from: wakeUpTime)
       }
    
    func saveWakeUpTime() {
        UserDefaults.standard.set(formattedTime, forKey: "wakeUpTime")
    }
    
    func progressStep(icon: String, text: String, isSelected: Bool) -> some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .blue : .gray)
                .padding()
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(text)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

struct WakeUpSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WakeUpSelectionView(path: .constant(NavigationPath()))
    }
}


