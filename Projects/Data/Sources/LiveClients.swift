import Foundation
import ComposableArchitecture
import Core
import SupabaseClient

// MARK: - Live Implementations
extension EventClient {
    public static func live(repository: EventRepository) -> Self {
        Self(
            fetchEvents: { from, to in
                try await repository.fetchEvents(from: from, to: to)
            },
            createEvent: { event in
                try await repository.createEvent(event)
            },
            updateEvent: { event in
                try await repository.updateEvent(event)
            },
            deleteEvent: { id in
                try await repository.deleteEvent(id)
            },
            getEvent: { id in
                try await repository.fetchEvents(from: Date.distantPast, to: Date.distantFuture)
                    .first(where: { $0.id == id })
            }
        )
    }
}

extension CalendarClient {
    public static func live(repository: CalendarRepository) -> Self {
        Self(
            fetchCalendars: {
                try await repository.fetchCalendars()
            },
            createCalendar: { calendar in
                try await repository.createCalendar(calendar)
            },
            updateCalendar: { calendar in
                try await repository.updateCalendar(calendar)
            },
            deleteCalendar: { id in
                try await repository.deleteCalendar(id)
            }
        )
    }
}

extension SyncClient {
    public static func live(syncService: SyncService, userID: UUID) -> Self {
        Self(
            syncAll: {
                try await syncService.syncAll(userID: userID)
            },
            syncEvents: {
                let now = Date()
                let calendar = Calendar.current
                let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                let end = calendar.date(byAdding: .month, value: 2, to: now) ?? now
                try await syncService.syncEventsFromServer(userID: userID, from: start, to: end)
                try await syncService.processPendingOutbox()
            },
            syncCalendars: {
                try await syncService.syncCalendarsFromServer(userID: userID)
                try await syncService.processPendingOutbox()
            },
            syncSettings: {
                // Settings pull/push hooks can be added; for now reuse full sync.
                try await syncService.syncAll(userID: userID)
            },
            processPendingOutbox: {
                try await syncService.processPendingOutbox()
            }
        )
    }
}

extension AuthClient {
    public static func live(supabaseClient: SupabaseClientWrapper) -> Self {
        Self(
            signInWithApple: { idToken in
                let user = try await supabaseClient.signInWithApple(idToken: idToken)
                return UserProfile(
                    id: user.id,
                    email: user.email,
                    displayName: user.userMetadata["full_name"]?.value as? String
                )
            },
            signOut: {
                try await supabaseClient.signOut()
            },
            getCurrentUser: {
                guard let user = try await supabaseClient.getCurrentUser() else {
                    return nil
                }
                return UserProfile(
                    id: user.id,
                    email: user.email
                )
            },
            isAuthenticated: {
                (try? await supabaseClient.getCurrentSession()) != nil
            }
        )
    }
}
