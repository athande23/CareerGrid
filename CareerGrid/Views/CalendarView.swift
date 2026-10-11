
import SwiftUI

struct CalendarView: View {
    @State private var viewModel: CalendarViewModel
    @State private var selectedDate = Date()
    @State private var activeSheet: CalendarSheet?

    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: CalendarViewModel(repository: repository)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CareerGridStyle.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    calendarHeader

                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(CareerGridStyle.primaryBlue)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    .background(.white)

                    Divider()
                        .overlay(CareerGridStyle.border)

                    eventList
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add(selectedDate)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(CareerGridStyle.primaryBlue)
                            .clipShape(Circle())
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
                    get: { viewModel.errorMessage != nil },
                    set: {
                        if !$0 {
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
        .tint(CareerGridStyle.primaryBlue)
    }

    private var calendarHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your schedule")
                    .font(.system(size: 23, weight: .bold))

                Text("Keep track of assessments and interviews.")
                    .font(.subheadline)
                    .foregroundStyle(CareerGridStyle.secondaryText)
            }

            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(CareerGridStyle.primaryBlue)
                .frame(width: 48, height: 48)
                .background(CareerGridStyle.primaryBlue.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, CareerGridStyle.horizontalPadding)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(.white)
    }

    private var eventList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading events...")
                    .tint(CareerGridStyle.primaryBlue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage,
                      viewModel.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 34))
                        .foregroundStyle(CareerGridStyle.primaryBlue)

                    Text("Unable to load events")
                        .font(.headline)

                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        viewModel.loadEvents()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                selectedDateEvents
            }
        }
    }

    private var selectedDateEvents: some View {
        let events = eventsForSelectedDate()

        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            selectedDate.formatted(
                                .dateTime.weekday(.wide)
                                    .day()
                                    .month(.wide)
                            )
                        )
                        .font(.system(size: 19, weight: .bold))

                        Text(
                            events.isEmpty
                                ? "Nothing scheduled"
                                : "\(events.count) scheduled event\(events.count == 1 ? "" : "s")"
                        )
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                    }

                    Spacer()

                    Button {
                        activeSheet = .add(selectedDate)
                    } label: {
                        Label("Add event", systemImage: "plus")
                            .font(.caption.weight(.semibold))
                    }
                }

                if events.isEmpty {
                    emptyDateState
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(events) { event in
                            eventRow(event)
                        }
                    }
                }
            }
            .padding(.horizontal, CareerGridStyle.horizontalPadding)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
    }

    private var emptyDateState: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundStyle(CareerGridStyle.primaryBlue)

            Text("No events for this date")
                .font(.headline)

            Text("Add an interview, assessment or reminder to plan ahead.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                activeSheet = .add(selectedDate)
            } label: {
                Label("Add event", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(CareerGridStyle.primaryBlue)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    private func eventsForSelectedDate() -> [CalendarEventModel] {
        let calendar = Calendar.current

        return viewModel.events
            .filter { event in
                calendar.isDate(event.date, inSameDayAs: selectedDate)
            }
            .sorted { $0.date < $1.date }
    }

    private func eventRow(_ event: CalendarEventModel) -> some View {
        Button {
            activeSheet = .edit(event)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 5) {
                    Image(systemName: iconName(for: event.eventType))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CareerGridStyle.primaryBlue)
                        .frame(width: 44, height: 44)
                        .background(
                            CareerGridStyle.primaryBlue.opacity(0.10)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Rectangle()
                        .fill(CareerGridStyle.border)
                        .frame(width: 2, height: 18)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        event.date.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CareerGridStyle.primaryBlue)

                    Text(event.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(event.eventType.displayName)
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)

                    if let notes = event.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(CareerGridStyle.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: CareerGridStyle.cornerRadius
                )
                .stroke(CareerGridStyle.border, lineWidth: 1)
            }
            .contentShape(
                RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
            )
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

    private func iconName(for eventType: CalendarEventType) -> String {
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

    let onSave: (String, Date, CalendarEventType, String?) -> Bool

    init(
        title: String,
        date: Date,
        eventType: CalendarEventType,
        notes: String,
        onSave: @escaping (String, Date, CalendarEventType, String?) -> Bool
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
                Section("Event details") {
                    TextField("Title", text: $title)

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    Picker("Type", selection: $eventType) {
                        ForEach(CalendarEventType.allCases, id: \.self) { type in
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
        .tint(CareerGridStyle.primaryBlue)
    }

    private func saveEvent() {
        guard !isSaving else { return }

        isSaving = true

        let trimmedNotes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let didSave = onSave(
            title,
            date,
            eventType,
            trimmedNotes.isEmpty ? nil : trimmedNotes
        )

        isSaving = false

        if didSave {
            dismiss()
        }
    }
}
