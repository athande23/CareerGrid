import SwiftUI

struct ContentView: View {
    
    private let repository: CareerGridRepository
    
    init() {
        repository = CoreDataCareerGridRepository()
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
