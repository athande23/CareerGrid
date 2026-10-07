import Foundation

struct ManageCalendarEventUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String? = nil,
        opportunityID: UUID? = nil,
        applicationID: UUID? = nil
    ) throws {
        
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedTitle.isEmpty else {
            throw ManageCalendarEventError.emptyTitle
        }
        
        guard opportunityID != nil || applicationID != nil else {
            throw ManageCalendarEventError.noRelatedJob
        }
        
        if let opportunityID {
            guard try repository.fetchOpportunity(
                id: opportunityID
            ) != nil else {
                throw ManageCalendarEventError.opportunityNotFound
            }
        }
        
        if let applicationID {
            guard try repository.fetchApplication(
                id: applicationID
            ) != nil else {
                throw ManageCalendarEventError.applicationNotFound
            }
        }
        
        let event = CalendarEventModel(
            title: trimmedTitle,
            date: date,
            eventType: eventType,
            notes: notes,
            opportunityID: opportunityID,
            applicationID: applicationID
        )
        
        try repository.saveCalendarEvent(event)
    }
}

enum ManageCalendarEventError: Error, Equatable {
    case emptyTitle
    case noRelatedJob
    case opportunityNotFound
    case applicationNotFound
}
