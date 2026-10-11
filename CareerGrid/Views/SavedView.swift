
import SwiftUI

struct SavedView: View {
    @State private var viewModel: SavedViewModel
    @State private var selectedOpportunity: JobOpportunityModel?

    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: SavedViewModel(repository: repository)
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading saved jobs...")
                } else if viewModel.savedOpportunities.isEmpty {
                    emptyState
                } else {
                    opportunityList
                }
            }
            .navigationTitle("Saved")
            .onAppear {
                viewModel.loadSavedOpportunities()
            }
            .sheet(item: $selectedOpportunity, onDismiss: {
                viewModel.loadSavedOpportunities()
            }) { opportunity in
                OpportunityDetailView(
                    opportunity: opportunity,
                    onSave: {
                        viewModel.removeSavedOpportunity(
                            id: opportunity.id
                        )
                        selectedOpportunity = nil
                    },
                    onApply: {
                        viewModel.applyToOpportunity(
                            id: opportunity.id
                        )
                        selectedOpportunity = nil
                    }
                )
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: {
                        viewModel.errorMessage != nil
                    },
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
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No saved jobs")
                .font(.headline)

            Text("Jobs you save will appear here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var opportunityList: some View {
        List {
            ForEach(viewModel.savedOpportunities) { opportunity in
                Button {
                    selectedOpportunity = opportunity
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(opportunity.roleTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(opportunity.company.name)
                            .foregroundStyle(.secondary)

                        Text(opportunity.industry)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let location = opportunity.location,
                           !location.isEmpty {
                            Label(location, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let degree = opportunity.degreeRequirement,
                           !degree.isEmpty {
                            Label(
                                degree,
                                systemImage: "graduationcap"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        if let deadline = opportunity.applicationDeadline {
                            Text(
                                "Deadline: \(deadline.formatted(date: .abbreviated, time: .omitted))"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                Calendar.current.startOfDay(for: deadline)
                                    < Calendar.current.startOfDay(for: .now)
                                    ? .red
                                    : .secondary
                            )
                        }
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Saved") {
    SavedView(
        repository: MockCareerGridRepository()
    )
}
