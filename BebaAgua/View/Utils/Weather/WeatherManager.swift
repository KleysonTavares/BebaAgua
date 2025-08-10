//
//  WeatherManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 04/08/25.
//

import Foundation
import SwiftUI

struct WeatherAPIResponse: Codable {
    let current: Current
}

struct Current: Codable {
    let temp_c: Double
    let humidity: Int
}

class WeatherManager: ObservableObject {
    @AppStorage("dailyGoal") var baseGoal: Double = 2000
    @AppStorage("adjustedGoal") var adjustedGoal: Double = 2000
    @Published var temperature: Double?
    @Published var humidity: Int?

    private let weatherapiKey: String = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String ?? ""

    func fetchWeather(city: String) async throws -> WeatherAPIResponse {
        let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(weatherapiKey)&q=\(cityQuery)&lang=pt"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
        return decoded
    }
    
    func adjustedGoalStorage(city: String) async {
        do {
            let weather = try await fetchWeather(city: city)
            var goal = baseGoal
            
            if weather.current.temp_c >= 30 {
                goal *= 1.15
            } else if weather.current.temp_c >= 25 {
                goal *= 1.10
            }

            if weather.current.humidity <= 30 {
                goal *= 1.05
            }

            let finalGoal = goal
            await MainActor.run {
                if finalGoal > adjustedGoal {
                    adjustedGoal = finalGoal
                }
            }
        } catch {
            print("Erro ao buscar dados do clima: \(error.localizedDescription)")
        }
    }
}
