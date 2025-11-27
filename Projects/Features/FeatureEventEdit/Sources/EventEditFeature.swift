import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct EventEditFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var startAt: Date = Date()
        public var endAt: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        public var allDay: Bool = false
        public var location: String = ""
        public var memo: String = ""
        public var selectedCalendarID: Int64?
        public var isSaving: Bool = false
        public init() {}
    }
    
    public enum Action {
        case setTitle(String)
        case setStart(Date)
        case setEnd(Date)
        case setAllDay(Bool)
        case setLocation(String)
        case setMemo(String)
        case setCalendar(Int64?)
        case save
        case saved(Result<Event, Error>)
        case cancel
    }
    
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setTitle(let t): state.title = t; return .none
            case .setStart(let d): state.startAt = d; return .none
            case .setEnd(let d): state.endAt = d; return .none
            case .setAllDay(let v): state.allDay = v; return .none
            case .setLocation(let v): state.location = v; return .none
            case .setMemo(let v): state.memo = v; return .none
            case .setCalendar(let id): state.selectedCalendarID = id; return .none
            case .save:
                state.isSaving = true
                let event = Event(
                    id: nil,
                    userID: UUID(),
                    calendarID: state.selectedCalendarID ?? 0,
                    title: state.title.isEmpty ? "(제목 없음)" : state.title,
                    startAt: state.startAt,
                    endAt: state.endAt,
                    allDay: state.allDay,
                    location: state.location.isEmpty ? nil : state.location,
                    memo: state.memo.isEmpty ? nil : state.memo,
                    url: nil,
                    recurrenceRule: nil,
                    colorOverride: nil,
                    onlineMeetingLink: nil
                )
                return .run { send in
                    do {
                        let created = try await eventClient.createEvent(event)
                        await send(.saved(.success(created)))
                    } catch {
                        await send(.saved(.failure(error)))
                    }
                }
            case .saved:
                state.isSaving = false
                return .run { _ in await dismiss() }
            case .cancel:
                return .run { _ in await dismiss() }
            }
        }
    }
}
