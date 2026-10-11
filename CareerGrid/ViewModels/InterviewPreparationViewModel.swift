import Foundation
import Observation

@Observable
final class InterviewPreparationViewModel {
    private let manageInterviewQuestionUseCase: ManageInterviewQuestionUseCase
    private let updateApplicationNotesUseCase: UpdateApplicationNotesUseCase
    private let fetchApplicationsUseCase: FetchApplicationsUseCase
    private let fetchInterviewQuestionsUseCase: FetchInterviewQuestionsUseCase
    private let deleteInterviewQuestionUseCase: DeleteInterviewQuestionUseCase
    private let fetchApplicationUseCase: FetchApplicationUseCase

    var applications: [JobApplicationModel] = []
    var selectedApplication: JobApplicationModel?
    var interviewQuestions: [InterviewQuestionModel] = []
    var errorMessage: String?
    var isLoading = false

    init(repository: CareerGridRepository) {
        self.manageInterviewQuestionUseCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        self.updateApplicationNotesUseCase = UpdateApplicationNotesUseCase(
            repository: repository
        )
        self.fetchApplicationsUseCase = FetchApplicationsUseCase(
            repository: repository
        )
        self.fetchInterviewQuestionsUseCase = FetchInterviewQuestionsUseCase(
            repository: repository
        )
        self.deleteInterviewQuestionUseCase = DeleteInterviewQuestionUseCase(
            repository: repository
        )
        self.fetchApplicationUseCase = FetchApplicationUseCase(
            repository: repository
        )
    }

    func loadApplications() {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            applications = try fetchApplicationsUseCase.execute()

            if let selectedApplication,
               let refreshedApplication = applications.first(where: {
                   $0.id == selectedApplication.id
               }) {
                self.selectedApplication = refreshedApplication
            }
        } catch {
            errorMessage = "Unable to load applications."
        }
    }

    func selectApplication(_ application: JobApplicationModel) {
        selectedApplication = application
        loadInterviewQuestions(for: application.id)
    }

    func loadInterviewQuestions(for applicationID: UUID) {
        errorMessage = nil

        do {
            interviewQuestions = try fetchInterviewQuestionsUseCase.execute(
                for: applicationID
            )
        } catch {
            errorMessage = "Unable to load interview questions."
        }
    }

    @discardableResult
    func addQuestion(
        question: String,
        exampleAnswer: String,
        category: InterviewQuestionCategory
    ) -> Bool {
        guard let application = selectedApplication else {
            errorMessage = "Select an application first."
            return false
        }

        errorMessage = nil

        do {
            try manageInterviewQuestionUseCase.execute(
                applicationID: application.id,
                question: question,
                exampleAnswer: exampleAnswer,
                category: category
            )

            loadInterviewQuestions(for: application.id)

            // Keep the sheet open if refreshing the questions failed.
            guard errorMessage == nil else {
                return false
            }

            return true
        } catch let error as ManageInterviewQuestionError {
            handleQuestionError(error)
            return false
        } catch {
            errorMessage = "Unable to add interview question."
            return false
        }
    }
    
    func deleteQuestion(id: UUID) {
        guard let application = selectedApplication else {
            errorMessage = "Select an application first."
            return
        }

        errorMessage = nil

        do {
            try deleteInterviewQuestionUseCase.execute(
                questionID: id,
                applicationID: application.id
            )

            loadInterviewQuestions(for: application.id)
        } catch let error as DeleteInterviewQuestionError {
            switch error {
            case .questionNotFound:
                errorMessage = "This interview question could not be found."
            }
        } catch {
            errorMessage = "Unable to delete interview question."
        }
    }

    func updateNotes(notes: String?) {
        guard let application = selectedApplication else {
            errorMessage = "Select an application first."
            return
        }

        errorMessage = nil

        do {
            try updateApplicationNotesUseCase.execute(
                applicationID: application.id,
                notes: notes
            )

            selectedApplication = try fetchApplicationUseCase.execute(
                id: application.id
            )

            loadApplications()
        } catch let error as UpdateApplicationNotesError {
            switch error {
            case .applicationNotFound:
                errorMessage = "This application could not be found."
            }
        } catch {
            errorMessage = "Unable to update notes."
        }
    }

    private func handleQuestionError(
        _ error: ManageInterviewQuestionError
    ) {
        switch error {
        case .applicationNotFound:
            errorMessage = "This application could not be found."
        case .emptyQuestion:
            errorMessage = "Enter an interview question."
        case .emptyExampleAnswer:
            errorMessage = "Enter an example answer."
        }
    }
}
