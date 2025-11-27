import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
        var selectedDate: Date = Date()
        var events: [EventDTO] = []
        @Presents var addEvent: EventFormFeature.State?
        @Presents var eventDetail: EventDetailFeature.State?
    }
    
    enum Action {
        case nextPage
        case previousPage
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
            case .nextPage:
                let calendar = Calendar.current
                let newDate = calendar.date(byAdding: .month, value: 1, to: state.currentDate) ?? state.currentDate
                state.currentDate = newDate
                // Only update selectedDate if we want the selection to follow the page
                // For now, let's keep selectedDate as is, unless it's out of view?
                // Minical behavior: selection stays on the date you clicked, but if you scroll far, maybe it should update?
                // Let's update selectedDate to the first day of the new page to avoid confusion
                state.selectedDate = newDate
                return .send(.fetchEvents)
                
            case .previousPage:
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
