
import Foundation

struct WidgetDeadline: Codable {
    let roleTitle: String
    let companyName: String
    let deadline: Date
}

struct WidgetSnapshot: Codable {
    let nextDeadline: WidgetDeadline?
    let updatedAt: Date
}

enum WidgetDataProvider {

    static let appGroupIdentifier = "group.com.example.CareerGrid"

    private static let storageKey = "careerGridWidgetSnapshot"

    static func save(_ snapshot: WidgetSnapshot) throws {
        guard let defaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            throw WidgetDataError.sharedContainerUnavailable
        }

        let data = try JSONEncoder().encode(snapshot)
        defaults.set(data, forKey: storageKey)
    }

    static func load() -> WidgetSnapshot? {
        guard
            let defaults = UserDefaults(
                suiteName: appGroupIdentifier
            ),
            let data = defaults.data(forKey: storageKey)
        else {
            return nil
        }

        return try? JSONDecoder().decode(
            WidgetSnapshot.self,
            from: data
        )
    }
}

enum WidgetDataError: Error {
    case sharedContainerUnavailable
}
