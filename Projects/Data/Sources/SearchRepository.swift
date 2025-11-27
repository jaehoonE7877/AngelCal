import Foundation
import Core
import SwiftDataClient

public struct SearchRepository {
    let swiftDataClient: SwiftDataClient
    public init(swiftDataClient: SwiftDataClient) { self.swiftDataClient = swiftDataClient }
    
    public func search(query: String, calendarIDs: [Int64]?, from: Date?, to: Date?) async throws -> [Event] {
        let events = try await swiftDataClient.fetchEvents(from: from ?? .distantPast, to: to ?? .distantFuture)
        let lowered = query.lowercased()
        return events.map { $0.toDomain() }.filter { ev in
            (calendarIDs == nil || calendarIDs!.contains(ev.calendarID)) &&
            (
                ev.title.lowercased().contains(lowered) ||
                (ev.memo ?? "").lowercased().contains(lowered) ||
                (ev.location ?? "").lowercased().contains(lowered) ||
                (ev.url ?? "").lowercased().contains(lowered)
            )
        }
    }
}
