
import Foundation

struct UnsaveJobOpportunityUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(opportunityID: UUID) throws {
        guard var opportunity = try repository.fetchOpportunity(
            id: opportunityID
        ) else {
            throw UnsaveJobOpportunityError.opportunityNotFound
        }

        guard opportunity.isSaved else {
            throw UnsaveJobOpportunityError.notSaved
        }

        opportunity.isSaved = false
        try repository.saveOpportunity(opportunity)
    }
}

enum UnsaveJobOpportunityError: Error, Equatable {
    case opportunityNotFound
    case notSaved
}
