import SwiftUI

struct CalendarView: View {
    
    @State private var viewModel: CalendarViewModel
    @State private var showingAddEvent = false
    
    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: CalendarViewModel(repository: repository)
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading events...")
                } else if viewModel.events.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                        
                        Text("No upcoming events")
                            .font(.headline)
                        
                        Text("Application deadlines, interviews and other events will appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List(viewModel.events) { event in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.title)
                                .font(.headline)
                            
                            Text(event.eventType.displayName)
                                .foregroundStyle(.secondary)
                            
                            Text(
                                event.date.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                viewModel.loadEvents()
            }
            .sheet(isPresented: $showingAddEvent) {
                Text("Add Event")
                    .padding()
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
