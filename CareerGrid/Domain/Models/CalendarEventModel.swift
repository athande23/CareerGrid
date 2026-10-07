import Foundation

struct CalendarEventModel: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var eventType: CalendarEventType
    var notes: String?
    var opportunityID: UUID?
    var applicationID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String? = nil,
        opportunityID: UUID? = nil,
        applicationID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.eventType = eventType
        self.notes = notes
        self.opportunityID = opportunityID
        self.applicationID = applicationID
    }
}
