
import Foundation

struct SeedInterviewQuestionsUseCase {

    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(for application: JobApplicationModel) throws {
        let templates = CareerGridInterviewQuestionSeedData.questions(
            for: application.opportunity.company.name
        )

        guard !templates.isEmpty else {
            return
        }

        let existingQuestions = try repository.fetchInterviewQuestions(
            for: application.id
        )

        let existingQuestionTexts = Set(
            existingQuestions.map {
                $0.question.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).lowercased()
            }
        )

        for template in templates {
            let normalisedQuestion = template.question
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            guard !existingQuestionTexts.contains(normalisedQuestion) else {
                continue
            }

            let question = InterviewQuestionModel(
                question: template.question,
                exampleAnswer: template.exampleAnswer,
                category: template.category,
                isCustom: false,
                applicationID: application.id
            )

            try repository.saveInterviewQuestion(question)
        }
    }
}
