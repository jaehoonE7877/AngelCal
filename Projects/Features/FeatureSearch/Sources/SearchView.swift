import SwiftUI
import ComposableArchitecture
import Core

public struct SearchView: View {
    @Bindable public var store: StoreOf<SearchFeature>
    
    public init(store: StoreOf<SearchFeature>) { self.store = store }
    
    public var body: some View {
        VStack {
            TextField(
                "검색",
                text: Binding(
                    get: { store.query },
                    set: { store.send(.setQuery($0)) }
                )
            )
                .textFieldStyle(.roundedBorder)
                .padding()
            Picker(
                "정렬",
                selection: Binding(
                    get: { store.sort },
                    set: { store.send(.setSort($0)) }
                )
            ) {
                Text("빠른 순").tag(SearchFeature.Sort.startAscending)
                Text("늦은 순").tag(SearchFeature.Sort.startDescending)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Button("검색") { store.send(.search) }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 8)
            
            List(store.results, id: \.id) { event in
                Button {
                    store.send(.select(event))
                } label: {
                    VStack(alignment: .leading) {
                        Text(event.title).foregroundStyle(.primary)
                        Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { store.selectedEvent != nil },
            set: { if !$0 { store.send(.dismissDetail) } }
        )) {
            if let event = store.selectedEvent {
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.title).font(.title2).bold()
                    Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                    if let memo = event.memo { Text(memo) }
                    Spacer()
                }
                .padding()
            }
        }
    }
}
