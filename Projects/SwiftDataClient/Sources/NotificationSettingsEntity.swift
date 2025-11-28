import Foundation
import SwiftData

/// Persisted notification settings for a user.
@Model
public final class NotificationSettingsEntity {
    @Attribute(.unique) public var userID: UUID
    public var defaultAlertOffsetMinutes: Int
    public var allDayDefaultAlertOffsetMinutes: Int
    public var dailySummaryEnabled: Bool
    public var dailySummaryTimeLocal: String?
    public var dailySummaryScope: String
    public var badgeType: String
    public var soundKey: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        userID: UUID,
        defaultAlertOffsetMinutes: Int = -10,
        allDayDefaultAlertOffsetMinutes: Int = -60,
        dailySummaryEnabled: Bool = false,
        dailySummaryTimeLocal: String? = nil,
        dailySummaryScope: String = "today",
        badgeType: String = "none",
        soundKey: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userID = userID
        self.defaultAlertOffsetMinutes = defaultAlertOffsetMinutes
        self.allDayDefaultAlertOffsetMinutes = allDayDefaultAlertOffsetMinutes
        self.dailySummaryEnabled = dailySummaryEnabled
        self.dailySummaryTimeLocal = dailySummaryTimeLocal
        self.dailySummaryScope = dailySummaryScope
        self.badgeType = badgeType
        self.soundKey = soundKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Immutable Sendable snapshot of notification settings.
public struct NotificationSettingsEntitySnapshot: Sendable {
    public let userID: UUID
    public let defaultAlertOffsetMinutes: Int
    public let allDayDefaultAlertOffsetMinutes: Int
    public let dailySummaryEnabled: Bool
    public let dailySummaryTimeLocal: String?
    public let dailySummaryScope: String
    public let badgeType: String
    public let soundKey: String?
    public let createdAt: Date
    public let updatedAt: Date
}

public extension NotificationSettingsEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> NotificationSettingsEntitySnapshot {
        NotificationSettingsEntitySnapshot(
            userID: userID,
            defaultAlertOffsetMinutes: defaultAlertOffsetMinutes,
            allDayDefaultAlertOffsetMinutes: allDayDefaultAlertOffsetMinutes,
            dailySummaryEnabled: dailySummaryEnabled,
            dailySummaryTimeLocal: dailySummaryTimeLocal,
            dailySummaryScope: dailySummaryScope,
            badgeType: badgeType,
            soundKey: soundKey,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
