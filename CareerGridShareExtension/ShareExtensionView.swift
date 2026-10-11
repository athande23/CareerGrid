
import SwiftUI

struct ShareExtensionView: View {
    @ObservedObject var viewModel: ShareExtensionViewModel
    let onFinish: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Job Details") {
                    TextField("Role Title", text: $viewModel.roleTitle)
                    TextField("Company", text: $viewModel.companyName)
                    TextField("Industry", text: $viewModel.industry)
                    TextField("Location", text: $viewModel.location)

                    TextField(
                        "Degree Requirement (e.g. Computer Science)",
                        text: $viewModel.degreeRequirement
                    )
                }

                Section("Application") {
                    Toggle(
                        "Application Deadline",
                        isOn: $viewModel.hasDeadline
                    )

                    if viewModel.hasDeadline {
                        DatePicker(
                            "Deadline",
                            selection: $viewModel.applicationDeadline,
                            in: Date.now...,
                            displayedComponents: .date
                        )
                    }

                    TextField("Source URL", text: $viewModel.sourceURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Job Information") {
                    TextField(
                        "Description",
                        text: $viewModel.description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    TextField(
                        "Requirements",
                        text: $viewModel.requirements,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    TextField(
                        "Interview Process",
                        text: $viewModel.interviewProcess,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Opportunity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onFinish()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if viewModel.saveOpportunity() {
                            onFinish()
                        }
                    }
                }
            }
        }
    }
}
