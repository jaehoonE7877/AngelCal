import Foundation
import SwiftData

// MARK: - Event Entity
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

// MARK: - Calendar Entity
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

// MARK: - Outbox Entity
@Model
public final class OutboxEntity {
    @Attribute(.unique) public var id: UUID
    public var entityType: String
    public var entityLocalID: UUID
    public var operation: String // "create", "update", "delete"
    public var payload: Data
    public var createdAt: Date
    public var retryCount: Int
    public var lastError: String?
    
    public init(
        id: UUID = UUID(),
        entityType: String,
        entityLocalID: UUID,
        operation: String,
        payload: Data,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.entityType = entityType
        self.entityLocalID = entityLocalID
        self.operation = operation
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.lastError = lastError
    }
}

// MARK: - User Profile Entity
@Model
public final class UserProfileEntity {
    @Attribute(.unique) public var id: UUID
    public var email: String?
    public var displayName: String?
    public var avatarURL: String?
    public var locale: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    
    public init(
        id: UUID,
        email: String? = nil,
        displayName: String? = nil,
        avatarURL: String? = nil,
        locale: String = "ko-KR",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.locale = locale
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

// MARK: - Settings Entities
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

@Model
public final class AppearanceSettingsEntity {
    @Attribute(.unique) public var userID: UUID
    public var startOfWeek: String
    public var highlightHolidays: Bool
    public var colorThemeKey: String
    public var fontKey: String
    public var textScale: Double
    public var showEventColors: Bool
    public var showWeekNumber: Bool
    public var showHolidayName: Bool
    public var is24h: Bool
    public var enableLunar: Bool
    public var languageOverride: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        userID: UUID,
        startOfWeek: String = "monday",
        highlightHolidays: Bool = true,
        colorThemeKey: String = "system",
        fontKey: String = "system",
        textScale: Double = 1.0,
        showEventColors: Bool = true,
        showWeekNumber: Bool = false,
        showHolidayName: Bool = true,
        is24h: Bool = true,
        enableLunar: Bool = false,
        languageOverride: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userID = userID
        self.startOfWeek = startOfWeek
        self.highlightHolidays = highlightHolidays
        self.colorThemeKey = colorThemeKey
        self.fontKey = fontKey
        self.textScale = textScale
        self.showEventColors = showEventColors
        self.showWeekNumber = showWeekNumber
        self.showHolidayName = showHolidayName
        self.is24h = is24h
        self.enableLunar = enableLunar
        self.languageOverride = languageOverride
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
