import Foundation

struct DeleteCalendarEventUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        eventID: UUID
    ) throws {
        
        guard try repository.fetchCalendarEvents().contains(
            where: { $0.id == eventID }
        ) else {
            throw DeleteCalendarEventError.eventNotFound
        }
        
        try repository.deleteCalendarEvent(
            id: eventID
        )
    }
}

enum DeleteCalendarEventError: Error, Equatable {
    case eventNotFound
}
