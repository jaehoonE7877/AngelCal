import Foundation
import Core

public struct SeedService {
    let calendarRepository: CalendarRepository
    public init(calendarRepository: CalendarRepository) {
        self.calendarRepository = calendarRepository
    }
    
    public func ensureDefaultData(userID: UUID) async throws {
        let calendars = try await calendarRepository.fetchCalendars()
        if calendars.isEmpty {
            let defaultCal = CalendarModel(ownerID: userID, name: "기본 캘린더", colorKey: "blue", isPrimary: true, isDefaultForNewEvents: true)
            _ = try await calendarRepository.createCalendar(defaultCal)
        }
        // 설정/알림은 추후 확장
    }
}
