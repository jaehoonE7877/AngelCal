import Foundation
import Core
import SwiftDataClient
import SupabaseClient

public actor SyncService {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    private let eventRepository: EventRepository
    private let calendarRepository: CalendarRepository
    
    private var isSyncing = false
    private let maxRetries = 3
    
    public init(
        swiftDataClient: SwiftDataClient,
        supabaseClient: SupabaseClientWrapper,
        eventRepository: EventRepository,
        calendarRepository: CalendarRepository
    ) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
        self.eventRepository = eventRepository
        self.calendarRepository = calendarRepository
    }
    
    // MARK: - Full Sync
    public func syncAll(userID: UUID) async throws {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        // 1. Pull from server
        try await pullFromServer(userID: userID)
        
        // 2. Push pending changes
        try await processPendingOutbox()
    }
    
    public func syncEventsFromServer(userID: UUID, from: Date, to: Date) async throws {
        try await eventRepository.syncEventsFromServer(userID: userID, from: from, to: to)
    }
    
    public func syncCalendarsFromServer(userID: UUID) async throws {
        try await calendarRepository.syncCalendarsFromServer(userID: userID)
    }
    
    // MARK: - Pull from Server
    private func pullFromServer(userID: UUID) async throws {
        // Sync calendars first
        try await calendarRepository.syncCalendarsFromServer(userID: userID)
        
        // Sync events for the current month
        let now = Date()
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        try await eventRepository.syncEventsFromServer(
            userID: userID,
            from: startOfMonth,
            to: endOfMonth
        )
    }
    
    // MARK: - Push Outbox
    public func processPendingOutbox() async throws {
        let outboxItems = try await swiftDataClient.getPendingOutbox()
        
        for outbox in outboxItems {
            do {
                try await processOutboxItem(outbox)
                try await swiftDataClient.deleteOutbox(outbox)
            } catch {
                if outbox.retryCount < maxRetries {
                    try await swiftDataClient.incrementOutboxRetry(outbox, error: error.localizedDescription)
                } else {
                    // Max retries reached, log or handle
                    print("⚠️ Outbox item \(outbox.id) exceeded max retries")
                }
            }
        }
    }
    
    private func processOutboxItem(_ outbox: OutboxEntity) async throws {
        switch outbox.entityType {
        case "event":
            try await processEventOutbox(outbox)
        case "calendar":
            try await processCalendarOutbox(outbox)
        default:
            print("⚠️ Unknown entity type: \(outbox.entityType)")
        }
    }
    
    private func processEventOutbox(_ outbox: OutboxEntity) async throws {
        switch outbox.operation {
        case "create":
            let dto = try JSONDecoder().decode(EventDTO.self, from: outbox.payload)
            let created = try await supabaseClient.createEvent(dto)
            // Update local entity with remote ID
            if let entity = try await findEventEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
                try await swiftDataClient.updateEvent(entity, markPending: false)
            }
            
        case "update":
            let dto = try JSONDecoder().decode(EventDTO.self, from: outbox.payload)
            _ = try await supabaseClient.updateEvent(dto)
            if let entity = try await findEventEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try await swiftDataClient.updateEvent(entity, markPending: false)
            }
            
        case "delete":
            let deletePayload = try JSONDecoder().decode([String: Int64].self, from: outbox.payload)
            if let id = deletePayload["id"] {
                try await supabaseClient.deleteEvent(id: id)
            }
            if let entity = try await findEventEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try await swiftDataClient.updateEvent(entity, markPending: false)
            }
            
        default:
            print("⚠️ Unknown operation: \(outbox.operation)")
        }
    }
    
    private func processCalendarOutbox(_ outbox: OutboxEntity) async throws {
        switch outbox.operation {
        case "create":
            let dto = try JSONDecoder().decode(CalendarDTO.self, from: outbox.payload)
            let created = try await supabaseClient.createCalendar(dto)
            if let entity = try await findCalendarEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
                try await swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        case "update":
            let dto = try JSONDecoder().decode(CalendarDTO.self, from: outbox.payload)
            _ = try await supabaseClient.updateCalendar(dto)
            if let entity = try await findCalendarEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try await swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        case "delete":
            let deletePayload = try JSONDecoder().decode([String: Int64].self, from: outbox.payload)
            if let id = deletePayload["id"] {
                try await supabaseClient.deleteCalendar(id: id)
            }
            if let entity = try await findCalendarEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try await swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        default:
            break
        }
    }
    
    private func findEventEntity(localID: UUID) async throws -> EventEntity? {
        try await swiftDataClient.getEvent(localID: localID)
    }
    
    private func findCalendarEntity(localID: UUID) async throws -> CalendarEntity? {
        try await swiftDataClient.getCalendar(localID: localID)
    }
}
