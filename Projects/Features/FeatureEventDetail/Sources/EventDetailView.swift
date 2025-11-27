import SwiftUI
import ComposableArchitecture
import Core

public struct EventDetailView: View {
    @Bindable public var store: StoreOf<EventDetailFeature>
    
    public init(store: StoreOf<EventDetailFeature>) { self.store = store }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.event.title).font(.title2).bold()
            Text(store.event.startAt.formatted(date: .abbreviated, time: .shortened))
            if let loc = store.event.location { Text(loc).font(.subheadline) }
            if let memo = store.event.memo { Text(memo).font(.body) }
            Spacer()
            HStack {
                Button("삭제") { store.send(.delete) }.foregroundStyle(.red)
                Spacer()
                Button("복사") { store.send(.copyToDate(Date())) }
            }
        }
        .padding()
    }
}
