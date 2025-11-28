import ComposableArchitecture
import SwiftUI
import Core

@Reducer
public struct NotificationSettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var settings: NotificationSettings?
        public var isLoading: Bool = false
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case settingsResponse(TaskResult<NotificationSettings?>)
        case setDefaultAlert(Int)
        case toggleDailySummary(Bool)
    }
    
    @Dependency(\.settingsClient) var settingsClient
    @Dependency(\.currentUserID) var currentUserID
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.settingsResponse(TaskResult { try await settingsClient.getNotificationSettings() }))
                }
            case .settingsResponse(.success(let settings)):
                state.isLoading = false
                state.settings = settings ?? NotificationSettings(userID: currentUserID)
                return .none
            case .settingsResponse(.failure):
                state.isLoading = false
                state.settings = NotificationSettings(userID: currentUserID)
                return .none
            case .setDefaultAlert(let offset):
                guard var settings = state.settings else { return .none }
                settings = NotificationSettings(
                    id: settings.id,
                    userID: settings.userID,
                    defaultAlertOffsetMinutes: offset,
                    allDayDefaultAlertOffsetMinutes: settings.allDayDefaultAlertOffsetMinutes,
                    dailySummaryEnabled: settings.dailySummaryEnabled,
                    dailySummaryTimeLocal: settings.dailySummaryTimeLocal,
                    dailySummaryScope: settings.dailySummaryScope,
                    badgeType: settings.badgeType,
                    soundKey: settings.soundKey,
                    createdAt: settings.createdAt,
                    updatedAt: Date()
                )
                state.settings = settings
                let updatedSettings = settings
                return .run { _ in _ = try await settingsClient.updateNotificationSettings(updatedSettings) }
            case .toggleDailySummary(let enabled):
                guard var settings = state.settings else { return .none }
                settings = NotificationSettings(
                    id: settings.id,
                    userID: settings.userID,
                    defaultAlertOffsetMinutes: settings.defaultAlertOffsetMinutes,
                    allDayDefaultAlertOffsetMinutes: settings.allDayDefaultAlertOffsetMinutes,
                    dailySummaryEnabled: enabled,
                    dailySummaryTimeLocal: settings.dailySummaryTimeLocal,
                    dailySummaryScope: settings.dailySummaryScope,
                    badgeType: settings.badgeType,
                    soundKey: settings.soundKey,
                    createdAt: settings.createdAt,
                    updatedAt: Date()
                )
                state.settings = settings
                let updatedSettings = settings
                return .run { _ in _ = try await settingsClient.updateNotificationSettings(updatedSettings) }
            }
        }
    }
}

public struct NotificationSettingsView: View {
    @Bindable public var store: StoreOf<NotificationSettingsFeature>
    
    public init(store: StoreOf<NotificationSettingsFeature>) { self.store = store }
    
    public var body: some View {
        Form {
            if let settings = store.settings {
                Section("기본 알림 시점") {
                    Stepper(value: Binding(
                        get: { settings.defaultAlertOffsetMinutes },
                        set: { store.send(.setDefaultAlert($0)) }
                    ), in: -240...0, step: 5) {
                        Text("\(settings.defaultAlertOffsetMinutes)분 전에 알림")
                    }
                }
                Section("데일리 요약") {
                    Toggle("활성화", isOn: Binding(
                        get: { settings.dailySummaryEnabled },
                        set: { store.send(.toggleDailySummary($0)) }
                    ))
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("알림")
        .task { await store.send(.onAppear).finish() }
    }
}
