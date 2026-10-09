
import Foundation

struct SeedJobOpportunitiesUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(
        opportunities: [JobOpportunityModel]
    ) throws {
        let existingOpportunities = try repository.fetchAllOpportunities()
        var existingIDs = Set(existingOpportunities.map(\.id))

        for opportunity in opportunities {
            guard existingIDs.insert(opportunity.id).inserted else {
                continue
            }

            try repository.saveOpportunity(opportunity)
        }
    }
}
