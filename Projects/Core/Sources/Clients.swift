import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

private func _unimplemented<T>() -> T {
    fatalError("unimplemented")
}

private func _unimplementedThrowing<T>() throws -> T {
    fatalError("unimplemented")
}

// MARK: - Event Client
@DependencyClient
public struct EventClient: Sendable {
    public var fetchEvents: @Sendable (_ from: Date, _ to: Date) async throws -> [Event]
    public var createEvent: @Sendable (Event) async throws -> Event
    public var updateEvent: @Sendable (Event) async throws -> Event
    public var deleteEvent: @Sendable (Int64) async throws -> Void
    public var getEvent: @Sendable (Int64) async throws -> Event?
}

// MARK: - Calendar Client
@DependencyClient
public struct CalendarClient: Sendable {
    public var fetchCalendars: @Sendable () async throws -> [CalendarModel]
    public var createCalendar: @Sendable (CalendarModel) async throws -> CalendarModel
    public var updateCalendar: @Sendable (CalendarModel) async throws -> CalendarModel
    public var deleteCalendar: @Sendable (Int64) async throws -> Void
}

// MARK: - Auth Client
@DependencyClient
public struct AuthClient: Sendable {
    public var signInWithApple: @Sendable (String) async throws -> UserProfile
    public var signOut: @Sendable () async throws -> Void
    public var getCurrentUser: @Sendable () async throws -> UserProfile?
    public var isAuthenticated: @Sendable () async -> Bool = { false }
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

// MARK: - Settings Client
@DependencyClient
public struct SettingsClient: Sendable {
    public var getNotificationSettings: @Sendable () async throws -> NotificationSettings?
    public var updateNotificationSettings: @Sendable (NotificationSettings) async throws -> NotificationSettings
    public var getAppearanceSettings: @Sendable () async throws -> AppearanceSettings?
    public var updateAppearanceSettings: @Sendable (AppearanceSettings) async throws -> AppearanceSettings
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

// MARK: - Test Defaults
extension EventClient: TestDependencyKey {
    public static var testValue: EventClient = .init(
        fetchEvents: { _, _ in try await _unimplementedThrowing() },
        createEvent: { _ in try await _unimplementedThrowing() },
        updateEvent: { _ in try await _unimplementedThrowing() },
        deleteEvent: { _ in try await _unimplementedThrowing() },
        getEvent: { _ in try await _unimplementedThrowing() }
    )
}

extension CalendarClient: TestDependencyKey {
    public static var testValue: CalendarClient = .init(
        fetchCalendars: { try await _unimplementedThrowing() },
        createCalendar: { _ in try await _unimplementedThrowing() },
        updateCalendar: { _ in try await _unimplementedThrowing() },
        deleteCalendar: { _ in try await _unimplementedThrowing() }
    )
}

extension AuthClient: TestDependencyKey {
    public static var testValue: AuthClient = .init(
        signInWithApple: { _ in UserProfile(id: UUID(), locale: "ko-KR") },
        signOut: { },
        getCurrentUser: { UserProfile(id: UUID(), locale: "ko-KR") },
        isAuthenticated: { true }
    )
}

extension SyncClient: TestDependencyKey {
    public static var testValue: SyncClient = .init(
        syncAll: { },
        syncEvents: { },
        syncCalendars: { },
        syncSettings: { },
        processPendingOutbox: { }
    )
}

extension SettingsClient: TestDependencyKey {
    public static var testValue: SettingsClient = .init(
        getNotificationSettings: { try await _unimplementedThrowing() },
        updateNotificationSettings: { _ in try await _unimplementedThrowing() },
        getAppearanceSettings: { try await _unimplementedThrowing() },
        updateAppearanceSettings: { _ in try await _unimplementedThrowing() }
    )
}

extension TemplateClient: TestDependencyKey {
    public static var testValue: TemplateClient = .init(
        fetchTemplates: { try await _unimplementedThrowing() },
        createTemplate: { _ in try await _unimplementedThrowing() },
        updateTemplate: { _ in try await _unimplementedThrowing() },
        deleteTemplate: { _ in try await _unimplementedThrowing() },
        reorderTemplates: { _ in try await _unimplementedThrowing() }
    )
}

// MARK: - Dependency accessors
public extension DependencyValues {
    var eventClient: EventClient {
        get { self[EventClient.self] }
        set { self[EventClient.self] = newValue }
    }
    
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
    
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
    
    var syncClient: SyncClient {
        get { self[SyncClient.self] }
        set { self[SyncClient.self] = newValue }
    }
    
    var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
    
    var templateClient: TemplateClient {
        get { self[TemplateClient.self] }
        set { self[TemplateClient.self] = newValue }
    }
}
