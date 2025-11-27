import ComposableArchitecture
import SwiftUI

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        var title: String
    }
    
    enum Action {
        case close
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .close:
                return .none
            }
        }
    }
}

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    var body: some View {
        Text("Detail: \(store.title)")
    }
}
