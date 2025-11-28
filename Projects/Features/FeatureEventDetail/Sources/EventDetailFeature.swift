import ComposableArchitecture
import Foundation
import Core

@Reducer
public struct EventDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var event: Event
        public init(event: Event) { self.event = event }
    }
    
    public enum Action {
        case edit
        case copyToDate(Date)
        case delete
        case deleted(Result<Void, Error>)
        case onAppear
        case delegate(Delegate)
        case saveAsTemplate
        case templateSaved(TaskResult<EventTemplate>)
    }
    
    public enum Delegate {
        case edit(Event)
        case copied(Event)
        case deleted(Int64?)
    }
    
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.templateClient) var templateClient
    @Dependency(\.currentUserID) var currentUserID
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .edit:
                let event = state.event
                return .run { send in await send(.delegate(.edit(event))) }
            case .copyToDate(let date):
                guard let id = state.event.id else { return .none }
                return .run { send in
                    let copied = try await eventClient.copyEvent(id, date)
                    await send(.delegate(.copied(copied)))
                }
            case .saveAsTemplate:
                let duration = state.event.endAt.timeIntervalSince(state.event.startAt)
                let template = EventTemplate(
                    id: nil,
                    userID: currentUserID,
                    title: state.event.title,
                    defaultDurationMinutes: Int(duration/60),
                    defaultAlertOffsets: [-10],
                    defaultLocation: state.event.location,
                    defaultColorKey: state.event.colorOverride,
                    defaultMemo: state.event.memo,
                    sortOrder: 0
                )
                return .run { send in
                    await send(.templateSaved(TaskResult { try await templateClient.createTemplate(template) }))
                }
            case .delete:
                guard let id = state.event.id else { return .none }
                return .run { send in
                    do { try await eventClient.deleteEvent(id); await send(.deleted(.success(()))) }
                    catch { await send(.deleted(.failure(error))) }
                }
            case .deleted:
                let id = state.event.id
                return .concatenate(
                    .run { send in await send(.delegate(.deleted(id))) },
                    .run { _ in await dismiss() }
                )
            case .templateSaved:
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
