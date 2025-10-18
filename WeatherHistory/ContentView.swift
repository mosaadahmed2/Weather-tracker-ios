// CurrentView.swift
import SwiftUI


struct CurrentView: View {
    @ObservedObject var vm: WeatherHistoryViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // 🌗 Background gradient changes with time of day
                let night = vm.currentWeather.map { vm.isNight(for: $0) } ?? false

                LinearGradient(
                    colors: night
                        ? [Color.black, Color.blue.opacity(0.7)]
                        : [Color.cyan, Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // 🔍 Search bar
                    HStack {
                        TextField("City name (e.g., Cincinnati)", text: $vm.cityInput)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit { Task { await vm.fetchAndSave() } }

                        Button {
                            Task { await vm.fetchAndSave() }
                        } label: {
                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 28))
                            }
                        }
                    }

                    // 🌦 Weather card or placeholder
                    if let w = vm.currentWeather {
                        WeatherCard(w: w, vm: vm)

                    } else {
                        Text("Search a city to see weather and save to history.")
                            .foregroundStyle(.secondary)
                    }

                    // 📊 Analytics strip
                    AnalyticsStrip(
                        avgTemp: vm.avgTemp,
                        hottest: vm.hottest,
                        topCity: vm.countsByCity.first?.city
                    )

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Weather Tracker")
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: {
                Text(vm.errorMessage ?? "")
            })
        }
    }
}


struct WeatherCard: View {
    let w: WeatherResponse
    @ObservedObject var vm: WeatherHistoryViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text("\(w.name), \(w.sys.country)")
                .font(.title2)
                .bold()

            Image(systemName: vm.isNight(for: w) ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 50))
                .symbolRenderingMode(.multicolor)

            Text("\(Int(w.main.temp))°C")
                .font(.system(size: 60))
                .bold()

            Text(w.weather.first?.description.capitalized ?? "")
                .font(.title3)
                .foregroundStyle(.secondary)

            Divider().padding(.vertical, 8)

            HStack(spacing: 20) {
                InfoItem(icon: "thermometer", label: "Feels Like", value: "\(Int(w.main.feels_like))°")
                InfoItem(icon: "humidity.fill", label: "Humidity", value: "\(w.main.humidity)%")
                InfoItem(icon: "wind", label: "Wind", value: "\(String(format: "%.1f m/s", w.wind.speed))")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 6)
    }
}

struct InfoItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(label).font(.caption2)
            Text(value).font(.headline)
        }
    }
}
    
struct AnalyticsStrip: View {
    let avgTemp: Double
    let hottest: HistoryRecord?
    let topCity: String?

    var body: some View {
        HStack(spacing: 12) {
            StatPill(title: "Avg Temp", value: avgTemp.isFinite ? String(format: "%.1f°C", avgTemp) : "--")
            StatPill(title: "Hottest", value: hottest != nil ? "\(hottest!.city) \(Int(hottest!.temperature))°" : "--")
            StatPill(title: "Top City", value: topCity ?? "--")
        }
    }
}

struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.secondary.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
