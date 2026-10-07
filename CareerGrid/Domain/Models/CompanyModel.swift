import Foundation

struct CompanyModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var websiteURL: URL?
    var description: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        websiteURL: URL? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.websiteURL = websiteURL
        self.description = description
    }
}
