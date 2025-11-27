import Foundation
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var url: URL?
    var isAllDay: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Supabase Sync Status
    var isSynced: Bool = false
    var userId: UUID? // Owner ID from Supabase
    
    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil,
        isAllDay: Bool = false,
        userId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.url = url
        self.isAllDay = isAllDay
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// SwiftData @Model types are not Sendable by default.
// We only pass Event across Sendable closures; the underlying storage remains on main actor.
extension Event: @unchecked Sendable {}
