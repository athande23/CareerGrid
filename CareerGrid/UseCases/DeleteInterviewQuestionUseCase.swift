import Foundation

struct DeleteInterviewQuestionUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(
        questionID: UUID,
        applicationID: UUID
    ) throws {
        let questions = try repository.fetchInterviewQuestions(
            for: applicationID
        )

        guard questions.contains(where: { $0.id == questionID }) else {
            throw DeleteInterviewQuestionError.questionNotFound
        }

        try repository.deleteInterviewQuestion(id: questionID)
    }
}

enum DeleteInterviewQuestionError: Error, Equatable {
    case questionNotFound
}
