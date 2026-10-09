import SwiftUI

struct OpportunityDetailView: View {
    
    let opportunity: JobOpportunityModel
    let onSave: () -> Void
    let onApply: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    headerSection
                    
                    Divider()
                    
                    if let deadline = opportunity.applicationDeadline {
                        informationRow(
                            title: "Application Deadline",
                            value: deadline.formatted(date: .abbreviated, time: .omitted)
                        )
                    }
                    
                    if let location = opportunity.location {
                        informationRow(
                            title: "Location",
                            value: location
                        )
                    }
                    
                    informationRow(
                        title: "Industry",
                        value: opportunity.industry
                    )
                    
                    if let description = opportunity.description,
                       !description.isEmpty {
                        detailSection(
                            title: "Description",
                            text: description
                        )
                    }
                    
                    if let requirements = opportunity.requirements,
                       !requirements.isEmpty {
                        detailSection(
                            title: "Requirements",
                            text: requirements
                        )
                    }
                    
                    if let interviewProcess = opportunity.interviewProcess,
                       !interviewProcess.isEmpty {
                        detailSection(
                            title: "Interview Process",
                            text: interviewProcess
                        )
                    }
                    
                    if let sourceURL = opportunity.sourceURL {
                        Link(
                            "View Original Job Posting",
                            destination: sourceURL
                        )
                        .font(.headline)
                    }
                    
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(opportunity.roleTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(opportunity.company.name)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    private func informationRow(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
    
    private func detailSection(
        title: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(text)
                .font(.body)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onSave()
                dismiss()
            } label: {
                Label("Save Opportunity", systemImage: "bookmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button {
                onApply()
                dismiss()
            } label: {
                Label("Apply", systemImage: "paperplane")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }
}
