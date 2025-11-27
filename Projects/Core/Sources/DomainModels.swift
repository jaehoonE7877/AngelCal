// Re-export 및 Domain alias 정의로 중복 모델 생성을 피함
// 기존 Models.swift의 구조체를 그대로 사용한다.

public typealias DomainUserProfile = UserProfile
public typealias DomainCalendar = CalendarModel
public typealias DomainEvent = Event
public typealias DomainEventReminder = EventReminder
public typealias DomainEventTemplate = EventTemplate
public typealias DomainNotificationSettings = NotificationSettings
public typealias DomainAppearanceSettings = AppearanceSettings
