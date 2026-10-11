import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var activeSheet: HomeSheet?

    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: HomeViewModel(repository: repository)
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading opportunities...")
                } else if viewModel.opportunities.isEmpty {
                    emptyState
                } else {
                    opportunityList
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add opportunity")
                }
            }
            .onAppear {
                viewModel.loadOpportunities()
            }
            .sheet(item: $activeSheet, onDismiss: {
                viewModel.loadOpportunities()
            }) { sheet in
                switch sheet {
                case .add:
                    AddOpportunityView(
                        onSave: handleNewOpportunity
                    )

                case .details(let opportunity):
                    OpportunityDetailView(
                        opportunity: opportunity,
                        onSave: {
                            viewModel.saveOpportunity(id: opportunity.id)
                        },
                        onApply: {
                            viewModel.applyToOpportunity(id: opportunity.id)
                        }
                    )
                }
            }
            .alert(
                "Error",
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
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No job opportunities")
                .font(.headline)

            Text("Add a job opportunity to get started.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var opportunityList: some View {
        List {
            ForEach(viewModel.opportunities) { opportunity in
                Button {
                    activeSheet = .details(opportunity)
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
                           !location.trimmingCharacters(
                               in: .whitespacesAndNewlines
                           ).isEmpty {
                            Label(
                                location,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        if let degree = opportunity.degreeRequirement,
                           !degree.trimmingCharacters(
                               in: .whitespacesAndNewlines
                           ).isEmpty {
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
                                    ? .red : .secondary
                            )
                        }
                    }
                    .padding(.vertical, 4)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func handleNewOpportunity(
        roleTitle: String,
        companyName: String,
        industry: String,
        location: String?,
        description: String?,
        requirements: String?,
        interviewProcess: String?,
        sourceURL: URL?,
        applicationDeadline: Date?,
        degreeRequirement: String?
    ) {
        viewModel.addOpportunity(
            roleTitle: roleTitle,
            companyName: companyName,
            industry: industry,
            location: location,
            description: description,
            requirements: requirements,
            interviewProcess: interviewProcess,
            sourceURL: sourceURL,
            applicationDeadline: applicationDeadline,
            degreeRequirement: degreeRequirement
        )
    }
}

private enum HomeSheet: Identifiable {
    case add
    case details(JobOpportunityModel)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .details(let opportunity):
            return opportunity.id.uuidString
        }
    }
}

#Preview {
    HomeView(
        repository: CoreDataCareerGridRepository()
    )
}
