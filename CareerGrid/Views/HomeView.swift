
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
            ZStack {
                CareerGridStyle.background
                    .ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading opportunities...")
                            .tint(CareerGridStyle.primaryBlue)
                    } else if viewModel.opportunities.isEmpty {
                        emptyState
                    } else {
                        opportunityList
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 7) {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundStyle(CareerGridStyle.primaryBlue)

                        Text("CareerGrid")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(CareerGridStyle.primaryBlue)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Add opportunity")
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadOpportunities()
            }
            .sheet(
                item: $activeSheet,
                onDismiss: {
                    viewModel.loadOpportunities()
                }
            ) { sheet in
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
        .tint(CareerGridStyle.primaryBlue)
    }

    private var opportunityList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Find your next opportunity")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("Explore roles and keep your career moving.")
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)

                HStack {
                    Text("Available opportunities")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Text("\(viewModel.opportunities.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CareerGridStyle.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            CareerGridStyle.primaryBlue.opacity(0.10)
                        )
                        .clipShape(Capsule())
                }

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.opportunities) { opportunity in
                        OpportunityCardView(
                            opportunity: opportunity
                        ) {
                            activeSheet = .details(opportunity)
                        }
                    }
                }
            }
            .padding(.horizontal, CareerGridStyle.horizontalPadding)
            .padding(.bottom, 24)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "briefcase")
                .font(.system(size: 36))
                .foregroundStyle(CareerGridStyle.primaryBlue)
                .frame(width: 76, height: 76)
                .background(
                    CareerGridStyle.primaryBlue.opacity(0.10)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text("No opportunities yet")
                .font(.title3.weight(.bold))

            Text("Add a job opportunity to start building your career pipeline.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                activeSheet = .add
            } label: {
                Label("Add opportunity", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(CareerGridStyle.primaryBlue)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview("CareerGrid Home") {
    HomeView(repository: MockCareerGridRepository())
}
