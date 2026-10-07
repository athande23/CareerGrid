import Foundation

enum ApplicationStage: String, CaseIterable, Codable {
    case applied
    case onlineAssessment
    case interview
    case finalInterview
    case decision
    case offer
    case rejected
    
    var displayName: String {
        switch self {
        case .applied:
            return "Applied"
        case .onlineAssessment:
            return "Online Assessment"
        case .interview:
            return "Interview"
        case .finalInterview:
            return "Final Interview"
        case .decision:
            return "Decision"
        case .offer:
            return "Offer"
        case .rejected:
            return "Rejected"
        }
    }
}
