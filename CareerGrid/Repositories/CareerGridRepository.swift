import Foundation

protocol CareerGridRepository {

    func fetchAvailableOpportunities() throws -> [JobOpportunityModel]
    
    func fetchSavedOpportunities() throws -> [JobOpportunityModel]
    
    func fetchOpportunity(id: UUID) throws -> JobOpportunityModel?
    
    func saveOpportunity(_ opportunity: JobOpportunityModel) throws
    
    func unsaveOpportunity(id: UUID) throws

    func fetchApplications() throws -> [JobApplicationModel]
    
    func fetchApplication(id: UUID) throws -> JobApplicationModel?
    
    func createApplication(_ application: JobApplicationModel) throws
    
    func deleteApplication(id: UUID) throws
    
    func updateApplicationStage(
        id: UUID,
        stage: ApplicationStage
    ) throws
    
    func updateApplicationNotes(
        id: UUID,
        notes: String?
    ) throws
   
    
    func fetchInterviewQuestions(
        for applicationID: UUID
    ) throws -> [InterviewQuestionModel]
    
    func saveInterviewQuestion(
        _ question: InterviewQuestionModel
    ) throws
 
    
    func fetchCalendarEvents() throws -> [CalendarEventModel]
    
    func saveCalendarEvent(
        _ event: CalendarEventModel
    ) throws
    
    func updateCalendarEvent(
        _ event: CalendarEventModel
    ) throws
    
    func deleteCalendarEvent(id: UUID) throws

    
    func fetchShareDrafts() throws -> [ShareDraftModel]
    
    func saveShareDraft(_ draft: ShareDraftModel) throws
    
    func markShareDraftAsProcessed(id: UUID) throws
}
