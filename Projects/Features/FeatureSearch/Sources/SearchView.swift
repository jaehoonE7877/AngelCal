import SwiftUI
import ComposableArchitecture
import Core

public struct SearchView: View {
    @Bindable public var store: StoreOf<SearchFeature>
    
    public init(store: StoreOf<SearchFeature>) { self.store = store }
    
    public var body: some View {
        VStack {
            TextField("검색", text: $store.query)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button("검색") { store.send(.search) }
            List(store.results, id: \.
self.id) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                    Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
