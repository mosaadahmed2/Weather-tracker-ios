//
//  RootView.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// RootView.swift
import SwiftUI

struct RootView: View {
    @StateObject private var vm = WeatherHistoryViewModel()

    var body: some View {
        TabView {
            CurrentView(vm: vm)
                .tabItem { Label("Current", systemImage: "sun.max.fill") }

            HistoryView(vm: vm)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .onAppear { vm.startListening() }
        .onDisappear { vm.stopListening() }
    }
}
