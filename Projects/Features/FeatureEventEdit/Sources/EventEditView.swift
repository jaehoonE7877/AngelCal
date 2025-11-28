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
                calendarSection
                titleSection
                timeSection
                locationSection
                memoSection
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
        .onAppear { store.send(.onAppear) }
        .alert(
            store: store.scope(state: \.$alert, action: \.alert)
        )
    }

    private var calendarSection: some View {
        Section("캘린더") {
            Picker("캘린더 선택", selection: Binding(
                get: { store.selectedCalendarID },
                set: { store.send(.setCalendar($0)) }
            )) {
                ForEach(store.availableCalendars, id: \.id) { calendar in
                    Text(calendar.name).tag(calendar.id as Int64?)
                }
            }
        }
    }

    private var titleSection: some View {
        Section("제목") {
            TextField("제목", text: Binding(
                get: { store.title },
                set: { store.send(.setTitle($0)) }
            ))
        }
    }

    private var timeSection: some View {
        Section("시간") {
            Toggle("하루 종일", isOn: Binding(
                get: { store.allDay },
                set: { store.send(.setAllDay($0)) }
            ))
            DatePicker("시작", selection: Binding(
                get: { store.startAt },
                set: { store.send(.setStart($0)) }
            ))
            DatePicker("종료", selection: Binding(
                get: { store.endAt },
                set: { store.send(.setEnd($0)) }
            ))
        }
    }

    private var locationSection: some View {
        Section("위치") {
            TextField("위치", text: Binding(
                get: { store.location },
                set: { store.send(.setLocation($0)) }
            ))
        }
    }

    private var memoSection: some View {
        Section("메모") {
            TextField("메모", text: Binding(
                get: { store.memo },
                set: { store.send(.setMemo($0)) }
            ), axis: .vertical)
        }
    }
}
