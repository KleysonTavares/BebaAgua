//
//  AgeView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 04/04/25.
//

import SwiftUI

struct AgeSelectionView: View {
    @AppStorage("gender") var gender: Gender = .male
    @AppStorage("weight") var weight: Int = 70
    @State private var age: Int = 18
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            // Barra de progresso
            HStack {
                progressStep(icon: "person.2.fill", text: gender.rawValue, isSelected: true)
                progressStep(icon: "scalemass", text: "\(weight) kg", isSelected: true)
                progressStep(icon: "calendar", text: "\(age)", isSelected: true)
                progressStep(icon: "alarm", text: "--", isSelected: false)
                progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
            }
            .padding(.top, 40)
            
            Text(LocalizedStringKey("yourAge"))
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            HStack(spacing: 30) {
                Picker(LocalizedStringKey("age"), selection: $age) {
                    ForEach(1...120, id: \ .self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 200, height: 120)
                
                Text(LocalizedStringKey("years"))
                    .font(.headline)
            }
            .padding(.top, 40)
            .padding(.trailing, -60)

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
                    saveAge()
                    path.append(RouteScreensEnum.wakeUp)
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
    
    func saveAge() {
        UserDefaults.standard.set(age, forKey: "age")
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

struct AgeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AgeSelectionView(path: .constant(NavigationPath()))
    }
}

