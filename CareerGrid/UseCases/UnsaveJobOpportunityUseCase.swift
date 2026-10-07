import Foundation

struct UnsaveJobOpportunityUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        opportunityID: UUID
    ) throws {
        
        guard let opportunity = try repository.fetchOpportunity(
            id: opportunityID
        ) else {
            throw UnsaveJobOpportunityError.opportunityNotFound
        }
        
        guard opportunity.isSaved else {
            throw UnsaveJobOpportunityError.notSaved
        }
        
        var updatedOpportunity = opportunity
        updatedOpportunity.isSaved = false
        
        try repository.saveOpportunity(updatedOpportunity)
    }
}

enum UnsaveJobOpportunityError: Error, Equatable {
    case opportunityNotFound
    case notSaved
}
