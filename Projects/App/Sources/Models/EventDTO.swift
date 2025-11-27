import Foundation

struct EventDTO: Equatable, Identifiable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var url: URL?
    var isAllDay: Bool
    
    init(from event: Event) {
        self.id = event.id
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.location = event.location
        self.notes = event.notes
        self.url = event.url
        self.isAllDay = event.isAllDay
    }
}
