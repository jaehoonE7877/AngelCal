import SwiftUI
import ComposableArchitecture
import DSKit
import Core

public struct MainView: View {
    @Bindable public var store: StoreOf<MainFeature>
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $store.viewMode) {
                Text("월").tag(ViewMode.month)
                Text("주").tag(ViewMode.week)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(Tokens.Color.background))
            
            CalendarView(store: store.scope(state: \.
calendar, action: \.calendar))
        }
    }
}
