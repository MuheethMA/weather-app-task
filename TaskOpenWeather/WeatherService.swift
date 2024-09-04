//
//  WeatherService.swift
//  TaskOpenWeather
//
//  Created by Abdul on 9/3/24.
//

import Foundation
import CoreLocation

class WeatherService {
    
    private let apiKey = "4dfceaa4551cad6626b4d42c293f2eba"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(byLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
            let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
            performRequest(with: urlString, completion: completion)
        
        }
    
    func fetchWeather(forCity city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?q=\(city)&appid=\(apiKey)&units=imperial"
        performRequest(with: urlString, completion: completion)
    }
    
    private func performRequest(with urlString: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(ServiceError.decodingError))
            }
        }
        task.resume()
    }
}

enum ServiceError: Error {
    case invalidURL
    case noData
    case decodingError
}
