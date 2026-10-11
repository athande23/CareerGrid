
import Foundation
import Observation

@Observable
final class HomeViewModel {

    private let saveJobOpportunityUseCase: SaveJobOpportunityUseCase
    private let trackJobApplicationUseCase: TrackJobApplicationUseCase
    private let createJobOpportunityUseCase: CreateJobOpportunityUseCase
    private let fetchJobOpportunitiesUseCase: FetchJobOpportunitiesUseCase

    var opportunities: [JobOpportunityModel] = []
    var errorMessage: String?
    var isLoading = false

    init(repository: CareerGridRepository) {
        self.saveJobOpportunityUseCase = SaveJobOpportunityUseCase(
            repository: repository
        )
        self.trackJobApplicationUseCase = TrackJobApplicationUseCase(
            repository: repository
        )
        self.createJobOpportunityUseCase = CreateJobOpportunityUseCase(
            repository: repository
        )
        self.fetchJobOpportunitiesUseCase = FetchJobOpportunitiesUseCase(
            repository: repository
        )
    }

    func loadOpportunities() {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            opportunities = try fetchJobOpportunitiesUseCase.executeAvailable()
        } catch {
            errorMessage = "Unable to load job opportunities."
        }
    }

    func saveOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try saveJobOpportunityUseCase.execute(
                opportunityID: id
            )
            loadOpportunities()
        } catch {
            errorMessage = "Unable to save this opportunity."
        }
    }

    func applyToOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try trackJobApplicationUseCase.execute(
                opportunityID: id
            )
            loadOpportunities()
        } catch {
            errorMessage = "Unable to apply for this opportunity."
        }
    }

    func addOpportunity(
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
    ) {
        errorMessage = nil

        do {
            try createJobOpportunityUseCase.execute(
                roleTitle: roleTitle,
                companyName: companyName,
                industry: industry,
                location: location,
                description: description,
                requirements: requirements,
                interviewProcess: interviewProcess,
                sourceURL: sourceURL,
                applicationDeadline: applicationDeadline,
                degreeRequirement: degreeRequirement
            )

            loadOpportunities()
        } catch let error as CreateJobOpportunityError {
            switch error {
            case .emptyRoleTitle:
                errorMessage = "Enter a job title."
            case .emptyCompanyName:
                errorMessage = "Enter a company name."
            case .emptyIndustry:
                errorMessage = "Enter an industry."
            case .deadlineInPast:
                errorMessage = "The application deadline cannot be in the past."
            }
        } catch {
            errorMessage = "Unable to create this job opportunity."
        }
    }
}
