// CurrentView.swift
import SwiftUI

struct CurrentView: View {
    @ObservedObject var vm: WeatherHistoryViewModel
    @State private var night = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: night
                        ? [Color.black, Color.blue.opacity(0.7)]
                        : [Color.cyan, Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .animation(.easeInOut(duration: 1.0), value: night)
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
                                    .foregroundColor(night ? .white : .black)
                            }
                        }
                    }

                    // 🌦 Weather card or placeholder
                    if let w = vm.currentWeather {
                        WeatherCard(w: w, night: night)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.8), value: night)
                    } else {
                        Text("Search a city to see weather and save to history.")
                            .foregroundColor(night ? .white.opacity(0.7) : .black.opacity(0.7))
                            .animation(.easeInOut(duration: 0.8), value: night)
                    }

                    // 📊 Analytics strip
                    AnalyticsRow(vm: vm, night: night)
                        .animation(.easeInOut(duration: 1.0), value: night)

                    Spacer()
                }
                .padding()
                .environment(\.colorScheme, night ? .dark : .light)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Weather Tracker")
                        .font(.headline.bold())
                        .foregroundColor(night ? .white : .black)
                }
            }
            .toolbarBackground(night ? Color.black : Color.cyan, for: .navigationBar)
            .toolbarColorScheme(night ? .dark : .light)
            .foregroundColor(night ? .white : .black)
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: {
                Text(vm.errorMessage ?? "")
            })
            // ✅ MOVED onChange HERE - at the NavigationStack level
            .onChange(of: vm.lastUpdateTime) { _, _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    night = vm.currentWeather.map { vm.isNight(for: $0) } ?? false
                    print("👁 lastUpdateTime changed - night is now: \(night)")
                }
            }
            .onAppear {
                night = vm.currentWeather.map { vm.isNight(for: $0) } ?? false
            }
        }
    }
}

// MARK: - Weather Card
struct WeatherCard: View {
    let w: WeatherResponse
    let night: Bool

    var localTime: String {
        let df = DateFormatter()
        df.timeStyle = .short
        df.timeZone = TimeZone(secondsFromGMT: w.timezone)
        return df.string(from: Date())  // ✅ Just use Date() directly
    }

    var body: some View {
        VStack(spacing: 14) {
            // 🏙 City + Country
            Text("\(w.name), \(w.sys.country)")
                .font(.title2.bold())
                .foregroundColor(night ? .white : .black)

            // 🕐 Local Time
            Text("Local Time: \(localTime)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // ☀️ Weather Icon + Temperature
            Image(systemName: night ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 50))
                .symbolRenderingMode(.multicolor)

            Text("\(Int(w.main.temp))°C")
                .font(.system(size: 60).bold())
                .foregroundColor(night ? .white : .black)

            Text(w.weather.first?.description.capitalized ?? "")
                .font(.title3)
                .foregroundColor(night ? .white.opacity(0.8) : .black.opacity(0.8))

            // 🌙 Divider (clean, theme-aware)
            Divider()
                .background(night ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                .padding(.vertical, 4)

            // 📊 Main details row
            HStack(spacing: 20) {
                InfoItem(icon: "thermometer", label: "Feels Like", value: "\(Int(w.main.feels_like))°", night: night)
                InfoItem(icon: "humidity.fill", label: "Humidity", value: "\(w.main.humidity)%", night: night)
                InfoItem(icon: "wind", label: "Wind", value: "\(String(format: "%.1f m/s", w.wind.speed))", night: night)
            }

            // 🌅 Sunrise & Sunset
            Divider()
                .background(night ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                .padding(.vertical, 4)

            HStack(spacing: 20) {
                InfoItem(icon: "sunrise.fill", label: "Sunrise", value: formatTime(w.sys.sunrise, tz: w.timezone), night: night)
                InfoItem(icon: "sunset.fill", label: "Sunset", value: formatTime(w.sys.sunset, tz: w.timezone), night: night)
            }
        }
        .padding()
        .background(night ? Color.white.opacity(0.15) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: night ? .white.opacity(0.1) : .gray.opacity(0.4), radius: 6)
        .animation(.easeInOut(duration: 1.0), value: night)
    }
}


// MARK: - Helper for local times
func formatTime(_ timestamp: Int, tz: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let df = DateFormatter()
    df.timeStyle = .short
    df.timeZone = TimeZone(secondsFromGMT: tz)
    return df.string(from: date)
}


// MARK: - Info Item
struct InfoItem: View {
    let icon: String
    let label: String
    let value: String
    let night: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(night ? .white : .black)
            Text(label)
                .font(.caption2)
                .foregroundColor(night ? .white.opacity(0.8) : .black.opacity(0.8))
            Text(value)
                .font(.headline)
                .foregroundColor(night ? .white : .black)
        }
        .animation(.easeInOut(duration: 1.0), value: night)
    }
}

// MARK: - AnalyticsItem
struct AnalyticsItem: View {
    let title: String
    let value: String
    let night: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(night ? .white.opacity(0.8) : .black.opacity(0.7))

            Text(value)
                .font(.headline.bold())
                .foregroundColor(night ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(night ? Color.white.opacity(0.12) : Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: night ? .white.opacity(0.1) : .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.8), value: night)
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




struct AnalyticsRow: View {
    @ObservedObject var vm: WeatherHistoryViewModel
    let night: Bool

    var body: some View {
        HStack(spacing: 16) {
            AnalyticsItem(
                title: "Avg Temp",
                value: String(format: "%.1f°C", vm.avgTemp),
                night: night
            )

            AnalyticsItem(
                title: "Hottest City",
                value: vm.hottest?.city ?? "N/A",
                night: night
            )

            AnalyticsItem(
                title: "Top City",
                value: vm.countsByCity.first?.city ?? "N/A",
                night: night
            )
        }
        .font(.subheadline)
        .bold()
        .padding()
        .frame(maxWidth: .infinity)
        .background(night ? Color.white.opacity(0.15) : Color.white.opacity(0.7))
        .foregroundColor(night ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .animation(.easeInOut(duration: 1.0), value: night)
    }
}



