import Foundation
import Supabase

public actor SupabaseClientWrapper {
    private let client: SupabaseClient
    
    public init(supabaseURL: URL, supabaseKey: String) {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
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
    
    // MARK: - Events
    public func fetchEvents(userID: UUID, from: Date, to: Date) async throws -> [EventDTO] {
        try await client.database
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
        try await client.database
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
        return try await client.database
            .from("events")
            .update(event)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }
    
    public func deleteEvent(id: Int64) async throws {
        try await client.database
            .from("events")
            .update(["deleted_at": Date().ISO8601Format()])
            .eq("id", value: Int(id))
            .execute()
    }
    
    // MARK: - Calendars
    public func fetchCalendars(userID: UUID) async throws -> [CalendarDTO] {
        try await client.database
            .from("calendars")
            .select()
            .eq("owner_id", value: userID.uuidString)
            .is("deleted_at", value: nil as Bool?)
            .execute()
            .value
    }
    
    public func createCalendar(_ calendar: CalendarDTO) async throws -> CalendarDTO {
        try await client.database
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
        return try await client.database
            .from("calendars")
            .update(calendar)
            .eq("id", value: Int(id))
            .select()
            .single()
            .execute()
            .value
    }
    
    public func deleteCalendar(id: Int64) async throws {
        try await client.database
            .from("calendars")
            .update(["deleted_at": Date().ISO8601Format()])
            .eq("id", value: Int(id))
            .execute()
    }
    
    // MARK: - Settings
    public func fetchNotificationSettings(userID: UUID) async throws -> NotificationSettingsDTO? {
        let response: PostgrestResponse<[NotificationSettingsDTO]> = try await client.database
            .from("notification_settings")
            .select()
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
        return response.value.first
    }
    
    public func upsertNotificationSettings(_ settings: NotificationSettingsDTO) async throws -> NotificationSettingsDTO {
        try await client.database
            .from("notification_settings")
            .upsert(settings)
            .select()
            .single()
            .execute()
            .value
    }
    
    public func fetchAppearanceSettings(userID: UUID) async throws -> AppearanceSettingsDTO? {
        let response: PostgrestResponse<[AppearanceSettingsDTO]> = try await client.database
            .from("appearance_settings")
            .select()
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
        return response.value.first
    }
    
    public func upsertAppearanceSettings(_ settings: AppearanceSettingsDTO) async throws -> AppearanceSettingsDTO {
        try await client.database
            .from("appearance_settings")
            .upsert(settings)
            .select()
            .single()
            .execute()
            .value
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
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case defaultAlertOffsetMinutes = "default_alert_offset_minutes"
        case allDayDefaultAlertOffsetMinutes = "all_day_default_alert_offset_minutes"
        case dailySummaryEnabled = "daily_summary_enabled"
        case dailySummaryTimeLocal = "daily_summary_time_local"
        case dailySummaryScope = "daily_summary_scope"
        case badgeType = "badge_type"
        case soundKey = "sound_key"
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
    }
}

public enum SupabaseError: Error {
    case missingID
    case networkError(Error)
    case decodingError(Error)
}
