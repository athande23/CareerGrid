
import Foundation

struct FetchApplicationsUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute() throws -> [JobApplicationModel] {
        try repository.fetchApplications()
    }
}
