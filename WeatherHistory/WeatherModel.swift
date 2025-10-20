//
//  WeatherResponse.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// WeatherModel.swift
import Foundation

struct WeatherResponse: Codable, Equatable {
    let name: String
    let main: Main
    let weather: [Weather]
    let sys: Sys
    let wind: Wind
    let timezone: Int     // seconds from UTC
    let dt: Int           // current time (UTC seconds)
}

struct Main: Codable, Equatable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Weather: Codable, Equatable {
    let description: String
    let icon: String
}

struct Sys: Codable, Equatable {
    let sunrise: Int
    let sunset: Int
    let country: String
}

struct Wind: Codable, Equatable {
    let speed: Double
}

