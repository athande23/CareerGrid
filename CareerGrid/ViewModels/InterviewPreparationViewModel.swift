import Foundation
import Observation

@Observable
final class InterviewPreparationViewModel {
    
    private let repository: CareerGridRepository
    private let manageInterviewQuestionUseCase: ManageInterviewQuestionUseCase
    private let updateApplicationNotesUseCase: UpdateApplicationNotesUseCase
    
    var applications: [JobApplicationModel] = []
    var selectedApplication: JobApplicationModel?
    var interviewQuestions: [InterviewQuestionModel] = []
    var errorMessage: String?
    var isLoading = false
    
    init(repository: CareerGridRepository) {
        self.repository = repository
        self.manageInterviewQuestionUseCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        self.updateApplicationNotesUseCase = UpdateApplicationNotesUseCase(
            repository: repository
        )
    }
    
    func loadApplications() {
        isLoading = true
        errorMessage = nil
        
        do {
            applications = try repository.fetchApplications()
        } catch {
            errorMessage = "Unable to load applications."
        }
        
        isLoading = false
    }
    
    func selectApplication(
        _ application: JobApplicationModel
    ) {
        selectedApplication = application
        loadInterviewQuestions(
            for: application.id
        )
    }
    
    func loadInterviewQuestions(
        for applicationID: UUID
    ) {
        errorMessage = nil
        
        do {
            interviewQuestions = try repository.fetchInterviewQuestions(
                for: applicationID
            )
        } catch {
            errorMessage = "Unable to load interview questions."
        }
    }
    
    func addQuestion(
        question: String,
        exampleAnswer: String,
        category: InterviewQuestionCategory
    ) {
        guard let application = selectedApplication else {
            errorMessage = "Select an application first."
            return
        }
        
        errorMessage = nil
        
        do {
            try manageInterviewQuestionUseCase.execute(
                applicationID: application.id,
                question: question,
                exampleAnswer: exampleAnswer,
                category: category
            )
            
            loadInterviewQuestions(
                for: application.id
            )
        } catch let error as ManageInterviewQuestionError {
            handleQuestionError(error)
        } catch {
            errorMessage = "Unable to add interview question."
        }
    }
    
    func updateNotes(
        notes: String?
    ) {
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
            
            selectedApplication = try repository.fetchApplication(
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
