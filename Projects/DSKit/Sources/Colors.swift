import SwiftUI

public extension Color {
    // Base palette tuned for dark, minimal calendar UI
    static let angelBackground = Color(red: 0.07, green: 0.07, blue: 0.08) // #111
    static let angelSurface = Color(red: 0.13, green: 0.13, blue: 0.15)    // #222
    static let angelCard = Color(red: 0.16, green: 0.16, blue: 0.18)       // #292c
    static let angelBorder = Color(red: 0.24, green: 0.24, blue: 0.27)     // subtle divider
    
    // Text
    static let angelTextPrimary = Color.white
    static let angelTextSecondary = Color(white: 0.72)
    static let angelTextTertiary = Color(white: 0.55)
    
    // Accents
    static let angelBlue = Color(red: 0.32, green: 0.62, blue: 0.98)
    static let angelMint = Color(red: 0.35, green: 0.83, blue: 0.68)
    static let angelAmber = Color(red: 0.98, green: 0.71, blue: 0.32)
    static let angelRed = Color(red: 0.93, green: 0.41, blue: 0.41)
    static let angelPurple = Color(red: 0.63, green: 0.52, blue: 0.96)
    
    // Semantic Colors
    static let background = Color.angelBackground
    static let textPrimary = Color.angelTextPrimary
    static let textSecondary = Color.angelTextSecondary
}

public struct AngelColors {
    public static let primary = Color.angelBlue
    public static let secondary = Color.angelTextSecondary
    public static let accent = Color.angelMint
    
    // Surfaces
    public static let surface = Color.angelSurface
    public static let card = Color.angelCard
    public static let border = Color.angelBorder
}
