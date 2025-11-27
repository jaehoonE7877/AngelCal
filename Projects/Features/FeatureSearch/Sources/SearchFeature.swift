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
        public init() {}
    }
    
    public enum Action {
        case setQuery(String)
        case setRange(ClosedRange<Date>?)
        case setCalendarFilter([Int64]?)
        case search
        case results([Event])
    }
    
    @Dependency(\.searchRepository) var searchRepo
    
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
                    let res = try await searchRepo.search(
                        query: query,
                        calendarIDs: filter,
                        from: range?.lowerBound,
                        to: range?.upperBound
                    )
                    await send(.results(res))
                }
            case .results(let res):
                state.results = res
                return .none
            }
        }
    }
}
