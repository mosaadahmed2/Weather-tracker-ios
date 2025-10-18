//
//  HistoryRecord.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// HistoryRecord.swift (our Firestore DTO)
import Foundation
import FirebaseFirestore

struct HistoryRecord: Identifiable, Codable {
    var id: String = UUID().uuidString
    let city: String
    let temperature: Double
    let condition: String
    let timestamp: Date

    // Firestore mapping
    init(city: String, temperature: Double, condition: String, timestamp: Date = Date()) {
        self.city = city
        self.temperature = temperature
        self.condition = condition
        self.timestamp = timestamp
    }

    init?(from doc: DocumentSnapshot) {
        guard let data = doc.data(),
              let city = data["city"] as? String,
              let temperature = data["temperature"] as? Double,
              let condition = data["condition"] as? String,
              let ts = data["timestamp"] as? Timestamp
        else { return nil }
        self.id = doc.documentID
        self.city = city
        self.temperature = temperature
        self.condition = condition
        self.timestamp = ts.dateValue()
    }

    var asDict: [String: Any] {
        [
            "city": city,
            "temperature": temperature,
            "condition": condition,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
