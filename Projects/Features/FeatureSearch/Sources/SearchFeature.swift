import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct SearchFeature {
    @ObservableState
    public struct State: Equatable {
        public var query: String = ""
        public var dateRange: ClosedRange<Date>? = nil
        public var calendarFilter: [Int64]? = nil
        public var results: [Event] = []
        public var sort: Sort = .startAscending
        public var selectedEvent: Event?
        public init() {}
    }
    
    public enum Action {
        case setQuery(String)
        case setRange(ClosedRange<Date>?)
        case setCalendarFilter([Int64]?)
        case search
        case searchResponse(TaskResult<[Event]>)
        case setSort(Sort)
        case select(Event)
        case dismissDetail
    }
    
    public enum Sort: Equatable {
        case startAscending
        case startDescending
    }
    
    @Dependency(\.searchClient) var searchClient
    @Dependency(\.syncClient) var syncClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setQuery(let q):
                state.query = q; return .none
            case .setRange(let r):
                state.dateRange = r; return .none
            case .setCalendarFilter(let ids):
                state.calendarFilter = ids; return .none
            case .search:
                let query = state.query
                let range = state.dateRange
                let filter = state.calendarFilter
                return .run { send in
                    if range != nil {
                        try? await syncClient.syncEvents()
                    }
                    let res = try await searchClient.searchEvents(
                        query,
                        filter,
                        range?.lowerBound,
                        range?.upperBound
                    )
                    await send(.searchResponse(.success(res)))
                }
            case .searchResponse(.success(let res)):
                state.results = applySort(res, sort: state.sort)
                return .none
            case .searchResponse(.failure):
                state.results = []
                return .none
            case .setSort(let sort):
                state.sort = sort
                state.results = applySort(state.results, sort: sort)
                return .none
            case .select(let event):
                state.selectedEvent = event
                return .none
            case .dismissDetail:
                state.selectedEvent = nil
                return .none
            }
        }
    }
    
    private func applySort(_ events: [Event], sort: Sort) -> [Event] {
        switch sort {
        case .startAscending:
            return events.sorted { $0.startAt < $1.startAt }
        case .startDescending:
            return events.sorted { $0.startAt > $1.startAt }
        }
    }
}
