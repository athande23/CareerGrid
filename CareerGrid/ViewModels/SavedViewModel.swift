import Foundation
import Observation

@Observable
final class SavedViewModel {
    
    private let repository: CareerGridRepository
    private let saveJobOpportunityUseCase: SaveJobOpportunityUseCase
    private let unsaveJobOpportunityUseCase: UnsaveJobOpportunityUseCase
    
    var savedOpportunities: [JobOpportunityModel] = []
    var errorMessage: String?
    var isLoading = false
    
    init(repository: CareerGridRepository) {
        self.repository = repository
        self.saveJobOpportunityUseCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        self.unsaveJobOpportunityUseCase = UnsaveJobOpportunityUseCase(
            repository: repository
        )
    }
    
    func loadSavedOpportunities() {
        isLoading = true
        errorMessage = nil
        
        do {
            savedOpportunities = try repository.fetchSavedOpportunities()
        } catch {
            errorMessage = "Unable to load saved opportunities."
        }
        
        isLoading = false
    }
    
    func removeSavedOpportunity(
        id: UUID
    ) {
        errorMessage = nil
        
        do {
            try unsaveJobOpportunityUseCase.execute(
                opportunityID: id
            )
            
            loadSavedOpportunities()
        } catch let error as UnsaveJobOpportunityError {
            switch error {
            case .opportunityNotFound:
                errorMessage = "This opportunity could not be found."
            case .notSaved:
                errorMessage = "This opportunity is no longer saved."
            }
        } catch {
            errorMessage = "Unable to remove this saved opportunity."
        }
    }
    
    func applyToOpportunity(
        id: UUID
    ) {
        errorMessage = nil
        
        let useCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                opportunityID: id
            )
            
            loadSavedOpportunities()
        } catch let error as ApplyToSavedOpportunityError {
            handleApplyError(error)
        } catch {
            errorMessage = "Unable to apply to this opportunity."
        }
    }
    
    private func handleApplyError(
        _ error: ApplyToSavedOpportunityError
    ) {
        switch error {
        case .opportunityNotFound:
            errorMessage = "This opportunity could not be found."
            
        case .opportunityNotSaved:
            errorMessage = "This opportunity is no longer saved."
            
        case .alreadyApplied:
            errorMessage = "You have already applied to this opportunity."
        }
    }
}
