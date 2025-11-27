import ComposableArchitecture
import SwiftUI

@Reducer
struct EventDetailFeature {
    @ObservableState
    struct State: Equatable {
        let event: EventDTO
    }
    
    enum Action {
        case deleteButtonTapped
        case delegate(Delegate)
        
        enum Delegate {
            case deleteEvent(UUID)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .deleteButtonTapped:
                return .run { [id = state.event.id] send in
                    await send(.delegate(.deleteEvent(id)))
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
