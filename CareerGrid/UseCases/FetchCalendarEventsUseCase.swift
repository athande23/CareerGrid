
import Foundation

struct FetchCalendarEventsUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute() throws -> [CalendarEventModel] {
        try repository.fetchCalendarEvents()
    }
}
