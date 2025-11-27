import SwiftUI

/// 디자인 토큰 모음 (경량): 기존 Colors/Typography를 참조
public enum Tokens {
    public enum Color {
        public static let primary = AngelCalTheme.primary
        public static let secondary = AngelCalTheme.secondary
        public static let background = AngelCalTheme.background
        public static let accent = AngelCalTheme.accent
    }
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
    }
    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
    }
    public enum TypographyToken {
        public static let heading = AngelCalTheme.heading
        public static let body = AngelCalTheme.body
        public static let caption = AngelCalTheme.caption
    }
}
