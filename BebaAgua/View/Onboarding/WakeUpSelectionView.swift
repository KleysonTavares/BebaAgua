//
//  WakeUpSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 05/04/25.
//

import SwiftUI

struct WakeUpSelectionView: View {
    @AppStorage("gender") var gender: String?
    @AppStorage("weight") var weight: Int?
    @AppStorage("age") var age: Int?
    @State private var wakeUpTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()

    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            // Barra de progresso
            HStack {
                progressStep(icon: "person.2.fill", text: gender ?? "Gênero", isSelected: true)
                progressStep(icon: "scalemass", text: "\(weight ?? 70) kg", isSelected: true)
                progressStep(icon: "calendar", text: "\(age ?? 18) anos", isSelected: true)
                progressStep(icon: "alarm", text: "\(formattedTime)", isSelected: true)
                progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
            }
            .padding(.top, 40)
            
            Text("Horário Acordar")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Spacer()

            DatePicker("WakeUpTime", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
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
                    Text("Voltar")
                        .customBackButton()
                }
                
                Spacer()
                
                Button(action: {
                    saveWakeUpTime()
                    path.append(RouteScreensEnum.bedTime)
                }) {
                    Text("Próximo")
                        .customNextButton()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            
            .navigationDestination(for: RouteScreensEnum.self) { route in
                RouteScreen.destination(for: route, path: $path)
            }
        }
        .navigationBarBackButtonHidden(true)
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


