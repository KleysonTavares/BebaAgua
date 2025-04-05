//
//  WeightSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 02/04/25.
//

import SwiftUI

struct WeightSelectionView: View {
    @AppStorage("gender") var gender: String?
    @State private var weight: Int = 70 // Peso inicial
    @State private var navigateToNext = false
    
    var body: some View {
            VStack {
                // Barra de progresso
                HStack {
                    progressStep(icon: "person.2.fill", text: gender ?? "Gênero", isSelected: true)
                    progressStep(icon: "scalemass", text: "\(weight) kg", isSelected: true)
                    progressStep(icon: "calendar.and.person", text: "idade", isSelected: false)
                    progressStep(icon: "alarm", text: "--", isSelected: false)
                    progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
                }
                .padding(.top, 40)
                
                Text("Seu Peso")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                HStack(spacing: 30) {
                    Picker("Peso", selection: $weight) {
                        ForEach(30...200, id: \ .self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 200, height: 120)
                    
                    Text("kg")
                        .font(.headline)
                }
                .padding(.top, 40)
                .padding(.trailing, -60)
                
                Spacer()
                
                HStack {
                    Text("Voltar")
                        .customBackButton()
                    
                    Spacer()
                    
                    Button(action: saveWeight) {
                        Text("Próximo")
                            .customNextButton()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                NavigationLink(destination: AgeSelectionView(), isActive: $navigateToNext) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    
    func saveWeight() {
        UserDefaults.standard.set(weight, forKey: "weight")
        navigateToNext = true
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

struct WeightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WeightSelectionView()
    }
}

