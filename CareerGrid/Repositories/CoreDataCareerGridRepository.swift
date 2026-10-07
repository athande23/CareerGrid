import CoreData
import Foundation

final class CoreDataCareerGridRepository: CareerGridRepository {
    
    private let context: NSManagedObjectContext
    
    init(
        context: NSManagedObjectContext = CoreDataStack.shared.container.viewContext
    ) {
        self.context = context
    }

    
    func fetchAvailableOpportunities() throws -> [JobOpportunityModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobOpportunity"
        )
        
        request.predicate = NSPredicate(
            format: "isSaved == NO AND applications.@count == 0"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "applicationDeadline",
                ascending: true
            )
        ]
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapJobOpportunity)
    }
    
    func fetchSavedOpportunities() throws -> [JobOpportunityModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobOpportunity"
        )
        
        request.predicate = NSPredicate(
            format: "isSaved == YES"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "applicationDeadline",
                ascending: true
            )
        ]
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapJobOpportunity)
    }
    
    func fetchOpportunity(
        id: UUID
    ) throws -> JobOpportunityModel? {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobOpportunity"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let object = try context.fetch(request).first else {
            return nil
        }
        
        return try mapJobOpportunity(object)
    }
    
    func saveOpportunity(
        _ opportunity: JobOpportunityModel
    ) throws {
        let object = try findOrCreateOpportunity(
            id: opportunity.id
        )
        
        object.setValue(opportunity.id, forKey: "id")
        object.setValue(opportunity.roleTitle, forKey: "roleTitle")
        object.setValue(opportunity.industry, forKey: "industry")
        object.setValue(opportunity.location, forKey: "location")
        object.setValue(opportunity.description, forKey: "jobDescription")
        object.setValue(opportunity.requirements, forKey: "requirements")
        object.setValue(
            opportunity.interviewProcess,
            forKey: "interviewProcess"
        )
        object.setValue(
            opportunity.sourceURL?.absoluteString,
            forKey: "sourceURL"
        )
        object.setValue(
            opportunity.applicationDeadline,
            forKey: "applicationDeadline"
        )
        object.setValue(
            opportunity.isSaved,
            forKey: "isSaved"
        )
        
        let company = try findOrCreateCompany(
            model: opportunity.company
        )
        
        object.setValue(company, forKey: "company")
        
        try saveContext()
    }
    
    func unsaveOpportunity(id: UUID) throws {
        guard let object = try fetchOpportunityObject(id: id) else {
            return
        }
        
        object.setValue(false, forKey: "isSaved")
        
        try saveContext()
    }
 
    func fetchApplications() throws -> [JobApplicationModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobApplication"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "applicationDate",
                ascending: false
            )
        ]
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapJobApplication)
    }
    
    func fetchApplication(
        id: UUID
    ) throws -> JobApplicationModel? {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobApplication"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let object = try context.fetch(request).first else {
            return nil
        }
        
        return try mapJobApplication(object)
    }
    
    func createApplication(
        _ application: JobApplicationModel
    ) throws {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: "JobApplication",
            into: context
        )
        
        object.setValue(application.id, forKey: "id")
        object.setValue(
            application.applicationDate,
            forKey: "applicationDate"
        )
        object.setValue(
            application.currentStage.rawValue,
            forKey: "currentStage"
        )
        object.setValue(
            application.status.rawValue,
            forKey: "status"
        )
        object.setValue(
            application.notes,
            forKey: "notes"
        )
        
        guard let opportunity = try fetchOpportunityObject(
            id: application.opportunity.id
        ) else {
            throw RepositoryError.opportunityNotFound
        }
        
        object.setValue(
            opportunity,
            forKey: "opportunity"
        )
        
        try saveContext()
    }
    
    func deleteApplication(id: UUID) throws {
        guard let object = try fetchApplicationObject(id: id) else {
            return
        }
        
        context.delete(object)
        
        try saveContext()
    }
    
    func updateApplicationStage(
        id: UUID,
        stage: ApplicationStage
    ) throws {
        guard let object = try fetchApplicationObject(id: id) else {
            throw RepositoryError.applicationNotFound
        }
        
        object.setValue(
            stage.rawValue,
            forKey: "currentStage"
        )
        
        try saveContext()
    }
    
    func updateApplicationNotes(
        id: UUID,
        notes: String?
    ) throws {
        guard let object = try fetchApplicationObject(id: id) else {
            throw RepositoryError.applicationNotFound
        }
        
        object.setValue(notes, forKey: "notes")
        
        try saveContext()
    }
    
    func fetchInterviewQuestions(
        for applicationID: UUID
    ) throws -> [InterviewQuestionModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "InterviewQuestion"
        )
        
        request.predicate = NSPredicate(
            format: "application.id == %@",
            applicationID as CVarArg
        )
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapInterviewQuestion)
    }
    
    func saveInterviewQuestion(
        _ question: InterviewQuestionModel
    ) throws {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: "InterviewQuestion",
            into: context
        )
        
        object.setValue(question.id, forKey: "id")
        object.setValue(question.question, forKey: "question")
        object.setValue(
            question.exampleAnswer,
            forKey: "exampleAnswer"
        )
        object.setValue(
            question.category.rawValue,
            forKey: "category"
        )
        object.setValue(
            question.isCustom,
            forKey: "isCustom"
        )
        
        guard let application = try fetchApplicationObject(
            id: question.applicationID
        ) else {
            throw RepositoryError.applicationNotFound
        }
        
        object.setValue(
            application,
            forKey: "application"
        )
        
        try saveContext()
    }

    
    func fetchCalendarEvents() throws -> [CalendarEventModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "CalendarEvent"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "date",
                ascending: true
            )
        ]
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapCalendarEvent)
    }
    
    func saveCalendarEvent(
        _ event: CalendarEventModel
    ) throws {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: "CalendarEvent",
            into: context
        )
        
        object.setValue(event.id, forKey: "id")
        object.setValue(event.title, forKey: "title")
        object.setValue(event.date, forKey: "date")
        object.setValue(
            event.eventType.rawValue,
            forKey: "eventType"
        )
        object.setValue(event.notes, forKey: "notes")
        
        if let opportunityID = event.opportunityID {
            guard let opportunity = try fetchOpportunityObject(
                id: opportunityID
            ) else {
                throw RepositoryError.opportunityNotFound
            }
            
            object.setValue(
                opportunity,
                forKey: "opportunity"
            )
        }
        
        if let applicationID = event.applicationID {
            guard let application = try fetchApplicationObject(
                id: applicationID
            ) else {
                throw RepositoryError.applicationNotFound
            }
            
            object.setValue(
                application,
                forKey: "application"
            )
        }
        
        try saveContext()
    }
    
    func updateCalendarEvent(
        _ event: CalendarEventModel
    ) throws {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "CalendarEvent"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            event.id as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let object = try context.fetch(request).first else {
            throw RepositoryError.calendarEventNotFound
        }
        
        object.setValue(event.title, forKey: "title")
        object.setValue(event.date, forKey: "date")
        object.setValue(
            event.eventType.rawValue,
            forKey: "eventType"
        )
        object.setValue(event.notes, forKey: "notes")
        
        try saveContext()
    }
    
    func deleteCalendarEvent(id: UUID) throws {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "CalendarEvent"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let object = try context.fetch(request).first else {
            return
        }
        
        context.delete(object)
        
        try saveContext()
    }

    
    func fetchShareDrafts() throws -> [ShareDraftModel] {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "ShareDraft"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "receivedAt",
                ascending: false
            )
        ]
        
        let objects = try context.fetch(request)
        
        return try objects.map(mapShareDraft)
    }
    
    func saveShareDraft(
        _ draft: ShareDraftModel
    ) throws {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: "ShareDraft",
            into: context
        )
        
        object.setValue(draft.id, forKey: "id")
        object.setValue(draft.title, forKey: "title")
        object.setValue(
            draft.url?.absoluteString,
            forKey: "url"
        )
        object.setValue(
            draft.receivedAt,
            forKey: "receivedAt"
        )
        object.setValue(
            draft.processed,
            forKey: "processed"
        )
        
        try saveContext()
    }
    
    func markShareDraftAsProcessed(
        id: UUID
    ) throws {
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "ShareDraft"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        guard let object = try context.fetch(request).first else {
            throw RepositoryError.shareDraftNotFound
        }
        
        object.setValue(true, forKey: "processed")
        
        try saveContext()
    }

    
    private func findOrCreateCompany(
        model: CompanyModel
    ) throws -> NSManagedObject {
        
        if let existing = try fetchCompanyObject(id: model.id) {
            existing.setValue(model.name, forKey: "name")
            existing.setValue(
                model.websiteURL?.absoluteString,
                forKey: "websiteURL"
            )
            existing.setValue(
                model.description,
                forKey: "companyDescription"
            )
            
            return existing
        }
        
        let company = NSEntityDescription.insertNewObject(
            forEntityName: "Company",
            into: context
        )
        
        company.setValue(model.id, forKey: "id")
        company.setValue(model.name, forKey: "name")
        company.setValue(
            model.websiteURL?.absoluteString,
            forKey: "websiteURL"
        )
        company.setValue(
            model.description,
            forKey: "companyDescription"
        )
        
        return company
    }
    
    private func findOrCreateOpportunity(
        id: UUID
    ) throws -> NSManagedObject {
        
        if let existing = try fetchOpportunityObject(id: id) {
            return existing
        }
        
        return NSEntityDescription.insertNewObject(
            forEntityName: "JobOpportunity",
            into: context
        )
    }
    
    private func fetchCompanyObject(
        id: UUID
    ) throws -> NSManagedObject? {
        
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "Company"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func fetchOpportunityObject(
        id: UUID
    ) throws -> NSManagedObject? {
        
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobOpportunity"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func fetchApplicationObject(
        id: UUID
    ) throws -> NSManagedObject? {
        
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "JobApplication"
        )
        
        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )
        
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func mapJobOpportunity(
        _ object: NSManagedObject
    ) throws -> JobOpportunityModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let roleTitle = object.value(forKey: "roleTitle") as? String,
            let industry = object.value(forKey: "industry") as? String,
            let companyObject = object.value(forKey: "company") as? NSManagedObject
        else {
            throw RepositoryError.invalidStoredOpportunity
        }
        
        let company = try mapCompany(companyObject)
        
        return JobOpportunityModel(
            id: id,
            roleTitle: roleTitle,
            company: company,
            industry: industry,
            location: object.value(
                forKey: "location"
            ) as? String,
            description: object.value(
                forKey: "jobDescription"
            ) as? String,
            requirements: object.value(
                forKey: "requirements"
            ) as? String,
            interviewProcess: object.value(
                forKey: "interviewProcess"
            ) as? String,
            sourceURL: url(
                from: object.value(
                    forKey: "sourceURL"
                ) as? String
            ),
            applicationDeadline: object.value(
                forKey: "applicationDeadline"
            ) as? Date,
            isSaved: object.value(
                forKey: "isSaved"
            ) as? Bool ?? false
        )
    }
    
    private func mapCompany(
        _ object: NSManagedObject
    ) throws -> CompanyModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let name = object.value(forKey: "name") as? String
        else {
            throw RepositoryError.invalidStoredCompany
        }
        
        return CompanyModel(
            id: id,
            name: name,
            websiteURL: url(
                from: object.value(
                    forKey: "websiteURL"
                ) as? String
            ),
            description: object.value(
                forKey: "companyDescription"
            ) as? String
        )
    }
    
    private func mapJobApplication(
        _ object: NSManagedObject
    ) throws -> JobApplicationModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let applicationDate = object.value(
                forKey: "applicationDate"
            ) as? Date,
            let stageRawValue = object.value(
                forKey: "currentStage"
            ) as? String,
            let statusRawValue = object.value(
                forKey: "status"
            ) as? String,
            let opportunityObject = object.value(
                forKey: "opportunity"
            ) as? NSManagedObject,
            let stage = ApplicationStage(
                rawValue: stageRawValue
            ),
            let status = ApplicationStatus(
                rawValue: statusRawValue
            )
        else {
            throw RepositoryError.invalidStoredApplication
        }
        
        let opportunity = try mapJobOpportunity(
            opportunityObject
        )
        
        return JobApplicationModel(
            id: id,
            opportunity: opportunity,
            applicationDate: applicationDate,
            currentStage: stage,
            status: status,
            notes: object.value(
                forKey: "notes"
            ) as? String
        )
    }
    
    private func mapInterviewQuestion(
        _ object: NSManagedObject
    ) throws -> InterviewQuestionModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let question = object.value(
                forKey: "question"
            ) as? String,
            let exampleAnswer = object.value(
                forKey: "exampleAnswer"
            ) as? String,
            let categoryRawValue = object.value(
                forKey: "category"
            ) as? String,
            let application = object.value(
                forKey: "application"
            ) as? NSManagedObject,
            let applicationID = application.value(
                forKey: "id"
            ) as? UUID,
            let category = InterviewQuestionCategory(
                rawValue: categoryRawValue
            )
        else {
            throw RepositoryError.invalidStoredInterviewQuestion
        }
        
        return InterviewQuestionModel(
            id: id,
            question: question,
            exampleAnswer: exampleAnswer,
            category: category,
            isCustom: object.value(
                forKey: "isCustom"
            ) as? Bool ?? false,
            applicationID: applicationID
        )
    }
    
    private func mapCalendarEvent(
        _ object: NSManagedObject
    ) throws -> CalendarEventModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let title = object.value(
                forKey: "title"
            ) as? String,
            let date = object.value(
                forKey: "date"
            ) as? Date,
            let eventTypeRawValue = object.value(
                forKey: "eventType"
            ) as? String,
            let eventType = CalendarEventType(
                rawValue: eventTypeRawValue
            )
        else {
            throw RepositoryError.invalidStoredCalendarEvent
        }
        
        let opportunityID = (
            object.value(forKey: "opportunity") as? NSManagedObject
        )?.value(forKey: "id") as? UUID
        
        let applicationID = (
            object.value(forKey: "application") as? NSManagedObject
        )?.value(forKey: "id") as? UUID
        
        return CalendarEventModel(
            id: id,
            title: title,
            date: date,
            eventType: eventType,
            notes: object.value(
                forKey: "notes"
            ) as? String,
            opportunityID: opportunityID,
            applicationID: applicationID
        )
    }
    
    private func mapShareDraft(
        _ object: NSManagedObject
    ) throws -> ShareDraftModel {
        
        guard
            let id = object.value(forKey: "id") as? UUID,
            let title = object.value(
                forKey: "title"
            ) as? String,
            let receivedAt = object.value(
                forKey: "receivedAt"
            ) as? Date
        else {
            throw RepositoryError.invalidStoredShareDraft
        }
        
        return ShareDraftModel(
            id: id,
            title: title,
            url: url(
                from: object.value(
                    forKey: "url"
                ) as? String
            ),
            receivedAt: receivedAt,
            processed: object.value(
                forKey: "processed"
            ) as? Bool ?? false
        )
    }
    
    private func url(from string: String?) -> URL? {
        guard let string else {
            return nil
        }
        
        return URL(string: string)
    }
    
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

enum RepositoryError: Error {
    case opportunityNotFound
    case applicationNotFound
    case calendarEventNotFound
    case shareDraftNotFound
    
    case invalidStoredCompany
    case invalidStoredOpportunity
    case invalidStoredApplication
    case invalidStoredInterviewQuestion
    case invalidStoredCalendarEvent
    case invalidStoredShareDraft
}
