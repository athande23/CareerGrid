
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
                return compareDeadlines(
                    first.applicationDeadline,
                    second.applicationDeadline,
                    ascending: true
                )

            case .deadlineDescending:
                return compareDeadlines(
                    first.applicationDeadline,
                    second.applicationDeadline,
                    ascending: false
                )

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

    private func compareDeadlines(
        _ first: Date?,
        _ second: Date?,
        ascending: Bool
    ) -> Bool {
        switch (first, second) {
        case let (first?, second?):
            return ascending ? first < second : first > second

        case (_?, nil):
            return true

        case (nil, _?):
            return false

        case (nil, nil):
            return false
        }
    }
}
