import Foundation

struct InterviewQuestionModel: Identifiable, Equatable {
    let id: UUID
    var question: String
    var exampleAnswer: String
    var category: InterviewQuestionCategory
    var isCustom: Bool
    var applicationID: UUID
    
    init(
        id: UUID = UUID(),
        question: String,
        exampleAnswer: String,
        category: InterviewQuestionCategory,
        isCustom: Bool = false,
        applicationID: UUID
    ) {
        self.id = id
        self.question = question
        self.exampleAnswer = exampleAnswer
        self.category = category
        self.isCustom = isCustom
        self.applicationID = applicationID
    }
}
