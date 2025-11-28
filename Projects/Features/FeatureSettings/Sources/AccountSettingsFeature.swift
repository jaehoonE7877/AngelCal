import ComposableArchitecture
import SwiftUI
import Core

@Reducer
public struct AccountSettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var isProcessing: Bool = false
        public init() {}
    }
    
    public enum Action {
        case logout
        case resetData
        case finished
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.syncClient) var syncClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .logout:
                state.isProcessing = true
                return .run { send in
                    try? await authClient.signOut()
                    await send(.finished)
                }
            case .resetData:
                state.isProcessing = true
                return .run { send in
                    try? await syncClient.processPendingOutbox()
                    await send(.finished)
                }
            case .finished:
                state.isProcessing = false
                return .none
            }
        }
    }
}

public struct AccountSettingsView: View {
    @Bindable public var store: StoreOf<AccountSettingsFeature>
    
    public init(store: StoreOf<AccountSettingsFeature>) { self.store = store }
    
    public var body: some View {
        Form {
            Section {
                Button("로그아웃") { store.send(.logout) }
                Button("데이터 초기화") { store.send(.resetData) }
            }
        }
        .navigationTitle("계정")
        .disabled(store.isProcessing)
    }
}
