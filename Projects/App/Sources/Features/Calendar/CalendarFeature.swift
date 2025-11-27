import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
        var selectedDate: Date = Date()
        var viewMode: ViewMode = .month
        var events: [EventDTO] = []
        @Presents var addEvent: EventFormFeature.State?
        @Presents var eventDetail: EventDetailFeature.State?
        
        enum ViewMode: Equatable {
            case month
            case week
        }
    }
    
    enum Action {
        case toggleViewMode
        case nextMonth
        case previousMonth
        case goToday
        case selectDate(Date)
        case addEventButtonTapped
        case addEvent(PresentationAction<EventFormFeature.Action>)
        case eventTapped(EventDTO)
        case eventDetail(PresentationAction<EventDetailFeature.Action>)
        case fetchEvents
        case eventsLoaded([EventDTO])
    }
    
    @Dependency(\.database) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggleViewMode:
                state.viewMode = state.viewMode == .month ? .week : .month
                return .none
                
            case .nextMonth:
                let calendar = Calendar.current
                let newDate = calendar.date(byAdding: .month, value: 1, to: state.currentDate) ?? state.currentDate
                state.currentDate = newDate
                state.selectedDate = newDate
                return .send(.fetchEvents)
                
            case .previousMonth:
                let calendar = Calendar.current
                let newDate = calendar.date(byAdding: .month, value: -1, to: state.currentDate) ?? state.currentDate
                state.currentDate = newDate
                state.selectedDate = newDate
                return .send(.fetchEvents)
                
            case .goToday:
                let today = Date()
                state.currentDate = today
                state.selectedDate = today
                return .send(.fetchEvents)
                
            case .selectDate(let date):
                state.selectedDate = date
                state.currentDate = date
                return .none
                
            case .addEventButtonTapped:
                state.addEvent = EventFormFeature.State()
                return .none
                
            case .addEvent(.presented(.delegate(.saveEvent(let event)))):
                return .run { send in
                    try await database.addEvent(event)
                    await send(.fetchEvents)
                }
                
            case .addEvent:
                return .none
                
            case .eventTapped(let event):
                state.eventDetail = EventDetailFeature.State(event: event)
                return .none
                
            case .eventDetail(.presented(.delegate(.deleteEvent(let id)))):
                return .run { send in
                    if let event = try await database.fetchEvents(Date.distantPast, Date.distantFuture).first(where: { $0.id == id }) {
                        try await database.deleteEvent(event)
                        await send(.fetchEvents)
                    }
                }
                
            case .eventDetail:
                return .none
                
            case .fetchEvents:
                let currentDate = state.currentDate
                return .run { send in
                    let calendar = Calendar.current
                    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                          let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
                    else { return }
                    
                    let events = try await database.fetchEvents(startOfMonth, endOfMonth)
                    let dtos = events.map(EventDTO.init)
                    await send(.eventsLoaded(dtos))
                }
                
            case .eventsLoaded(let events):
                state.events = events
                return .none
            }
        }
        .ifLet(\.$addEvent, action: \.addEvent) {
            EventFormFeature()
        }
        .ifLet(\.$eventDetail, action: \.eventDetail) {
            EventDetailFeature()
        }
    }
}
