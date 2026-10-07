import Foundation

enum InterviewQuestionCategory: String, CaseIterable, Codable {
    case behavioural
    case technical
    case company
    case role
    case general
    
    var displayName: String {
        switch self {
        case .behavioural:
            return "Behavioural"
        case .technical:
            return "Technical"
        case .company:
            return "Company"
        case .role:
            return "Role"
        case .general:
            return "General"
        }
    }
}
