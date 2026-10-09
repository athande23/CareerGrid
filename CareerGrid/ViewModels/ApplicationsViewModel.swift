import Foundation
import Observation

@Observable
final class ApplicationsViewModel {
    
    private let repository: CareerGridRepository
    private let advanceStageUseCase: AdvanceApplicationStageUseCase
    private let deleteJobApplicationUseCase: DeleteJobApplicationUseCase
    private let updateApplicationNotesUseCase: UpdateApplicationNotesUseCase
    
    var applications: [JobApplicationModel] = []
    var calendarEvents: [CalendarEventModel] = []
    var errorMessage: String?
    var isLoading = false
    
    init(repository: CareerGridRepository) {
        self.repository = repository
        self.advanceStageUseCase = AdvanceApplicationStageUseCase(
            repository: repository
        )
        self.deleteJobApplicationUseCase = DeleteJobApplicationUseCase(
            repository: repository
        )

        self.updateApplicationNotesUseCase = UpdateApplicationNotesUseCase(
            repository: repository
        )
    }
    
    func loadApplications() {
        isLoading = true
        errorMessage = nil

        do {
            applications = try repository.fetchApplications()
            calendarEvents = try repository.fetchCalendarEvents()
        } catch {
            errorMessage = "Unable to load applications or calendar events."
        }

        isLoading = false
    }
    
    func moveStageForward(
        id: UUID
    ) {
        updateStage(
            id: id,
            direction: .forward
        )
    }
    
    func moveStageBackward(
        id: UUID
    ) {
        updateStage(
            id: id,
            direction: .backward
        )
    }
    
    func deleteApplication(
        id: UUID
    ) {
        errorMessage = nil
        
        do {
            try deleteJobApplicationUseCase.execute(
                applicationID: id
            )
            
            loadApplications()
        } catch let error as DeleteJobApplicationError {
            switch error {
            case .applicationNotFound:
                errorMessage = "This application could not be found."
            }
        } catch {
            errorMessage = "Unable to delete this application."
        }
    }
    
    func updateNotes(
        id: UUID,
        notes: String?
    ) {
        errorMessage = nil
        
        do {
            try updateApplicationNotesUseCase.execute(
                applicationID: id,
                notes: notes
            )
            
            loadApplications()
        } catch let error as UpdateApplicationNotesError {
            switch error {
            case .applicationNotFound:
                errorMessage = "This application could not be found."
            }
        } catch {
            errorMessage = "Unable to update application notes."
        }
    }
    
    private func updateStage(
        id: UUID,
        direction: StageDirection
    ) {
        errorMessage = nil
        
        do {
            try advanceStageUseCase.execute(
                applicationID: id,
                direction: direction
            )
            
            loadApplications()
        } catch let error as AdvanceApplicationStageError {
            handleStageError(error)
        } catch {
            errorMessage = "Unable to update application stage."
        }
    }
    
    private func handleStageError(
        _ error: AdvanceApplicationStageError
    ) {
        switch error {
        case .applicationNotFound:
            errorMessage = "This application could not be found."
            
        case .applicationNotActive:
            errorMessage = "This application is no longer active."
            
        case .rejectedApplication:
            errorMessage = "A rejected application cannot change stage."
            
        case .invalidStage:
            errorMessage = "This application has an invalid stage."
            
        case .invalidStageTransition:
            errorMessage = "The application cannot move further in that direction."
        }
    }
    
    func stageDateEvent(
        applicationID: UUID,
        eventType: CalendarEventType
    ) -> CalendarEventModel? {
        calendarEvents.first {
            $0.applicationID == applicationID &&
            $0.eventType == eventType
        }
    }

    func setStageDate(
        applicationID: UUID,
        eventType: CalendarEventType,
        date: Date
    ) {
        errorMessage = nil

        do {
            guard let application = try repository.fetchApplication(
                id: applicationID
            ) else {
                errorMessage = "This application could not be found."
                return
            }

            // Only allow a date for the application's current stage.
            let expectedType: CalendarEventType

            switch application.currentStage {
            case .onlineAssessment:
                expectedType = .onlineAssessment
            case .interview:
                expectedType = .interview
            case .finalInterview:
                expectedType = .finalInterview
            default:
                errorMessage = "This stage does not have a date field."
                return
            }

            guard eventType == expectedType else {
                errorMessage = "This date does not match the current stage."
                return
            }

            let title: String

            switch eventType {
            case .onlineAssessment:
                title = "OA: \(application.opportunity.roleTitle) at \(application.opportunity.company.name)"
            case .interview:
                title = "Interview: \(application.opportunity.roleTitle) at \(application.opportunity.company.name)"
            case .finalInterview:
                title = "Final Interview: \(application.opportunity.roleTitle) at \(application.opportunity.company.name)"
            default:
                errorMessage = "This event type is not supported here."
                return
            }

            let persistedEvents = try repository.fetchCalendarEvents()

            if let existingEvent = persistedEvents.first(where: {
                $0.applicationID == applicationID &&
                $0.eventType == eventType
            }) {
                let updatedEvent = CalendarEventModel(
                    id: existingEvent.id,
                    title: title,
                    date: date,
                    eventType: eventType,
                    notes: existingEvent.notes,
                    opportunityID: application.opportunity.id,
                    applicationID: applicationID
                )

                try repository.updateCalendarEvent(updatedEvent)
            } else {
                let event = CalendarEventModel(
                    title: title,
                    date: date,
                    eventType: eventType,
                    opportunityID: application.opportunity.id,
                    applicationID: applicationID
                )

                try repository.saveCalendarEvent(event)
            }

            calendarEvents = try repository.fetchCalendarEvents()

        } catch {
            errorMessage = "Unable to save this stage date."
        }
    }

    func clearStageDate(
        applicationID: UUID,
        eventType: CalendarEventType
    ) {
        errorMessage = nil

        do {
            if let event = stageDateEvent(
                applicationID: applicationID,
                eventType: eventType
            ) {
                try repository.deleteCalendarEvent(id: event.id)
                calendarEvents = try repository.fetchCalendarEvents()
            }
        } catch {
            errorMessage = "Unable to remove this stage date."
        }
    }
}
