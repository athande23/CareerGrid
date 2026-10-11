
import Foundation

struct ShareDraftTransfer: Codable, Identifiable {
    let id: UUID
    var title: String
    var urlString: String?
    var receivedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        urlString: String? = nil,
        receivedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.urlString = urlString
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
