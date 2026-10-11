
import Foundation

struct CreateJobOpportunityUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(
        roleTitle: String,
        companyName: String,
        industry: String,
        location: String?,
        description: String?,
        requirements: String?,
        interviewProcess: String?,
        sourceURL: URL?,
        applicationDeadline: Date?,
        degreeRequirement: String? = nil
    ) throws {
        let trimmedRoleTitle = roleTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedRoleTitle.isEmpty else {
            throw CreateJobOpportunityError.emptyRoleTitle
        }

        let trimmedCompanyName = companyName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedCompanyName.isEmpty else {
            throw CreateJobOpportunityError.emptyCompanyName
        }

        let trimmedIndustry = industry.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedIndustry.isEmpty else {
            throw CreateJobOpportunityError.emptyIndustry
        }

        let now = Date()
        if let applicationDeadline, applicationDeadline < now {
            throw CreateJobOpportunityError.deadlineInPast
        }

        let company = CompanyModel(name: trimmedCompanyName)

        let opportunity = JobOpportunityModel(
            roleTitle: trimmedRoleTitle,
            company: company,
            industry: trimmedIndustry,
            location: location?.nilIfBlank,
            description: description?.nilIfBlank,
            requirements: requirements?.nilIfBlank,
            interviewProcess: interviewProcess?.nilIfBlank,
            sourceURL: sourceURL,
            applicationDeadline: applicationDeadline,
            isSaved: false,
            degreeRequirement: degreeRequirement?.nilIfBlank
        )

        try repository.saveOpportunity(opportunity)
    }
}

enum CreateJobOpportunityError: Error, Equatable {
    case emptyRoleTitle
    case emptyCompanyName
    case emptyIndustry
    case deadlineInPast
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return trimmed.isEmpty ? nil : trimmed
    }
}
