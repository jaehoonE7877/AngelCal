import Foundation
import SwiftData

public actor SwiftDataClient {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() throws {
        let schema = Schema([
            EventEntity.self,
            CalendarEntity.self,
            OutboxEntity.self,
            UserProfileEntity.self,
            NotificationSettingsEntity.self,
            AppearanceSettingsEntity.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        self.modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        self.modelContext = ModelContext(modelContainer)
        self.modelContext.autosaveEnabled = true
    }
    
    public func getContext() -> ModelContext {
        modelContext
    }
    
    // MARK: - Event Operations
    public func fetchEvents(from: Date, to: Date) throws -> [EventEntity] {
        let predicate = #Predicate<EventEntity> { event in
            event.startAt >= from && event.startAt <= to && event.deletedAt == nil
        }
        let descriptor = FetchDescriptor<EventEntity>(predicate: predicate, sortBy: [SortDescriptor(\.startAt)])
        return try modelContext.fetch(descriptor)
    }
    
    public func saveEvent(_ event: EventEntity) throws {
        modelContext.insert(event)
        try modelContext.save()
    }
    
    public func updateEvent(_ event: EventEntity, markPending: Bool = true) throws {
        event.updatedAt = Date()
        if markPending { event.pendingSync = true }
        try modelContext.save()
    }
    
    public func deleteEvent(_ event: EventEntity) throws {
        event.deletedAt = Date()
        event.pendingSync = true
        try modelContext.save()
    }
    
    public func getEvent(remoteID: Int64) throws -> EventEntity? {
        let predicate = #Predicate<EventEntity> { event in
            event.remoteID == remoteID
        }
        let descriptor = FetchDescriptor<EventEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func getEvent(localID: UUID) throws -> EventEntity? {
        let predicate = #Predicate<EventEntity> { event in
            event.localID == localID
        }
        let descriptor = FetchDescriptor<EventEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - Calendar Operations
    public func fetchCalendars() throws -> [CalendarEntity] {
        let predicate = #Predicate<CalendarEntity> { calendar in
            calendar.deletedAt == nil
        }
        let descriptor = FetchDescriptor<CalendarEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    public func saveCalendar(_ calendar: CalendarEntity) throws {
        modelContext.insert(calendar)
        try modelContext.save()
    }
    
    public func getCalendar(remoteID: Int64) throws -> CalendarEntity? {
        let predicate = #Predicate<CalendarEntity> { calendar in
            calendar.remoteID == remoteID
        }
        let descriptor = FetchDescriptor<CalendarEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func getCalendar(localID: UUID) throws -> CalendarEntity? {
        let predicate = #Predicate<CalendarEntity> { calendar in
            calendar.localID == localID
        }
        let descriptor = FetchDescriptor<CalendarEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func updateCalendar(_ calendar: CalendarEntity, markPending: Bool = true) throws {
        calendar.updatedAt = Date()
        if markPending { calendar.pendingSync = true }
        try modelContext.save()
    }
    
    public func deleteCalendar(_ calendar: CalendarEntity) throws {
        calendar.deletedAt = Date()
        calendar.pendingSync = true
        try modelContext.save()
    }
    
    // MARK: - Outbox Operations
    public func addToOutbox(entityType: String, entityLocalID: UUID, operation: String, payload: Data) throws {
        let outbox = OutboxEntity(
            entityType: entityType,
            entityLocalID: entityLocalID,
            operation: operation,
            payload: payload
        )
        modelContext.insert(outbox)
        try modelContext.save()
    }
    
    public func getPendingOutbox() throws -> [OutboxEntity] {
        let descriptor = FetchDescriptor<OutboxEntity>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }
    
    public func deleteOutbox(_ outbox: OutboxEntity) throws {
        modelContext.delete(outbox)
        try modelContext.save()
    }
    
    public func incrementOutboxRetry(_ outbox: OutboxEntity, error: String) throws {
        outbox.retryCount += 1
        outbox.lastError = error
        try modelContext.save()
    }
    
    // MARK: - Settings Operations
    public func getNotificationSettings(userID: UUID) throws -> NotificationSettingsEntity? {
        let predicate = #Predicate<NotificationSettingsEntity> { settings in
            settings.userID == userID
        }
        let descriptor = FetchDescriptor<NotificationSettingsEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func saveNotificationSettings(_ settings: NotificationSettingsEntity) throws {
        if let existing = try getNotificationSettings(userID: settings.userID) {
            modelContext.delete(existing)
        }
        modelContext.insert(settings)
        try modelContext.save()
    }
    
    public func getAppearanceSettings(userID: UUID) throws -> AppearanceSettingsEntity? {
        let predicate = #Predicate<AppearanceSettingsEntity> { settings in
            settings.userID == userID
        }
        let descriptor = FetchDescriptor<AppearanceSettingsEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func saveAppearanceSettings(_ settings: AppearanceSettingsEntity) throws {
        if let existing = try getAppearanceSettings(userID: settings.userID) {
            modelContext.delete(existing)
        }
        modelContext.insert(settings)
        try modelContext.save()
    }
}
