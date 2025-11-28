import Dependencies
import Foundation

private enum CurrentUserIDKey: DependencyKey {
    static let liveValue: UUID = UUID()
    static let testValue: UUID = UUID()
}

public extension DependencyValues {
    var currentUserID: UUID {
        get { self[CurrentUserIDKey.self] }
        set { self[CurrentUserIDKey.self] = newValue }
    }
}
