import ComposableArchitecture
import SwiftUI
import Core
import FeatureTemplate

@Reducer
public struct SettingsRootFeature {
    @ObservableState
    public struct State: Equatable {
        public var calendarSettings: CalendarSettingsFeature.State = .init()
        public var appearanceSettings: AppearanceSettingsFeature.State = .init()
        public var notificationSettings: NotificationSettingsFeature.State = .init()
        public var widgetGuide: WidgetGuideFeature.State = .init()
        public var account: AccountSettingsFeature.State = .init()
        public var templateList: TemplateListFeature.State = .init()
        public var isSyncing: Bool = false
        public var lastSyncError: String?
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case calendarSettings(CalendarSettingsFeature.Action)
        case appearanceSettings(AppearanceSettingsFeature.Action)
        case notificationSettings(NotificationSettingsFeature.Action)
        case widgetGuide(WidgetGuideFeature.Action)
        case account(AccountSettingsFeature.Action)
        case templateList(TemplateListFeature.Action)
        case syncNow
        case syncCompleted(TaskResult<Void>)
    }
    
    @Dependency(\.syncClient) var syncClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.calendarSettings, action: \.calendarSettings) {
            CalendarSettingsFeature()
        }
        Scope(state: \.appearanceSettings, action: \.appearanceSettings) {
            AppearanceSettingsFeature()
        }
        Scope(state: \.notificationSettings, action: \.notificationSettings) {
            NotificationSettingsFeature()
        }
        Scope(state: \.widgetGuide, action: \.widgetGuide) {
            WidgetGuideFeature()
        }
        Scope(state: \.account, action: \.account) {
            AccountSettingsFeature()
        }
        Scope(state: \.templateList, action: \.templateList) {
            TemplateListFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.calendarSettings(.onAppear)),
                    .send(.appearanceSettings(.onAppear)),
                    .send(.notificationSettings(.onAppear)),
                    .send(.widgetGuide(.onAppear)),
                    .send(.templateList(.onAppear))
                )
            case .calendarSettings, .appearanceSettings, .notificationSettings, .widgetGuide, .account, .templateList:
                return .none
            case .syncNow:
                state.isSyncing = true
                state.lastSyncError = nil
                return .run { send in
                    await send(.syncCompleted(TaskResult { try await syncClient.syncAll() }))
                }
            case .syncCompleted(.success):
                state.isSyncing = false
                state.lastSyncError = nil
                return .none
            case .syncCompleted(.failure(let error)):
                state.isSyncing = false
                state.lastSyncError = error.localizedDescription
                return .none
            }
        }
    }
}

public struct SettingsRootView: View {
    @Bindable public var store: StoreOf<SettingsRootFeature>
    
    public init(store: StoreOf<SettingsRootFeature>) { self.store = store }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("동기화 상태")
                            if let error = store.lastSyncError {
                                Text(error).font(.footnote).foregroundStyle(.red)
                            } else if store.isSyncing {
                                Text("동기화 중...").font(.footnote).foregroundStyle(.secondary)
                            } else {
                                Text("정상").font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button("다시 동기화") { store.send(.syncNow) }
                            .disabled(store.isSyncing)
                    }
                }
                Section {
                    NavigationLink("캘린더", destination: {
                        CalendarSettingsView(store: store.scope(state: \.calendarSettings, action: \.calendarSettings))
                    })
                    NavigationLink("외관", destination: {
                        AppearanceSettingsView(store: store.scope(state: \.appearanceSettings, action: \.appearanceSettings))
                    })
                    NavigationLink("알림", destination: {
                        NotificationSettingsView(store: store.scope(state: \.notificationSettings, action: \.notificationSettings))
                    })
                    NavigationLink("위젯", destination: {
                        WidgetGuideView(store: store.scope(state: \.widgetGuide, action: \.widgetGuide))
                    })
                    NavigationLink("템플릿", destination: {
                        TemplateListView(store: store.scope(state: \.templateList, action: \.templateList))
                    })
                    NavigationLink("계정", destination: {
                        AccountSettingsView(store: store.scope(state: \.account, action: \.account))
                    })
                }
            }
            .navigationTitle("설정")
        }
        .task { await store.send(.onAppear).finish() }
    }
}
