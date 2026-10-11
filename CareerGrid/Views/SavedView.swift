
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
            ZStack {
                CareerGridStyle.background
                    .ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading saved opportunities...")
                            .tint(CareerGridStyle.primaryBlue)
                    } else if viewModel.savedOpportunities.isEmpty {
                        emptyState
                    } else {
                        savedList
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
                    },
                    onApply: {
                        viewModel.applyToOpportunity(
                            id: opportunity.id
                        )
                    }
                )
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

    private var savedList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your saved jobs")
                        .font(.system(size: 25, weight: .bold))

                    Text("Keep track of opportunities you want to revisit.")
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)

                HStack {
                    Text("Saved opportunities")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Text("\(viewModel.savedOpportunities.count)")
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
                    ForEach(viewModel.savedOpportunities) { opportunity in
                        OpportunityCardView(
                            opportunity: opportunity
                        ) {
                            selectedOpportunity = opportunity
                        }
                        .contextMenu {
                            Button {
                                viewModel.removeSavedOpportunity(
                                    id: opportunity.id
                                )
                            } label: {
                                Label(
                                    "Remove from Saved",
                                    systemImage: "bookmark.slash"
                                )
                            }
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
            Image(systemName: "bookmark")
                .font(.system(size: 36))
                .foregroundStyle(CareerGridStyle.primaryBlue)
                .frame(width: 76, height: 76)
                .background(
                    CareerGridStyle.primaryBlue.opacity(0.10)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text("No saved jobs yet")
                .font(.title3.weight(.bold))

            Text("Save opportunities from Home to keep them here.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Saved Opportunities") {
    SavedView(repository: MockCareerGridRepository())
}
