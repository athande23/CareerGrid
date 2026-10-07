import Foundation

struct JobApplicationModel: Identifiable, Equatable {
    let id: UUID
    var opportunity: JobOpportunityModel
    var applicationDate: Date
    var currentStage: ApplicationStage
    var status: ApplicationStatus
    var notes: String?
    
    init(
        id: UUID = UUID(),
        opportunity: JobOpportunityModel,
        applicationDate: Date = Date(),
        currentStage: ApplicationStage = .applied,
        status: ApplicationStatus = .active,
        notes: String? = nil
    ) {
        self.id = id
        self.opportunity = opportunity
        self.applicationDate = applicationDate
        self.currentStage = currentStage
        self.status = status
        self.notes = notes
    }
}
