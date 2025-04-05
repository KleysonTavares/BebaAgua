//
//  AgeView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 04/04/25.
//

import SwiftUI

struct AgeSelectionView: View {
    @AppStorage("gender") var gender: String?
    @AppStorage("weight") var weight: Int?
    @State private var age: Int = 18 // Idade inicial
    
    var body: some View {
        VStack {
            // Barra de progresso
            HStack {
                progressStep(icon: "person.2.fill", text: gender ?? "Gênero", isSelected: true)
                progressStep(icon: "scalemass", text: "\(weight ?? 70) kg", isSelected: true)
                progressStep(icon: "calendar", text: "\(age) anos", isSelected: true)
                progressStep(icon: "alarm", text: "--", isSelected: false)
                progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
            }
            .padding(.top, 40)
            
            Text("Sua Idade")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            HStack(spacing: 30) {
                Picker("Age", selection: $age) {
                    ForEach(1...120, id: \ .self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 200, height: 120)
                
                Text("anos")
                    .font(.headline)
            }
            .padding(.top, 40)
            .padding(.trailing, -60)

            Spacer()
            
            HStack {
                    Text("Voltar")
                        .customBackButton()

                Spacer()
                
                Button(action: saveAndContinue) {
                    Text("Próximo")
                    .customNextButton()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func saveAndContinue() {
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
        AgeSelectionView()
    }
}

