import SwiftUI
import ComposableArchitecture
import DSKit
import Core
import Data
import SwiftDataClient
import SupabaseClient

@main
struct AngelCalApp: App {
    private let swiftDataClient: SwiftDataClient
    private let supabaseClient: SupabaseClientWrapper
    private let eventRepository: EventRepository
    private let calendarRepository: CalendarRepository
    private let settingsRepository: SettingsRepository
    private let searchRepository: SearchRepository
    private let templateRepository: TemplateRepository
    private let reminderRepository: ReminderRepository
    private let syncService: SyncService
    private let currentUserID = UUID()

    init() {
        do {
            let swiftDataClient = try SwiftDataClient()
            let supabaseClient = SupabaseClientWrapper(
                supabaseURL: AppConfig.supabaseURL,
                supabaseKey: AppConfig.supabaseAnonKey
            )
            let eventRepository = EventRepository(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient
            )
            let calendarRepository = CalendarRepository(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient
            )
            let settingsRepository = SettingsRepository(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient,
                userID: currentUserID
            )
            let searchRepository = SearchRepository(swiftDataClient: swiftDataClient)
            let templateRepository = TemplateRepository(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient,
                userID: currentUserID
            )
            let reminderRepository = ReminderRepository(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient
            )
            let syncService = SyncService(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient,
                eventRepository: eventRepository,
                calendarRepository: calendarRepository,
                templateRepository: templateRepository,
                settingsRepository: settingsRepository,
                reminderRepository: reminderRepository
            )

            self.swiftDataClient = swiftDataClient
            self.supabaseClient = supabaseClient
            self.eventRepository = eventRepository
            self.calendarRepository = calendarRepository
            self.settingsRepository = settingsRepository
            self.searchRepository = searchRepository
            self.templateRepository = templateRepository
            self.reminderRepository = reminderRepository
            self.syncService = syncService
        } catch {
            fatalError("Failed to create SwiftDataClient: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                } withDependencies: { dependencies in
                    dependencies.eventClient = .live(repository: eventRepository)
                    dependencies.calendarClient = .live(repository: calendarRepository)
                    dependencies.syncClient = .live(syncService: syncService, userID: currentUserID)
                    dependencies.authClient = .live(supabaseClient: supabaseClient)
                    dependencies.settingsClient = .live(repository: settingsRepository)
                    dependencies.searchClient = .live(repository: searchRepository)
                    dependencies.templateClient = .live(repository: templateRepository)
                    dependencies.metricsClient = .init(
                        logEvent: { name, props in
                            print("Metrics:", name, props)
                        }
                    )
                    dependencies.errorReporter = .init(
                        handle: { error, context in
                            print("Error[\(context)]:", error.localizedDescription)
                        }
                    )
                    dependencies.currentUserID = currentUserID
                }
            )
        }
    }
}
