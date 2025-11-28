import SwiftUI
import ComposableArchitecture
import Core

public struct TemplateListView: View {
    @Bindable public var store: StoreOf<TemplateListFeature>
    public var onUse: ((EventTemplate) -> Void)?
    
    public init(store: StoreOf<TemplateListFeature>, onUse: ((EventTemplate) -> Void)? = nil) {
        self.store = store
        self.onUse = onUse
    }
    
    public var body: some View {
        List {
            ForEach(store.templates, id: \.id) { template in
                VStack(alignment: .leading) {
                    Text(template.title).bold()
                    if let memo = template.defaultMemo { Text(memo).font(.footnote).foregroundStyle(.secondary) }
                    HStack {
                        Text("기본 \(template.defaultDurationMinutes)분")
                        if let loc = template.defaultLocation { Text(loc).foregroundStyle(.secondary) }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onUse?(template)
                    store.send(.useTemplate(template))
                }
            }
            .onDelete { store.send(.delete($0)) }
            .onMove { store.send(.move($0, $1)) }
        }
        .navigationTitle("템플릿")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { store.send(.addButtonTapped) }) { Image(systemName: "plus") }
            }
            ToolbarItem(placement: .navigationBarLeading) { EditButton() }
        }
        .task { await store.send(.onAppear).finish() }
        .sheet(
            store: store.scope(state: \.$editor, action: \.editor)
        ) { editStore in
            TemplateEditView(store: editStore)
        }
    }
}
