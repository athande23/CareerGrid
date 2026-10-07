import Foundation
import Observation

@Observable
final class ApplicationsViewModel {
    
    private let repository: CareerGridRepository
    private let advanceStageUseCase: AdvanceApplicationStageUseCase
    private let deleteJobApplicationUseCase: DeleteJobApplicationUseCase
    private let updateApplicationNotesUseCase: UpdateApplicationNotesUseCase
    
    var applications: [JobApplicationModel] = []
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
        } catch {
            errorMessage = "Unable to load applications."
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
}
