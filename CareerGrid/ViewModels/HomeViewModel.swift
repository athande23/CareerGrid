import Foundation
import Observation

@Observable
final class HomeViewModel {
    
    private let repository: CareerGridRepository
    private let saveJobOpportunityUseCase: SaveJobOpportunityUseCase
    
    var opportunities: [JobOpportunityModel] = []
    var errorMessage: String?
    var isLoading = false
    
    init(repository: CareerGridRepository) {
        self.repository = repository
        self.saveJobOpportunityUseCase = SaveJobOpportunityUseCase(
            repository: repository
        )
    }
    
    func loadOpportunities() {
        isLoading = true
        errorMessage = nil
        
        do {
            opportunities = try repository.fetchAvailableOpportunities()
        } catch {
            errorMessage = "Unable to load job opportunities."
        }
        
        isLoading = false
    }
    
    func saveOpportunity(
        id: UUID
    ) {
        errorMessage = nil
        
        do {
            try saveJobOpportunityUseCase.execute(
                opportunityID: id
            )
            
            loadOpportunities()
        } catch let error as SaveJobOpportunityError {
            handleSaveError(error)
        } catch {
            errorMessage = "Unable to save this opportunity."
        }
    }
    
    private func handleSaveError(
        _ error: SaveJobOpportunityError
    ) {
        switch error {
        case .opportunityNotFound:
            errorMessage = "This opportunity could not be found."
            
        case .alreadySaved:
            errorMessage = "This opportunity is already saved."
            
        case .invalidRoleTitle:
            errorMessage = "This opportunity has an invalid role title."
        }
    }
}
