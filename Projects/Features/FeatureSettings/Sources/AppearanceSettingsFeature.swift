import ComposableArchitecture
import SwiftUI
import Core

@Reducer
public struct AppearanceSettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var settings: AppearanceSettings?
        public var isLoading: Bool = false
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case settingsResponse(TaskResult<AppearanceSettings?>)
        case setStartOfWeek(String)
        case setTextScale(Double)
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
                    await send(.settingsResponse(TaskResult { try await settingsClient.getAppearanceSettings() }))
                }
            case .settingsResponse(.success(let settings)):
                state.isLoading = false
                state.settings = settings ?? AppearanceSettings(userID: currentUserID)
                return .none
            case .settingsResponse(.failure):
                state.isLoading = false
                state.settings = AppearanceSettings(userID: currentUserID)
                return .none
            case .setStartOfWeek(let value):
                guard var settings = state.settings else { return .none }
                settings = AppearanceSettings(
                    id: settings.id,
                    userID: settings.userID,
                    startOfWeek: value,
                    highlightHolidays: settings.highlightHolidays,
                    colorThemeKey: settings.colorThemeKey,
                    fontKey: settings.fontKey,
                    textScale: settings.textScale,
                    showEventColors: settings.showEventColors,
                    showWeekNumber: settings.showWeekNumber,
                    showHolidayName: settings.showHolidayName,
                    is24h: settings.is24h,
                    enableLunar: settings.enableLunar,
                    languageOverride: settings.languageOverride,
                    createdAt: settings.createdAt,
                    updatedAt: Date()
                )
                state.settings = settings
                let updatedSettings = settings
                return .run { _ in _ = try await settingsClient.updateAppearanceSettings(updatedSettings) }
            case .setTextScale(let value):
                guard var settings = state.settings else { return .none }
                settings = AppearanceSettings(
                    id: settings.id,
                    userID: settings.userID,
                    startOfWeek: settings.startOfWeek,
                    highlightHolidays: settings.highlightHolidays,
                    colorThemeKey: settings.colorThemeKey,
                    fontKey: settings.fontKey,
                    textScale: value,
                    showEventColors: settings.showEventColors,
                    showWeekNumber: settings.showWeekNumber,
                    showHolidayName: settings.showHolidayName,
                    is24h: settings.is24h,
                    enableLunar: settings.enableLunar,
                    languageOverride: settings.languageOverride,
                    createdAt: settings.createdAt,
                    updatedAt: Date()
                )
                state.settings = settings
                let updatedSettings = settings
                return .run { _ in _ = try await settingsClient.updateAppearanceSettings(updatedSettings) }
            }
        }
    }
}

public struct AppearanceSettingsView: View {
    @Bindable public var store: StoreOf<AppearanceSettingsFeature>
    
    public init(store: StoreOf<AppearanceSettingsFeature>) { self.store = store }
    
    public var body: some View {
        Form {
            if let settings = store.settings {
                Section("주 시작 요일") {
                    Picker("시작 요일", selection: Binding(
                        get: { settings.startOfWeek },
                        set: { store.send(.setStartOfWeek($0)) }
                    )) {
                        Text("월요일").tag("monday")
                        Text("일요일").tag("sunday")
                    }
                    .pickerStyle(.segmented)
                }
                Section("텍스트 크기") {
                    Slider(
                        value: Binding(
                            get: { settings.textScale },
                            set: { store.send(.setTextScale($0)) }
                        ),
                        in: 0.8...1.4
                    )
                    Text("배율: \(String(format: "%.2f", settings.textScale))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("외관")
        .task { await store.send(.onAppear).finish() }
    }
}
