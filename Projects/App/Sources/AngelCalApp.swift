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
            let syncService = SyncService(
                swiftDataClient: swiftDataClient,
                supabaseClient: supabaseClient,
                eventRepository: eventRepository,
                calendarRepository: calendarRepository
            )

            self.swiftDataClient = swiftDataClient
            self.supabaseClient = supabaseClient
            self.eventRepository = eventRepository
            self.calendarRepository = calendarRepository
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
                }
            )
        }
    }
}
