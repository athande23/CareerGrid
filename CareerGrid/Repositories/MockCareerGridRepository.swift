import Foundation

final class MockCareerGridRepository: CareerGridRepository {
    
    var opportunities: [JobOpportunityModel] = []
    var applications: [JobApplicationModel] = []
    var interviewQuestions: [InterviewQuestionModel] = []
    var calendarEvents: [CalendarEventModel] = []
    var shareDrafts: [ShareDraftModel] = []

    func fetchAvailableOpportunities() throws -> [JobOpportunityModel] {
        opportunities.filter { opportunity in
            !opportunity.isSaved &&
            !applications.contains {
                $0.opportunity.id == opportunity.id
            }
        }
    }
    
    func fetchSavedOpportunities() throws -> [JobOpportunityModel] {
        opportunities.filter { $0.isSaved }
    }
    
    func fetchOpportunity(
        id: UUID
    ) throws -> JobOpportunityModel? {
        opportunities.first { $0.id == id }
    }
    
    func saveOpportunity(
        _ opportunity: JobOpportunityModel
    ) throws {
        if let index = opportunities.firstIndex(
            where: { $0.id == opportunity.id }
        ) {
            opportunities[index] = opportunity
        } else {
            opportunities.append(opportunity)
        }
    }
    
    func unsaveOpportunity(
        id: UUID
    ) throws {
        guard let index = opportunities.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }
        
        opportunities[index].isSaved = false
    }
    
    func fetchApplications() throws -> [JobApplicationModel] {
        applications.sorted {
            $0.applicationDate > $1.applicationDate
        }
    }
    
    func fetchApplication(
        id: UUID
    ) throws -> JobApplicationModel? {
        applications.first { $0.id == id }
    }
    
    func createApplication(
        _ application: JobApplicationModel
    ) throws {
        applications.append(application)
    }
    
    func deleteApplication(
        id: UUID
    ) throws {
        applications.removeAll { $0.id == id }
    }
    
    func updateApplicationStage(
        id: UUID,
        stage: ApplicationStage
    ) throws {
        guard let index = applications.firstIndex(
            where: { $0.id == id }
        ) else {
            throw RepositoryError.applicationNotFound
        }
        
        applications[index].currentStage = stage
    }
    
    func updateApplicationNotes(
        id: UUID,
        notes: String?
    ) throws {
        guard let index = applications.firstIndex(
            where: { $0.id == id }
        ) else {
            throw RepositoryError.applicationNotFound
        }
        
        applications[index].notes = notes
    }
    
    func fetchInterviewQuestions(
        for applicationID: UUID
    ) throws -> [InterviewQuestionModel] {
        interviewQuestions.filter {
            $0.applicationID == applicationID
        }
    }
    
    func saveInterviewQuestion(
        _ question: InterviewQuestionModel
    ) throws {
        interviewQuestions.append(question)
    }
    
    func fetchCalendarEvents() throws -> [CalendarEventModel] {
        calendarEvents.sorted {
            $0.date < $1.date
        }
    }
    
    func saveCalendarEvent(
        _ event: CalendarEventModel
    ) throws {
        calendarEvents.append(event)
    }
    
    func updateCalendarEvent(
        _ event: CalendarEventModel
    ) throws {
        guard let index = calendarEvents.firstIndex(
            where: { $0.id == event.id }
        ) else {
            throw RepositoryError.calendarEventNotFound
        }
        
        calendarEvents[index] = event
    }
    
    func deleteCalendarEvent(
        id: UUID
    ) throws {
        calendarEvents.removeAll { $0.id == id }
    }
    
    func fetchShareDrafts() throws -> [ShareDraftModel] {
        shareDrafts.sorted {
            $0.receivedAt > $1.receivedAt
        }
    }
    
    func saveShareDraft(
        _ draft: ShareDraftModel
    ) throws {
        shareDrafts.append(draft)
    }
    
    func markShareDraftAsProcessed(
        id: UUID
    ) throws {
        guard let index = shareDrafts.firstIndex(
            where: { $0.id == id }
        ) else {
            throw RepositoryError.shareDraftNotFound
        }
        
        shareDrafts[index].processed = true
    }
}
