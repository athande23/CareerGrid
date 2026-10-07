import SwiftUI

struct HomeView: View {
    
    @State private var viewModel: HomeViewModel
    @State private var showingAddOpportunity = false
    @State private var selectedOpportunity: JobOpportunityModel?
    
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
                        showingAddOpportunity = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadOpportunities()
            }
            .sheet(isPresented: $showingAddOpportunity) {
                AddOpportunityView(
                    onSave: handleNewOpportunity
                )
            }
            .sheet(item: $selectedOpportunity) { opportunity in
                OpportunityDetailView(
                    opportunity: opportunity,
                    onSave: {
                        viewModel.saveOpportunity(
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
            Image(systemName: "briefcase")
                .font(.system(size: 40))
            
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
            ForEach(viewModel.opportunities, id: \.id) { opportunity in
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
                        
                        if let location = opportunity.location {
                            Text(location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if opportunity.applicationDeadline != nil {
                            Text("Application deadline set")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
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
        applicationDeadline: Date?
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
            applicationDeadline: applicationDeadline
        )
    }
}

#Preview {
    HomeView(
        repository: CoreDataCareerGridRepository()
    )
}


