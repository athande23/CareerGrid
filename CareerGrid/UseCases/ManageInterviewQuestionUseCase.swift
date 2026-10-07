import Foundation

struct ManageInterviewQuestionUseCase {
    
    private let repository: CareerGridRepository
    
    init(repository: CareerGridRepository) {
        self.repository = repository
    }
    
    func execute(
        applicationID: UUID,
        question: String,
        exampleAnswer: String,
        category: InterviewQuestionCategory,
        isCustom: Bool = true
    ) throws {
        
        guard try repository.fetchApplication(
            id: applicationID
        ) != nil else {
            throw ManageInterviewQuestionError.applicationNotFound
        }
        
        let trimmedQuestion = question.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedQuestion.isEmpty else {
            throw ManageInterviewQuestionError.emptyQuestion
        }
        
        let trimmedAnswer = exampleAnswer.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedAnswer.isEmpty else {
            throw ManageInterviewQuestionError.emptyExampleAnswer
        }
        
        let interviewQuestion = InterviewQuestionModel(
            question: trimmedQuestion,
            exampleAnswer: trimmedAnswer,
            category: category,
            isCustom: isCustom,
            applicationID: applicationID
        )
        
        try repository.saveInterviewQuestion(interviewQuestion)
    }
}

enum ManageInterviewQuestionError: Error, Equatable {
    case applicationNotFound
    case emptyQuestion
    case emptyExampleAnswer
}
