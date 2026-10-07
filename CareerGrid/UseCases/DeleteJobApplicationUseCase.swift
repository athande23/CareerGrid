import Foundation

struct DeleteJobApplicationUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        applicationID: UUID
    ) throws {
        
        guard let application = try repository.fetchApplication(
            id: applicationID
        ) else {
            throw DeleteJobApplicationError.applicationNotFound
        }
        
        try repository.deleteApplication(
            id: application.id
        )
    }
}

enum DeleteJobApplicationError: Error, Equatable {
    case applicationNotFound
}
