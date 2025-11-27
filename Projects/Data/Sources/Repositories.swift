import Foundation
import Core
import SwiftDataClient
import SupabaseClient

public actor EventRepository {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    
    public init(swiftDataClient: SwiftDataClient, supabaseClient: SupabaseClientWrapper) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
    }
    
    // MARK: - Fetch
    public func fetchEvents(from: Date, to: Date) async throws -> [Event] {
        // First try local
        let entities = try await swiftDataClient.fetchEvents(from: from, to: to)
        return entities.map { $0.toDomain() }
    }
    
    // MARK: - Create
    public func createEvent(_ event: Event) async throws -> Event {
        // 1. Save to local SwiftData first
        let entity = EventEntity.fromDomain(event)
        try await swiftDataClient.saveEvent(entity)
        
        // 2. Add to outbox for sync
        let payload = try JSONEncoder().encode(EventDTO.fromDomain(event))
        try await swiftDataClient.addToOutbox(
            entityType: "event",
            entityLocalID: entity.localID,
            operation: "create",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    // MARK: - Update
    public func updateEvent(_ event: Event) async throws -> Event {
        guard let remoteID = event.id else {
            throw RepositoryError.missingID
        }
        
        // 1. Update local entity
        guard let entity = try await swiftDataClient.getEvent(remoteID: remoteID) else {
            throw RepositoryError.notFound
        }
        
        entity.title = event.title
        entity.startAt = event.startAt
        entity.endAt = event.endAt
        entity.allDay = event.allDay
        entity.location = event.location
        entity.memo = event.memo
        entity.url = event.url
        entity.colorOverride = event.colorOverride
        
        try await swiftDataClient.updateEvent(entity)
        
        // 2. Add to outbox
        let payload = try JSONEncoder().encode(EventDTO.fromDomain(event))
        try await swiftDataClient.addToOutbox(
            entityType: "event",
            entityLocalID: entity.localID,
            operation: "update",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    // MARK: - Delete
    public func deleteEvent(_ id: Int64) async throws {
        guard let entity = try await swiftDataClient.getEvent(remoteID: id) else {
            throw RepositoryError.notFound
        }
        
        try await swiftDataClient.deleteEvent(entity)
        
        let payload = try JSONEncoder().encode(["id": id])
        try await swiftDataClient.addToOutbox(
            entityType: "event",
            entityLocalID: entity.localID,
            operation: "delete",
            payload: payload
        )
    }
    
    // MARK: - Sync from server
    public func syncEventsFromServer(userID: UUID, from: Date, to: Date) async throws {
        let dtos = try await supabaseClient.fetchEvents(userID: userID, from: from, to: to)
        
        for dto in dtos {
            let domain = dto.toDomain()
            
            // Check if exists locally
            if let remoteID = domain.id,
               let existingEntity = try await swiftDataClient.getEvent(remoteID: remoteID) {
                // Update existing
                existingEntity.title = domain.title
                existingEntity.startAt = domain.startAt
                existingEntity.endAt = domain.endAt
                existingEntity.allDay = domain.allDay
                existingEntity.location = domain.location
                existingEntity.memo = domain.memo
                existingEntity.url = domain.url
                existingEntity.updatedAt = domain.updatedAt
                existingEntity.pendingSync = false
                try await swiftDataClient.updateEvent(existingEntity, markPending: false)
            } else {
                // Create new
                let newEntity = EventEntity.fromDomain(domain)
                newEntity.pendingSync = false
                try await swiftDataClient.saveEvent(newEntity)
            }
        }
    }
}

public actor CalendarRepository {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    
    public init(swiftDataClient: SwiftDataClient, supabaseClient: SupabaseClientWrapper) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
    }
    
    public func fetchCalendars() async throws -> [CalendarModel] {
        let entities = try await swiftDataClient.fetchCalendars()
        return entities.map { $0.toDomain() }
    }
    
    public func createCalendar(_ calendar: CalendarModel) async throws -> CalendarModel {
        let entity = CalendarEntity.fromDomain(calendar)
        try await swiftDataClient.saveCalendar(entity)
        
        let payload = try JSONEncoder().encode(CalendarDTO.fromDomain(calendar))
        try await swiftDataClient.addToOutbox(
            entityType: "calendar",
            entityLocalID: entity.localID,
            operation: "create",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    public func updateCalendar(_ calendar: CalendarModel) async throws -> CalendarModel {
        guard let remoteID = calendar.id,
              let entity = try await swiftDataClient.getCalendar(remoteID: remoteID) else {
            throw RepositoryError.notFound
        }
        
        entity.name = calendar.name
        entity.colorKey = calendar.colorKey
        entity.isPrimary = calendar.isPrimary
        entity.isDefaultForNewEvents = calendar.isDefaultForNewEvents
        entity.updatedAt = Date()
        entity.pendingSync = true
        try await swiftDataClient.updateCalendar(entity)
        
        let payload = try JSONEncoder().encode(CalendarDTO.fromDomain(calendar))
        try await swiftDataClient.addToOutbox(
            entityType: "calendar",
            entityLocalID: entity.localID,
            operation: "update",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    public func deleteCalendar(_ id: Int64) async throws {
        guard let entity = try await swiftDataClient.getCalendar(remoteID: id) else {
            throw RepositoryError.notFound
        }
        try await swiftDataClient.deleteCalendar(entity)
        
        let payload = try JSONEncoder().encode(["id": id])
        try await swiftDataClient.addToOutbox(
            entityType: "calendar",
            entityLocalID: entity.localID,
            operation: "delete",
            payload: payload
        )
    }
    
    public func syncCalendarsFromServer(userID: UUID) async throws {
        let dtos = try await supabaseClient.fetchCalendars(userID: userID)
        
        for dto in dtos {
            let domain = dto.toDomain()
            
            if let remoteID = domain.id,
               let existingEntity = try await swiftDataClient.getCalendar(remoteID: remoteID) {
                existingEntity.name = domain.name
                existingEntity.colorKey = domain.colorKey
                existingEntity.isPrimary = domain.isPrimary
                existingEntity.isDefaultForNewEvents = domain.isDefaultForNewEvents
                existingEntity.updatedAt = domain.updatedAt
                existingEntity.pendingSync = false
                try await swiftDataClient.updateCalendar(existingEntity, markPending: false)
            } else {
                let newEntity = CalendarEntity.fromDomain(domain)
                newEntity.pendingSync = false
                try await swiftDataClient.saveCalendar(newEntity)
            }
        }
    }
}

public enum RepositoryError: Error {
    case notFound
    case missingID
    case syncFailed(Error)
}
