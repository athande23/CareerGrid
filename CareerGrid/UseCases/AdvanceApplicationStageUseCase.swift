import Foundation

struct AdvanceApplicationStageUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        applicationID: UUID,
        direction: StageDirection
    ) throws {
        
        guard let application = try repository.fetchApplication(
            id: applicationID
        ) else {
            throw AdvanceApplicationStageError.applicationNotFound
        }
        
        guard application.status == .active else {
            throw AdvanceApplicationStageError.applicationNotActive
        }
        
        guard application.currentStage != .rejected else {
            throw AdvanceApplicationStageError.rejectedApplication
        }
        
        let stages: [ApplicationStage] = [
            .applied,
            .onlineAssessment,
            .interview,
            .finalInterview,
            .decision,
            .offer
        ]
        
        guard let currentIndex = stages.firstIndex(
            of: application.currentStage
        ) else {
            throw AdvanceApplicationStageError.invalidStage
        }
        
        let newIndex: Int
        
        switch direction {
        case .forward:
            newIndex = currentIndex + 1
            
        case .backward:
            newIndex = currentIndex - 1
        }
        
        guard stages.indices.contains(newIndex) else {
            throw AdvanceApplicationStageError.invalidStageTransition
        }
        
        try repository.updateApplicationStage(
            id: applicationID,
            stage: stages[newIndex]
        )
    }
}

enum StageDirection {
    case forward
    case backward
}

enum AdvanceApplicationStageError: Error, Equatable {
    case applicationNotFound
    case applicationNotActive
    case rejectedApplication
    case invalidStage
    case invalidStageTransition
}
