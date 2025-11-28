import Foundation
import SwiftData

/// Persisted event template used for quick creation.
@Model
public final class TemplateEntity {
    @Attribute(.unique) public var remoteID: Int64?
    public var userID: UUID
    public var title: String
    public var defaultDurationMinutes: Int
    public var defaultAlertOffsets: [Int]
    public var defaultLocation: String?
    public var defaultColorKey: String?
    public var defaultMemo: String?
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var localID: UUID
    public var pendingSync: Bool
    
    public init(
        remoteID: Int64? = nil,
        userID: UUID,
        title: String,
        defaultDurationMinutes: Int = 60,
        defaultAlertOffsets: [Int] = [-10],
        defaultLocation: String? = nil,
        defaultColorKey: String? = nil,
        defaultMemo: String? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        localID: UUID = UUID(),
        pendingSync: Bool = true
    ) {
        self.remoteID = remoteID
        self.userID = userID
        self.title = title
        self.defaultDurationMinutes = defaultDurationMinutes
        self.defaultAlertOffsets = defaultAlertOffsets
        self.defaultLocation = defaultLocation
        self.defaultColorKey = defaultColorKey
        self.defaultMemo = defaultMemo
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.localID = localID
        self.pendingSync = pendingSync
    }
}

/// Immutable Sendable snapshot of a template entity.
public struct TemplateEntitySnapshot: Sendable {
    public let remoteID: Int64?
    public let userID: UUID
    public let title: String
    public let defaultDurationMinutes: Int
    public let defaultAlertOffsets: [Int]
    public let defaultLocation: String?
    public let defaultColorKey: String?
    public let defaultMemo: String?
    public let sortOrder: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let localID: UUID
    public let pendingSync: Bool
}

public extension TemplateEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> TemplateEntitySnapshot {
        TemplateEntitySnapshot(
            remoteID: remoteID,
            userID: userID,
            title: title,
            defaultDurationMinutes: defaultDurationMinutes,
            defaultAlertOffsets: defaultAlertOffsets,
            defaultLocation: defaultLocation,
            defaultColorKey: defaultColorKey,
            defaultMemo: defaultMemo,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localID: localID,
            pendingSync: pendingSync
        )
    }
}
