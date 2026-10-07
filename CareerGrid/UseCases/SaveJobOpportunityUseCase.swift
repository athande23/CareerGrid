import Foundation

struct SaveJobOpportunityUseCase {
    
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
            throw SaveJobOpportunityError.opportunityNotFound
        }
        
        guard !opportunity.isSaved else {
            throw SaveJobOpportunityError.alreadySaved
        }
        
        guard !opportunity.roleTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw SaveJobOpportunityError.invalidRoleTitle
        }
        
        var updatedOpportunity = opportunity
        updatedOpportunity.isSaved = true
        
        try repository.saveOpportunity(updatedOpportunity)
    }
}

enum SaveJobOpportunityError: Error, Equatable {
    case opportunityNotFound
    case alreadySaved
    case invalidRoleTitle
}
