import SwiftUI
import ComposableArchitecture
import Core

public struct DayListView: View {
    @Bindable public var store: StoreOf<DayListFeature>
    
    public init(store: StoreOf<DayListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        List(store.events, id: \.
self.id) { event in
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title).bold()
                Text("\(event.startAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.plain)
    }
}
