import Foundation

enum ApplicationStatus: String, CaseIterable, Codable {
    case active
    case completed
    case withdrawn
    
    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        case .withdrawn:
            return "Withdrawn"
        }
    }
}
