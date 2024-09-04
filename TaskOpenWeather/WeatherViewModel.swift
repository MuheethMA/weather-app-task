//
//  WeatherViewModel.swift
//  TaskOpenWeather
//
//  Created by Abdul on 9/3/24.
//

import Foundation
import CoreLocation

class WeatherViewModel {
    
    private let weatherService = WeatherService()
    
    var cityName: String = ""
    var countryCode: String = ""
    var temperature: String = ""
    var feels_like: String = ""
    var temp_min: String = ""
    var temp_max: String = ""
    var humidity: String = ""
    var description: String = ""
    var iconURL: String = ""
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // Fetch weather by latitude and longitude
        func fetchWeather(byLatitude latitude: Double, longitude: Double) {
            weatherService.fetchWeather(byLatitude: latitude, longitude: longitude) { [weak self] result in
                switch result {
                case .success(let weather):
                    self?.updateProperties(with: weather)
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    
    
    func fetchWeather(byCity city: String) {
        weatherService.fetchWeather(forCity: city) { [weak self] result in
            switch result {
            case .success(let weather):
                self?.updateProperties(with: weather)
                self?.onDataUpdated?()
                self?.saveLastSearchedCity(city)
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
    
    private func updateProperties(with weather: WeatherResponse) {
        self.cityName = weather.name
        self.countryCode = weather.sys.country
        self.temperature = String(format: "%.0f°F", weather.main.temp)
        self.feels_like = String(format: "%.0f°F", weather.main.feels_like)
        self.temp_min = String(format: "%.0f°F", weather.main.temp_min)
        self.temp_max = String(format: "%.0f°F", weather.main.temp_max)
        self.humidity = "\(weather.main.humidity)%"
        self.description = weather.weather.first?.description.capitalized ?? ""
        if let icon = weather.weather.first?.icon {
            self.iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        }
    }
    
    private func saveLastSearchedCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: "LastSearchedCity")
    }
    
    func loadLastSearchedCity() -> String? {
        return UserDefaults.standard.string(forKey: "LastSearchedCity")
    }
}
