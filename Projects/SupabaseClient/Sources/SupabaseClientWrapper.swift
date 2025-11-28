import Foundation
import Supabase

public actor SupabaseClientWrapper {
    private let client: SupabaseClient
    
    public init(supabaseURL: URL, supabaseKey: String) {
        // Opt-in to the upcoming default behavior so the SDK doesn't log the deprecation warning
        // about initial sessions. This emits any locally stored session immediately.
        let options = SupabaseClientOptions(
            auth: .init(emitLocalSessionAsInitialSession: true)
        )

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: options
        )
    }
    
    // MARK: - Auth
    public func signInWithApple(idToken: String) async throws -> User {
        let response = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
        return response.user
    }
    
    public func signOut() async throws {
        try await client.auth.signOut()
    }
    
    public func getCurrentSession() async throws -> Session? {
        try await client.auth.session
    }
    
    public func getCurrentUser() async throws -> User? {
        try await client.auth.user()
    }

    // MARK: - Profiles
    public func fetchProfile(userID: UUID) async throws -> ProfileDTO? {
        let response: PostgrestResponse<[ProfileDTO]> = try await client
            .from("profiles")
            .select()
            .eq("id", value: userID.uuidString)
            .limit(1)
            .execute()
        return response.value.first
    }

    public func upsertProfile(_ profile: ProfileDTO) async throws -> ProfileDTO {
        try await client
            .from("profiles")
            .upsert(profile)
            .select()
            .single()
            .execute()
            .value
    }
    
    // MARK: - Events
    public func fetchEvents(userID: UUID, from: Date, to: Date) async throws -> [EventDTO] {
        try await client
            .from("events")
            .select()
            .eq("user_id", value: userID.uuidString)
            .gte("start_at", value: from.ISO8601Format())
            .lte("start_at", value: to.ISO8601Format())
            .is("deleted_at", value: nil as Bool?)
            .execute()
            .value
    }

    public func createEvent(_ event: EventDTO) async throws -> EventDTO {
        try await client
            .from("events")
            .insert(event)
            .select()
            .single()
            .execute()
            .value
    }
    
    public func updateEvent(_ event: EventDTO) async throws -> EventDTO {
        guard let id = event.id else {
            throw SupabaseError.missingID
        }
        return try await client
            .from("events")
            .update(event)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }

    public func deleteEvent(id: Int64) async throws {
        try await client
            .from("events")
            .update(["deleted_at": Date().ISO8601Format()])
            .eq("id", value: Int(id))
            .execute()
    }

    // MARK: - Calendars
    public func fetchCalendars(userID: UUID) async throws -> [CalendarDTO] {
        try await client
            .from("calendars")
            .select()
            .eq("owner_id", value: userID.uuidString)
            .is("deleted_at", value: nil as Bool?)
            .execute()
            .value
    }

    public func createCalendar(_ calendar: CalendarDTO) async throws -> CalendarDTO {
        try await client
            .from("calendars")
            .insert(calendar)
            .select()
            .single()
            .execute()
            .value
    }
    
    public func updateCalendar(_ calendar: CalendarDTO) async throws -> CalendarDTO {
        guard let id = calendar.id else {
            throw SupabaseError.missingID
        }
        return try await client
            .from("calendars")
            .update(calendar)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }

    public func deleteCalendar(id: Int64) async throws {
        try await client
            .from("calendars")
            .update(["deleted_at": Date().ISO8601Format()])
            .eq("id", value: Int(id))
            .execute()
    }

    // MARK: - Settings
    public func fetchNotificationSettings(userID: UUID) async throws -> NotificationSettingsDTO? {
        let response: PostgrestResponse<[NotificationSettingsDTO]> = try await client
            .from("notification_settings")
            .select()
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
        return response.value.first
    }

    public func upsertNotificationSettings(_ settings: NotificationSettingsDTO) async throws -> NotificationSettingsDTO {
        try await client
            .from("notification_settings")
            .upsert(settings)
            .select()
            .single()
            .execute()
            .value
    }

    public func fetchAppearanceSettings(userID: UUID) async throws -> AppearanceSettingsDTO? {
        let response: PostgrestResponse<[AppearanceSettingsDTO]> = try await client
            .from("appearance_settings")
            .select()
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
        return response.value.first
    }

    public func upsertAppearanceSettings(_ settings: AppearanceSettingsDTO) async throws -> AppearanceSettingsDTO {
        try await client
            .from("appearance_settings")
            .upsert(settings)
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Event Templates
    public func fetchEventTemplates(userID: UUID) async throws -> [EventTemplateDTO] {
        try await client
            .from("event_templates")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
    }

    public func createEventTemplate(_ template: EventTemplateDTO) async throws -> EventTemplateDTO {
        try await client
            .from("event_templates")
            .insert(template)
            .select()
            .single()
            .execute()
            .value
    }

    public func updateEventTemplate(_ template: EventTemplateDTO) async throws -> EventTemplateDTO {
        guard let id = template.id else { throw SupabaseError.missingID }
        return try await client
            .from("event_templates")
            .update(template)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }

    public func deleteEventTemplate(id: Int64) async throws {
        try await client
            .from("event_templates")
            .delete()
            .eq("id", value: Int(id))
            .execute()
    }

    // MARK: - Event Reminders
    public func fetchEventReminders(eventID: Int64) async throws -> [EventReminderDTO] {
        try await client
            .from("event_reminders")
            .select()
            .eq("event_id", value: Int(eventID))
            .execute()
            .value
    }

    public func createEventReminder(_ reminder: EventReminderDTO) async throws -> EventReminderDTO {
        try await client
            .from("event_reminders")
            .insert(reminder)
            .select()
            .single()
            .execute()
            .value
    }

    public func updateEventReminder(_ reminder: EventReminderDTO) async throws -> EventReminderDTO {
        guard let id = reminder.id else { throw SupabaseError.missingID }
        return try await client
            .from("event_reminders")
            .update(reminder)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }

    public func deleteEventReminder(id: Int64) async throws {
        try await client
            .from("event_reminders")
            .delete()
            .eq("id", value: Int(id))
            .execute()
    }

    // MARK: - Widget Configs
    public func fetchWidgetConfigs(userID: UUID) async throws -> [WidgetConfigDTO] {
        try await client
            .from("widget_configs")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
    }

    public func upsertWidgetConfig(_ config: WidgetConfigDTO) async throws -> WidgetConfigDTO {
        try await client
            .from("widget_configs")
            .upsert(config)
            .select()
            .single()
            .execute()
            .value
    }

    public func deleteWidgetConfig(id: Int64) async throws {
        try await client
            .from("widget_configs")
            .delete()
            .eq("id", value: Int(id))
            .execute()
    }
}

// MARK: - DTOs for Supabase
public struct EventDTO: Codable {
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
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    
    public init(
        id: Int64? = nil,
        userID: UUID,
        calendarID: Int64,
        title: String,
        startAt: Date,
        endAt: Date,
        allDay: Bool,
        timeZone: String?,
        location: String?,
        memo: String?,
        url: String?,
        recurrenceRule: String?,
        colorOverride: String?,
        onlineMeetingLink: String?,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
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
    
    enum CodingKeys: String, CodingKey {
        case id, title, location, memo, url
        case userID = "user_id"
        case calendarID = "calendar_id"
        case startAt = "start_at"
        case endAt = "end_at"
        case allDay = "all_day"
        case timeZone = "time_zone"
        case recurrenceRule = "recurrence_rule"
        case colorOverride = "color_override"
        case onlineMeetingLink = "online_meeting_link"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

public struct CalendarDTO: Codable {
    public let id: Int64?
    public let ownerID: UUID
    public let name: String
    public let colorKey: String
    public let isPrimary: Bool
    public let isDefaultForNewEvents: Bool
    public let isShared: Bool
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    
    public init(
        id: Int64? = nil,
        ownerID: UUID,
        name: String,
        colorKey: String,
        isPrimary: Bool,
        isDefaultForNewEvents: Bool,
        isShared: Bool,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
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
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerID = "owner_id"
        case colorKey = "color_key"
        case isPrimary = "is_primary"
        case isDefaultForNewEvents = "is_default_for_new_events"
        case isShared = "is_shared"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

public struct NotificationSettingsDTO: Codable {
    public let userID: UUID
    public let defaultAlertOffsetMinutes: Int
    public let allDayDefaultAlertOffsetMinutes: Int
    public let dailySummaryEnabled: Bool
    public let dailySummaryTimeLocal: String?
    public let dailySummaryScope: String
    public let badgeType: String
    public let soundKey: String?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        userID: UUID,
        defaultAlertOffsetMinutes: Int,
        allDayDefaultAlertOffsetMinutes: Int,
        dailySummaryEnabled: Bool,
        dailySummaryTimeLocal: String?,
        dailySummaryScope: String,
        badgeType: String,
        soundKey: String?,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case defaultAlertOffsetMinutes = "default_alert_offset_minutes"
        case allDayDefaultAlertOffsetMinutes = "all_day_default_alert_offset_minutes"
        case dailySummaryEnabled = "daily_summary_enabled"
        case dailySummaryTimeLocal = "daily_summary_time_local"
        case dailySummaryScope = "daily_summary_scope"
        case badgeType = "badge_type"
        case soundKey = "sound_key"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct AppearanceSettingsDTO: Codable {
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
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        userID: UUID,
        startOfWeek: String,
        highlightHolidays: Bool,
        colorThemeKey: String,
        fontKey: String,
        textScale: Double,
        showEventColors: Bool,
        showWeekNumber: Bool,
        showHolidayName: Bool,
        is24h: Bool,
        enableLunar: Bool,
        languageOverride: String?,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case startOfWeek = "start_of_week"
        case highlightHolidays = "highlight_holidays"
        case colorThemeKey = "color_theme_key"
        case fontKey = "font_key"
        case textScale = "text_scale"
        case showEventColors = "show_event_colors"
        case showWeekNumber = "show_week_number"
        case showHolidayName = "show_holiday_name"
        case is24h = "is_24h"
        case enableLunar = "enable_lunar"
        case languageOverride = "language_override"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct EventReminderDTO: Codable {
    public let id: Int64?
    public let eventID: Int64
    public let offsetMinutes: Int
    public let createdAt: Date?

    public init(
        id: Int64? = nil,
        eventID: Int64,
        offsetMinutes: Int,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.offsetMinutes = offsetMinutes
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case eventID = "event_id"
        case offsetMinutes = "offset_minutes"
        case createdAt = "created_at"
    }
}

public struct EventTemplateDTO: Codable {
    public let id: Int64?
    public let userID: UUID
    public let title: String
    public let defaultDurationMinutes: Int
    public let defaultAlertOffsets: [Int]
    public let defaultLocation: String?
    public let defaultColorKey: String?
    public let defaultMemo: String?
    public let sortOrder: Int
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: Int64? = nil,
        userID: UUID,
        title: String,
        defaultDurationMinutes: Int,
        defaultAlertOffsets: [Int],
        defaultLocation: String?,
        defaultColorKey: String?,
        defaultMemo: String?,
        sortOrder: Int,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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

    enum CodingKeys: String, CodingKey {
        case id, title, sortOrder
        case userID = "user_id"
        case defaultDurationMinutes = "default_duration_minutes"
        case defaultAlertOffsets = "default_alert_offsets"
        case defaultLocation = "default_location"
        case defaultColorKey = "default_color_key"
        case defaultMemo = "default_memo"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct WidgetConfigDTO: Codable {
    public let id: Int64?
    public let userID: UUID
    public let widgetIdentifier: String
    public let widgetType: String
    public let linkedCalendarIDs: [Int64]?
    public let maxEventCount: Int
    public let showAllDay: Bool
    public let sortOrder: Int
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: Int64? = nil,
        userID: UUID,
        widgetIdentifier: String,
        widgetType: String,
        linkedCalendarIDs: [Int64]?,
        maxEventCount: Int,
        showAllDay: Bool,
        sortOrder: Int,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case widgetIdentifier = "widget_identifier"
        case widgetType = "widget_type"
        case linkedCalendarIDs = "linked_calendar_ids"
        case maxEventCount = "max_event_count"
        case showAllDay = "show_all_day"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct ProfileDTO: Codable {
    public let id: UUID
    public let email: String?
    public let displayName: String?
    public let avatarURL: String?
    public let locale: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?

    public init(
        id: UUID,
        email: String?,
        displayName: String?,
        avatarURL: String?,
        locale: String?,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
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

    enum CodingKeys: String, CodingKey {
        case id, email
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case locale
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

public enum SupabaseError: Error {
    case missingID
    case networkError(Error)
    case decodingError(Error)
}
