import Foundation

struct FetchInterviewQuestionsUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(for applicationID: UUID) throws
        -> [InterviewQuestionModel] {
        try repository.fetchInterviewQuestions(for: applicationID)
    }
}
