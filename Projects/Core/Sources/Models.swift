import Foundation

// MARK: - User Profile
public struct UserProfile: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let email: String?
    public let displayName: String?
    public let avatarURL: String?
    public let locale: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    
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

// MARK: - Calendar
public struct CalendarModel: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
    public let ownerID: UUID
    public let name: String
    public let colorKey: String
    public let isPrimary: Bool
    public let isDefaultForNewEvents: Bool
    public let isShared: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    
    public init(
        id: Int64? = nil,
        ownerID: UUID,
        name: String,
        colorKey: String = "blue",
        isPrimary: Bool = false,
        isDefaultForNewEvents: Bool = false,
        isShared: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.ownerID = ownerID
        self.name = name
        self.colorKey = colorKey
        self.isPrimary = isPrimary
        self.isDefaultForNewEvents = isDefaultForNewEvents
        self.isShared = isShared
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

// MARK: - Event
public struct Event: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
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
    
    public init(
        id: Int64? = nil,
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
        deletedAt: Date? = nil
    ) {
        self.id = id
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
    }
}

// MARK: - Event Reminder
public struct EventReminder: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
    public let eventID: Int64
    public let offsetMinutes: Int
    public let createdAt: Date
    
    public init(
        id: Int64? = nil,
        eventID: Int64,
        offsetMinutes: Int = -10,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.eventID = eventID
        self.offsetMinutes = offsetMinutes
        self.createdAt = createdAt
    }
}

// MARK: - Event Template
public struct EventTemplate: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
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
    
    public init(
        id: Int64? = nil,
        userID: UUID,
        title: String,
        defaultDurationMinutes: Int = 60,
        defaultAlertOffsets: [Int] = [-10],
        defaultLocation: String? = nil,
        defaultColorKey: String? = nil,
        defaultMemo: String? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
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
    }
}

// MARK: - Notification Settings
public struct NotificationSettings: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
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
    
    public init(
        id: Int64? = nil,
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
        self.id = id
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

// MARK: - Appearance Settings
public struct AppearanceSettings: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
    public let userID: UUID
    public let startOfWeek: String
    public let highlightHolidays: Bool
    public let colorThemeKey: String
    public let fontKey: String
    public let textScale: Double
    public let showEventColors: Bool
    public let showWeekNumber: Bool
    public let showHolidayName: Bool
    public let is24h: Bool
    public let enableLunar: Bool
    public let languageOverride: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: Int64? = nil,
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
        self.id = id
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

// MARK: - Widget Config
public struct WidgetConfig: Codable, Equatable, Identifiable, Sendable {
    public let id: Int64?
    public let userID: UUID
    public let widgetIdentifier: String
    public let widgetType: String
    public let linkedCalendarIDs: [Int64]
    public let maxEventCount: Int
    public let showAllDay: Bool
    public let sortOrder: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: Int64? = nil,
        userID: UUID,
        widgetIdentifier: String,
        widgetType: String,
        linkedCalendarIDs: [Int64] = [],
        maxEventCount: Int = 5,
        showAllDay: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.widgetIdentifier = widgetIdentifier
        self.widgetType = widgetType
        self.linkedCalendarIDs = linkedCalendarIDs
        self.maxEventCount = maxEventCount
        self.showAllDay = showAllDay
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
