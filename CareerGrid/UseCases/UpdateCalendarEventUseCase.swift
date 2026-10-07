import Foundation

struct UpdateCalendarEventUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        _ event: CalendarEventModel
    ) throws {
        
        let trimmedTitle = event.title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedTitle.isEmpty else {
            throw UpdateCalendarEventError.emptyTitle
        }
        
        guard event.opportunityID != nil ||
              event.applicationID != nil else {
            throw UpdateCalendarEventError.noRelatedJob
        }
        
        guard try repository.fetchCalendarEvents().contains(
            where: { $0.id == event.id }
        ) else {
            throw UpdateCalendarEventError.eventNotFound
        }
        
        if let opportunityID = event.opportunityID {
            guard try repository.fetchOpportunity(
                id: opportunityID
            ) != nil else {
                throw UpdateCalendarEventError.opportunityNotFound
            }
        }
        
        if let applicationID = event.applicationID {
            guard try repository.fetchApplication(
                id: applicationID
            ) != nil else {
                throw UpdateCalendarEventError.applicationNotFound
            }
        }
        
        var updatedEvent = event
        updatedEvent.title = trimmedTitle
        
        try repository.updateCalendarEvent(updatedEvent)
    }
}

enum UpdateCalendarEventError: Error, Equatable {
    case eventNotFound
    case emptyTitle
    case noRelatedJob
    case opportunityNotFound
    case applicationNotFound
}
