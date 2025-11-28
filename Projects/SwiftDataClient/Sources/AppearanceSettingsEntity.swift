import Foundation
import SwiftData

/// Persisted appearance settings for a user.
@Model
public final class AppearanceSettingsEntity {
    @Attribute(.unique) public var userID: UUID
    public var startOfWeek: String
    public var highlightHolidays: Bool
    public var colorThemeKey: String
    public var fontKey: String
    public var textScale: Double
    public var showEventColors: Bool
    public var showWeekNumber: Bool
    public var showHolidayName: Bool
    public var is24h: Bool
    public var enableLunar: Bool
    public var languageOverride: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        userID: UUID,
        startOfWeek: String = "monday",
        highlightHolidays: Bool = true,
        colorThemeKey: String = "system",
        fontKey: String = "system",
        textScale: Double = 1.0,
        showEventColors: Bool = true,
        showWeekNumber: Bool = false,
        showHolidayName: Bool = true,
        is24h: Bool = true,
        enableLunar: Bool = false,
        languageOverride: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userID = userID
        self.startOfWeek = startOfWeek
        self.highlightHolidays = highlightHolidays
        self.colorThemeKey = colorThemeKey
        self.fontKey = fontKey
        self.textScale = textScale
        self.showEventColors = showEventColors
        self.showWeekNumber = showWeekNumber
        self.showHolidayName = showHolidayName
        self.is24h = is24h
        self.enableLunar = enableLunar
        self.languageOverride = languageOverride
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Immutable Sendable snapshot of appearance settings.
public struct AppearanceSettingsEntitySnapshot: Sendable {
    public let userID: UUID
    public let startOfWeek: String
    public let highlightHolidays: Bool
    public let colorThemeKey: String
    public let fontKey: String
    public let textScale: Double
    public let showEventColors: Bool
    public let showWeekNumber: Bool
    public let showHolidayName: Bool
    public let is24h: Bool
    public let enableLunar: Bool
    public let languageOverride: String?
    public let createdAt: Date
    public let updatedAt: Date
}

public extension AppearanceSettingsEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> AppearanceSettingsEntitySnapshot {
        AppearanceSettingsEntitySnapshot(
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
}
