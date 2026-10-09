
import Foundation

struct FetchJobOpportunitiesUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute() throws -> [JobOpportunityModel] {
        try repository.fetchAllOpportunities()
    }
}
