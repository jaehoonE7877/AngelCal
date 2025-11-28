import Foundation
import SwiftData

/// Persisted reminder entry linked to an event.
@Model
public final class EventReminderEntity {
    @Attribute(.unique) public var remoteID: Int64?
    public var eventID: Int64
    public var offsetMinutes: Int
    public var createdAt: Date
    public var localID: UUID
    public var pendingSync: Bool

    public init(
        remoteID: Int64? = nil,
        eventID: Int64,
        offsetMinutes: Int = -10,
        createdAt: Date = Date(),
        localID: UUID = UUID(),
        pendingSync: Bool = true
    ) {
        self.remoteID = remoteID
        self.eventID = eventID
        self.offsetMinutes = offsetMinutes
        self.createdAt = createdAt
        self.localID = localID
        self.pendingSync = pendingSync
    }
}

/// Immutable Sendable snapshot of an event reminder entity.
public struct EventReminderEntitySnapshot: Sendable {
    public let remoteID: Int64?
    public let eventID: Int64
    public let offsetMinutes: Int
    public let createdAt: Date
    public let localID: UUID
    public let pendingSync: Bool
}

public extension EventReminderEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> EventReminderEntitySnapshot {
        EventReminderEntitySnapshot(
            remoteID: remoteID,
            eventID: eventID,
            offsetMinutes: offsetMinutes,
            createdAt: createdAt,
            localID: localID,
            pendingSync: pendingSync
        )
    }
}
