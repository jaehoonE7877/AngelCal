import Foundation
import SwiftData

/// Persisted event record stored by SwiftData.
@Model
public final class EventEntity {
    @Attribute(.unique) public var remoteID: Int64?
    public var userID: UUID
    public var calendarID: Int64
    public var title: String
    public var startAt: Date
    public var endAt: Date
    public var allDay: Bool
    public var timeZone: String?
    public var location: String?
    public var memo: String?
    public var url: String?
    public var recurrenceRule: String?
    public var colorOverride: String?
    public var onlineMeetingLink: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var localID: UUID
    public var pendingSync: Bool
    
    public init(
        remoteID: Int64? = nil,
        userID: UUID,
        calendarID: Int64,
        title: String,
        startAt: Date,
        endAt: Date,
        allDay: Bool = false,
        timeZone: String? = nil,
        location: String? = nil,
        memo: String? = nil,
        url: String? = nil,
        recurrenceRule: String? = nil,
        colorOverride: String? = nil,
        onlineMeetingLink: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        localID: UUID = UUID(),
        pendingSync: Bool = true
    ) {
        self.remoteID = remoteID
        self.userID = userID
        self.calendarID = calendarID
        self.title = title
        self.startAt = startAt
        self.endAt = endAt
        self.allDay = allDay
        self.timeZone = timeZone
        self.location = location
        self.memo = memo
        self.url = url
        self.recurrenceRule = recurrenceRule
        self.colorOverride = colorOverride
        self.onlineMeetingLink = onlineMeetingLink
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.localID = localID
        self.pendingSync = pendingSync
    }
}

/// Immutable Sendable snapshot of an event entity.
public struct EventEntitySnapshot: Sendable {
    public let remoteID: Int64?
    public let userID: UUID
    public let calendarID: Int64
    public let title: String
    public let startAt: Date
    public let endAt: Date
    public let allDay: Bool
    public let timeZone: String?
    public let location: String?
    public let memo: String?
    public let url: String?
    public let recurrenceRule: String?
    public let colorOverride: String?
    public let onlineMeetingLink: String?
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let localID: UUID
    public let pendingSync: Bool
}

public extension EventEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> EventEntitySnapshot {
        EventEntitySnapshot(
            remoteID: remoteID,
            userID: userID,
            calendarID: calendarID,
            title: title,
            startAt: startAt,
            endAt: endAt,
            allDay: allDay,
            timeZone: timeZone,
            location: location,
            memo: memo,
            url: url,
            recurrenceRule: recurrenceRule,
            colorOverride: colorOverride,
            onlineMeetingLink: onlineMeetingLink,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localID: localID,
            pendingSync: pendingSync
        )
    }
}
