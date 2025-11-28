import SwiftUI

public struct AngelCalTheme {
    // Color tokens (fallback 기본 색상)
    public static let primary = Color.blue
    public static let secondary = Color.gray
    public static let background = Color(.systemBackground)
    public static let accent = Color.accentColor
    
    // Typography tokens
    public static let heading: Font = .title3.weight(.semibold)
    public static let body: Font = .body
    public static let caption: Font = .caption
}
