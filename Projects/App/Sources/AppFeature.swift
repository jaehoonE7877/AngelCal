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
        case onAppear
        case calendar(CalendarFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: preload minimal data or trigger sync when dependency 주입 완료 시 교체
                return .none
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
        .task { await store.send(.onAppear).finish() }
    }
}

// Keep navigation path state equatable for StackState.
extension AppFeature.Path.State: Equatable {}
