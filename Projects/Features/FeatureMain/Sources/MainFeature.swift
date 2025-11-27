import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var viewMode: ViewMode = .month
        public var calendar: CalendarFeature.State = .init()
        public init() {}
    }
    
    public enum Action {
        case setViewMode(ViewMode)
        case selectDate(Date)
        case calendar(CalendarFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.
calendar, action: \.calendar) {
            CalendarFeature()
        }
        Reduce { state, action in
            switch action {
            case .setViewMode(let mode):
                state.viewMode = mode
                return .none
            case .selectDate(let date):
                state.selectedDate = date
                return .send(.calendar(.setDate(date)))
            case .calendar:
                return .none
            }
        }
    }
}
