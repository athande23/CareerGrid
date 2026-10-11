import SwiftUI

struct CalendarView: View {
    @State private var viewModel: CalendarViewModel
    @State private var selectedDate = Date()
    @State private var activeSheet: CalendarSheet?

    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: CalendarViewModel(
                repository: repository
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)

                Divider()

                eventList
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add(selectedDate)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add event")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add(let date):
                    CalendarEventFormView(
                        title: "",
                        date: date,
                        eventType: .custom,
                        notes: "",
                        onSave: { title, date, type, notes in
                            viewModel.addEvent(
                                title: title,
                                date: date,
                                eventType: type,
                                notes: notes
                            )
                            return viewModel.errorMessage == nil
                        }
                    )

                case .edit(let event):
                    CalendarEventFormView(
                        title: event.title,
                        date: event.date,
                        eventType: event.eventType,
                        notes: event.notes ?? "",
                        onSave: { title, date, type, notes in
                            viewModel.updateEvent(
                                id: event.id,
                                title: title,
                                date: date,
                                eventType: type,
                                notes: notes,
                                opportunityID: event.opportunityID,
                                applicationID: event.applicationID
                            )
                            return viewModel.errorMessage == nil
                        }
                    )
                }
            }
            .alert(
                "Calendar Error",
                isPresented: Binding(
                    get: {
                        viewModel.errorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.loadEvents()
            }
        }
    }

    private var eventList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading events...")
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            } else if let error = viewModel.errorMessage,
                      viewModel.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)

                    Text("Unable to load events")
                        .font(.headline)

                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        viewModel.loadEvents()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
            } else if eventsForSelectedDate().isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)

                    Text("No events")
                        .font(.headline)

                    Text("There are no events scheduled for this date.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Add Event") {
                        activeSheet = .add(selectedDate)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
            } else {
                List {
                    Section {
                        ForEach(eventsForSelectedDate()) { event in
                            eventRow(event)
                        }
                    } header: {
                        Text(
                            selectedDate.formatted(
                                .dateTime
                                    .weekday(.wide)
                                    .day()
                                    .month(.wide)
                            )
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func eventsForSelectedDate() -> [CalendarEventModel] {
        let calendar = Calendar.current

        return viewModel.events
            .filter { event in
                calendar.isDate(
                    event.date,
                    inSameDayAs: selectedDate
                )
            }
            .sorted { $0.date < $1.date }
    }

    private func eventRow(
        _ event: CalendarEventModel
    ) -> some View {
        Button {
            activeSheet = .edit(event)
        } label: {
            HStack(spacing: 14) {
                Image(
                    systemName: iconName(for: event.eventType)
                )
                .font(.title3)
                .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(event.eventType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(
                        event.date.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let notes = event.notes,
                       !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteEvent(id: event.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func iconName(
        for eventType: CalendarEventType
    ) -> String {
        switch eventType {
        case .applicationDeadline:
            return "calendar.badge.clock"
        case .onlineAssessment:
            return "checkmark.rectangle"
        case .interview:
            return "person.2"
        case .finalInterview:
            return "person.2.fill"
        case .decision:
            return "arrow.triangle.branch"
        case .custom:
            return "calendar"
        }
    }
}

private enum CalendarSheet: Identifiable {
    case add(Date)
    case edit(CalendarEventModel)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let event):
            return "edit-\(event.id.uuidString)"
        }
    }
}

private struct CalendarEventFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var date: Date
    @State private var eventType: CalendarEventType
    @State private var notes: String

    @State private var isSaving = false

    let onSave: (
        String,
        Date,
        CalendarEventType,
        String?
    ) -> Bool

    init(
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String,
        onSave: @escaping (
            String,
            Date,
            CalendarEventType,
            String?
        ) -> Bool
    ) {
        _title = State(initialValue: title)
        _date = State(initialValue: date)
        _eventType = State(initialValue: eventType)
        _notes = State(initialValue: notes)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField("Title", text: $title)

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )

                    Picker("Type", selection: $eventType) {
                        ForEach(
                            CalendarEventType.allCases,
                            id: \.self
                        ) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                }

                Section("Notes") {
                    TextField(
                        "Notes",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Calendar Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || isSaving
                    )
                }
            }
        }
    }

    private func saveEvent() {
        guard !isSaving else {
            return
        }

        isSaving = true

        let didSave = onSave(
            title,
            date,
            eventType,
            notes.nilIfBlank
        )

        isSaving = false

        if didSave {
            dismiss()
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }
}

#Preview {
    CalendarView(
        repository: MockCareerGridRepository()
    )
}
