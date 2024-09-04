//
//  WeatherModel.swift
//  TaskOpenWeather
//
//  Created by Abdul on 9/3/24.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    let sys: Sys
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Sys: Codable {
    let country: String
}
