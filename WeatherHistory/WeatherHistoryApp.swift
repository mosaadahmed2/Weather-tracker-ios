//
//  WeatherHistoryApp.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//

import SwiftUI
import FirebaseCore

@main
struct SwiftWeatherApp: App {
    init() {
        FirebaseApp.configure()
        print("✅ Firebase configured: \(FirebaseApp.app() != nil)")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
