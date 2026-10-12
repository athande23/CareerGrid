
import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let saveJobOpportunityUseCase: SaveJobOpportunityUseCase
    private let trackJobApplicationUseCase: TrackJobApplicationUseCase
    private let createJobOpportunityUseCase: CreateJobOpportunityUseCase
    private let fetchJobOpportunitiesUseCase: FetchJobOpportunitiesUseCase
    private let filterJobOpportunitiesUseCase: FilterJobOpportunitiesUseCase
    private let sortJobOpportunitiesUseCase: SortJobOpportunitiesUseCase
    private let repository: CareerGridRepository

    var opportunities: [JobOpportunityModel] = []
    var errorMessage: String?
    var isLoading = false

    var searchText = ""
    var selectedIndustry = "All"
    var selectedDegree = "All degrees"
    var selectedSortOption = JobOpportunitySortOption.deadlineAscending

    init(repository: CareerGridRepository) {
        self.repository = repository

        saveJobOpportunityUseCase = SaveJobOpportunityUseCase(
            repository: repository
        )

        trackJobApplicationUseCase = TrackJobApplicationUseCase(
            repository: repository
        )

        createJobOpportunityUseCase = CreateJobOpportunityUseCase(
            repository: repository
        )

        fetchJobOpportunitiesUseCase = FetchJobOpportunitiesUseCase(
            repository: repository
        )

        filterJobOpportunitiesUseCase = FilterJobOpportunitiesUseCase()
        sortJobOpportunitiesUseCase = SortJobOpportunitiesUseCase()
    }

    var industries: [String] {
        let values = Set(
            opportunities.map {
                $0.industry.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter { !$0.isEmpty }
        )

        return ["All"] + values.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    var degreeOptions: [String] {
        [
            "All degrees",
            "Computer Science",
            "Software Engineering",
            "Information Technology",
            "Data Science",
            "Engineering",
            "Business & Commerce",
            "Finance",
            "Economics",
            "Accounting",
            "Marketing & Communications",
            "Science",
            "Law & Policy",
            "Arts & Humanities",
            "Human Resources",
            "Psychology"
        ]
    }

    var filteredOpportunities: [JobOpportunityModel] {
        let filtered = filterJobOpportunitiesUseCase.execute(
            opportunities: opportunities,
            industry: selectedIndustry,
            degreeRequirement: selectedDegree
        )

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let searched = filtered.filter { opportunity in
            guard !query.isEmpty else { return true }

            let searchableValues = [
                opportunity.roleTitle,
                opportunity.company.name,
                opportunity.industry,
                opportunity.location ?? "",
                opportunity.degreeRequirement ?? "",
                opportunity.description ?? ""
            ]

            return searchableValues.contains {
                $0.localizedCaseInsensitiveContains(query)
            }
        }

        return sortJobOpportunitiesUseCase.execute(
            opportunities: searched,
            by: selectedSortOption
        )
    }

    func loadOpportunities() {
        isLoading = true
        defer { isLoading = false }

        do {
            opportunities = try fetchJobOpportunitiesUseCase.executeAvailable()

            if !industries.contains(selectedIndustry) {
                selectedIndustry = "All"
            }
        } catch {
            print("CareerGrid: Failed to load opportunities: \(error)")
            errorMessage = "The opportunity was saved, but the Home list could not be refreshed."
        }
    }


    func saveOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try saveJobOpportunityUseCase.execute(opportunityID: id)
            loadOpportunities()
        } catch let error as SaveJobOpportunityError {
            switch error {
            case .opportunityNotFound:
                errorMessage = "This job could not be found. Refresh the list and try again."
            case .alreadySaved:
                errorMessage = "This job is already in your saved list."
            case .invalidRoleTitle:
                errorMessage = "This job has incomplete information and cannot be saved."
            }
        } catch {
            print("CareerGrid: Failed to save opportunity: \(error)")
            errorMessage = "We couldn't save this job to your saved list. Please try again."
        }
    }



    func applyToOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try trackJobApplicationUseCase.execute(
                opportunityID: id
            )
            loadOpportunities()
        } catch let error as TrackJobApplicationError {
            switch error {
            case .opportunityNotFound:
                errorMessage =
                    "This job could not be found. Refresh the list and try again."

            case .invalidOpportunity:
                errorMessage =
                    "This job has incomplete information and cannot be applied to."

            case .opportunityNotSaved:
                errorMessage =
                    "Save this job before applying for it."

            case .applicationDateInFuture:
                errorMessage =
                    "The application date cannot be in the future."

            case .alreadyApplied:
                errorMessage =
                    "You have already applied for this job. Check your Applications list."
            }
        } catch {
            print("CareerGrid: Failed to load opportunities: \(error)")
            errorMessage = "We couldn't load job opportunities. Please try again."
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
            WidgetSnapshotRefresher(
                repository: repository
            ).refresh()
            
        } catch let error as CreateJobOpportunityError {
            switch error {
            case .emptyRoleTitle:
                errorMessage = "Enter a job title."
            case .emptyCompanyName:
                errorMessage = "Enter a company name."
            case .emptyIndustry:
                errorMessage = "Enter an industry."
            case .deadlineInPast:
                errorMessage = "The application deadline must be today or later."
            }
        } catch {
            print("CareerGrid: Failed to create opportunity: \(error)")
            errorMessage = "We couldn't save this job. Please check the details and try again."
        }
    }
}
