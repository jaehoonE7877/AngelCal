import Foundation
import Core
import SwiftDataClient

public struct SearchRepository {
    let swiftDataClient: SwiftDataClient
    public init(swiftDataClient: SwiftDataClient) { self.swiftDataClient = swiftDataClient }
    
    public func search(query: String, calendarIDs: [Int64]?, from: Date?, to: Date?) throws -> [Event] {
        let events = try swiftDataClient.fetchEvents(from: from ?? .distantPast, to: to ?? .distantFuture)
        let lowered = query.lowercased()
        let filtered = events
            .filter { $0.deletedAt == nil }
            .map { $0.toDomain() }
            .filter { ev in
                let matchesCalendar = calendarIDs == nil || calendarIDs!.contains(ev.calendarID)
                guard matchesCalendar else { return false }
                if lowered.isEmpty { return true }
                let text = [
                    ev.title,
                    ev.memo ?? "",
                    ev.location ?? "",
                    ev.url ?? ""
                ].joined(separator: " ").lowercased()
                return text.contains(lowered)
            }
        return filtered.sorted { $0.startAt < $1.startAt }
    }
}
