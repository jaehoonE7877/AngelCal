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
    
    public enum Action { case none }
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .none:
                return .none
            }
        }
    }
}
