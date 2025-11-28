import SwiftUI
import ComposableArchitecture

public struct TemplateEditView: View {
    @Bindable public var store: StoreOf<TemplateEditFeature>
    
    public init(store: StoreOf<TemplateEditFeature>) { self.store = store }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("제목") {
                    TextField("템플릿 이름", text: $store.title)
                }
                Section("기본 설정") {
                    Stepper(value: $store.durationMinutes, in: 5...240, step: 5) {
                        Text("기본 지속시간 \(Int(store.durationMinutes))분")
                    }
                    TextField("알림 분(콤마로 구분, 예: -10,-30)", text: $store.alertText)
                }
                Section("기본 값") {
                    TextField("위치", text: $store.location)
                    TextField("메모", text: $store.memo, axis: .vertical)
                }
            }
            .navigationTitle("템플릿 편집")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { store.send(.cancel) } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.save) }
                        .disabled(store.isSaving || store.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
