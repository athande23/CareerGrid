import Foundation

struct UpdateApplicationNotesUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        applicationID: UUID,
        notes: String?
    ) throws {
        
        guard try repository.fetchApplication(
            id: applicationID
        ) != nil else {
            throw UpdateApplicationNotesError.applicationNotFound
        }
        
        let trimmedNotes = notes?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        try repository.updateApplicationNotes(
            id: applicationID,
            notes: trimmedNotes?.isEmpty == true
                ? nil
                : trimmedNotes
        )
    }
}

enum UpdateApplicationNotesError: Error, Equatable {
    case applicationNotFound
}
