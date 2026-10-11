
import WidgetKit
import SwiftUI

struct CareerGridWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct CareerGridWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> CareerGridWidgetEntry {
        CareerGridWidgetEntry(
            date: Date(),
            snapshot: WidgetSnapshot(
                nextDeadline: WidgetDeadline(
                    roleTitle: "Graduate Software Engineer",
                    companyName: "Example Company",
                    deadline: Calendar.current.date(
                        byAdding: .day,
                        value: 7,
                        to: Date()
                    )!
                ),
                updatedAt: Date()
            )
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CareerGridWidgetEntry) -> Void
    ) {
        completion(
            CareerGridWidgetEntry(
                date: Date(),
                snapshot: WidgetDataProvider.load()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CareerGridWidgetEntry>) -> Void
    ) {
        let entry = CareerGridWidgetEntry(
            date: Date(),
            snapshot: WidgetDataProvider.load()
        )

        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date()
        )!

        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
        )
    }
}

struct CareerGridWidgetEntryView: View {
    let entry: CareerGridWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("NEXT DEADLINE", systemImage: "calendar")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            if let item = entry.snapshot?.nextDeadline {
                Text(item.roleTitle)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(item.deadline, format: .dateTime.day().month(.abbreviated).year())
                    .font(.subheadline.weight(.semibold))

                let daysRemaining = max(
                    0,
                    Calendar.current.dateComponents(
                        [.day],
                        from: Calendar.current.startOfDay(for: entry.date),
                        to: Calendar.current.startOfDay(for: item.deadline)
                    ).day ?? 0
                )

                Text(daysRemaining == 0 ? "Due today" : "\(daysRemaining) days remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else {
                Spacer(minLength: 0)

                Text("No upcoming deadlines")
                    .font(.headline)

                Text("Add a deadline to an opportunity in CareerGrid.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CareerGridWidget: Widget {
    let kind = "CareerGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CareerGridWidgetProvider()
        ) { entry in
            CareerGridWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CareerGrid Deadlines")
        .description("Keep track of your next job application deadline.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CareerGridWidget()
} timeline: {
    CareerGridWidgetEntry(
        date: .now,
        snapshot: nil
    )
}
