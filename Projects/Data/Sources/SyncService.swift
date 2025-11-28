import Foundation
import Core
import SwiftDataClient
import SupabaseClient

public actor SyncService {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    private let eventRepository: EventRepository
    private let calendarRepository: CalendarRepository
    private let templateRepository: TemplateRepository?
    private let settingsRepository: SettingsRepository?
    private let reminderRepository: ReminderRepository?
    
    private var isSyncing = false
    private let maxRetries = 3
    
    public init(
        swiftDataClient: SwiftDataClient,
        supabaseClient: SupabaseClientWrapper,
        eventRepository: EventRepository,
        calendarRepository: CalendarRepository,
        templateRepository: TemplateRepository? = nil,
        settingsRepository: SettingsRepository? = nil,
        reminderRepository: ReminderRepository? = nil
    ) {
        self.swiftDataClient = swiftDataClient
        self.supabaseClient = supabaseClient
        self.eventRepository = eventRepository
        self.calendarRepository = calendarRepository
        self.templateRepository = templateRepository
        self.settingsRepository = settingsRepository
        self.reminderRepository = reminderRepository
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

    public func syncRange(userID: UUID, from: Date, to: Date) async throws {
        try await eventRepository.syncEventsFromServer(userID: userID, from: from, to: to)
    }

    public func syncCalendarsFromServer(userID: UUID) async throws {
        try await calendarRepository.syncCalendarsFromServer(userID: userID)
    }

    public func syncTemplatesFromServer(userID: UUID) async throws {
        _ = try await templateRepository?.fetchTemplates()
    }

    public func syncSettingsFromServer(userID: UUID) async throws {
        if let settingsRepository {
            _ = try await settingsRepository.fetchNotificationSettings(userID: userID)
            _ = try await settingsRepository.fetchAppearanceSettings(userID: userID)
            _ = try await settingsRepository.fetchWidgetConfigs()
        }
    }
    
    // MARK: - Pull from Server
    public func pullFromServer(userID: UUID) async throws {
        // Sync calendars first
        try await calendarRepository.syncCalendarsFromServer(userID: userID)

        // Sync templates
        _ = try await templateRepository?.fetchTemplates()

        // Sync settings and widgets
        if let settingsRepository {
            _ = try await settingsRepository.fetchNotificationSettings(userID: userID)
            _ = try await settingsRepository.fetchAppearanceSettings(userID: userID)
            _ = try await settingsRepository.fetchWidgetConfigs()
        }
        
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
        let outboxItems = try swiftDataClient.getPendingOutbox()
        
        for outbox in outboxItems {
            do {
                try await processOutboxItem(outbox)
                try swiftDataClient.deleteOutbox(outbox)
            } catch {
                if outbox.retryCount < maxRetries {
                    try swiftDataClient.incrementOutboxRetry(outbox, error: error.localizedDescription)
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
            if let entity = try findEventEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
                try swiftDataClient.updateEvent(entity, markPending: false)
            }
            
        case "update":
            let dto = try JSONDecoder().decode(EventDTO.self, from: outbox.payload)
            _ = try await supabaseClient.updateEvent(dto)
            if let entity = try findEventEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try swiftDataClient.updateEvent(entity, markPending: false)
            }
            
        case "delete":
            let deletePayload = try JSONDecoder().decode([String: Int64].self, from: outbox.payload)
            if let id = deletePayload["id"] {
                try await supabaseClient.deleteEvent(id: id)
            }
            if let entity = try findEventEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try swiftDataClient.updateEvent(entity, markPending: false)
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
            if let entity = try findCalendarEntity(localID: outbox.entityLocalID) {
                entity.remoteID = created.id
                entity.pendingSync = false
                try swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        case "update":
            let dto = try JSONDecoder().decode(CalendarDTO.self, from: outbox.payload)
            _ = try await supabaseClient.updateCalendar(dto)
            if let entity = try findCalendarEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        case "delete":
            let deletePayload = try JSONDecoder().decode([String: Int64].self, from: outbox.payload)
            if let id = deletePayload["id"] {
                try await supabaseClient.deleteCalendar(id: id)
            }
            if let entity = try findCalendarEntity(localID: outbox.entityLocalID) {
                entity.pendingSync = false
                try swiftDataClient.updateCalendar(entity, markPending: false)
            }
            
        default:
            break
        }
    }
    
    private func findEventEntity(localID: UUID) throws -> EventEntity? {
        try swiftDataClient.getEvent(localID: localID)
    }
    
    private func findCalendarEntity(localID: UUID) throws -> CalendarEntity? {
        try swiftDataClient.getCalendar(localID: localID)
    }

    // MARK: - Triggers
    public func initialLoad(userID: UUID) async throws {
        try await syncAll(userID: userID)
    }
    
    public func handleConnectivityRestored(userID: UUID) async throws {
        try await processPendingOutbox()
        try await pullFromServer(userID: userID)
    }
    
    public func handleBackgroundRefresh(userID: UUID) async throws {
        try await processPendingOutbox()
    }
}
