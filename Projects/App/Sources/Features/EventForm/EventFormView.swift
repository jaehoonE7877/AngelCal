import SwiftUI
import ComposableArchitecture
import DSKit

struct EventFormView: View {
    @Bindable var store: StoreOf<EventFormFeature>
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $store.title)
                        .font(AngelTypography.body())
                }
                
                Section {
                    Toggle("All-day", isOn: $store.isAllDay)
                        .tint(AngelColors.primary)
                    
                    DatePicker("Starts", selection: $store.startDate, displayedComponents: store.isAllDay ? .date : [.date, .hourAndMinute])
                    
                    DatePicker("Ends", selection: $store.endDate, displayedComponents: store.isAllDay ? .date : [.date, .hourAndMinute])
                }
                
                Section {
                    TextField("Location", text: $store.location)
                    TextField("Notes", text: $store.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(store.eventId == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                    .foregroundStyle(AngelColors.accent)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.send(.saveButtonTapped)
                    }
                    .disabled(store.title.isEmpty)
                    .foregroundStyle(store.title.isEmpty ? AngelColors.secondary : AngelColors.primary)
                }
            }
        }
    }
}
