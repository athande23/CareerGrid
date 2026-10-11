import Foundation
import Observation

@Observable
final class SavedViewModel {
    private let fetchSavedOpportunitiesUseCase: FetchSavedOpportunitiesUseCase
    private let unsaveJobOpportunityUseCase: UnsaveJobOpportunityUseCase
    private let applyToSavedOpportunityUseCase: ApplyToSavedOpportunityUseCase

    var savedOpportunities: [JobOpportunityModel] = []
    var errorMessage: String?
    var isLoading = false

    init(repository: CareerGridRepository) {
        self.fetchSavedOpportunitiesUseCase = FetchSavedOpportunitiesUseCase(
            repository: repository
        )
        self.unsaveJobOpportunityUseCase = UnsaveJobOpportunityUseCase(
            repository: repository
        )
        self.applyToSavedOpportunityUseCase = ApplyToSavedOpportunityUseCase(
            repository: repository
        )
    }

    func loadSavedOpportunities() {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            savedOpportunities = try fetchSavedOpportunitiesUseCase.execute()
        } catch {
            errorMessage = "Unable to load saved opportunities."
        }
    }

    func removeSavedOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try unsaveJobOpportunityUseCase.execute(
                opportunityID: id
            )
            loadSavedOpportunities()
        } catch let error as UnsaveJobOpportunityError {
            switch error {
            case .opportunityNotFound:
                errorMessage = "This opportunity could not be found."
            case .notSaved:
                errorMessage = "This opportunity is no longer saved."
            }
        } catch {
            errorMessage = "Unable to remove this saved opportunity."
        }
    }

    func applyToOpportunity(id: UUID) {
        errorMessage = nil

        do {
            try applyToSavedOpportunityUseCase.execute(
                opportunityID: id
            )
            loadSavedOpportunities()
        } catch let error as ApplyToSavedOpportunityError {
            handleApplyError(error)
        } catch {
            errorMessage = "Unable to apply to this opportunity."
        }
    }

    private func handleApplyError(
        _ error: ApplyToSavedOpportunityError
    ) {
        switch error {
        case .opportunityNotFound:
            errorMessage = "This opportunity could not be found."
        case .opportunityNotSaved:
            errorMessage = "This opportunity is no longer saved."
        case .alreadyApplied:
            errorMessage = "You have already applied to this opportunity."
        }
    }
}
