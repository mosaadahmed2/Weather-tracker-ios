//
//  HistoryView.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// HistoryView.swift
import SwiftUI

struct HistoryView: View {
    @ObservedObject var vm: WeatherHistoryViewModel
    @State private var showCityCounts = false

    var body: some View {
        NavigationStack {
            List {
                if !vm.countsByCity.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.countsByCity, id: \.city) { pair in
                                    Chip(text: "\(pair.city): \(pair.count)")
                                }
                            }.padding(.vertical, 6)
                        }
                    } header: {
                        Text("City Counts (recent)")
                    }
                }

                Section("Recent Searches") {
                    ForEach(vm.history) { rec in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rec.city).bold()
                                Text(rec.condition.capitalized).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(Int(rec.temperature))°C").bold()
                                Text(Self.format(rec.timestamp)).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private static func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct Chip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
}
