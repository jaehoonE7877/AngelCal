import ComposableArchitecture
import SwiftUI
import Core

@Reducer
public struct CalendarSettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var calendars: [CalendarModel] = []
        public var isLoading: Bool = false
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case refresh
        case calendarsResponse(TaskResult<[CalendarModel]>)
        case setDefault(Int64)
    }
    
    @Dependency(\.calendarClient) var calendarClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                state.isLoading = true
                return .run { send in
                    await send(.calendarsResponse(TaskResult { try await calendarClient.fetchCalendars() }))
                }
            case .calendarsResponse(.success(let calendars)):
                state.isLoading = false
                state.calendars = calendars
                return .none
            case .calendarsResponse(.failure):
                state.isLoading = false
                state.calendars = []
                return .none
            case .setDefault(let id):
                guard let calendar = state.calendars.first(where: { $0.id == id }) else { return .none }
                let updated = CalendarModel(
                    id: calendar.id,
                    ownerID: calendar.ownerID,
                    name: calendar.name,
                    colorKey: calendar.colorKey,
                    isPrimary: calendar.isPrimary,
                    isDefaultForNewEvents: true,
                    isShared: calendar.isShared,
                    createdAt: calendar.createdAt,
                    updatedAt: Date(),
                    deletedAt: calendar.deletedAt
                )
                state.calendars = state.calendars.map { existing in
                    if existing.id == id {
                        return updated
                    }
                    return existing
                }
                return .run { _ in _ = try await calendarClient.updateCalendar(updated) }
            }
        }
    }
}

public struct CalendarSettingsView: View {
    @Bindable public var store: StoreOf<CalendarSettingsFeature>
    
    public init(store: StoreOf<CalendarSettingsFeature>) { self.store = store }
    
    public var body: some View {
        List {
            ForEach(store.calendars, id: \.id) { calendar in
                HStack {
                    VStack(alignment: .leading) {
                        Text(calendar.name)
                        Text(calendar.colorKey).font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if calendar.isDefaultForNewEvents {
                        Text("기본").foregroundStyle(.blue)
                    } else if let id = calendar.id {
                        Button("기본으로") { store.send(.setDefault(id)) }
                    }
                }
            }
        }
        .overlay {
            if store.isLoading { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
        }
        .navigationTitle("캘린더 설정")
        .task { await store.send(.onAppear).finish() }
        .refreshable { store.send(.refresh) }
    }
}
