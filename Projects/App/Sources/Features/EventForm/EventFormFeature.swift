import ComposableArchitecture
import Core
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
        var userID: UUID = UUID()
        var calendarID: Int64 = 1
        
        // If editing an existing event
        var eventId: Int64?
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
                    id: state.eventId,
                    userID: state.userID,
                    calendarID: state.calendarID,
                    title: state.title,
                    startAt: state.startDate,
                    endAt: state.endDate,
                    allDay: state.isAllDay,
                    location: state.location.isEmpty ? nil : state.location,
                    memo: state.notes.isEmpty ? nil : state.notes
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
