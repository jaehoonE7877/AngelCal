import ComposableArchitecture
import SwiftData
import SwiftUI

struct DatabaseClient {
    var fetchEvents: @Sendable (Date, Date) async throws -> [Event]
    var addEvent: @Sendable (Event) async throws -> Void
    var deleteEvent: @Sendable (Event) async throws -> Void
    var updateEvent: @Sendable (Event) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static let liveValue: DatabaseClient = {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Event.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        return DatabaseClient(
            fetchEvents: { @MainActor startDate, endDate in
                let context = sharedModelContainer.mainContext
                let descriptor = FetchDescriptor<Event>(
                    predicate: #Predicate<Event> { event in
                        event.startDate >= startDate && event.endDate <= endDate
                    },
                    sortBy: [SortDescriptor(\.startDate)]
                )
                return try context.fetch(descriptor)
            },
            addEvent: { @MainActor event in
                let context = sharedModelContainer.mainContext
                context.insert(event)
                try context.save()
            },
            deleteEvent: { @MainActor event in
                let context = sharedModelContainer.mainContext
                context.delete(event)
                try context.save()
            },
            updateEvent: { @MainActor event in
                let context = sharedModelContainer.mainContext
                try context.save()
            }
        )
    }()
}

extension DependencyValues {
    var database: DatabaseClient {
        get { self[DatabaseClientKey.self] }
        set { self[DatabaseClientKey.self] = newValue }
    }
}

private enum DatabaseClientKey: DependencyKey {
    static let liveValue = DatabaseClient.liveValue
}
