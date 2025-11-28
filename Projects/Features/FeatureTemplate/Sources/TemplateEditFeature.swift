import ComposableArchitecture
import Core
import Foundation

@Reducer
public struct TemplateEditFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var durationMinutes: Double = 60
        public var alertText: String = "-10"
        public var location: String = ""
        public var memo: String = ""
        public var colorKey: String = "system"
        public var sortOrder: Int = 0
        public var isSaving: Bool = false
        public var templateID: Int64?
        public init() {}
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case save
        case saved(TaskResult<EventTemplate>)
        case cancel
    }
    
    @Dependency(\.templateClient) var templateClient
    @Dependency(\.currentUserID) var currentUserID
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .save:
                guard !state.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .none }
                state.isSaving = true
                let template = EventTemplate(
                    id: state.templateID,
                    userID: currentUserID,
                    title: state.title,
                    defaultDurationMinutes: Int(state.durationMinutes),
                    defaultAlertOffsets: parseOffsets(state.alertText),
                    defaultLocation: state.location.isEmpty ? nil : state.location,
                    defaultColorKey: state.colorKey,
                    defaultMemo: state.memo.isEmpty ? nil : state.memo,
                    sortOrder: state.sortOrder
                )
                return .run { send in
                    await send(.saved(TaskResult { try await templateClient.updateTemplate(template) }))
                }
            case .saved(.success):
                state.isSaving = false
                return .run { _ in await dismiss() }
            case .saved(.failure):
                state.isSaving = false
                return .none
            case .cancel:
                return .run { _ in await dismiss() }
            }
        }
    }
    
    private func parseOffsets(_ text: String) -> [Int] {
        text.split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}
