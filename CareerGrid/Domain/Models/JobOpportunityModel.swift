import Foundation

struct JobOpportunityModel: Identifiable, Equatable {
    let id: UUID
    var roleTitle: String
    var company: CompanyModel
    var industry: String
    var location: String?
    var description: String?
    var requirements: String?
    var interviewProcess: String?
    var sourceURL: URL?
    var applicationDeadline: Date?
    var isSaved: Bool
    
    init(
        id: UUID = UUID(),
        roleTitle: String,
        company: CompanyModel,
        industry: String,
        location: String? = nil,
        description: String? = nil,
        requirements: String? = nil,
        interviewProcess: String? = nil,
        sourceURL: URL? = nil,
        applicationDeadline: Date? = nil,
        isSaved: Bool = false
    ) {
        self.id = id
        self.roleTitle = roleTitle
        self.company = company
        self.industry = industry
        self.location = location
        self.description = description
        self.requirements = requirements
        self.interviewProcess = interviewProcess
        self.sourceURL = sourceURL
        self.applicationDeadline = applicationDeadline
        self.isSaved = isSaved
    }
}
