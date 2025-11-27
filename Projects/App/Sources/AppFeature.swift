import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var calendar = CalendarFeature.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case calendar(CalendarFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .calendar:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    @Reducer
    enum Path {
        case detail(DetailFeature)
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
        } destination: { store in
            switch store.case {
            case .detail(let store):
                DetailView(store: store)
            }
        }
    }
}

// Keep navigation path state equatable for StackState.
extension AppFeature.Path.State: Equatable {}
