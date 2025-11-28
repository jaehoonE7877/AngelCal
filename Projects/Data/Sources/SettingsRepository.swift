import Foundation
import Core
import SwiftDataClient
import SupabaseClient

public actor SettingsRepository: SettingsRepositorying {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    let userID: UUID
    
    public init(swiftDataClient: SwiftDataClient, supabaseClient: SupabaseClientWrapper, userID: UUID) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
        self.userID = userID
    }
    
    // MARK: - Notification Settings
    public func fetchNotificationSettings(userID: UUID) async throws -> NotificationSettings? {
        if let cached = try swiftDataClient.getNotificationSettings(userID: userID) {
            return cached.toDomain()
        }
        if let remote = try await supabaseClient.fetchNotificationSettings(userID: userID) {
            let domain = remote.toDomain(userID: userID)
            try swiftDataClient.saveNotificationSettings(.fromDomain(domain))
            return domain
        }
        return nil
    }
    
    public func upsertNotificationSettings(_ settings: NotificationSettings) async throws -> NotificationSettings {
        let saved = try await supabaseClient.upsertNotificationSettings(.fromDomain(settings))
        let domain = saved.toDomain(userID: settings.userID)
        try swiftDataClient.saveNotificationSettings(.fromDomain(domain))
        return domain
    }
    
    // MARK: - Appearance Settings
    public func fetchAppearanceSettings(userID: UUID) async throws -> AppearanceSettings? {
        if let cached = try swiftDataClient.getAppearanceSettings(userID: userID) {
            return cached.toDomain()
        }
        if let remote = try await supabaseClient.fetchAppearanceSettings(userID: userID) {
            let domain = remote.toDomain(userID: userID)
            try swiftDataClient.saveAppearanceSettings(.fromDomain(domain))
            return domain
        }
        return nil
    }
    
    public func upsertAppearanceSettings(_ settings: AppearanceSettings) async throws -> AppearanceSettings {
        let saved = try await supabaseClient.upsertAppearanceSettings(.fromDomain(settings))
        let domain = saved.toDomain(userID: settings.userID)
        try swiftDataClient.saveAppearanceSettings(.fromDomain(domain))
        return domain
    }
    
    // MARK: - Widget Configs (local-first)
    public func fetchWidgetConfigs() async throws -> [WidgetConfig] {
        let remote = try await supabaseClient.fetchWidgetConfigs(userID: userID)
        for dto in remote {
            try await upsertLocal(dto.toDomain())
        }
        let configs = try swiftDataClient.fetchWidgetConfigs(userID: userID)
        return configs.map { $0.toDomain() }
    }
    
    public func upsertWidgetConfig(_ config: WidgetConfig) async throws -> WidgetConfig {
        let saved = try await supabaseClient.upsertWidgetConfig(.fromDomain(config))
        let domain = saved.toDomain()
        try await upsertLocal(domain)
        return domain
    }
    
    public func deleteWidgetConfig(id: Int64?) async throws {
        guard let id else { return }
        try await supabaseClient.deleteWidgetConfig(id: id)
        if let entity = try swiftDataClient.getWidgetConfig(remoteID: id) {
            try swiftDataClient.deleteWidgetConfig(entity)
        }
    }

    private func upsertLocal(_ config: WidgetConfig) async throws {
        if let remoteID = config.id, let existing = try swiftDataClient.getWidgetConfig(remoteID: remoteID) {
            existing.widgetIdentifier = config.widgetIdentifier
            existing.widgetType = config.widgetType
            existing.linkedCalendarIDs = config.linkedCalendarIDs
            existing.maxEventCount = config.maxEventCount
            existing.showAllDay = config.showAllDay
            existing.sortOrder = config.sortOrder
            existing.createdAt = config.createdAt
            existing.updatedAt = config.updatedAt
            try swiftDataClient.updateWidgetConfig(existing, markPending: false)
        } else {
            let entity = WidgetConfigEntity.fromDomain(config)
            try swiftDataClient.saveWidgetConfig(entity)
        }
    }
}
