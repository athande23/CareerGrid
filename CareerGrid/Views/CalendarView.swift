import SwiftUI

struct CalendarView: View {
    
    @State private var viewModel: CalendarViewModel
    
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var editingEvent: CalendarEventModel?
    
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
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add event")
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                CalendarEventFormView(
                    title: "",
                    date: selectedDate,
                    eventType: .custom,
                    notes: "",
                    onSave: { title, date, type, notes in
                        viewModel.addEvent(
                            title: title,
                            date: date,
                            eventType: type,
                            notes: notes,
                        )
                    }
                )
            }
            .sheet(item: $editingEvent) { event in
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
                    }
                )
            }
            .alert(
                "Calendar Error",
                isPresented: Binding(
                    get: {
                        viewModel.errorMessage != nil
                    },
                    set: { value in
                        if !value {
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
        let selectedEvents = eventsForSelectedDate()
        
        return Group {
            if selectedEvents.isEmpty {
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
                        showingAddEvent = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    Section {
                        ForEach(selectedEvents) { event in
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
        
        return viewModel.events.filter { event in
            calendar.isDate(
                event.date,
                inSameDayAs: selectedDate
            )
        }
    }
    
    private func eventRow(
        _ event: CalendarEventModel
    ) -> some View {
        Button {
            editingEvent = event
        } label: {
            HStack(spacing: 14) {
                Image(
                    systemName: iconName(
                        for: event.eventType
                    )
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
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteEvent(
                    id: event.id
                )
            } label: {
                Label(
                    "Delete",
                    systemImage: "trash"
                )
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

private struct CalendarEventFormView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var date: Date
    @State private var eventType: CalendarEventType
    @State private var notes: String
    
    let onSave: (
        String,
        Date,
        CalendarEventType,
        String?
    ) -> Void
    
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
        ) -> Void
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
                    TextField(
                        "Title",
                        text: $title
                    )
                    
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )
                    
                    Picker(
                        "Type",
                        selection: $eventType
                    ) {
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
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Save") {
                        onSave(
                            title,
                            date,
                            eventType,
                            notes.nilIfBlank
                        )
                        
                        dismiss()
                    }
                    .disabled(
                        title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
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
