import Foundation

// Repository 프로토콜 정의 (구현은 Data 모듈에 존재)
public protocol EventRepositorying: Sendable {
    func fetchEvents(from: Date, to: Date) async throws -> [Event]
    func createEvent(_ event: Event) async throws -> Event
    func updateEvent(_ event: Event) async throws -> Event
    func deleteEvent(_ id: Int64) async throws
}

public protocol CalendarRepositorying: Sendable {
    func fetchCalendars() async throws -> [CalendarModel]
    func createCalendar(_ calendar: CalendarModel) async throws -> CalendarModel
    func updateCalendar(_ calendar: CalendarModel) async throws -> CalendarModel
    func deleteCalendar(_ id: Int64) async throws
}

public protocol SettingsRepositorying: Sendable {
    func fetchNotificationSettings(userID: UUID) async throws -> NotificationSettings?
    func upsertNotificationSettings(_ settings: NotificationSettings) async throws -> NotificationSettings
    func fetchAppearanceSettings(userID: UUID) async throws -> AppearanceSettings?
    func upsertAppearanceSettings(_ settings: AppearanceSettings) async throws -> AppearanceSettings
}
