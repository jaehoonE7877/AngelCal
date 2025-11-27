import Foundation
import Dependencies

public extension SyncClient {
    static func live(
        syncAll: @escaping @Sendable () async throws -> Void,
        pullRange: @escaping @Sendable () async throws -> Void,
        pushPending: @escaping @Sendable () async throws -> Void
    ) -> Self {
        .init(
            syncAll: syncAll,
            syncEvents: pullRange,
            syncCalendars: pullRange,
            syncSettings: { },
            processPendingOutbox: pushPending
        )
    }
}

public extension SyncClient {
    static let placeholder = SyncClient(
        syncAll: { },
        syncEvents: { },
        syncCalendars: { },
        syncSettings: { },
        processPendingOutbox: { }
    )
}
