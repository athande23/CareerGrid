import Foundation
import Testing
@testable import CareerGrid

struct CareerGridTests {

    @Test
    func saveOpportunityMarksOpportunityAsSaved() throws {
        let repository = MockCareerGridRepository()
        let useCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        try useCase.execute(
            opportunityID: opportunity.id
        )
        
        #expect(repository.opportunities[0].isSaved == true)
    }
    
    @Test
    func saveOpportunityThrowsWhenOpportunityDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        
        let unknownID = UUID()
        
        do {
            try useCase.execute(
                opportunityID: unknownID
            )
            
            Issue.record(
                "Expected opportunityNotFound error"
            )
        } catch let error as SaveJobOpportunityError {
            #expect(error == .opportunityNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func saveOpportunityThrowsWhenAlreadySaved() {
        let repository = MockCareerGridRepository()
        let useCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: true
        )
        repository.opportunities = [opportunity]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected alreadySaved error"
            )
        } catch let error as SaveJobOpportunityError {
            #expect(error == .alreadySaved)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func saveOpportunityThrowsWhenRoleTitleIsEmpty() {
        let repository = MockCareerGridRepository()
        let useCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            roleTitle: "   "
        )
        repository.opportunities = [opportunity]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected invalidRoleTitle error"
            )
        } catch let error as SaveJobOpportunityError {
            #expect(error == .invalidRoleTitle)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func applyToSavedOpportunityCreatesApplication() throws {
        let repository = MockCareerGridRepository()
        let useCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: true
        )
        
        repository.opportunities = [opportunity]
        
        try useCase.execute(
            opportunityID: opportunity.id
        )
        
        #expect(repository.applications.count == 1)
        #expect(
            repository.applications[0].opportunity.id == opportunity.id
        )
        #expect(repository.opportunities[0].isSaved == false)
    }

    @Test
    func applyToSavedOpportunityThrowsWhenOpportunityDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                opportunityID: UUID()
            )
            
            Issue.record(
                "Expected opportunityNotFound error"
            )
        } catch let error as ApplyToSavedOpportunityError {
            #expect(error == .opportunityNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func applyToSavedOpportunityThrowsWhenOpportunityIsNotSaved() {
        let repository = MockCareerGridRepository()
        let useCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: false
        )
        
        repository.opportunities = [opportunity]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected opportunityNotSaved error"
            )
        } catch let error as ApplyToSavedOpportunityError {
            #expect(error == .opportunityNotSaved)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func applyToSavedOpportunityThrowsWhenAlreadyApplied() {
        let repository = MockCareerGridRepository()
        let useCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: true
        )
        
        repository.opportunities = [opportunity]
        
        let existingApplication = JobApplicationModel(
            opportunity: opportunity,
            status: .active
        )
        
        repository.applications = [existingApplication]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected alreadyApplied error"
            )
        } catch let error as ApplyToSavedOpportunityError {
            #expect(error == .alreadyApplied)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func trackJobApplicationCreatesApplication() throws {
        let repository = MockCareerGridRepository()
        let useCase = TrackJobApplicationUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let applicationDate = Date().addingTimeInterval(-3600)
        
        try useCase.execute(
            opportunityID: opportunity.id,
            applicationDate: applicationDate
        )
        
        #expect(repository.applications.count == 1)
        #expect(
            repository.applications[0].opportunity.id == opportunity.id
        )
        #expect(
            repository.applications[0].applicationDate == applicationDate
        )
    }

    @Test
    func trackJobApplicationThrowsWhenOpportunityDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = TrackJobApplicationUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                opportunityID: UUID()
            )
            
            Issue.record(
                "Expected opportunityNotFound error"
            )
        } catch let error as TrackJobApplicationError {
            #expect(error == .opportunityNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func trackJobApplicationThrowsWhenDateIsInFuture() {
        let repository = MockCareerGridRepository()
        let useCase = TrackJobApplicationUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let futureDate = Date().addingTimeInterval(3600)
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id,
                applicationDate: futureDate
            )
            
            Issue.record(
                "Expected applicationDateInFuture error"
            )
        } catch let error as TrackJobApplicationError {
            #expect(error == .applicationDateInFuture)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func trackJobApplicationThrowsWhenAlreadyApplied() {
        let repository = MockCareerGridRepository()
        let useCase = TrackJobApplicationUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let existingApplication = JobApplicationModel(
            opportunity: opportunity,
            status: .active
        )
        
        repository.applications = [existingApplication]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected alreadyApplied error"
            )
        } catch let error as TrackJobApplicationError {
            #expect(error == .alreadyApplied)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func advanceApplicationStageMovesForward() throws {
        let repository = MockCareerGridRepository()
        let useCase = AdvanceApplicationStageUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity,
            currentStage: .applied
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            direction: .forward
        )
        
        #expect(
            repository.applications[0].currentStage == .onlineAssessment
        )
    }

    @Test
    func advanceApplicationStageMovesBackward() throws {
        let repository = MockCareerGridRepository()
        let useCase = AdvanceApplicationStageUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity,
            currentStage: .interview
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            direction: .backward
        )
        
        #expect(
            repository.applications[0].currentStage == .onlineAssessment
        )
    }

    @Test
    func advanceApplicationStageThrowsAtFirstStage() {
        let repository = MockCareerGridRepository()
        let useCase = AdvanceApplicationStageUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity,
            currentStage: .applied
        )
        
        repository.applications = [application]
        
        do {
            try useCase.execute(
                applicationID: application.id,
                direction: .backward
            )
            
            Issue.record(
                "Expected invalidStageTransition error"
            )
        } catch let error as AdvanceApplicationStageError {
            #expect(error == .invalidStageTransition)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func advanceApplicationStageThrowsWhenApplicationDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = AdvanceApplicationStageUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                applicationID: UUID(),
                direction: .forward
            )
            
            Issue.record(
                "Expected applicationNotFound error"
            )
        } catch let error as AdvanceApplicationStageError {
            #expect(error == .applicationNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func manageInterviewQuestionCreatesQuestion() throws {
        let repository = MockCareerGridRepository()
        let useCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            question: "Why do you want this role?",
            exampleAnswer: "I am interested in software engineering.",
            category: .role
        )
        
        #expect(repository.interviewQuestions.count == 1)
        #expect(
            repository.interviewQuestions[0].applicationID == application.id
        )
        #expect(
            repository.interviewQuestions[0].question
            == "Why do you want this role?"
        )
        #expect(
            repository.interviewQuestions[0].category == .role
        )
    }

    @Test
    func manageInterviewQuestionTrimsQuestionAndAnswer() throws {
        let repository = MockCareerGridRepository()
        let useCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            question: "  Tell me about yourself.  ",
            exampleAnswer: "  My background is in computer science.  ",
            category: .behavioural
        )
        
        #expect(
            repository.interviewQuestions[0].question
            == "Tell me about yourself."
        )
        
        #expect(
            repository.interviewQuestions[0].exampleAnswer
            == "My background is in computer science."
        )
    }

    @Test
    func manageInterviewQuestionThrowsWhenApplicationDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                applicationID: UUID(),
                question: "Why this company?",
                exampleAnswer: "I like the company's work.",
                category: .company
            )
            
            Issue.record(
                "Expected applicationNotFound error"
            )
        } catch let error as ManageInterviewQuestionError {
            #expect(error == .applicationNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func manageInterviewQuestionThrowsWhenQuestionIsEmpty() {
        let repository = MockCareerGridRepository()
        let useCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        do {
            try useCase.execute(
                applicationID: application.id,
                question: "   ",
                exampleAnswer: "Some answer",
                category: .general
            )
            
            Issue.record(
                "Expected emptyQuestion error"
            )
        } catch let error as ManageInterviewQuestionError {
            #expect(error == .emptyQuestion)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func manageInterviewQuestionThrowsWhenExampleAnswerIsEmpty() {
        let repository = MockCareerGridRepository()
        let useCase = ManageInterviewQuestionUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        do {
            try useCase.execute(
                applicationID: application.id,
                question: "Why this role?",
                exampleAnswer: "   ",
                category: .role
            )
            
            Issue.record(
                "Expected emptyExampleAnswer error"
            )
        } catch let error as ManageInterviewQuestionError {
            #expect(error == .emptyExampleAnswer)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func manageCalendarEventCreatesEvent() throws {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let eventDate = Date().addingTimeInterval(86400)
        
        try useCase.execute(
            title: "Online Assessment",
            date: eventDate,
            eventType: .onlineAssessment,
            opportunityID: opportunity.id
        )
        
        #expect(repository.calendarEvents.count == 1)
        #expect(
            repository.calendarEvents[0].title == "Online Assessment"
        )
        #expect(
            repository.calendarEvents[0].eventType == .onlineAssessment
        )
        #expect(
            repository.calendarEvents[0].opportunityID == opportunity.id
        )
    }

    @Test
    func manageCalendarEventTrimsTitle() throws {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        try useCase.execute(
            title: "  Technical Interview  ",
            date: Date(),
            eventType: .interview,
            opportunityID: opportunity.id
        )
        
        #expect(
            repository.calendarEvents[0].title
            == "Technical Interview"
        )
    }

    @Test
    func manageCalendarEventThrowsWhenTitleIsEmpty() {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                title: "   ",
                date: Date(),
                eventType: .custom
            )
            
            Issue.record(
                "Expected emptyTitle error"
            )
        } catch let error as ManageCalendarEventError {
            #expect(error == .emptyTitle)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func manageCalendarEventThrowsWhenNoRelatedJobExists() {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                title: "Study Interview Questions",
                date: Date(),
                eventType: .custom
            )
            
            Issue.record(
                "Expected noRelatedJob error"
            )
        } catch let error as ManageCalendarEventError {
            #expect(error == .noRelatedJob)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func manageCalendarEventThrowsWhenOpportunityDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                title: "Application Deadline",
                date: Date(),
                eventType: .applicationDeadline,
                opportunityID: UUID()
            )
            
            Issue.record(
                "Expected opportunityNotFound error"
            )
        } catch let error as ManageCalendarEventError {
            #expect(error == .opportunityNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func manageCalendarEventThrowsWhenApplicationDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = ManageCalendarEventUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                title: "Final Interview",
                date: Date(),
                eventType: .finalInterview,
                applicationID: UUID()
            )
            
            Issue.record(
                "Expected applicationNotFound error"
            )
        } catch let error as ManageCalendarEventError {
            #expect(error == .applicationNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    @Test
    func unsaveJobOpportunityRemovesSavedState() throws {
        let repository = MockCareerGridRepository()
        let useCase = UnsaveJobOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: true
        )
        
        repository.opportunities = [opportunity]
        
        try useCase.execute(
            opportunityID: opportunity.id
        )
        
        #expect(repository.opportunities[0].isSaved == false)
    }

    @Test
    func unsaveJobOpportunityThrowsWhenNotSaved() {
        let repository = MockCareerGridRepository()
        let useCase = UnsaveJobOpportunityUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity(
            isSaved: false
        )
        
        repository.opportunities = [opportunity]
        
        do {
            try useCase.execute(
                opportunityID: opportunity.id
            )
            
            Issue.record(
                "Expected notSaved error"
            )
        } catch let error as UnsaveJobOpportunityError {
            #expect(error == .notSaved)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func deleteJobApplicationRemovesApplication() throws {
        let repository = MockCareerGridRepository()
        let useCase = DeleteJobApplicationUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id
        )
        
        #expect(repository.applications.isEmpty)
    }

    @Test
    func deleteJobApplicationThrowsWhenApplicationDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = DeleteJobApplicationUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                applicationID: UUID()
            )
            
            Issue.record(
                "Expected applicationNotFound error"
            )
        } catch let error as DeleteJobApplicationError {
            #expect(error == .applicationNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }


    @Test
    func updateApplicationNotesSavesNotes() throws {
        let repository = MockCareerGridRepository()
        let useCase = UpdateApplicationNotesUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            notes: "Prepare STAR examples"
        )
        
        #expect(
            repository.applications[0].notes
            == "Prepare STAR examples"
        )
    }

    @Test
    func updateApplicationNotesConvertsWhitespaceToNil() throws {
        let repository = MockCareerGridRepository()
        let useCase = UpdateApplicationNotesUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let application = JobApplicationModel(
            opportunity: opportunity,
            notes: "Existing notes"
        )
        
        repository.applications = [application]
        
        try useCase.execute(
            applicationID: application.id,
            notes: "   "
        )
        
        #expect(
            repository.applications[0].notes == nil
        )
    }

    @Test
    func updateCalendarEventUpdatesEvent() throws {
        let repository = MockCareerGridRepository()
        let useCase = UpdateCalendarEventUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let event = CalendarEventModel(
            title: "Interview",
            date: Date(),
            eventType: .interview,
            opportunityID: opportunity.id
        )
        
        repository.calendarEvents = [event]
        
        var updatedEvent = event
        updatedEvent.title = "Technical Interview"
        
        try useCase.execute(updatedEvent)
        
        #expect(
            repository.calendarEvents[0].title
            == "Technical Interview"
        )
    }

    @Test
    func updateCalendarEventThrowsWhenTitleIsEmpty() {
        let repository = MockCareerGridRepository()
        let useCase = UpdateCalendarEventUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        repository.opportunities = [opportunity]
        
        let event = CalendarEventModel(
            title: "Interview",
            date: Date(),
            eventType: .interview,
            opportunityID: opportunity.id
        )
        
        repository.calendarEvents = [event]
        
        var updatedEvent = event
        updatedEvent.title = "   "
        
        do {
            try useCase.execute(updatedEvent)
            
            Issue.record(
                "Expected emptyTitle error"
            )
        } catch let error as UpdateCalendarEventError {
            #expect(error == .emptyTitle)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }

    @Test
    func deleteCalendarEventRemovesEvent() throws {
        let repository = MockCareerGridRepository()
        let useCase = DeleteCalendarEventUseCase(
            repository: repository
        )
        
        let opportunity = makeOpportunity()
        
        let event = CalendarEventModel(
            title: "Application Deadline",
            date: Date(),
            eventType: .applicationDeadline,
            opportunityID: opportunity.id
        )
        
        repository.calendarEvents = [event]
        
        try useCase.execute(
            eventID: event.id
        )
        
        #expect(repository.calendarEvents.isEmpty)
    }

    @Test
    func deleteCalendarEventThrowsWhenEventDoesNotExist() {
        let repository = MockCareerGridRepository()
        let useCase = DeleteCalendarEventUseCase(
            repository: repository
        )
        
        do {
            try useCase.execute(
                eventID: UUID()
            )
            
            Issue.record(
                "Expected eventNotFound error"
            )
        } catch let error as DeleteCalendarEventError {
            #expect(error == .eventNotFound)
        } catch {
            Issue.record(
                "Unexpected error: \(error)"
            )
        }
    }
    
    

    
    private func makeOpportunity(
        roleTitle: String = "Software Engineer Intern",
        isSaved: Bool = false
    ) -> JobOpportunityModel {
        
        let company = CompanyModel(
            name: "Test Company"
        )
        
        return JobOpportunityModel(
            roleTitle: roleTitle,
            company: company,
            industry: "Technology",
            isSaved: isSaved
        )
    }
}
