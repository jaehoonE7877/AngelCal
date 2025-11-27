import ComposableArchitecture
import SwiftUI

@Reducer
struct EventFormFeature {
    @ObservableState
    struct State: Equatable {
        var title: String = ""
        var startDate: Date = Date()
        var endDate: Date = Date().addingTimeInterval(3600)
        var isAllDay: Bool = false
        var location: String = ""
        var notes: String = ""
        
        // If editing an existing event
        var eventId: UUID?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
        case cancelButtonTapped
        case delegate(Delegate)
        
        enum Delegate {
            case saveEvent(Event)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .saveButtonTapped:
                let event = Event(
                    id: state.eventId ?? UUID(),
                    title: state.title,
                    startDate: state.startDate,
                    endDate: state.endDate,
                    location: state.location.isEmpty ? nil : state.location,
                    notes: state.notes.isEmpty ? nil : state.notes,
                    isAllDay: state.isAllDay
                )
                return .run { send in
                    await send(.delegate(.saveEvent(event)))
                    await dismiss()
                }
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .delegate:
                return .none
            }
        }
    }
}
