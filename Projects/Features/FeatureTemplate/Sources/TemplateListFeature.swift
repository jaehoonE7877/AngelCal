import ComposableArchitecture
import Core
import Foundation

@Reducer
public struct TemplateListFeature {
    @ObservableState
    public struct State: Equatable {
        public var templates: [EventTemplate] = []
        @Presents public var editor: TemplateEditFeature.State?
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case refresh
        case templatesResponse(TaskResult<[EventTemplate]>)
        case addButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case editor(PresentationAction<TemplateEditFeature.Action>)
        case useTemplate(EventTemplate)
        case delegate(Delegate)
    }
    
    public enum Delegate: Equatable {
        case use(EventTemplate)
    }
    
    @Dependency(\.templateClient) var templateClient
    @Dependency(\.currentUserID) var currentUserID
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                return .run { send in
                    await send(.templatesResponse(TaskResult { try await templateClient.fetchTemplates() }))
                }
            case .templatesResponse(.success(let templates)):
                state.templates = templates.sorted { $0.sortOrder < $1.sortOrder }
                return .none
            case .templatesResponse(.failure):
                state.templates = []
                return .none
            case .addButtonTapped:
                let sortOrder = state.templates.count
                state.editor = .init()
                state.editor?.sortOrder = sortOrder
                return .none
            case .delete(let indexSet):
                guard let index = indexSet.first, state.templates.indices.contains(index) else { return .none }
                let id = state.templates[index].id
                state.templates.remove(at: index)
                if let id {
                    return .run { _ in try await templateClient.deleteTemplate(id) }
                }
                return .none
            case .move(let indexSet, let newOffset):
                state.templates.move(fromOffsets: indexSet, toOffset: newOffset)
                let orderedIDs = state.templates.compactMap { $0.id }
                return .run { _ in try await templateClient.reorderTemplates(orderedIDs) }
            case .editor(.presented(.saved(.success(let template)))):
                state.editor = nil
                return .concatenate(
                    .send(.refresh),
                    .run { _ in _ = try? await templateClient.updateTemplate(template) }
                )
            case .editor:
                return .none
            case .useTemplate(let template):
                return .send(.delegate(.use(template)))
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$editor, action: \.editor) {
            TemplateEditFeature()
        }
    }
}
