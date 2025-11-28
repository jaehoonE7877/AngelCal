import Foundation
import SwiftData

/// Thin SwiftData helper. Not thread-safe; call from a single actor (e.g., repositories) to serialize access.
public final class SwiftDataClient {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() throws {
        let schema = Schema([
            EventEntity.self,
            EventReminderEntity.self,
            CalendarEntity.self,
            OutboxEntity.self,
            UserProfileEntity.self,
            NotificationSettingsEntity.self,
            AppearanceSettingsEntity.self,
            TemplateEntity.self,
            WidgetConfigEntity.self,
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
        if markPending {
            event.updatedAt = Date()
            event.pendingSync = true
        } else {
            event.pendingSync = false
        }
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

    // MARK: - Event Reminder Operations
    public func fetchEventReminders(eventID: Int64) throws -> [EventReminderEntity] {
        let predicate = #Predicate<EventReminderEntity> { reminder in
            reminder.eventID == eventID
        }
        let descriptor = FetchDescriptor<EventReminderEntity>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    public func saveEventReminder(_ reminder: EventReminderEntity) throws {
        modelContext.insert(reminder)
        try modelContext.save()
    }

    public func updateEventReminder(_ reminder: EventReminderEntity, markPending: Bool = true) throws {
        if markPending { reminder.pendingSync = true }
        try modelContext.save()
    }

    public func deleteEventReminder(_ reminder: EventReminderEntity) throws {
        modelContext.delete(reminder)
        try modelContext.save()
    }

    public func getEventReminder(remoteID: Int64) throws -> EventReminderEntity? {
        let predicate = #Predicate<EventReminderEntity> { reminder in
            reminder.remoteID == remoteID
        }
        let descriptor = FetchDescriptor<EventReminderEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    public func getEventReminder(localID: UUID) throws -> EventReminderEntity? {
        let predicate = #Predicate<EventReminderEntity> { reminder in
            reminder.localID == localID
        }
        let descriptor = FetchDescriptor<EventReminderEntity>(predicate: predicate)
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
        if markPending {
            calendar.updatedAt = Date()
            calendar.pendingSync = true
        } else {
            calendar.pendingSync = false
        }
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
    
    // MARK: - Template Operations
    public func fetchTemplates(userID: UUID) throws -> [TemplateEntity] {
        let predicate = #Predicate<TemplateEntity> { $0.userID == userID }
        let descriptor = FetchDescriptor<TemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.sortOrder)])
        return try modelContext.fetch(descriptor)
    }
    
    public func saveTemplate(_ template: TemplateEntity) throws {
        modelContext.insert(template)
        try modelContext.save()
    }
    
    public func updateTemplate(_ template: TemplateEntity, markPending: Bool = true) throws {
        if markPending {
            template.updatedAt = Date()
            template.pendingSync = true
        } else {
            template.pendingSync = false
        }
        try modelContext.save()
    }
    
    public func deleteTemplate(_ template: TemplateEntity) throws {
        modelContext.delete(template)
        try modelContext.save()
    }
    
    public func getTemplate(remoteID: Int64) throws -> TemplateEntity? {
        let predicate = #Predicate<TemplateEntity> { $0.remoteID == remoteID }
        let descriptor = FetchDescriptor<TemplateEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func getTemplate(localID: UUID) throws -> TemplateEntity? {
        let predicate = #Predicate<TemplateEntity> { $0.localID == localID }
        let descriptor = FetchDescriptor<TemplateEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - Widget Config Operations
    public func fetchWidgetConfigs(userID: UUID) throws -> [WidgetConfigEntity] {
        let predicate = #Predicate<WidgetConfigEntity> { config in
            config.userID == userID
        }
        let descriptor = FetchDescriptor<WidgetConfigEntity>(predicate: predicate, sortBy: [SortDescriptor(\.sortOrder)])
        return try modelContext.fetch(descriptor)
    }
    
    public func saveWidgetConfig(_ config: WidgetConfigEntity) throws {
        modelContext.insert(config)
        try modelContext.save()
    }
    
    public func updateWidgetConfig(_ config: WidgetConfigEntity, markPending: Bool = true) throws {
        if markPending {
            config.updatedAt = Date()
        }
        try modelContext.save()
    }
    
    public func deleteWidgetConfig(_ config: WidgetConfigEntity) throws {
        modelContext.delete(config)
        try modelContext.save()
    }
    
    public func getWidgetConfig(remoteID: Int64) throws -> WidgetConfigEntity? {
        let predicate = #Predicate<WidgetConfigEntity> { $0.remoteID == remoteID }
        let descriptor = FetchDescriptor<WidgetConfigEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    public func getWidgetConfig(localID: UUID) throws -> WidgetConfigEntity? {
        let predicate = #Predicate<WidgetConfigEntity> { $0.localID == localID }
        let descriptor = FetchDescriptor<WidgetConfigEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
}
