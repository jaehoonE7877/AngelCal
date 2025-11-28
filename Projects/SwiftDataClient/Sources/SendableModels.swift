import Foundation

// SwiftData models are reference types; mark them as unchecked Sendable so they can cross actor boundaries
// when wrapped by the SwiftDataClient actor. Mutations remain serialized by that actor.
extension EventEntity: @unchecked Sendable {}
extension EventReminderEntity: @unchecked Sendable {}
extension CalendarEntity: @unchecked Sendable {}
extension OutboxEntity: @unchecked Sendable {}
extension UserProfileEntity: @unchecked Sendable {}
extension NotificationSettingsEntity: @unchecked Sendable {}
extension AppearanceSettingsEntity: @unchecked Sendable {}
extension TemplateEntity: @unchecked Sendable {}
extension WidgetConfigEntity: @unchecked Sendable {}
