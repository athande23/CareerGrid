
import Foundation

struct FilterJobOpportunitiesUseCase {

    func execute(
        opportunities: [JobOpportunityModel],
        industry: String? = nil,
        degreeRequirement: String? = nil
    ) -> [JobOpportunityModel] {
        opportunities.filter { opportunity in
            let matchesIndustry: Bool

            if let industry,
               !industry.isEmpty,
               industry != "All" {
                matchesIndustry =
                    opportunity.industry.localizedCaseInsensitiveCompare(
                        industry
                    ) == .orderedSame
            } else {
                matchesIndustry = true
            }

            let matchesDegree: Bool

            if let degreeRequirement,
               !degreeRequirement.isEmpty,
               degreeRequirement != "All" {
                matchesDegree =
                    opportunity.requirements?.localizedCaseInsensitiveContains(
                        degreeRequirement
                    ) ?? false
            } else {
                matchesDegree = true
            }

            return matchesIndustry && matchesDegree
        }
    }
}
