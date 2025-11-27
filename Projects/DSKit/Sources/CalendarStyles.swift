import SwiftUI

public struct CalendarCellStyle {
    public static func background(isToday: Bool) -> Color {
        isToday ? Tokens.Color.accent : Color.clear
    }
    public static func textColor(isToday: Bool) -> Color {
        isToday ? .white : .primary
    }
}
