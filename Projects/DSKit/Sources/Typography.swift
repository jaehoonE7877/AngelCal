import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum AngelTypography {
    public enum Family {
        public static let pretendard = "Pretendard"
    }
    
    public static func display(_ weight: Font.Weight = .bold) -> Font {
        pretendard(size: 34, textStyle: .largeTitle, weight: weight, leading: .tight)
    }
    
    public static func title1(_ weight: Font.Weight = .semibold) -> Font {
        pretendard(size: 28, textStyle: .title, weight: weight)
    }
    
    public static func title2(_ weight: Font.Weight = .semibold) -> Font {
        pretendard(size: 22, textStyle: .title2, weight: weight)
    }
    
    public static func headline(_ weight: Font.Weight = .semibold) -> Font {
        pretendard(size: 18, textStyle: .headline, weight: weight)
    }
    
    public static func body(_ weight: Font.Weight = .regular) -> Font {
        pretendard(size: 17, textStyle: .body, weight: weight)
    }
    
    public static func callout(_ weight: Font.Weight = .medium) -> Font {
        pretendard(size: 15, textStyle: .callout, weight: weight)
    }
    
    public static func caption(_ weight: Font.Weight = .medium) -> Font {
        pretendard(size: 13, textStyle: .caption, weight: weight)
    }
    
    private static func pretendard(
        size: CGFloat,
        textStyle: Font.TextStyle,
        weight: Font.Weight,
        leading: Font.Leading? = nil
    ) -> Font {
        #if canImport(UIKit)
        guard UIFont(name: Family.pretendard, size: size) != nil else {
            var systemFont = Font.system(size: size, weight: weight, design: .default)
            if let leading {
                systemFont = systemFont.leading(leading)
            }
            return systemFont
        }
        
        var font = Font.custom(Family.pretendard, size: size, relativeTo: textStyle)
        if let leading {
            font = font.leading(leading)
        }
        return font.weight(weight)
        #else
        var font = Font.custom(Family.pretendard, size: size, relativeTo: textStyle)
        if let leading {
            font = font.leading(leading)
        }
        return font.weight(weight)
        #endif
    }
}
