import Foundation

struct TrackJobApplicationUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        opportunityID: UUID,
        applicationDate: Date = Date()
    ) throws {
        
        guard let opportunity = try repository.fetchOpportunity(
            id: opportunityID
        ) else {
            throw TrackJobApplicationError.opportunityNotFound
        }
        
        guard !opportunity.roleTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw TrackJobApplicationError.invalidOpportunity
        }
        
        guard applicationDate <= Date() else {
            throw TrackJobApplicationError.applicationDateInFuture
        }
        
        let applications = try repository.fetchApplications()
        
        let alreadyApplied = applications.contains {
            $0.opportunity.id == opportunityID &&
            $0.status == .active
        }
        
        guard !alreadyApplied else {
            throw TrackJobApplicationError.alreadyApplied
        }
        
        let application = JobApplicationModel(
            opportunity: opportunity,
            applicationDate: applicationDate
        )
        
        try repository.createApplication(application)
    }
}

enum TrackJobApplicationError: Error, Equatable {
    case opportunityNotFound
    case invalidOpportunity
    case applicationDateInFuture
    case alreadyApplied
}
