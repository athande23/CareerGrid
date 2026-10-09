
import Foundation

enum JobOpportunitySortOption {
    case deadlineAscending
    case deadlineDescending
    case companyName
    case roleTitle
}

struct SortJobOpportunitiesUseCase {

    func execute(
        opportunities: [JobOpportunityModel],
        by option: JobOpportunitySortOption
    ) -> [JobOpportunityModel] {
        opportunities.sorted { first, second in
            switch option {
            case .deadlineAscending:
                return (first.applicationDeadline ?? .distantFuture)
                    < (second.applicationDeadline ?? .distantFuture)

            case .deadlineDescending:
                return (first.applicationDeadline ?? .distantPast)
                    > (second.applicationDeadline ?? .distantPast)

            case .companyName:
                return first.company.name.localizedCaseInsensitiveCompare(
                    second.company.name
                ) == .orderedAscending

            case .roleTitle:
                return first.roleTitle.localizedCaseInsensitiveCompare(
                    second.roleTitle
                ) == .orderedAscending
            }
        }
    }
}
