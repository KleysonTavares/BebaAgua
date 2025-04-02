//
//  GenderSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 01/04/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender = .male // Masculino pré-selecionado

    enum Gender: String {
        case male = "Masculino"
        case female = "Feminino"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Barra de progresso (simulada)
                HStack {
                    genderStepView(icon: "person.2.fill", text: "Gênero", isSelected: true)
                    genderStepView(icon: "scalemass", text: "Peso", isSelected: false)
                    genderStepView(icon: "alarm", text: "--", isSelected: false)
                    genderStepView(icon: "moon.zzz.fill", text: "--", isSelected: false)
                }
                .padding(.top, 40)
                
                Text("Seu Gênero")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                HStack(spacing: 60) {
                    genderOption(imageName: "male", text: "Masculino", gender: .male)
                    genderOption(imageName: "female", text: "Feminino", gender: .female)
                }
                Spacer()
                    .padding(.top, 100)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)

                // Botão com navegação direta para OnboardingView
                NavigationLink(destination: OnboardingView().onAppear(perform: saveGender)) {
                    Text("Próximo")
                        .customButton()
                }
            }
            .padding(.bottom, 40)
        }
        .customBackButton()
    }
    
    // Função para salvar no UserDefaults e navegar
    func saveGender() {
        UserDefaults.standard.set(selectedGender.rawValue, forKey: "gender")
    }
    
    // Componente para os passos do topo
    func genderStepView(icon: String, text: String, isSelected: Bool) -> some View {
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
    
    // Opções de gênero (imagem e texto)
    func genderOption(imageName: String, text: String, gender: Gender) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(selectedGender == gender ? Color.blue : Color.gray, lineWidth: 4))
            
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(selectedGender == gender ? .blue : .gray)
        }
        .onTapGesture {
            selectedGender = gender
        }
    }
}

struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSelectionView()
    }
}
