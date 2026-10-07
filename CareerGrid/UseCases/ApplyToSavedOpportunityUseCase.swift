import Foundation

struct ApplyToSavedOpportunityUseCase {
    
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
            throw ApplyToSavedOpportunityError.opportunityNotFound
        }
        
        guard opportunity.isSaved else {
            throw ApplyToSavedOpportunityError.opportunityNotSaved
        }
        
        let applications = try repository.fetchApplications()
        
        let alreadyApplied = applications.contains {
            $0.opportunity.id == opportunityID &&
            $0.status == .active
        }
        
        guard !alreadyApplied else {
            throw ApplyToSavedOpportunityError.alreadyApplied
        }
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        try repository.createApplication(application)
        
        var updatedOpportunity = opportunity
        updatedOpportunity.isSaved = false
        
        try repository.saveOpportunity(updatedOpportunity)
    }
}

enum ApplyToSavedOpportunityError: Error, Equatable {
    case opportunityNotFound
    case opportunityNotSaved
    case alreadyApplied
}
