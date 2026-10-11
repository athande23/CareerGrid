
import SwiftUI

struct ContentView: View {

    private let repository: CareerGridRepository

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
            print("CareerGrid seeding failed: \(error)")
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
    }
}

#Preview("CareerGrid") {
    ContentView()
}
