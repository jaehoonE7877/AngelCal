import Foundation
import SwiftData

/// Persisted calendar definition.
@Model
public final class CalendarEntity {
    @Attribute(.unique) public var remoteID: Int64?
    public var ownerID: UUID
    public var name: String
    public var colorKey: String
    public var isPrimary: Bool
    public var isDefaultForNewEvents: Bool
    public var isShared: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var localID: UUID
    public var pendingSync: Bool
    
    public init(
        remoteID: Int64? = nil,
        ownerID: UUID,
        name: String,
        colorKey: String = "blue",
        isPrimary: Bool = false,
        isDefaultForNewEvents: Bool = false,
        isShared: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        localID: UUID = UUID(),
        pendingSync: Bool = true
    ) {
        self.remoteID = remoteID
        self.ownerID = ownerID
        self.name = name
        self.colorKey = colorKey
        self.isPrimary = isPrimary
        self.isDefaultForNewEvents = isDefaultForNewEvents
        self.isShared = isShared
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.localID = localID
        self.pendingSync = pendingSync
    }
}

/// Immutable Sendable snapshot of a calendar entity.
public struct CalendarEntitySnapshot: Sendable {
    public let remoteID: Int64?
    public let ownerID: UUID
    public let name: String
    public let colorKey: String
    public let isPrimary: Bool
    public let isDefaultForNewEvents: Bool
    public let isShared: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let localID: UUID
    public let pendingSync: Bool
}

public extension CalendarEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> CalendarEntitySnapshot {
        CalendarEntitySnapshot(
            remoteID: remoteID,
            ownerID: ownerID,
            name: name,
            colorKey: colorKey,
            isPrimary: isPrimary,
            isDefaultForNewEvents: isDefaultForNewEvents,
            isShared: isShared,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localID: localID,
            pendingSync: pendingSync
        )
    }
}
