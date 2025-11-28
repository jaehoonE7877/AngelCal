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
        public var availableCalendars: [CalendarModel] = []
        @Presents public var alert: AlertState<Alert>?
        public var appliedTemplate: EventTemplate?
        
        public init(startAt: Date = Date(), template: EventTemplate? = nil) {
            self.startAt = startAt
            self.endAt = Calendar.current.date(byAdding: .hour, value: 1, to: startAt) ?? startAt
            if let template {
                self.title = template.title
                self.memo = template.defaultMemo ?? ""
                self.location = template.defaultLocation ?? ""
                self.endAt = Calendar.current.date(byAdding: .minute, value: template.defaultDurationMinutes, to: startAt) ?? startAt
                self.appliedTemplate = template
            }
        }
    }
    
    public enum Action {
        case onAppear
        case setTitle(String)
        case setStart(Date)
        case setEnd(Date)
        case setAllDay(Bool)
        case setLocation(String)
        case setMemo(String)
        case setCalendar(Int64?)
        case save
        case saved(TaskResult<Event>)
        case defaultsLoaded(TaskResult<Defaults>)
        case cancel
        case delegate(Delegate)
        case alert(PresentationAction<Alert>)
        case applyTemplate(EventTemplate)
    }

    public enum Alert: Equatable {
        case cannotSave
        case saveFailed
    }
    
    public enum Delegate {
        case saved(Event)
    }
    
    public struct Defaults: Equatable {
        public let calendars: [CalendarModel]
        public let startAt: Date
        public let endAt: Date
        public let selectedCalendarID: Int64?
    }
    
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.currentUserID) var currentUserID
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let startAt = state.startAt
                let endAt = state.endAt
                return .run { send in
                    let calendars = (try? await calendarClient.fetchCalendars()) ?? []
                    let defaultCalendar = calendars.first(where: { $0.isDefaultForNewEvents }) ?? calendars.first
                    let start = Calendar.current.date(
                        bySettingHour: 9,
                        minute: 0,
                        second: 0,
                        of: startAt
                    ) ?? startAt
                    let end = Calendar.current.date(byAdding: .minute, value: 60, to: start) ?? endAt
                    await send(.defaultsLoaded(.success(.init(
                        calendars: calendars,
                        startAt: start,
                        endAt: end,
                        selectedCalendarID: defaultCalendar?.id
                    ))))
                }
            case .defaultsLoaded(.success(let defaults)):
                state.availableCalendars = defaults.calendars
                state.selectedCalendarID = state.selectedCalendarID ?? defaults.selectedCalendarID ?? 0
                if state.availableCalendars.isEmpty == false {
                    state.startAt = defaults.startAt
                    state.endAt = defaults.endAt
                }
                return .none
            case .defaultsLoaded(.failure):
                return .none
            case .setTitle(let t): state.title = t; return .none
            case .setStart(let d):
                state.startAt = d
                if state.endAt <= d {
                    state.endAt = Calendar.current.date(byAdding: .minute, value: 60, to: d) ?? d
                }
                return .none
            case .setEnd(let d):
                state.endAt = d <= state.startAt ? state.startAt.addingTimeInterval(1800) : d
                return .none
            case .setAllDay(let v):
                state.allDay = v
                if v {
                    let cal = Calendar.current
                    let startOfDay = cal.startOfDay(for: state.startAt)
                    state.startAt = startOfDay
                    state.endAt = cal.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
                } else if state.endAt <= state.startAt {
                    state.endAt = state.startAt.addingTimeInterval(3600)
                }
                return .none
            case .setLocation(let v): state.location = v; return .none
            case .setMemo(let v): state.memo = v; return .none
            case .setCalendar(let id): state.selectedCalendarID = id; return .none
            case .save:
                if let error = validate(state: state) {
                    state.alert = AlertState {
                        TextState("저장할 수 없음")
                    } message: {
                        TextState(error)
                    }
                    return .none
                }
                state.isSaving = true
                let event = Event(
                    id: nil,
                    userID: currentUserID,
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
                    await send(.saved(TaskResult { try await eventClient.createEvent(event) }))
                }
            case .saved(.success(let event)):
                state.isSaving = false
                return .concatenate(
                    .run { send in await send(.delegate(.saved(event))) },
                    .run { _ in await dismiss() }
                )
            case .saved(.failure(let error)):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장 실패")
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
            case .cancel:
                return .run { _ in await dismiss() }
            case .delegate:
                return .none
            case .alert:
                return .none
            case .applyTemplate(let template):
                state.appliedTemplate = template
                state.title = template.title
                state.memo = template.defaultMemo ?? ""
                state.location = template.defaultLocation ?? ""
                state.endAt = Calendar.current.date(byAdding: .minute, value: template.defaultDurationMinutes, to: state.startAt) ?? state.startAt
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func validate(state: State) -> String? {
        if state.selectedCalendarID == nil {
            return "캘린더를 선택해주세요."
        }
        if state.endAt <= state.startAt {
            return "종료 시간이 시작 시간 이후여야 합니다."
        }
        return nil
    }
}
