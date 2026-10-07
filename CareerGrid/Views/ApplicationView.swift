import SwiftUI

struct ApplicationView: View {
    
    @State private var viewModel: ApplicationsViewModel
    @State private var selectedApplication: JobApplicationModel?
    
    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: ApplicationsViewModel(repository: repository)
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading applications...")
                } else if viewModel.applications.isEmpty {
                    emptyState
                } else {
                    applicationList
                }
            }
            .navigationTitle("Applications")
            .onAppear {
                viewModel.loadApplications()
            }
            .sheet(item: $selectedApplication) { application in
                applicationDetail(application)
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
            
            Text("No applications")
                .font(.headline)
            
            Text("Jobs you apply for will appear here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var applicationList: some View {
        List {
            ForEach(
                viewModel.applications,
                id: \.id
            ) { application in
                
                Button {
                    selectedApplication = application
                } label: {
                    applicationRow(application)
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                for offset in offsets {
                    let application = viewModel.applications[offset]
                    viewModel.deleteApplication(
                        id: application.id
                    )
                }
            }
        }
    }
    
    private func applicationRow(
        _ application: JobApplicationModel
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(application.opportunity.roleTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(application.opportunity.company.name)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(
                "Applied: \(application.applicationDate.formatted())"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text(application.currentStage.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            ApplicationProgressView(
                currentStage: application.currentStage
            )
        }
        .padding(.vertical, 6)
    }
    
    private func applicationDetail(
        _ application: JobApplicationModel
    ) -> some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {
                        Text(application.opportunity.roleTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(application.opportunity.company.name)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        Text("Application Stage")
                            .font(.headline)
                        
                        Text(application.currentStage.displayName)
                            .foregroundStyle(.secondary)
                        
                        ApplicationProgressView(
                            currentStage: application.currentStage
                        )
                    }
                    
                    stageControls(application)
                    
                    Divider()
                    
                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        Text("Application Date")
                            .font(.headline)
                        
                        Text(application.applicationDate.formatted())
                            .foregroundStyle(.secondary)
                    }
                    
                    notesSection(application)
                    
                    Button(role: .destructive) {
                        viewModel.deleteApplication(
                            id: application.id
                        )
                        selectedApplication = nil
                    } label: {
                        Label(
                            "Delete Application",
                            systemImage: "trash"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Done") {
                        selectedApplication = nil
                    }
                }
            }
        }
    }
    
    private func stageControls(
        _ application: JobApplicationModel
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.moveStageBackward(
                    id: application.id
                )
                refreshSelectedApplication(
                    id: application.id
                )
            } label: {
                Label(
                    "Previous",
                    systemImage: "chevron.left"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button {
                viewModel.moveStageForward(
                    id: application.id
                )
                refreshSelectedApplication(
                    id: application.id
                )
            } label: {
                Label(
                    "Next",
                    systemImage: "chevron.right"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func notesSection(
        _ application: JobApplicationModel
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text("Notes")
                .font(.headline)
            
            TextField(
                "Add notes about this application...",
                text: Binding(
                    get: {
                        application.notes ?? ""
                    },
                    set: { newValue in
                        viewModel.updateNotes(
                            id: application.id,
                            notes: newValue
                        )
                    }
                ),
                axis: .vertical
            )
            .lineLimit(4...8)
            .textFieldStyle(.roundedBorder)
        }
    }
    
    private func refreshSelectedApplication(
        id: UUID
    ) {
        if let updatedApplication = viewModel.applications.first(
            where: { $0.id == id }
        ) {
            selectedApplication = updatedApplication
        }
    }
}

#Preview("Applications") {
    ApplicationView(
        repository: CoreDataCareerGridRepository()
    )
}
