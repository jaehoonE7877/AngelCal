import ComposableArchitecture
import SwiftUI
import Core
import FeatureMain

@Reducer
struct AppFeature {
    @Dependency(\.authClient) var authClient
    @Dependency(\.syncClient) var syncClient
    
    @ObservableState
    struct State: Equatable {
        var main = MainFeature.State()
        var path = StackState<Path.State>()
        var onboardingCompleted: Bool = false
    }
    
    enum Action {
        case onAppear
        case main(MainFeature.Action)
        case showOnboarding(Bool)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.
main, action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    _ = try await authClient.getCurrentUser()?.id
                    try await syncClient.syncAll()
                }
            case .main:
                return .none
            case .showOnboarding(let completed):
                state.onboardingCompleted = completed
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.
path, action: \.path)
    }
    
    @Reducer
    enum Path {
        case detail(DetailFeature)
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        Group {
            if store.onboardingCompleted {
                NavigationStack(path: $store.scope(state: \.
path, action: \.path)) {
                    MainView(store: store.scope(state: \.
main, action: \.main))
                } destination: { store in
                    switch store.case {
                    case .detail(let store):
                        DetailView(store: store)
                    }
                }
            } else {
                OnboardingView(
                    store: .init(initialState: .init()) { OnboardingFeature() },
                    onComplete: { store.send(.showOnboarding(true)) }
                )
            }
        }
        .task { await store.send(.onAppear).finish() }
    }
}

// Keep navigation path state equatable for StackState.
extension AppFeature.Path.State: Equatable {}
