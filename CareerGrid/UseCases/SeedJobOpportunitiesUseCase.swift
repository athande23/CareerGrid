
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

        let existingByID = Dictionary(
            uniqueKeysWithValues: existingOpportunities.map {
                ($0.id, $0)
            }
        )

        for seed in opportunities {
            guard let existing = existingByID[seed.id] else {
                try repository.saveOpportunity(seed)
                continue
            }
            guard existing.degreeRequirement != seed.degreeRequirement else {
                continue
            }

            var updated = existing
            updated.degreeRequirement = seed.degreeRequirement

            try repository.saveOpportunity(updated)
        }
    }
}
