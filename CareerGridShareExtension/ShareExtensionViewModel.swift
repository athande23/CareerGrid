
import Foundation
import Combine

@MainActor
final class ShareExtensionViewModel: ObservableObject {
    @Published var roleTitle: String
    @Published var companyName = ""
    @Published var industry = ""
    @Published var location = ""
    @Published var degreeRequirement = ""
    @Published var description = ""
    @Published var requirements = ""
    @Published var interviewProcess = ""
    @Published var sourceURL: String
    @Published var hasDeadline = false
    @Published var applicationDeadline = Date()
    @Published var errorMessage: String?

    init(title: String, url: URL?) {
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        self.roleTitle = url == nil ? trimmedTitle : ""
        self.sourceURL = url?.absoluteString ?? ""
    }

    func saveOpportunity() -> Bool {
        let cleanRole = roleTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanCompany = companyName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanIndustry = industry.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanURL = sourceURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanRole.isEmpty else {
            errorMessage = "Enter a role title."
            return false
        }

        guard !cleanCompany.isEmpty else {
            errorMessage = "Enter a company name."
            return false
        }

        guard !cleanIndustry.isEmpty else {
            errorMessage = "Enter an industry."
            return false
        }

        var parsedURL: URL?

        if !cleanURL.isEmpty {
            guard
                let candidate = URL(string: cleanURL),
                let scheme = candidate.scheme?.lowercased(),
                ["http", "https"].contains(scheme),
                candidate.host != nil
            else {
                errorMessage = "Enter a valid URL starting with https:// or http://."
                return false
            }

            parsedURL = candidate
        }

        let cleanLocation = location.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanDegree = degreeRequirement.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let transfer = ShareDraftTransfer(
            roleTitle: cleanRole,
            companyName: cleanCompany,
            industry: cleanIndustry,
            location: cleanLocation.isEmpty ? nil : cleanLocation,
            description: description,
            requirements: requirements,
            interviewProcess: interviewProcess,
            urlString: parsedURL?.absoluteString,
            applicationDeadline: hasDeadline
                ? Calendar.current.startOfDay(for: applicationDeadline)
                : nil,
            degreeRequirement: cleanDegree.isEmpty ? nil : cleanDegree
        )

        do {
            try ShareDraftTransferStore.save(transfer)
            errorMessage = nil
            print("CareerGrid Share Extension: Draft saved to App Group.")
            return true
        } catch {
            print(
                "CareerGrid Share Extension: Failed to save draft: \(error)"
            )
            errorMessage = "Unable to transfer the opportunity to CareerGrid. Please check the App Group configuration."
            return false
        }
    }
}
