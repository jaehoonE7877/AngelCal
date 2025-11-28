import ComposableArchitecture
import Foundation
import Core
import FeatureEventEdit

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var viewMode: ViewMode = .month
        public var dayList: DayListFeature.State = .init()
        public var showingEventEdit: Bool = false
        public var eventEditState: EventEditFeature.State = .init()
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case setDate(Date)
        case setViewMode(ViewMode)
        case pullToRefresh
        case dayList(DayListFeature.Action)
        case setEventEditPresented(Bool)
        case eventEdit(EventEditFeature.Action)
        case eventsResponse(TaskResult<[Event]>)
    }
    
    @Dependency(\.syncClient) var syncClient
    @Dependency(\.eventClient) var eventClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.dayList, action: \.dayList) {
            DayListFeature()
        }
        Scope(state: \.eventEditState, action: \.eventEdit) {
            EventEditFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return loadEventsEffect(for: state.selectedDate, viewMode: state.viewMode)
            case .setDate(let date):
                state.selectedDate = date
                return loadEventsEffect(for: date, viewMode: state.viewMode)
            case .setViewMode(let mode):
                state.viewMode = mode
                return loadEventsEffect(for: state.selectedDate, viewMode: mode)
            case .pullToRefresh:
                let refresh = Effect<Action>.run { _ in
                    try await syncClient.syncEvents()
                    try await syncClient.processPendingOutbox()
                }
                return .concatenate(
                    refresh,
                    loadEventsEffect(for: state.selectedDate, viewMode: state.viewMode)
                )
            case .dayList:
                return .none
            case .setEventEditPresented(let presented):
                state.showingEventEdit = presented
                state.eventEditState = .init(startAt: state.selectedDate)
                return .none
            case .eventEdit(.delegate(.saved)):
                state.showingEventEdit = false
                return .merge(
                    loadEventsEffect(for: state.selectedDate, viewMode: state.viewMode),
                    .run { _ in try? await syncClient.processPendingOutbox() }
                )
            case .eventEdit:
                return .none
            case .eventsResponse(.success(let events)):
                let cal = Calendar.current
                state.dayList.events = events
                    .filter { cal.isDate($0.startAt, inSameDayAs: state.selectedDate) }
                    .sorted { $0.startAt < $1.startAt }
                return .none
            case .eventsResponse(.failure):
                state.dayList.events = []
                return .none
            }
        }
    }
    
    private func loadEventsEffect(for date: Date, viewMode: ViewMode) -> Effect<Action> {
        .run { send in
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: date)
            let end: Date
            switch viewMode {
            case .week:
                end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
            case .month:
                end = calendar.date(byAdding: .day, value: 30, to: start) ?? start
            }
            await send(.eventsResponse(TaskResult { try await eventClient.fetchEvents(start, end) }))
        }
    }
}
