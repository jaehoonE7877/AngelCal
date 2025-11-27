import SwiftUI
import ComposableArchitecture
import Core
import DSKit

public struct EventEditView: View {
    @Bindable public var store: StoreOf<EventEditFeature>
    
    public init(store: StoreOf<EventEditFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("제목") {
                    TextField("제목", text: $store.title)
                }
                Section("시간") {
                    Toggle("하루 종일", isOn: $store.allDay)
                    DatePicker("시작", selection: $store.startAt)
                    DatePicker("종료", selection: $store.endAt)
                }
                Section("위치") {
                    TextField("위치", text: $store.location)
                }
                Section("메모") {
                    TextField("메모", text: $store.memo, axis: .vertical)
                }
            }
            .navigationTitle("이벤트 생성")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.cancel) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.save) }
                        .disabled(store.isSaving)
                }
            }
        }
    }
}
