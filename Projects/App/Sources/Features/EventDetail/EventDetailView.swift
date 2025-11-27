import SwiftUI
import ComposableArchitecture
import Core
import DSKit

struct EventDetailView: View {
    let store: StoreOf<EventDetailFeature>
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Title") {
                        Text(store.event.title)
                            .font(AngelTypography.body())
                    }
                    
                    LabeledContent("Date") {
                        Text(store.event.startAt, style: .date)
                            .font(AngelTypography.body())
                    }
                    
                    LabeledContent("Time") {
                        if store.event.allDay {
                            Text("All day")
                                .font(AngelTypography.body())
                        } else {
                            Text("\(store.event.startAt, style: .time) - \(store.event.endAt, style: .time)")
                                .font(AngelTypography.body())
                        }
                    }
                }
                
                if let location = store.event.location, !location.isEmpty {
                    Section("Location") {
                        Text(location)
                            .font(AngelTypography.body())
                    }
                }
                
                if let memo = store.event.memo, !memo.isEmpty {
                    Section("Notes") {
                        Text(memo)
                            .font(AngelTypography.body())
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        store.send(.deleteButtonTapped)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Event")
                                .font(AngelTypography.body(.medium))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
