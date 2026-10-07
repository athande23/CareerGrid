import Foundation

enum CalendarEventType: String, CaseIterable, Codable {
    case applicationDeadline
    case onlineAssessment
    case interview
    case finalInterview
    case decision
    case custom
    
    var displayName: String {
        switch self {
        case .applicationDeadline:
            return "Application Deadline"
        case .onlineAssessment:
            return "Online Assessment"
        case .interview:
            return "Interview"
        case .finalInterview:
            return "Final Interview"
        case .decision:
            return "Decision"
        case .custom:
            return "Custom Event"
        }
    }
}
