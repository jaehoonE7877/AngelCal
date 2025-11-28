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
            copyEvent: { id, newStart in
                try await repository.copyEvent(id: id, to: newStart)
            },
            getEvent: { id in
                try await repository.getEvent(id: id)
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
                try await syncService.syncSettingsFromServer(userID: userID)
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
                let displayName = user.userMetadata["full_name"]?.value as? String
                let profile = ProfileDTO(
                    id: user.id,
                    email: user.email,
                    displayName: displayName,
                    avatarURL: nil,
                    locale: nil
                )
                let savedProfile = try await supabaseClient.upsertProfile(profile)
                return savedProfile.toDomain()
            },
            signOut: {
                try await supabaseClient.signOut()
            },
            getCurrentUser: {
                guard let user = try await supabaseClient.getCurrentUser() else {
                    return nil
                }
                if let remoteProfile = try await supabaseClient.fetchProfile(userID: user.id) {
                    return remoteProfile.toDomain()
                }
                return UserProfile(id: user.id, email: user.email)
            },
            isAuthenticated: {
                (try? await supabaseClient.getCurrentSession()) != nil
            }
        )
    }
}

extension SearchClient {
    public static func live(repository: SearchRepository) -> Self {
        Self(
            searchEvents: { query, calendarIDs, from, to in
                try await repository.search(query: query, calendarIDs: calendarIDs, from: from, to: to)
            }
        )
    }
}

extension SettingsClient {
    public static func live(repository: SettingsRepository) -> Self {
        Self(
            getNotificationSettings: {
                try await repository.fetchNotificationSettings(userID: repository.userID)
            },
            updateNotificationSettings: { settings in
                try await repository.upsertNotificationSettings(settings)
            },
            getAppearanceSettings: {
                try await repository.fetchAppearanceSettings(userID: repository.userID)
            },
            updateAppearanceSettings: { settings in
                try await repository.upsertAppearanceSettings(settings)
            },
            getWidgetConfigs: {
                try await repository.fetchWidgetConfigs()
            },
            upsertWidgetConfig: { config in
                try await repository.upsertWidgetConfig(config)
            },
            deleteWidgetConfig: { id in
                try await repository.deleteWidgetConfig(id: id)
            }
        )
    }
}

extension TemplateClient {
    public static func live(repository: TemplateRepository) -> Self {
        Self(
            fetchTemplates: {
                try await repository.fetchTemplates()
            },
            createTemplate: { template in
                try await repository.createTemplate(template)
            },
            updateTemplate: { template in
                try await repository.updateTemplate(template)
            },
            deleteTemplate: { id in
                try await repository.deleteTemplate(id)
            },
            reorderTemplates: { ids in
                try await repository.reorderTemplates(ids)
            }
        )
    }
}
