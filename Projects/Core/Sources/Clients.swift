import Foundation
import ComposableArchitecture

// MARK: - Event Client
@DependencyClient
public struct EventClient: Sendable {
    public var fetchEvents: @Sendable (_ from: Date, _ to: Date) async throws -> [Event]
    public var createEvent: @Sendable (Event) async throws -> Event
    public var updateEvent: @Sendable (Event) async throws -> Event
    public var deleteEvent: @Sendable (Int64) async throws -> Void
    public var getEvent: @Sendable (Int64) async throws -> Event?
}

extension EventClient: TestDependencyKey {
    public static let testValue = EventClient()
}

extension DependencyValues {
    public var eventClient: EventClient {
        get { self[EventClient.self] }
        set { self[EventClient.self] = newValue }
    }
}

// MARK: - Calendar Client
@DependencyClient
public struct CalendarClient: Sendable {
    public var fetchCalendars: @Sendable () async throws -> [CalendarModel]
    public var createCalendar: @Sendable (CalendarModel) async throws -> CalendarModel
    public var updateCalendar: @Sendable (CalendarModel) async throws -> CalendarModel
    public var deleteCalendar: @Sendable (Int64) async throws -> Void
}

extension CalendarClient: TestDependencyKey {
    public static let testValue = CalendarClient()
}

extension DependencyValues {
    public var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}

// MARK: - Auth Client
@DependencyClient
public struct AuthClient: Sendable {
    public var signInWithApple: @Sendable (String) async throws -> UserProfile
    public var signOut: @Sendable () async throws -> Void
    public var getCurrentUser: @Sendable () async throws -> UserProfile?
    public var isAuthenticated: @Sendable () async -> Bool
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient()
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - Sync Client
@DependencyClient
public struct SyncClient: Sendable {
    public var syncAll: @Sendable () async throws -> Void
    public var syncEvents: @Sendable () async throws -> Void
    public var syncCalendars: @Sendable () async throws -> Void
    public var syncSettings: @Sendable () async throws -> Void
    public var processPendingOutbox: @Sendable () async throws -> Void
}

extension SyncClient: TestDependencyKey {
    public static let testValue = SyncClient()
}

extension DependencyValues {
    public var syncClient: SyncClient {
        get { self[SyncClient.self] }
        set { self[SyncClient.self] = newValue }
    }
}

// MARK: - Settings Client
@DependencyClient
public struct SettingsClient: Sendable {
    public var getNotificationSettings: @Sendable () async throws -> NotificationSettings?
    public var updateNotificationSettings: @Sendable (NotificationSettings) async throws -> NotificationSettings
    public var getAppearanceSettings: @Sendable () async throws -> AppearanceSettings?
    public var updateAppearanceSettings: @Sendable (AppearanceSettings) async throws -> AppearanceSettings
}

extension SettingsClient: TestDependencyKey {
    public static let testValue = SettingsClient()
}

extension DependencyValues {
    public var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
}

// MARK: - Template Client
@DependencyClient
public struct TemplateClient: Sendable {
    public var fetchTemplates: @Sendable () async throws -> [EventTemplate]
    public var createTemplate: @Sendable (EventTemplate) async throws -> EventTemplate
    public var updateTemplate: @Sendable (EventTemplate) async throws -> EventTemplate
    public var deleteTemplate: @Sendable (Int64) async throws -> Void
    public var reorderTemplates: @Sendable ([Int64]) async throws -> Void
}

extension TemplateClient: TestDependencyKey {
    public static let testValue = TemplateClient()
}

extension DependencyValues {
    public var templateClient: TemplateClient {
        get { self[TemplateClient.self] }
        set { self[TemplateClient.self] = newValue }
    }
}
