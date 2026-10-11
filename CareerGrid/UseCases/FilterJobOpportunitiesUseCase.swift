
import Foundation

struct FilterJobOpportunitiesUseCase {
    func execute(
        opportunities: [JobOpportunityModel],
        industry: String? = nil,
        degreeRequirement: String? = nil
    ) -> [JobOpportunityModel] {
        let selectedIndustry = industry?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let selectedDegree = degreeRequirement?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return opportunities.filter { opportunity in
            let matchesIndustry: Bool

            if let selectedIndustry,
               !selectedIndustry.isEmpty,
               selectedIndustry != "All" {
                matchesIndustry = opportunity.industry
                    .localizedCaseInsensitiveCompare(selectedIndustry) == .orderedSame
            } else {
                matchesIndustry = true
            }

            let eligibleDegrees = opportunity.degreeRequirement?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let matchesDegree: Bool

            if let selectedDegree,
               !selectedDegree.isEmpty,
               selectedDegree != "All degrees" {
                let acceptsAnyDegree =
                    eligibleDegrees.localizedCaseInsensitiveContains("Any degree")

                let degreeList = eligibleDegrees
                    .split(separator: ",")
                    .map {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                let matchesSpecificDegree = degreeList.contains {
                    $0.localizedCaseInsensitiveContains(selectedDegree)
                        || selectedDegree.localizedCaseInsensitiveContains($0)
                }

                matchesDegree = acceptsAnyDegree || matchesSpecificDegree
            } else {
                matchesDegree = true
            }

            return matchesIndustry && matchesDegree
        }
    }
}
