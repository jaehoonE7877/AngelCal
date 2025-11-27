import Foundation
import SwiftData
import SwiftUI

@Model
final class CalendarModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var colorHex: String
    var isShared: Bool
    var ownerId: UUID?
    var isVisible: Bool
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String,
        isShared: Bool = false,
        ownerId: UUID? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.isShared = isShared
        self.ownerId = ownerId
        self.isVisible = isVisible
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension CalendarModel: @unchecked Sendable {}
