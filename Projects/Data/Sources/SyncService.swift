import Foundation

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
        let dto = try JSONDecoder().decode(EventDTO.self, from: outbox.payload)
        
        switch outbox.operation {
        case "create":
            let created = try await supabaseClient.createEvent(dto)
            // Update local entity with remote ID
            if let entity = try await findEventEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
                try await swiftDataClient.updateEvent(entity)
            }
            
        case "update":
            _ = try await supabaseClient.updateEvent(dto)
            if let entity = try await findEventEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try await swiftDataClient.updateEvent(entity)
            }
            
        case "delete":
            if let id = dto.id {
                try await supabaseClient.deleteEvent(id: id)
            }
            
        default:
            print("⚠️ Unknown operation: \(outbox.operation)")
        }
    }
    
    private func processCalendarOutbox(_ outbox: OutboxEntity) async throws {
        let dto = try JSONDecoder().decode(CalendarDTO.self, from: outbox.payload)
        
        switch outbox.operation {
        case "create":
            let created = try await supabaseClient.createCalendar(dto)
            if let entity = try await findCalendarEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
            }
            
        case "update":
            _ = try await supabaseClient.updateCalendar(dto)
            
        default:
            break
        }
    }
    
    private func findEventEntity(localID: UUID) async throws -> EventEntity? {
        // This would need a proper fetch by localID in SwiftDataClient
        // For now, returning nil as placeholder
        return nil
    }
    
    private func findCalendarEntity(localID: UUID) async throws -> CalendarEntity? {
        return nil
    }
}
