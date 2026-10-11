
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
                matchesIndustry =
                    opportunity.industry.localizedCaseInsensitiveCompare(
                        selectedIndustry
                    ) == .orderedSame
            } else {
                matchesIndustry = true
            }

            let matchesDegree: Bool

            if let selectedDegree,
               !selectedDegree.isEmpty,
               selectedDegree != "All degrees" {
                let eligibleDegrees = opportunity.degreeRequirement ?? ""

                matchesDegree =
                    eligibleDegrees.localizedCaseInsensitiveContains("Any degree")
                    || eligibleDegrees.localizedCaseInsensitiveContains(
                        selectedDegree
                    )
            } else {
                matchesDegree = true
            }

            return matchesIndustry && matchesDegree
        }
    }
}
