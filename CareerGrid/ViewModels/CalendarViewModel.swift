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
        notes: String? = nil,
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
            handleCalendarError(error)
        } catch {
            errorMessage = "Unable to add calendar event."
        }
    }
    
    func updateEvent(
        _ event: CalendarEventModel
    ) {
        errorMessage = nil
        
        do {
            try updateCalendarEventUseCase.execute(event)
            loadEvents()
        } catch let error as UpdateCalendarEventError {
            switch error {
            case .eventNotFound:
                errorMessage = "This calendar event could not be found."
                
            case .emptyTitle:
                errorMessage = "Enter an event title."
                
            case .noRelatedJob:
                errorMessage = "Link the event to a job or application."
                
            case .opportunityNotFound:
                errorMessage = "The linked job opportunity could not be found."
                
            case .applicationNotFound:
                errorMessage = "The linked application could not be found."
            }
        } catch {
            errorMessage = "Unable to update calendar event."
        }
    }
    
    func deleteEvent(
        id: UUID
    ) {
        errorMessage = nil
        
        do {
            try deleteCalendarEventUseCase.execute(
                eventID: id
            )
            
            loadEvents()
        } catch let error as DeleteCalendarEventError {
            switch error {
            case .eventNotFound:
                errorMessage = "This calendar event could not be found."
            }
        } catch {
            errorMessage = "Unable to delete calendar event."
        }
    }
    
    private func handleCalendarError(
        _ error: ManageCalendarEventError
    ) {
        switch error {
        case .emptyTitle:
            errorMessage = "Enter an event title."
            
        case .noRelatedJob:
            errorMessage = "Link the event to a job or application."
            
        case .opportunityNotFound:
            errorMessage = "The linked job opportunity could not be found."
            
        case .applicationNotFound:
            errorMessage = "The linked application could not be found."
        }
    }
}
