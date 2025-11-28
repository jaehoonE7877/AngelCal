import SwiftUI
import ComposableArchitecture
import DSKit
import Core
import FeatureCalendar
import FeatureSearch
import FeatureSettings

public struct MainView: View {
    @Bindable public var store: StoreOf<MainFeature>
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    public var body: some View {
        TabView(selection: $store.selectedTab) {
            VStack(spacing: 0) {
                Picker("View", selection: $store.viewMode) {
                    Text("월").tag(ViewMode.month)
                    Text("주").tag(ViewMode.week)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(Tokens.Color.background))
                
                CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
            }
            .tabItem { Label("캘린더", systemImage: "calendar") }
            .tag(MainFeature.Tab.calendar)
            
            NavigationStack {
                SearchView(store: store.scope(state: \.search, action: \.search))
                    .navigationTitle("검색")
            }
            .tabItem { Label("검색", systemImage: "magnifyingglass") }
            .tag(MainFeature.Tab.search)
            
            SettingsRootView(store: store.scope(state: \.settings, action: \.settings))
                .tabItem { Label("설정", systemImage: "gear") }
                .tag(MainFeature.Tab.settings)
        }
    }
}
