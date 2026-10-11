
import Foundation

struct SaveJobOpportunityUseCase {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func execute(opportunityID: UUID) throws {
        guard var opportunity = try repository.fetchOpportunity(
            id: opportunityID
        ) else {
            throw SaveJobOpportunityError.opportunityNotFound
        }

        guard !opportunity.roleTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else {
            throw SaveJobOpportunityError.invalidRoleTitle
        }

        guard !opportunity.isSaved else {
            throw SaveJobOpportunityError.alreadySaved
        }

        opportunity.isSaved = true
        try repository.saveOpportunity(opportunity)

        guard let deadline = opportunity.applicationDeadline else {
            return
        }

        let existingEvents = try repository.fetchCalendarEvents()

        if let existingEvent = existingEvents.first(where: {
            $0.eventType == .applicationDeadline &&
            $0.opportunityID == opportunity.id
        }) {
            let updatedEvent = CalendarEventModel(
                id: existingEvent.id,
                title: "Application Deadline: \(opportunity.roleTitle) at \(opportunity.company.name)",
                date: deadline,
                eventType: .applicationDeadline,
                notes: existingEvent.notes,
                opportunityID: opportunity.id,
                applicationID: existingEvent.applicationID
            )

            try repository.updateCalendarEvent(updatedEvent)
        } else {
            let event = CalendarEventModel(
                title: "Application Deadline: \(opportunity.roleTitle) at \(opportunity.company.name)",
                date: deadline,
                eventType: .applicationDeadline,
                opportunityID: opportunity.id
            )

            try repository.saveCalendarEvent(event)
        }
    }
}

enum SaveJobOpportunityError: Error, Equatable {
    case opportunityNotFound
    case alreadySaved
    case invalidRoleTitle
}
