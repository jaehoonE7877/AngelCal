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
    }
    
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .edit:
                return .none // navigation handled upstream
            case .copyToDate(let date):
                var copy = state.event
                copy.id = nil
                copy.startAt = date
                copy.endAt = Calendar.current.date(byAdding: .minute, value: Int(copy.endAt.timeIntervalSince(copy.startAt)/60), to: date) ?? date
                return .run { _ in _ = try await eventClient.createEvent(copy) }
            case .delete:
                guard let id = state.event.id else { return .none }
                return .run { send in
                    do { try await eventClient.deleteEvent(id); await send(.deleted(.success(()))) }
                    catch { await send(.deleted(.failure(error))) }
                }
            case .deleted:
                return .run { _ in await dismiss() }
            }
        }
    }
}
