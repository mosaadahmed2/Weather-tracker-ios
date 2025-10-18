//
//  WeatherResponse.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// WeatherModel.swift
import Foundation

struct WeatherResponse: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    let sys: Sys
    let wind: Wind
    let timezone: Int     // seconds from UTC
    let dt: Int           // current time (UTC seconds)
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Sys: Codable {
    let sunrise: Int
    let sunset: Int
    let country: String
}

struct Wind: Codable {
    let speed: Double
}

