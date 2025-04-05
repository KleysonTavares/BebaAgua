//
//  BedTimeSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 05/04/25.
//

import SwiftUI

struct BedTimeSelectionView: View {
    @AppStorage("gender") var gender: String?
    @AppStorage("weight") var weight: Int?
    @AppStorage("age") var age: Int?
    @AppStorage("wakeUpTime") var wakeUpTime: String?
    @State private var bedTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()

    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            // Barra de progresso
            HStack {
                progressStep(icon: "person.2.fill", text: gender ?? "Gênero", isSelected: true)
                progressStep(icon: "scalemass", text: "\(weight ?? 70) kg", isSelected: true)
                progressStep(icon: "calendar", text: "\(age ?? 18) anos", isSelected: true)
                progressStep(icon: "alarm", text: "\(wakeUpTime ?? "07:00")", isSelected: true)
                progressStep(icon: "moon.zzz.fill", text: formattedTime, isSelected: true)
            }
            .padding(.top, 40)
            
            Text("Horário Dormir")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Spacer()

            DatePicker("$BedTime", selection: $bedTime, displayedComponents: .hourAndMinute)
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
                    saveBedTime()
                    path.append(RouteScreensEnum.home)
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
           return formatter.string(from: bedTime)
       }
    
    func saveBedTime() {
        UserDefaults.standard.set(formattedTime, forKey: "bedTime")
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

struct BedTimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        BedTimeSelectionView(path: .constant(NavigationPath()))
    }
}



