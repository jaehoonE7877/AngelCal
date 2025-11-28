import Foundation
import SwiftData

/// Persisted user profile record.
@Model
public final class UserProfileEntity {
    @Attribute(.unique) public var id: UUID
    public var email: String?
    public var displayName: String?
    public var avatarURL: String?
    public var locale: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    
    public init(
        id: UUID,
        email: String? = nil,
        displayName: String? = nil,
        avatarURL: String? = nil,
        locale: String = "ko-KR",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.locale = locale
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

/// Immutable Sendable snapshot of a user profile entity.
public struct UserProfileEntitySnapshot: Sendable {
    public let id: UUID
    public let email: String?
    public let displayName: String?
    public let avatarURL: String?
    public let locale: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
}

public extension UserProfileEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> UserProfileEntitySnapshot {
        UserProfileEntitySnapshot(
            id: id,
            email: email,
            displayName: displayName,
            avatarURL: avatarURL,
            locale: locale,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
}
