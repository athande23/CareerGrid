import Foundation

struct FetchApplicationUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws -> JobApplicationModel? {
        try repository.fetchApplication(id: id)
    }
}
