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
    
    // New fields
    var calendarId: UUID?
    var recurrenceRule: String? // iCal RRULE format
    var colorOverride: String? // Hex string
    var attendees: [String]? // List of email or names
    var onlineMeetingLink: URL?
    
    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil,
        isAllDay: Bool = false,
        userId: UUID? = nil,
        calendarId: UUID? = nil,
        recurrenceRule: String? = nil,
        colorOverride: String? = nil,
        attendees: [String]? = nil,
        onlineMeetingLink: URL? = nil
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
        self.calendarId = calendarId
        self.recurrenceRule = recurrenceRule
        self.colorOverride = colorOverride
        self.attendees = attendees
        self.onlineMeetingLink = onlineMeetingLink
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// SwiftData @Model types are not Sendable by default.
// We only pass Event across Sendable closures; the underlying storage remains on main actor.
extension Event: @unchecked Sendable {}
