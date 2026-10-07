import Foundation

struct ShareDraftModel: Identifiable, Equatable {
    let id: UUID
    var title: String
    var url: URL?
    var receivedAt: Date
    var processed: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        url: URL? = nil,
        receivedAt: Date = Date(),
        processed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.receivedAt = receivedAt
        self.processed = processed
    }
}
