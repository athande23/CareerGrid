
import Foundation
import WidgetKit

struct WidgetSnapshotRefresher {
    private let repository: CareerGridRepository

    init(repository: CareerGridRepository) {
        self.repository = repository
    }

    func refresh() {
        do {
            let opportunities = try repository.fetchAllOpportunities()
            let today = Calendar.current.startOfDay(for: Date())

            let nextDeadline = opportunities
                .compactMap { opportunity -> WidgetDeadline? in
                    guard let deadline = opportunity.applicationDeadline,
                          deadline >= today else {
                        return nil
                    }

                    return WidgetDeadline(
                        roleTitle: opportunity.roleTitle,
                        companyName: opportunity.company.name,
                        deadline: deadline
                    )
                }
                .sorted { first, second in
                    first.deadline < second.deadline
                }
                .first

            let snapshot = WidgetSnapshot(
                nextDeadline: nextDeadline,
                updatedAt: Date()
            )

            try WidgetDataProvider.save(snapshot)
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            print(
                "CareerGrid: Failed to refresh widget: \(error)"
            )
        }
    }
}
