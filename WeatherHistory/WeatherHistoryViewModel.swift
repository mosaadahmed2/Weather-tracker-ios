//
//  WeatherHistoryViewModel.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// WeatherHistoryViewModel.swift
import Foundation
import Combine
import FirebaseFirestore


@MainActor
final class WeatherHistoryViewModel: ObservableObject {
    @Published var cityInput: String = ""
    @Published var currentWeather: WeatherResponse?
    @Published var history: [HistoryRecord] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var lastUpdateTime = Date()

    // Analytics
    @Published var avgTemp: Double = 0
    @Published var hottest: HistoryRecord?
    @Published var countsByCity: [(city: String, count: Int)] = []

    private let weatherService = WeatherService()
    private let repo = HistoryRepository()
    private var listener: ListenerRegistration?

    func startListening() {
        listener = repo.listenLatest { [weak self] items in
            guard let self else { return }
            self.history = items
            self.recomputeAnalytics()
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func fetchAndSave() async {
        let name = cityInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        print("🔍 fetchAndSave called for city: \(name)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let weather = try await weatherService.fetchWeather(for: name)
            self.currentWeather = weather
            self.lastUpdateTime = Date()
            // 🐛 DEBUG: Check night calculation right after fetching
            print("✅ Got weather for: \(weather.name)")
            let nightValue = isNight(for: weather)
            print("🌙 Calculated isNight: \(nightValue)")
            
            // Save to Firestore
            let rec = HistoryRecord(
                city: weather.name,
                temperature: weather.main.temp,
                condition: weather.weather.first?.description ?? ""
            )
            try await repo.add(rec)
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching weather: \(error.localizedDescription)")
        }
        
        isLoading = false
    }

    private func recomputeAnalytics() {
        guard !history.isEmpty else {
            avgTemp = 0; hottest = nil; countsByCity = []; return
        }
        // Average temperature
        let sum = history.reduce(0.0) { $0 + $1.temperature }
        avgTemp = sum / Double(history.count)

        // Hottest record
        hottest = history.max(by: { $0.temperature < $1.temperature })

        // Per-city counts
        var counts: [String: Int] = [:]
        for rec in history {
            counts[rec.city, default: 0] += 1
        }
        countsByCity = counts
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                lhs.1 == rhs.1 ? lhs.0 < rhs.0 : lhs.1 > rhs.1
            }
    }
    func isNight(for weather: WeatherResponse) -> Bool {
        // Get current UTC time as Unix timestamp
        let currentTime = Date().timeIntervalSince1970
        
        // Sunrise and sunset are already Unix timestamps in UTC from the API
        let sunriseTime = TimeInterval(weather.sys.sunrise)
        let sunsetTime = TimeInterval(weather.sys.sunset)
        
        // 🐛 DEBUG: Print all the values
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🏙 City: \(weather.name)")
        print("🕐 Current Unix Time: \(currentTime)")
        print("🌅 Sunrise Unix Time: \(sunriseTime)")
        print("🌇 Sunset Unix Time: \(sunsetTime)")
        
        // Convert to readable times for debugging
        let df = DateFormatter()
        df.timeStyle = .medium
        df.timeZone = TimeZone(secondsFromGMT: weather.timezone)
        
        print("🕐 Current Local Time: \(df.string(from: Date()))")
        print("🌅 Sunrise Local Time: \(df.string(from: Date(timeIntervalSince1970: sunriseTime)))")
        print("🌇 Sunset Local Time: \(df.string(from: Date(timeIntervalSince1970: sunsetTime)))")
        
        let isNight = currentTime < sunriseTime || currentTime > sunsetTime
        print("🌙 Is Night? \(isNight)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        return isNight
    }



}
