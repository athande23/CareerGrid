
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
            ZStack {
                CareerGridStyle.background.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading applications...")
                            .tint(CareerGridStyle.primaryBlue)
                    } else if viewModel.applications.isEmpty {
                        emptyState
                    } else {
                        applicationList
                    }
                }
            }
            .navigationTitle("Applications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadApplications()
            }
            .sheet(item: $selectedApplication) { application in
                applicationDetail(application)
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

    private var applicationList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your career pipeline")
                        .font(.system(size: 25, weight: .bold))

                    Text("Track your progress from application to offer.")
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                }
                .padding(.top, 12)

                HStack {
                    Text("Active applications")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Text("\(viewModel.applications.count)")
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
                    ForEach(viewModel.applications, id: \.id) { application in
                        Button {
                            selectedApplication = application
                        } label: {
                            applicationCard(application)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteApplication(
                                    id: application.id
                                )
                            } label: {
                                Label(
                                    "Delete application",
                                    systemImage: "trash"
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

    private func applicationCard(
        _ application: JobApplicationModel
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                CompanyLogoView(
                    companyName: application.opportunity.company.name
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(application.opportunity.roleTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(application.opportunity.company.name)
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)

                    Text("Applied \(application.applicationDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 7) {
                Circle()
                    .fill(CareerGridStyle.primaryBlue)
                    .frame(width: 8, height: 8)

                Text(application.currentStage.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CareerGridStyle.primaryBlue)
            }

            ApplicationProgressView(
                currentStage: application.currentStage
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CareerGridStyle.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "briefcase")
                .font(.system(size: 36))
                .foregroundStyle(CareerGridStyle.primaryBlue)
                .frame(width: 76, height: 76)
                .background(CareerGridStyle.primaryBlue.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text("No applications yet")
                .font(.title3.weight(.bold))

            Text("Jobs you apply for will appear here so you can track every stage.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func applicationDetail(
        _ application: JobApplicationModel
    ) -> some View {
        NavigationStack {
            ZStack {
                CareerGridStyle.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 12) {
                            CompanyLogoView(
                                companyName: application.opportunity.company.name
                            )

                            VStack(alignment: .leading, spacing: 5) {
                                Text(application.opportunity.roleTitle)
                                    .font(.title3.weight(.bold))

                                Text(application.opportunity.company.name)
                                    .foregroundStyle(
                                        CareerGridStyle.secondaryText
                                    )
                            }
                        }

                        detailCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Application progress")
                                    .font(.headline)

                                Text(application.currentStage.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CareerGridStyle.primaryBlue)

                                ApplicationProgressView(
                                    currentStage: application.currentStage
                                )

                                stageControls(application)
                            }
                        }

                        detailCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Application date")
                                    .font(.headline)

                                Label(
                                    application.applicationDate.formatted(
                                        date: .long,
                                        time: .omitted
                                    ),
                                    systemImage: "calendar"
                                )
                                .foregroundStyle(
                                    CareerGridStyle.secondaryText
                                )
                            }
                        }

                        detailCard {
                            stageDateSection(application)
                        }

                        detailCard {
                            notesSection(application)
                        }

                        Button(role: .destructive) {
                            viewModel.deleteApplication(id: application.id)
                            selectedApplication = nil
                        } label: {
                            Label(
                                "Delete application",
                                systemImage: "trash"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(CareerGridStyle.horizontalPadding)
                }
            }
            .navigationTitle("Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedApplication = nil
                    }
                }
            }
        }
    }

    private func detailCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CareerGridStyle.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    private func stageControls(
        _ application: JobApplicationModel
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.moveStageBackward(id: application.id)
                refreshSelectedApplication(id: application.id)
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.moveStageForward(id: application.id)
                refreshSelectedApplication(id: application.id)
            } label: {
                Label("Next", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func notesSection(
        _ application: JobApplicationModel
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

            TextField(
                "Add notes about this application...",
                text: Binding(
                    get: {
                        selectedApplication?.notes ?? application.notes ?? ""
                    },
                    set: { newValue in
                        viewModel.updateNotes(
                            id: application.id,
                            notes: newValue
                        )
                        refreshSelectedApplication(id: application.id)
                    }
                ),
                axis: .vertical
            )
            .lineLimit(4...8)
            .textFieldStyle(.roundedBorder)
        }
    }

    private func refreshSelectedApplication(id: UUID) {
        if let updatedApplication = viewModel.applications.first(
            where: { $0.id == id }
        ) {
            selectedApplication = updatedApplication
        }
    }

    private func stageDateConfiguration(
        for stage: ApplicationStage
    ) -> (title: String, eventType: CalendarEventType)? {
        switch stage {
        case .onlineAssessment:
            return ("OA Date", .onlineAssessment)
        case .interview:
            return ("Interview Date", .interview)
        case .finalInterview:
            return ("Final Interview Date", .finalInterview)
        default:
            return nil
        }
    }

    private func stageDateSection(
        _ application: JobApplicationModel
    ) -> some View {
        Group {
            if let configuration = stageDateConfiguration(
                for: application.currentStage
            ) {
                let event = viewModel.stageDateEvent(
                    applicationID: application.id,
                    eventType: configuration.eventType
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text(configuration.title)
                        .font(.headline)

                    Toggle(
                        "Add \(configuration.title)",
                        isOn: Binding(
                            get: {
                                viewModel.stageDateEvent(
                                    applicationID: application.id,
                                    eventType: configuration.eventType
                                ) != nil
                            },
                            set: { isEnabled in
                                if isEnabled {
                                    viewModel.setStageDate(
                                        applicationID: application.id,
                                        eventType: configuration.eventType,
                                        date: Date()
                                    )
                                } else {
                                    viewModel.clearStageDate(
                                        applicationID: application.id,
                                        eventType: configuration.eventType
                                    )
                                }
                            }
                        )
                    )

                    if let event {
                        DatePicker(
                            configuration.title,
                            selection: Binding(
                                get: { event.date },
                                set: { newDate in
                                    viewModel.setStageDate(
                                        applicationID: application.id,
                                        eventType: configuration.eventType,
                                        date: newDate
                                    )
                                }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    } else {
                        Text("Add a date to display this event on your calendar.")
                            .font(.caption)
                            .foregroundStyle(CareerGridStyle.secondaryText)
                    }
                }
            }
        }
    }
}

#Preview("Applications") {
    ApplicationView(repository: MockCareerGridRepository())
}
