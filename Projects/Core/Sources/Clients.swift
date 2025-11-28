import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

private func _unimplemented<T>() -> T {
    fatalError("unimplemented")
}

private func _unimplementedThrowing<T>() throws -> T {
    fatalError("unimplemented")
}

private func _unimplementedAsync<T>() async throws -> T {
    fatalError("unimplemented")
}

// MARK: - Event Client
@DependencyClient
public struct EventClient: Sendable {
    public var fetchEvents: @Sendable (_ from: Date, _ to: Date) async throws -> [Event]
    public var createEvent: @Sendable (Event) async throws -> Event
    public var updateEvent: @Sendable (Event) async throws -> Event
    public var deleteEvent: @Sendable (Int64) async throws -> Void
    public var copyEvent: @Sendable (_ id: Int64, _ newStart: Date) async throws -> Event
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
    public var getWidgetConfigs: @Sendable () async throws -> [WidgetConfig]
    public var upsertWidgetConfig: @Sendable (WidgetConfig) async throws -> WidgetConfig
    public var deleteWidgetConfig: @Sendable (Int64?) async throws -> Void
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

// MARK: - Search Client
@DependencyClient
public struct SearchClient: Sendable {
    public var searchEvents: @Sendable (_ query: String, _ calendarIDs: [Int64]?, _ from: Date?, _ to: Date?) async throws -> [Event]
}

// MARK: - Metrics / Error
@DependencyClient
public struct MetricsClient: Sendable {
    public var logEvent: @Sendable (_ name: String, _ properties: [String: String]) -> Void
}

@DependencyClient
public struct ErrorReporter: Sendable {
    public var handle: @Sendable (_ error: Error, _ context: String) -> Void
}

// MARK: - Test Defaults
extension EventClient: TestDependencyKey {
    public static var testValue: EventClient = .init(
        fetchEvents: { _, _ in try await _unimplementedAsync() },
        createEvent: { _ in try await _unimplementedAsync() },
        updateEvent: { _ in try await _unimplementedAsync() },
        deleteEvent: { _ in try await _unimplementedAsync() },
        copyEvent: { _, _ in try await _unimplementedAsync() },
        getEvent: { _ in try await _unimplementedAsync() }
    )
}

extension CalendarClient: TestDependencyKey {
    public static var testValue: CalendarClient = .init(
        fetchCalendars: { try await _unimplementedAsync() },
        createCalendar: { _ in try await _unimplementedAsync() },
        updateCalendar: { _ in try await _unimplementedAsync() },
        deleteCalendar: { _ in try await _unimplementedAsync() }
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
        getNotificationSettings: { try await _unimplementedAsync() },
        updateNotificationSettings: { _ in try await _unimplementedAsync() },
        getAppearanceSettings: { try await _unimplementedAsync() },
        updateAppearanceSettings: { _ in try await _unimplementedAsync() },
        getWidgetConfigs: { try await _unimplementedAsync() },
        upsertWidgetConfig: { _ in try await _unimplementedAsync() },
        deleteWidgetConfig: { _ in try await _unimplementedAsync() }
    )
}

extension TemplateClient: TestDependencyKey {
    public static var testValue: TemplateClient = .init(
        fetchTemplates: { try await _unimplementedAsync() },
        createTemplate: { _ in try await _unimplementedAsync() },
        updateTemplate: { _ in try await _unimplementedAsync() },
        deleteTemplate: { _ in try await _unimplementedAsync() },
        reorderTemplates: { _ in try await _unimplementedAsync() }
    )
}

extension SearchClient: TestDependencyKey {
    public static var testValue: SearchClient = .init(
        searchEvents: { _, _, _, _ in try await _unimplementedAsync() }
    )
}

extension MetricsClient: TestDependencyKey {
    public static var testValue: MetricsClient = .init(
        logEvent: { _, _ in }
    )
}

extension ErrorReporter: TestDependencyKey {
    public static var testValue: ErrorReporter = .init(
        handle: { _, _ in }
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
    
    var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
    
    var metricsClient: MetricsClient {
        get { self[MetricsClient.self] }
        set { self[MetricsClient.self] = newValue }
    }
    
    var errorReporter: ErrorReporter {
        get { self[ErrorReporter.self] }
        set { self[ErrorReporter.self] = newValue }
    }
}
