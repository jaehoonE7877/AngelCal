import Foundation
import Dependencies

public extension SyncClient {
    static func live(
        userProvider: @escaping @Sendable () async throws -> UUID,
        syncService: SyncService
    ) -> Self {
        .init(
            syncAll: {
                let userID = try await userProvider()
                try await syncService.initialLoad(userID: userID)
            },
            syncEvents: {
                let userID = try await userProvider()
                try await syncService.pullFromServer(userID: userID)
            },
            syncCalendars: {
                let userID = try await userProvider()
                try await syncService.syncCalendarsFromServer(userID: userID)
            },
            syncSettings: { },
            processPendingOutbox: {
                try await syncService.processPendingOutbox()
            }
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
