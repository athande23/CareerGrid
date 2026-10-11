
import SwiftUI
import WidgetKit

struct ContentView: View {
    private let repository: CareerGridRepository

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let repository = CoreDataCareerGridRepository()
        self.repository = repository

        do {
            try SeedJobOpportunitiesUseCase(
                repository: repository
            ).execute(
                opportunities: CareerGridSeedData.opportunities
            )

            let applications = try repository.fetchApplications()

            let seedQuestions = SeedInterviewQuestionsUseCase(
                repository: repository
            )

            for application in applications {
                try seedQuestions.execute(for: application)
            }
        } catch {
            print("CareerGrid initialisation failed: \(error)")
        }
    }

    var body: some View {
        TabView {
            HomeView(repository: repository)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SavedView(repository: repository)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }

            ApplicationView(repository: repository)
                .tabItem {
                    Label("Applications", systemImage: "briefcase")
                }

            InterviewPreparationView(repository: repository)
                .tabItem {
                    Label("Practice", systemImage: "checklist")
                }

            CalendarView(repository: repository)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .onAppear {
            importPendingShareDrafts()
            refreshWidgetData()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                importPendingShareDrafts()
                refreshWidgetData()
            }
        }
    }


    private func importPendingShareDrafts() {
        do {
            let transfers = try ShareDraftTransferStore.fetchAll()

            guard !transfers.isEmpty else {
                return
            }

            let createUseCase = CreateJobOpportunityUseCase(
                repository: repository
            )

            var importedAtLeastOne = false

            for transfer in transfers {
                do {
                    let sourceURL = transfer.urlString.flatMap {
                        URL(string: $0)
                    }

                    try createUseCase.execute(
                        roleTitle: transfer.roleTitle,
                        companyName: transfer.companyName,
                        industry: transfer.industry,
                        location: transfer.location,
                        description: transfer.description,
                        requirements: transfer.requirements,
                        interviewProcess: transfer.interviewProcess,
                        sourceURL: sourceURL,
                        applicationDeadline: transfer.applicationDeadline,
                        degreeRequirement: transfer.degreeRequirement
                    )

                    try ShareDraftTransferStore.remove(
                        id: transfer.id
                    )

                    importedAtLeastOne = true
                } catch {
                    print(
                        "Unable to import shared opportunity \(transfer.roleTitle): \(error)"
                    )
                }
            }

            if importedAtLeastOne {
                refreshWidgetData()
            }
        } catch {
            print(
                "Unable to read pending shared opportunities: \(error)"
            )
        }
    }

    private func refreshWidgetData() {
        WidgetSnapshotRefresher(repository: repository).refresh()
    }
}

#Preview("CareerGrid") {
    ContentView()
}
