import Foundation
import Core
import SwiftDataClient
import SupabaseClient

public actor TemplateRepository {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    private let userID: UUID
    
    public init(swiftDataClient: SwiftDataClient, supabaseClient: SupabaseClientWrapper, userID: UUID) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
        self.userID = userID
    }
    
    public func fetchTemplates() async throws -> [EventTemplate] {
        // Pull latest from server then return local cache
        let remote = try await supabaseClient.fetchEventTemplates(userID: userID)
        for dto in remote {
            try await upsertLocal(template: dto.toDomain())
        }
        return try swiftDataClient.fetchTemplates(userID: userID).map { $0.toDomain() }
    }
    
    public func createTemplate(_ template: EventTemplate) async throws -> EventTemplate {
        let created = try await supabaseClient.createEventTemplate(.fromDomain(template))
        let domain = created.toDomain()
        try await upsertLocal(template: domain)
        return domain
    }
    
    public func updateTemplate(_ template: EventTemplate) async throws -> EventTemplate {
        guard template.id != nil else { return try await createTemplate(template) }
        let saved = try await supabaseClient.updateEventTemplate(.fromDomain(template))
        let domain = saved.toDomain()
        try await upsertLocal(template: domain)
        return domain
    }
    
    public func deleteTemplate(_ id: Int64) async throws {
        try await supabaseClient.deleteEventTemplate(id: id)
        if let entity = try swiftDataClient.getTemplate(remoteID: id) {
            try swiftDataClient.deleteTemplate(entity)
        }
    }
    
    public func reorderTemplates(_ ids: [Int64]) async throws {
        let current = try await fetchTemplates()
        let orderMap = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
        for template in current {
            guard let remoteID = template.id, let newOrder = orderMap[remoteID],
                  let entity = try swiftDataClient.getTemplate(remoteID: remoteID) else { continue }
            entity.sortOrder = newOrder
            entity.updatedAt = Date()
            try swiftDataClient.updateTemplate(entity, markPending: false)
            // Push reorder to server best-effort
            var updatedDomain = template
            updatedDomain = EventTemplate(
                id: template.id,
                userID: template.userID,
                title: template.title,
                defaultDurationMinutes: template.defaultDurationMinutes,
                defaultAlertOffsets: template.defaultAlertOffsets,
                defaultLocation: template.defaultLocation,
                defaultColorKey: template.defaultColorKey,
                defaultMemo: template.defaultMemo,
                sortOrder: newOrder,
                createdAt: template.createdAt,
                updatedAt: Date()
            )
            _ = try? await supabaseClient.updateEventTemplate(.fromDomain(updatedDomain))
        }
    }

    private func upsertLocal(template: EventTemplate) async throws {
        if let remoteID = template.id, let existing = try swiftDataClient.getTemplate(remoteID: remoteID) {
            existing.title = template.title
            existing.defaultDurationMinutes = template.defaultDurationMinutes
            existing.defaultAlertOffsets = template.defaultAlertOffsets
            existing.defaultLocation = template.defaultLocation
            existing.defaultColorKey = template.defaultColorKey
            existing.defaultMemo = template.defaultMemo
            existing.sortOrder = template.sortOrder
            existing.createdAt = template.createdAt
            existing.updatedAt = template.updatedAt
            try swiftDataClient.updateTemplate(existing, markPending: false)
        } else {
            let entity = TemplateEntity.fromDomain(template)
            entity.pendingSync = false
            try swiftDataClient.saveTemplate(entity)
        }
    }
}
