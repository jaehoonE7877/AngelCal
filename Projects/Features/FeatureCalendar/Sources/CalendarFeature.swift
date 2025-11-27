import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var viewMode: ViewMode = .month
        public var dayList: DayListFeature.State = .init()
        public init() {}
    }
    
    public enum Action {
        case setDate(Date)
        case setViewMode(ViewMode)
        case pullToRefresh
        case dayList(DayListFeature.Action)
    }
    
    @Dependency(\.syncClient) var syncClient
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.
.dayList, action: \.dayList) {
            DayListFeature()
        }
        Reduce { state, action in
            switch action {
            case .setDate(let date):
                state.selectedDate = date
                return .none
            case .setViewMode(let mode):
                state.viewMode = mode
                return .none
            case .pullToRefresh:
                // month span: current month
                let now = state.selectedDate
                return .run { _ in
                    var cal = Calendar.current
                    cal.timeZone = .current
                    let start = cal.date(from: cal.dateComponents([.year,.month], from: now)) ?? now
                    let end = cal.date(byAdding: .month, value: 1, to: start) ?? now
                    try await syncClient.syncEvents()
                    try await syncClient.processPendingOutbox()
                    // Optionally pull range with start/end if syncClient exposes
                    _ = (start, end)
                }
            case .dayList:
                return .none
            }
        }
    }
}
