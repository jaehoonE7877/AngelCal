import Foundation
import Core
import SwiftDataClient
import SupabaseClient

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

// MARK: - Event Reminder Mappers
public extension EventReminderEntity {
    func toDomain() -> EventReminder {
        EventReminder(
            id: remoteID,
            eventID: eventID,
            offsetMinutes: offsetMinutes,
            createdAt: createdAt
        )
    }

    static func fromDomain(_ reminder: EventReminder, localID: UUID = UUID()) -> EventReminderEntity {
        EventReminderEntity(
            remoteID: reminder.id,
            eventID: reminder.eventID,
            offsetMinutes: reminder.offsetMinutes,
            createdAt: reminder.createdAt,
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

public extension EventReminderDTO {
    func toDomain() -> EventReminder {
        EventReminder(
            id: id,
            eventID: eventID,
            offsetMinutes: offsetMinutes,
            createdAt: createdAt ?? Date()
        )
    }

    static func fromDomain(_ reminder: EventReminder) -> EventReminderDTO {
        EventReminderDTO(
            id: reminder.id,
            eventID: reminder.eventID,
            offsetMinutes: reminder.offsetMinutes,
            createdAt: reminder.createdAt
        )
    }
}

// MARK: - Templates
public extension TemplateEntity {
    func toDomain() -> EventTemplate {
        EventTemplate(
            id: remoteID,
            userID: userID,
            title: title,
            defaultDurationMinutes: defaultDurationMinutes,
            defaultAlertOffsets: defaultAlertOffsets,
            defaultLocation: defaultLocation,
            defaultColorKey: defaultColorKey,
            defaultMemo: defaultMemo,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func fromDomain(_ template: EventTemplate, localID: UUID = UUID()) -> TemplateEntity {
        TemplateEntity(
            remoteID: template.id,
            userID: template.userID,
            title: template.title,
            defaultDurationMinutes: template.defaultDurationMinutes,
            defaultAlertOffsets: template.defaultAlertOffsets,
            defaultLocation: template.defaultLocation,
            defaultColorKey: template.defaultColorKey,
            defaultMemo: template.defaultMemo,
            sortOrder: template.sortOrder,
            createdAt: template.createdAt,
            updatedAt: template.updatedAt,
            localID: localID,
            pendingSync: false
        )
    }
}

public extension EventTemplateDTO {
    func toDomain() -> EventTemplate {
        EventTemplate(
            id: id,
            userID: userID,
            title: title,
            defaultDurationMinutes: defaultDurationMinutes,
            defaultAlertOffsets: defaultAlertOffsets,
            defaultLocation: defaultLocation,
            defaultColorKey: defaultColorKey,
            defaultMemo: defaultMemo,
            sortOrder: sortOrder,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    static func fromDomain(_ template: EventTemplate) -> EventTemplateDTO {
        EventTemplateDTO(
            id: template.id,
            userID: template.userID,
            title: template.title,
            defaultDurationMinutes: template.defaultDurationMinutes,
            defaultAlertOffsets: template.defaultAlertOffsets,
            defaultLocation: template.defaultLocation,
            defaultColorKey: template.defaultColorKey,
            defaultMemo: template.defaultMemo,
            sortOrder: template.sortOrder,
            createdAt: template.createdAt,
            updatedAt: template.updatedAt
        )
    }
}

// MARK: - Settings Mappers
public extension NotificationSettingsEntity {
    func toDomain() -> NotificationSettings {
        NotificationSettings(
            id: nil,
            userID: userID,
            defaultAlertOffsetMinutes: defaultAlertOffsetMinutes,
            allDayDefaultAlertOffsetMinutes: allDayDefaultAlertOffsetMinutes,
            dailySummaryEnabled: dailySummaryEnabled,
            dailySummaryTimeLocal: dailySummaryTimeLocal,
            dailySummaryScope: dailySummaryScope,
            badgeType: badgeType,
            soundKey: soundKey,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func fromDomain(_ settings: NotificationSettings) -> NotificationSettingsEntity {
        NotificationSettingsEntity(
            userID: settings.userID,
            defaultAlertOffsetMinutes: settings.defaultAlertOffsetMinutes,
            allDayDefaultAlertOffsetMinutes: settings.allDayDefaultAlertOffsetMinutes,
            dailySummaryEnabled: settings.dailySummaryEnabled,
            dailySummaryTimeLocal: settings.dailySummaryTimeLocal,
            dailySummaryScope: settings.dailySummaryScope,
            badgeType: settings.badgeType,
            soundKey: settings.soundKey,
            createdAt: settings.createdAt,
            updatedAt: settings.updatedAt
        )
    }
}

public extension NotificationSettingsDTO {
    func toDomain(userID: UUID) -> NotificationSettings {
        NotificationSettings(
            id: nil,
            userID: userID,
            defaultAlertOffsetMinutes: defaultAlertOffsetMinutes,
            allDayDefaultAlertOffsetMinutes: allDayDefaultAlertOffsetMinutes,
            dailySummaryEnabled: dailySummaryEnabled,
            dailySummaryTimeLocal: dailySummaryTimeLocal,
            dailySummaryScope: dailySummaryScope,
            badgeType: badgeType,
            soundKey: soundKey,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func fromDomain(_ settings: NotificationSettings) -> NotificationSettingsDTO {
        NotificationSettingsDTO(
            userID: settings.userID,
            defaultAlertOffsetMinutes: settings.defaultAlertOffsetMinutes,
            allDayDefaultAlertOffsetMinutes: settings.allDayDefaultAlertOffsetMinutes,
            dailySummaryEnabled: settings.dailySummaryEnabled,
            dailySummaryTimeLocal: settings.dailySummaryTimeLocal,
            dailySummaryScope: settings.dailySummaryScope,
            badgeType: settings.badgeType,
            soundKey: settings.soundKey,
            createdAt: settings.createdAt,
            updatedAt: settings.updatedAt
        )
    }
}

public extension AppearanceSettingsEntity {
    func toDomain() -> AppearanceSettings {
        AppearanceSettings(
            id: nil,
            userID: userID,
            startOfWeek: startOfWeek,
            highlightHolidays: highlightHolidays,
            colorThemeKey: colorThemeKey,
            fontKey: fontKey,
            textScale: textScale,
            showEventColors: showEventColors,
            showWeekNumber: showWeekNumber,
            showHolidayName: showHolidayName,
            is24h: is24h,
            enableLunar: enableLunar,
            languageOverride: languageOverride,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func fromDomain(_ settings: AppearanceSettings) -> AppearanceSettingsEntity {
        AppearanceSettingsEntity(
            userID: settings.userID,
            startOfWeek: settings.startOfWeek,
            highlightHolidays: settings.highlightHolidays,
            colorThemeKey: settings.colorThemeKey,
            fontKey: settings.fontKey,
            textScale: settings.textScale,
            showEventColors: settings.showEventColors,
            showWeekNumber: settings.showWeekNumber,
            showHolidayName: settings.showHolidayName,
            is24h: settings.is24h,
            enableLunar: settings.enableLunar,
            languageOverride: settings.languageOverride,
            createdAt: settings.createdAt,
            updatedAt: settings.updatedAt
        )
    }
}

public extension AppearanceSettingsDTO {
    func toDomain(userID: UUID) -> AppearanceSettings {
        AppearanceSettings(
            id: nil,
            userID: userID,
            startOfWeek: startOfWeek,
            highlightHolidays: highlightHolidays,
            colorThemeKey: colorThemeKey,
            fontKey: fontKey,
            textScale: textScale,
            showEventColors: showEventColors,
            showWeekNumber: showWeekNumber,
            showHolidayName: showHolidayName,
            is24h: is24h,
            enableLunar: enableLunar,
            languageOverride: languageOverride,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func fromDomain(_ settings: AppearanceSettings) -> AppearanceSettingsDTO {
        AppearanceSettingsDTO(
            userID: settings.userID,
            startOfWeek: settings.startOfWeek,
            highlightHolidays: settings.highlightHolidays,
            colorThemeKey: settings.colorThemeKey,
            fontKey: settings.fontKey,
            textScale: settings.textScale,
            showEventColors: settings.showEventColors,
            showWeekNumber: settings.showWeekNumber,
            showHolidayName: settings.showHolidayName,
            is24h: settings.is24h,
            enableLunar: settings.enableLunar,
            languageOverride: settings.languageOverride,
            createdAt: settings.createdAt,
            updatedAt: settings.updatedAt
        )
    }
}

public extension WidgetConfigEntity {
    func toDomain() -> WidgetConfig {
        WidgetConfig(
            id: remoteID,
            userID: userID,
            widgetIdentifier: widgetIdentifier,
            widgetType: widgetType,
            linkedCalendarIDs: linkedCalendarIDs,
            maxEventCount: maxEventCount,
            showAllDay: showAllDay,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func fromDomain(_ config: WidgetConfig, localID: UUID = UUID()) -> WidgetConfigEntity {
        WidgetConfigEntity(
            remoteID: config.id,
            userID: config.userID,
            widgetIdentifier: config.widgetIdentifier,
            widgetType: config.widgetType,
            linkedCalendarIDs: config.linkedCalendarIDs,
            maxEventCount: config.maxEventCount,
            showAllDay: config.showAllDay,
            sortOrder: config.sortOrder,
            createdAt: config.createdAt,
            updatedAt: config.updatedAt,
            localID: localID
        )
    }
}

public extension WidgetConfigDTO {
    func toDomain() -> WidgetConfig {
        WidgetConfig(
            id: id,
            userID: userID,
            widgetIdentifier: widgetIdentifier,
            widgetType: widgetType,
            linkedCalendarIDs: linkedCalendarIDs ?? [],
            maxEventCount: maxEventCount,
            showAllDay: showAllDay,
            sortOrder: sortOrder,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    static func fromDomain(_ config: WidgetConfig) -> WidgetConfigDTO {
        WidgetConfigDTO(
            id: config.id,
            userID: config.userID,
            widgetIdentifier: config.widgetIdentifier,
            widgetType: config.widgetType,
            linkedCalendarIDs: config.linkedCalendarIDs,
            maxEventCount: config.maxEventCount,
            showAllDay: config.showAllDay,
            sortOrder: config.sortOrder,
            createdAt: config.createdAt,
            updatedAt: config.updatedAt
        )
    }
}

public extension ProfileDTO {
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            email: email,
            displayName: displayName,
            avatarURL: avatarURL,
            locale: locale ?? "ko-KR",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt
        )
    }

    static func fromDomain(_ profile: UserProfile) -> ProfileDTO {
        ProfileDTO(
            id: profile.id,
            email: profile.email,
            displayName: profile.displayName,
            avatarURL: profile.avatarURL,
            locale: profile.locale,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt,
            deletedAt: profile.deletedAt
        )
    }
}

// MARK: - Holiday / Lunar provider (Korea baseline)
public enum HolidayProvider {
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
    public static let koreanHolidays: Set<String> = [
        "2025-01-01", // 신정
        "2025-03-01", // 삼일절
        "2025-05-05", // 어린이날
        "2025-06-06", // 현충일
        "2025-08-15", // 광복절
        "2025-10-03", // 개천절
        "2025-10-09", // 한글날
        "2025-12-25"  // 성탄절
    ]
    
    public static func isKoreanHoliday(_ date: Date) -> Bool {
        let key = formatter.string(from: date)
        return koreanHolidays.contains(key)
    }
}
