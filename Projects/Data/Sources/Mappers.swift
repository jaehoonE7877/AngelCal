import Foundation

// MARK: - Mappers: Domain Model <-> Entity
public extension EventEntity {
    func toDomain() -> Event {
        Event(
            id: remoteID,
            userID: userID,
            calendarID: calendarID,
            title: title,
            startAt: startAt,
            endAt: endAt,
            allDay: allDay,
            timeZone: timeZone,
            location: location,
            memo: memo,
            url: url,
            recurrenceRule: recurrenceRule,
            colorOverride: colorOverride,
            onlineMeetingLink: onlineMeetingLink,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
    
    static func fromDomain(_ event: Event, localID: UUID = UUID()) -> EventEntity {
        EventEntity(
            remoteID: event.id,
            userID: event.userID,
            calendarID: event.calendarID,
            title: event.title,
            startAt: event.startAt,
            endAt: event.endAt,
            allDay: event.allDay,
            timeZone: event.timeZone,
            location: event.location,
            memo: event.memo,
            url: event.url,
            recurrenceRule: event.recurrenceRule,
            colorOverride: event.colorOverride,
            onlineMeetingLink: event.onlineMeetingLink,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            deletedAt: event.deletedAt,
            localID: localID,
            pendingSync: false
        )
    }
}

public extension CalendarEntity {
    func toDomain() -> CalendarModel {
        CalendarModel(
            id: remoteID,
            ownerID: ownerID,
            name: name,
            colorKey: colorKey,
            isPrimary: isPrimary,
            isDefaultForNewEvents: isDefaultForNewEvents,
            isShared: isShared,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
    
    static func fromDomain(_ calendar: CalendarModel, localID: UUID = UUID()) -> CalendarEntity {
        CalendarEntity(
            remoteID: calendar.id,
            ownerID: calendar.ownerID,
            name: calendar.name,
            colorKey: calendar.colorKey,
            isPrimary: calendar.isPrimary,
            isDefaultForNewEvents: calendar.isDefaultForNewEvents,
            isShared: calendar.isShared,
            createdAt: calendar.createdAt,
            updatedAt: calendar.updatedAt,
            deletedAt: calendar.deletedAt,
            localID: localID,
            pendingSync: false
        )
    }
}

// MARK: - Mappers: DTO <-> Domain
public extension EventDTO {
    func toDomain() -> Event {
        Event(
            id: id,
            userID: userID,
            calendarID: calendarID,
            title: title,
            startAt: startAt,
            endAt: endAt,
            allDay: allDay,
            timeZone: timeZone,
            location: location,
            memo: memo,
            url: url,
            recurrenceRule: recurrenceRule,
            colorOverride: colorOverride,
            onlineMeetingLink: onlineMeetingLink,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt
        )
    }
    
    static func fromDomain(_ event: Event) -> EventDTO {
        EventDTO(
            id: event.id,
            userID: event.userID,
            calendarID: event.calendarID,
            title: event.title,
            startAt: event.startAt,
            endAt: event.endAt,
            allDay: event.allDay,
            timeZone: event.timeZone,
            location: event.location,
            memo: event.memo,
            url: event.url,
            recurrenceRule: event.recurrenceRule,
            colorOverride: event.colorOverride,
            onlineMeetingLink: event.onlineMeetingLink,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            deletedAt: event.deletedAt
        )
    }
}

public extension CalendarDTO {
    func toDomain() -> CalendarModel {
        CalendarModel(
            id: id,
            ownerID: ownerID,
            name: name,
            colorKey: colorKey,
            isPrimary: isPrimary,
            isDefaultForNewEvents: isDefaultForNewEvents,
            isShared: isShared,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt
        )
    }
    
    static func fromDomain(_ calendar: CalendarModel) -> CalendarDTO {
        CalendarDTO(
            id: calendar.id,
            ownerID: calendar.ownerID,
            name: calendar.name,
            colorKey: calendar.colorKey,
            isPrimary: calendar.isPrimary,
            isDefaultForNewEvents: calendar.isDefaultForNewEvents,
            isShared: calendar.isShared,
            createdAt: calendar.createdAt,
            updatedAt: calendar.updatedAt,
            deletedAt: calendar.deletedAt
        )
    }
}
