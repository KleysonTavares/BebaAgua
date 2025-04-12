//
//  GenderSelectionView.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 01/04/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender = .male
    @Binding var path: NavigationPath
    
    var body: some View {
            VStack {
                // Barra de progresso (simulada)
                HStack {
                    progressStep(icon: "person.2.fill", text: selectedGender.rawValue, isSelected: true)
                    progressStep(icon: "scalemass", text: "Peso", isSelected: false)
                    progressStep(icon: "calendar.and.person", text: "idade", isSelected: false)
                    progressStep(icon: "alarm", text: "--", isSelected: false)
                    progressStep(icon: "moon.zzz.fill", text: "--", isSelected: false)
                }
                .padding(.top, 40)
                
                Text("Seu Gênero")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                HStack(spacing: 60) {
                    genderOption(imageName: "male", text: "Masculino", gender: .male)
                    genderOption(imageName: "female", text: "Feminino", gender: .female)
                }
                .padding(.top, 40)
                
                Spacer()
                    .padding(.top, 100)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
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
                        saveGender()
                        path.append(RouteScreensEnum.weight)
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
            .standardScreenStyle()
        }
    
    func saveGender() {
        UserDefaults.standard.set(selectedGender.rawValue, forKey: "gender")
    }
    
    // Componente para os passos do topo
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
        GenderSelectionView(path: .constant(NavigationPath()))
    }
}
