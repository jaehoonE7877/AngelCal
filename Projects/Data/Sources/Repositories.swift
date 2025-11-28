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
        let entities = try swiftDataClient.fetchEvents(from: from, to: to)
        return entities.map { $0.toDomain() }
    }
    
    public func getEvent(id: Int64) async throws -> Event? {
        try swiftDataClient.getEvent(remoteID: id)?.toDomain()
    }
    
    // MARK: - Create
    public func createEvent(_ event: Event) async throws -> Event {
        // 1. Save to local SwiftData first
        let entity = EventEntity.fromDomain(event)
        entity.pendingSync = true
        entity.createdAt = Date()
        entity.updatedAt = Date()
        try swiftDataClient.saveEvent(entity)
        
        // 2. Add to outbox for sync
        let payload = try JSONEncoder().encode(EventDTO.fromDomain(event))
        try swiftDataClient.addToOutbox(
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
        guard let entity = try swiftDataClient.getEvent(remoteID: remoteID) else {
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
        
        try swiftDataClient.updateEvent(entity)
        
        // 2. Add to outbox
        let payload = try JSONEncoder().encode(EventDTO.fromDomain(event))
        try swiftDataClient.addToOutbox(
            entityType: "event",
            entityLocalID: entity.localID,
            operation: "update",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    // MARK: - Delete
    public func deleteEvent(_ id: Int64) async throws {
        guard let entity = try swiftDataClient.getEvent(remoteID: id) else {
            throw RepositoryError.notFound
        }
        
        try swiftDataClient.deleteEvent(entity)
        
        let payload = try JSONEncoder().encode(["id": id])
        try swiftDataClient.addToOutbox(
            entityType: "event",
            entityLocalID: entity.localID,
            operation: "delete",
            payload: payload
        )
    }
    
    // MARK: - Copy
    public func copyEvent(id: Int64, to newStart: Date) async throws -> Event {
        guard let entity = try swiftDataClient.getEvent(remoteID: id) else {
            throw RepositoryError.notFound
        }
        let duration = entity.endAt.timeIntervalSince(entity.startAt)
        let endAt = newStart.addingTimeInterval(duration)
        let copy = Event(
            id: nil,
            userID: entity.userID,
            calendarID: entity.calendarID,
            title: entity.title,
            startAt: newStart,
            endAt: endAt,
            allDay: entity.allDay,
            timeZone: entity.timeZone,
            location: entity.location,
            memo: entity.memo,
            url: entity.url,
            recurrenceRule: entity.recurrenceRule,
            colorOverride: entity.colorOverride,
            onlineMeetingLink: entity.onlineMeetingLink
        )
        return try await createEvent(copy)
    }
    
    // MARK: - Sync from server
    public func syncEventsFromServer(userID: UUID, from: Date, to: Date) async throws {
        let dtos = try await supabaseClient.fetchEvents(userID: userID, from: from, to: to)
        
        for dto in dtos {
            let domain = dto.toDomain()
            
            // Check if exists locally
            if let remoteID = domain.id,
               let existingEntity = try swiftDataClient.getEvent(remoteID: remoteID) {
                // LWW: 서버가 더 최신일 때만 반영
                if domain.updatedAt > existingEntity.updatedAt {
                    existingEntity.title = domain.title
                    existingEntity.startAt = domain.startAt
                    existingEntity.endAt = domain.endAt
                    existingEntity.allDay = domain.allDay
                    existingEntity.location = domain.location
                    existingEntity.memo = domain.memo
                    existingEntity.url = domain.url
                    existingEntity.updatedAt = domain.updatedAt
                    existingEntity.pendingSync = false
                    try swiftDataClient.updateEvent(existingEntity, markPending: false)
                }
            } else {
                // Create new
                let newEntity = EventEntity.fromDomain(domain)
                newEntity.pendingSync = false
                try swiftDataClient.saveEvent(newEntity)
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
        let entities = try swiftDataClient.fetchCalendars()
        return entities.map { $0.toDomain() }
    }
    
    public func createCalendar(_ calendar: CalendarModel) async throws -> CalendarModel {
        let entity = CalendarEntity.fromDomain(calendar)
        try swiftDataClient.saveCalendar(entity)
        
        let payload = try JSONEncoder().encode(CalendarDTO.fromDomain(calendar))
        try swiftDataClient.addToOutbox(
            entityType: "calendar",
            entityLocalID: entity.localID,
            operation: "create",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    public func updateCalendar(_ calendar: CalendarModel) async throws -> CalendarModel {
        guard let remoteID = calendar.id,
              let entity = try swiftDataClient.getCalendar(remoteID: remoteID) else {
            throw RepositoryError.notFound
        }
        
        entity.name = calendar.name
        entity.colorKey = calendar.colorKey
        entity.isPrimary = calendar.isPrimary
        entity.isDefaultForNewEvents = calendar.isDefaultForNewEvents
        entity.updatedAt = Date()
        entity.pendingSync = true
        try swiftDataClient.updateCalendar(entity)
        
        let payload = try JSONEncoder().encode(CalendarDTO.fromDomain(calendar))
        try swiftDataClient.addToOutbox(
            entityType: "calendar",
            entityLocalID: entity.localID,
            operation: "update",
            payload: payload
        )
        
        return entity.toDomain()
    }
    
    public func deleteCalendar(_ id: Int64) async throws {
        guard let entity = try swiftDataClient.getCalendar(remoteID: id) else {
            throw RepositoryError.notFound
        }
        try swiftDataClient.deleteCalendar(entity)
        
        let payload = try JSONEncoder().encode(["id": id])
        try swiftDataClient.addToOutbox(
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
               let existingEntity = try swiftDataClient.getCalendar(remoteID: remoteID) {
                if domain.updatedAt > existingEntity.updatedAt {
                    existingEntity.name = domain.name
                    existingEntity.colorKey = domain.colorKey
                    existingEntity.isPrimary = domain.isPrimary
                    existingEntity.isDefaultForNewEvents = domain.isDefaultForNewEvents
                    existingEntity.updatedAt = domain.updatedAt
                    existingEntity.pendingSync = false
                    try swiftDataClient.updateCalendar(existingEntity, markPending: false)
                }
            } else {
                let newEntity = CalendarEntity.fromDomain(domain)
                newEntity.pendingSync = false
                try swiftDataClient.saveCalendar(newEntity)
            }
        }
    }
}

public actor ReminderRepository {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper

    public init(swiftDataClient: SwiftDataClient, supabaseClient: SupabaseClientWrapper) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
    }

    public func fetchReminders(eventID: Int64) async throws -> [EventReminder] {
        let remote = try await supabaseClient.fetchEventReminders(eventID: eventID)
        for dto in remote {
            try await upsertLocal(dto.toDomain())
        }
        return try swiftDataClient.fetchEventReminders(eventID: eventID).map { $0.toDomain() }
    }

    public func createReminder(_ reminder: EventReminder) async throws -> EventReminder {
        let created = try await supabaseClient.createEventReminder(.fromDomain(reminder))
        let domain = created.toDomain()
        try await upsertLocal(domain)
        return domain
    }

    public func updateReminder(_ reminder: EventReminder) async throws -> EventReminder {
        guard reminder.id != nil else { return try await createReminder(reminder) }
        let saved = try await supabaseClient.updateEventReminder(.fromDomain(reminder))
        let domain = saved.toDomain()
        try await upsertLocal(domain)
        return domain
    }

    public func deleteReminder(_ id: Int64) async throws {
        try await supabaseClient.deleteEventReminder(id: id)
        if let entity = try swiftDataClient.getEventReminder(remoteID: id) {
            try swiftDataClient.deleteEventReminder(entity)
        }
    }

    private func upsertLocal(_ reminder: EventReminder) async throws {
        if let remoteID = reminder.id, let entity = try swiftDataClient.getEventReminder(remoteID: remoteID) {
            entity.offsetMinutes = reminder.offsetMinutes
            entity.createdAt = reminder.createdAt
            entity.pendingSync = false
            try swiftDataClient.updateEventReminder(entity, markPending: false)
        } else {
            let entity = EventReminderEntity.fromDomain(reminder)
            entity.pendingSync = false
            try swiftDataClient.saveEventReminder(entity)
        }
    }
}

public enum RepositoryError: Error {
    case notFound
    case missingID
    case syncFailed(Error)
}
