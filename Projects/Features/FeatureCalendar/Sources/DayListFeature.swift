import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct DayListFeature {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public init() {}
    }
    
    public enum Action {
        case setEvents([Event])
    }
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setEvents(let events):
                state.events = events
                return .none
            }
        }
    }
}
