
import Foundation

struct ShareDraftTransfer: Codable, Identifiable {
    let id: UUID
    var roleTitle: String
    var companyName: String
    var industry: String
    var location: String?
    var description: String?
    var requirements: String?
    var interviewProcess: String?
    var urlString: String?
    var applicationDeadline: Date?
    var degreeRequirement: String?
    var receivedAt: Date

    init(
        id: UUID = UUID(),
        roleTitle: String,
        companyName: String,
        industry: String,
        location: String? = nil,
        description: String? = nil,
        requirements: String? = nil,
        interviewProcess: String? = nil,
        urlString: String? = nil,
        applicationDeadline: Date? = nil,
        degreeRequirement: String? = nil,
        receivedAt: Date = Date()
    ) {
        self.id = id
        self.roleTitle = roleTitle
        self.companyName = companyName
        self.industry = industry
        self.location = location
        self.description = description
        self.requirements = requirements
        self.interviewProcess = interviewProcess
        self.urlString = urlString
        self.applicationDeadline = applicationDeadline
        self.degreeRequirement = degreeRequirement
        self.receivedAt = receivedAt
    }
}

enum ShareDraftTransferStore {
    static let appGroupIdentifier = "group.com.example.CareerGrid"
    private static let storageKey = "careerGrid.pendingShareDrafts"

    static func fetchAll() throws -> [ShareDraftTransfer] {
        guard let defaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            throw ShareDraftTransferError.sharedContainerUnavailable
        }

        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }

        return try JSONDecoder().decode(
            [ShareDraftTransfer].self,
            from: data
        )
    }

    static func save(_ draft: ShareDraftTransfer) throws {
        guard let defaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            throw ShareDraftTransferError.sharedContainerUnavailable
        }

        var drafts = try fetchAll()
        drafts.append(draft)

        let data = try JSONEncoder().encode(drafts)
        defaults.set(data, forKey: storageKey)
    }

    static func remove(id: UUID) throws {
        guard let defaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            throw ShareDraftTransferError.sharedContainerUnavailable
        }

        let remainingDrafts = try fetchAll().filter {
            $0.id != id
        }

        let data = try JSONEncoder().encode(remainingDrafts)
        defaults.set(data, forKey: storageKey)
    }
}

enum ShareDraftTransferError: Error {
    case sharedContainerUnavailable
}
