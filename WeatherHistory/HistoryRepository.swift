//
//  HistoryRepository.swift
//  WeatherHistory
//
//  Created by Mosaad Ahmed Mohammed on 10/16/25.
//


// HistoryRepository.swift
import Foundation
import FirebaseFirestore

final class HistoryRepository {
    private let db = Firestore.firestore()
    private let collection = "weatherRecords"

    func add(_ record: HistoryRecord) async throws {
        _ = try await db.collection(collection).addDocument(data: record.asDict)
        print("✅ Added record to Firestore:", record.asDict)

    }

    func listenLatest(limit: Int = 50, onChange: @escaping ([HistoryRecord]) -> Void) -> ListenerRegistration {
        db.collection(collection)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else {
                    onChange([]); return
                }
                let items = docs.compactMap(HistoryRecord.init(from:))
                onChange(items)
            }
    }
}
