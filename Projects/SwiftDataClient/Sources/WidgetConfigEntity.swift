import Foundation
import SwiftData

/// Persisted widget configuration for WidgetKit timelines.
@Model
public final class WidgetConfigEntity {
    @Attribute(.unique) public var remoteID: Int64?
    public var userID: UUID
    public var widgetIdentifier: String
    public var widgetType: String
    public var linkedCalendarIDs: [Int64]
    public var maxEventCount: Int
    public var showAllDay: Bool
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var localID: UUID
    
    public init(
        remoteID: Int64? = nil,
        userID: UUID,
        widgetIdentifier: String,
        widgetType: String,
        linkedCalendarIDs: [Int64] = [],
        maxEventCount: Int = 5,
        showAllDay: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        localID: UUID = UUID()
    ) {
        self.remoteID = remoteID
        self.userID = userID
        self.widgetIdentifier = widgetIdentifier
        self.widgetType = widgetType
        self.linkedCalendarIDs = linkedCalendarIDs
        self.maxEventCount = maxEventCount
        self.showAllDay = showAllDay
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.localID = localID
    }
}

/// Immutable Sendable snapshot of a widget configuration entity.
public struct WidgetConfigEntitySnapshot: Sendable {
    public let remoteID: Int64?
    public let userID: UUID
    public let widgetIdentifier: String
    public let widgetType: String
    public let linkedCalendarIDs: [Int64]
    public let maxEventCount: Int
    public let showAllDay: Bool
    public let sortOrder: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let localID: UUID
}

public extension WidgetConfigEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> WidgetConfigEntitySnapshot {
        WidgetConfigEntitySnapshot(
            remoteID: remoteID,
            userID: userID,
            widgetIdentifier: widgetIdentifier,
            widgetType: widgetType,
            linkedCalendarIDs: linkedCalendarIDs,
            maxEventCount: maxEventCount,
            showAllDay: showAllDay,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localID: localID
        )
    }
}
