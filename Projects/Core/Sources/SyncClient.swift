import Foundation
import Dependencies

public extension SyncClient {
    static func live(
        initialSync: @escaping @Sendable (_ userID: UUID) async throws -> Void,
        pullRange: @escaping @Sendable (_ userID: UUID, _ from: Date, _ to: Date) async throws -> Void,
        pushPending: @escaping @Sendable () async throws -> Void
    ) -> Self {
        .init(
            syncAll: { try await initialSync(UUID()) },
            syncEvents: { /* placeholder: use pullRange with default window */ },
            syncCalendars: { /* handled inside initialSync */ },
            syncSettings: { /* no-op skeleton */ },
            processPendingOutbox: { try await pushPending() }
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
