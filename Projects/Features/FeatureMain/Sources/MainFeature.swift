import ComposableArchitecture
import Foundation
import Core
import FeatureCalendar
import FeatureSearch
import FeatureSettings

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab = .calendar
        public var selectedDate: Date = Date()
        public var viewMode: ViewMode = .month
        public var calendar: CalendarFeature.State = .init()
        public var search: SearchFeature.State = .init()
        public var settings: SettingsRootFeature.State = .init()
        public init() {}
    }
    
    public enum Tab: Hashable {
        case calendar
        case search
        case settings
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case setTab(Tab)
        case setViewMode(ViewMode)
        case selectDate(Date)
        case calendar(CalendarFeature.Action)
        case search(SearchFeature.Action)
        case settings(SettingsRootFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsRootFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .setTab(let tab):
                state.selectedTab = tab
                return .none
            case .setViewMode(let mode):
                state.viewMode = mode
                return .none
            case .selectDate(let date):
                state.selectedDate = date
                return .send(.calendar(.setDate(date)))
            case .calendar:
                return .none
            case .search:
                return .none
            case .settings:
                return .none
            }
        }
    }
}
