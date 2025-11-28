import ComposableArchitecture
import SwiftUI
import Core
import Foundation

@Reducer
public struct WidgetGuideFeature {
    @ObservableState
    public struct State: Equatable {
        public var configs: [WidgetConfig] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var availableCalendars: [CalendarModel] = []
        public var lastError: String?
        public var retryCount: Int = 0
        @Presents public var editingConfig: WidgetConfig?
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case calendarsResponse(TaskResult<[CalendarModel]>)
        case configsResponse(TaskResult<[WidgetConfig]>)
        case add
        case delete(IndexSet)
        case refreshTimeline
        case refreshCompleted(TaskResult<Void>)
        case startEdit(WidgetConfig)
        case closeEditor
        case setEditingType(String)
        case setEditingMax(Int)
        case toggleEditingAllDay(Bool)
        case toggleEditingCalendar(Int64)
        case saveEdit
    }
    
    @Dependency(\.settingsClient) var settingsClient
    @Dependency(\.currentUserID) var currentUserID
    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.syncClient) var syncClient
    @Dependency(\.errorReporter) var errorReporter
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .run { send in
                        await send(.calendarsResponse(TaskResult { try await calendarClient.fetchCalendars() }))
                    },
                    .run { send in
                        await send(.configsResponse(TaskResult { try await settingsClient.getWidgetConfigs() }))
                    }
                )
            case .calendarsResponse(.success(let calendars)):
                state.availableCalendars = calendars
                return .none
            case .calendarsResponse(.failure(let error)):
                state.lastError = error.localizedDescription
                errorReporter.handle(error, "WidgetGuideFeature.calendars")
                return .none
            case .configsResponse(.success(let configs)):
                state.isLoading = false
                state.retryCount = 0
                state.lastError = nil
                state.configs = configs
                return .none
            case .configsResponse(.failure(let error)):
                state.isLoading = false
                state.lastError = error.localizedDescription
                state.configs = []
                let retries = min(state.retryCount + 1, 3)
                state.retryCount = retries
                let delay = Duration.seconds(Double(pow(2.0, Double(retries))))
                return .run { send in
                    try await clock.sleep(for: delay)
                    await send(.onAppear)
                }
            case .add:
                let config = WidgetConfig(
                    id: nil,
                    userID: currentUserID,
                    widgetIdentifier: UUID().uuidString,
                    widgetType: "today",
                    linkedCalendarIDs: [],
                    maxEventCount: 5,
                    showAllDay: true,
                    sortOrder: state.configs.count
                )
                return .run { send in
                    _ = try await settingsClient.upsertWidgetConfig(config)
                    await send(.configsResponse(TaskResult { try await settingsClient.getWidgetConfigs() }))
                }
            case .delete(let indexSet):
                guard let index = indexSet.first, state.configs.indices.contains(index) else { return .none }
                let config = state.configs[index]
                return .run { send in
                    try await settingsClient.deleteWidgetConfig(config.id)
                    await send(.configsResponse(TaskResult { try await settingsClient.getWidgetConfigs() }))
                }
            case .refreshTimeline:
                state.isRefreshing = true
                return .run { send in
                    await send(.refreshCompleted(TaskResult {
                        try await syncClient.syncEvents()
                        _ = try await settingsClient.getWidgetConfigs()
                    }))
                }
            case .refreshCompleted(.success):
                state.isRefreshing = false
                state.lastError = nil
                return .run { send in
                    await send(.configsResponse(TaskResult { try await settingsClient.getWidgetConfigs() }))
                }
            case .refreshCompleted(.failure(let error)):
                state.isRefreshing = false
                state.lastError = error.localizedDescription
                errorReporter.handle(error, "WidgetGuideFeature.refresh")
                return .none
            case .startEdit(let config):
                state.editingConfig = config
                return .none
            case .closeEditor:
                state.editingConfig = nil
                return .none
            case .setEditingType(let type):
                if var editing = state.editingConfig {
                    editing = WidgetConfig(
                        id: editing.id,
                        userID: editing.userID,
                        widgetIdentifier: editing.widgetIdentifier,
                        widgetType: type,
                        linkedCalendarIDs: editing.linkedCalendarIDs,
                        maxEventCount: editing.maxEventCount,
                        showAllDay: editing.showAllDay,
                        sortOrder: editing.sortOrder,
                        createdAt: editing.createdAt,
                        updatedAt: Date()
                    )
                    state.editingConfig = editing
                }
                return .none
            case .setEditingMax(let max):
                if var editing = state.editingConfig {
                    editing = WidgetConfig(
                        id: editing.id,
                        userID: editing.userID,
                        widgetIdentifier: editing.widgetIdentifier,
                        widgetType: editing.widgetType,
                        linkedCalendarIDs: editing.linkedCalendarIDs,
                        maxEventCount: max,
                        showAllDay: editing.showAllDay,
                        sortOrder: editing.sortOrder,
                        createdAt: editing.createdAt,
                        updatedAt: Date()
                    )
                    state.editingConfig = editing
                }
                return .none
            case .toggleEditingAllDay(let value):
                if var editing = state.editingConfig {
                    editing = WidgetConfig(
                        id: editing.id,
                        userID: editing.userID,
                        widgetIdentifier: editing.widgetIdentifier,
                        widgetType: editing.widgetType,
                        linkedCalendarIDs: editing.linkedCalendarIDs,
                        maxEventCount: editing.maxEventCount,
                        showAllDay: value,
                        sortOrder: editing.sortOrder,
                        createdAt: editing.createdAt,
                        updatedAt: Date()
                    )
                    state.editingConfig = editing
                }
                return .none
            case .toggleEditingCalendar(let id):
                if var editing = state.editingConfig {
                    var set = Set(editing.linkedCalendarIDs)
                    if set.contains(id) { set.remove(id) } else { set.insert(id) }
                    editing = WidgetConfig(
                        id: editing.id,
                        userID: editing.userID,
                        widgetIdentifier: editing.widgetIdentifier,
                        widgetType: editing.widgetType,
                        linkedCalendarIDs: Array(set),
                        maxEventCount: editing.maxEventCount,
                        showAllDay: editing.showAllDay,
                        sortOrder: editing.sortOrder,
                        createdAt: editing.createdAt,
                        updatedAt: Date()
                    )
                    state.editingConfig = editing
                }
                return .none
            case .saveEdit:
                guard let editing = state.editingConfig else { return .none }
                state.isLoading = true
                return .run { send in
                    do {
                        _ = try await settingsClient.upsertWidgetConfig(editing)
                        await send(.configsResponse(TaskResult { try await settingsClient.getWidgetConfigs() }))
                    } catch {
                        await send(.configsResponse(.failure(error)))
                    }
                    await send(.closeEditor)
                }
            }
        }
    }
}

public struct WidgetGuideView: View {
    @Bindable public var store: StoreOf<WidgetGuideFeature>
    
    public init(store: StoreOf<WidgetGuideFeature>) { self.store = store }
    
    public var body: some View {
        List {
            Section("상태") {
                if let error = store.lastError {
                    Text("에러: \(error)").foregroundStyle(.red)
                } else if store.isLoading || store.isRefreshing {
                    ProgressView()
                } else {
                    Text("정상").foregroundStyle(.secondary)
                }
                Button("타임라인 새로고침") { store.send(.refreshTimeline) }
                    .disabled(store.isRefreshing)
            }
            
            Section("가이드") {
                Text("위젯 타입: 오늘/다가오는/월간 미니/스탠드바이 오늘 지원")
                Text("딥링크: 위젯 탭 시 해당 날짜 또는 이벤트 상세로 이동")
                Text("새로고침: 타임라인 실패 시 마지막 성공 데이터를 표시 후 재시도")
            }
            
            Section("구성") {
                ForEach(store.configs, id: \.widgetIdentifier) { config in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(config.widgetIdentifier).font(.headline)
                        Text("타입: \(config.widgetType)")
                            .font(.footnote).foregroundStyle(.secondary)
                        Text("최대 \(config.maxEventCount)개 · 올데이 \(config.showAllDay ? "포함" : "미포함")")
                            .font(.footnote).foregroundStyle(.secondary)
                        if !config.linkedCalendarIDs.isEmpty {
                            Text("캘린더: \(config.linkedCalendarIDs.map(String.init).joined(separator: ", "))")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        HStack {
                            Button("편집") { store.send(.startEdit(config)) }
                            Spacer()
                        }
                    }
                }
                .onDelete { store.send(.delete($0)) }
                
                Button("새 구성 추가") { store.send(.add) }
            }
        }
        .navigationTitle("위젯")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("새로고침") { store.send(.onAppear) }
            }
        }
        .task { await store.send(.onAppear).finish() }
        .sheet(isPresented: Binding(
            get: { store.editingConfig != nil },
            set: { if !$0 { store.send(.closeEditor) } }
        )) {
            if let editing = store.editingConfig {
                NavigationStack {
                    Form {
                        Section("기본 정보") {
                            Picker("타입", selection: Binding(
                                get: { editing.widgetType },
                                set: { store.send(.setEditingType($0)) }
                            )) {
                                ForEach(["today", "upcoming", "month-mini", "standby-today"], id: \.self) { type in
                                    Text(type)
                                }
                            }
                            Stepper(
                                value: Binding(
                                    get: { editing.maxEventCount },
                                    set: { store.send(.setEditingMax($0)) }
                                ),
                                in: 1...10
                            ) {
                                Text("최대 \(editing.maxEventCount)개")
                            }
                            Toggle(
                                "올데이 포함",
                                isOn: Binding(
                                    get: { editing.showAllDay },
                                    set: { store.send(.toggleEditingAllDay($0)) }
                                )
                            )
                        }
                        
                        Section("캘린더 선택") {
                            if store.availableCalendars.isEmpty {
                                Text("캘린더 정보를 불러오는 중").foregroundStyle(.secondary)
                            } else {
                                ForEach(store.availableCalendars, id: \.id) { calendar in
                                    Toggle(calendar.name, isOn: Binding(
                                        get: { editing.linkedCalendarIDs.contains(calendar.id ?? -1) },
                                        set: { _ in store.send(.toggleEditingCalendar(calendar.id ?? -1)) }
                                    ))
                                }
                            }
                        }
                    }
                    .navigationTitle("위젯 설정")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("저장") { store.send(.saveEdit) }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("닫기") { store.send(.closeEditor) }
                        }
                    }
                }
            }
        }
    }
}
