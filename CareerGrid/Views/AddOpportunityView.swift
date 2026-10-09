import SwiftUI

struct AddOpportunityView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (
        String,
        String,
        String,
        String?,
        String?,
        String?,
        String?,
        URL?,
        Date?
    ) -> Void
    
    @State private var roleTitle = ""
    @State private var companyName = ""
    @State private var industry = ""
    @State private var location = ""
    @State private var description = ""
    @State private var requirements = ""
    @State private var interviewProcess = ""
    @State private var sourceURL = ""
    
    @State private var hasDeadline = false
    @State private var applicationDeadline = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Job Details") {
                    TextField("Role Title", text: $roleTitle)
                    
                    TextField("Company", text: $companyName)
                    
                    TextField("Industry", text: $industry)
                    
                    TextField("Location", text: $location)
                }
                
                Section("Application") {
                    Toggle("Application Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker(
                            "Deadline",
                            selection: $applicationDeadline,
                            displayedComponents: .date
                        )
                    }
                    
                    TextField(
                        "Source URL",
                        text: $sourceURL
                    )
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                }
                
                Section("Job Information") {
                    TextField(
                        "Description",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    
                    TextField(
                        "Requirements",
                        text: $requirements,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    
                    TextField(
                        "Interview Process",
                        text: $interviewProcess,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Opportunity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveOpportunity()
                    }
                    .disabled(
                        roleTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        companyName.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        industry.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }
    
    private func saveOpportunity() {
        let url = URL(string: sourceURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        ))
        
        onSave(
            roleTitle,
            companyName,
            industry,
            location,
            description,
            requirements,
            interviewProcess,
            url,
            hasDeadline ? applicationDeadline : nil
        )
        
        dismiss()
    }
}
