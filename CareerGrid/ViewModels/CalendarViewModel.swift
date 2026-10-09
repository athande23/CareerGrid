import Foundation
import Observation

@Observable
final class CalendarViewModel {
    
    private let repository: CareerGridRepository
    private let manageCalendarEventUseCase: ManageCalendarEventUseCase
    private let updateCalendarEventUseCase: UpdateCalendarEventUseCase
    private let deleteCalendarEventUseCase: DeleteCalendarEventUseCase
    
    var events: [CalendarEventModel] = []
    var errorMessage: String?
    var isLoading = false
    
    init(repository: CareerGridRepository) {
        self.repository = repository
        
        self.manageCalendarEventUseCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        self.updateCalendarEventUseCase = UpdateCalendarEventUseCase(
            repository: repository
        )
        
        self.deleteCalendarEventUseCase = DeleteCalendarEventUseCase(
            repository: repository
        )
    }
    
    func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try repository.fetchCalendarEvents()
        } catch {
            errorMessage = "Unable to load calendar events."
        }
        
        isLoading = false
    }
    
    func addEvent(
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String?,
        opportunityID: UUID? = nil,
        applicationID: UUID? = nil
    ) {
        errorMessage = nil
        
        do {
            try manageCalendarEventUseCase.execute(
                title: title,
                date: date,
                eventType: eventType,
                notes: notes,
                opportunityID: opportunityID,
                applicationID: applicationID
            )
            
            loadEvents()
        } catch let error as ManageCalendarEventError {
            handleManageError(error)
        } catch {
            errorMessage = "Unable to add this event."
        }
    }
    
    func updateEvent(
        id: UUID,
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String?,
        opportunityID: UUID?,
        applicationID: UUID?
    ) {
        errorMessage = nil
        
        let event = CalendarEventModel(
            id: id,
            title: title,
            date: date,
            eventType: eventType,
            notes: notes,
            opportunityID: opportunityID,
            applicationID: applicationID
        )
        
        do {
            try updateCalendarEventUseCase.execute(
                event
            )
            
            loadEvents()
        } catch let error as UpdateCalendarEventError {
            handleUpdateError(error)
        } catch {
            errorMessage = "Unable to update this event."
        }
    }
    
    func deleteEvent(id: UUID) {
        errorMessage = nil
        
        do {
            try deleteCalendarEventUseCase.execute(
                eventID: id
            )
            
            loadEvents()
        } catch let error as DeleteCalendarEventError {
            switch error {
            case .eventNotFound:
                errorMessage = "This event could not be found."
            }
        } catch {
            errorMessage = "Unable to delete this event."
        }
    }
    
    private func handleManageError(
        _ error: ManageCalendarEventError
    ) {
        switch error {
        case .emptyTitle:
            errorMessage = "Enter an event title."
        default:
            errorMessage = "Unable to add this event."
        }
    }

    private func handleUpdateError(
        _ error: UpdateCalendarEventError
    ) {
        switch error {
        case .eventNotFound:
            errorMessage = "This event could not be found."
        case .emptyTitle:
            errorMessage = "Enter an event title."
        default:
            errorMessage = "Unable to update this event."
        }
    }
}
