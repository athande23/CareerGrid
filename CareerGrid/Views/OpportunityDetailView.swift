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
                            value: deadline.formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )

                        if Calendar.current.startOfDay(for: deadline)
                            < Calendar.current.startOfDay(for: .now) {
                            Label(
                                "This deadline has passed",
                                systemImage: "exclamationmark.circle"
                            )
                            .font(.caption)
                            .foregroundStyle(.red)
                        }
                    }

                    if let location = nonBlank(opportunity.location) {
                        informationRow(
                            title: "Location",
                            value: location
                        )
                    }

                    informationRow(
                        title: "Industry",
                        value: opportunity.industry
                    )

                    if let degree = nonBlank(
                        opportunity.degreeRequirement
                    ) {
                        informationRow(
                            title: "Degree Requirement",
                            value: degree
                        )
                    }

                    if let description = nonBlank(
                        opportunity.description
                    ) {
                        detailSection(
                            title: "Description",
                            text: description
                        )
                    }

                    if let requirements = nonBlank(
                        opportunity.requirements
                    ) {
                        detailSection(
                            title: "Requirements",
                            text: requirements
                        )
                    }

                    if let interviewProcess = nonBlank(
                        opportunity.interviewProcess
                    ) {
                        detailSection(
                            title: "Interview Process",
                            text: interviewProcess
                        )
                    }

                    if let sourceURL = opportunity.sourceURL {
                        Link(
                            destination: sourceURL
                        ) {
                            Label(
                                "View Original Job Posting",
                                systemImage: "arrow.up.right.square"
                            )
                            .font(.headline)
                        }
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
                .fixedSize(horizontal: false, vertical: true)

            Text(opportunity.company.name)
                .font(.title3)
                .foregroundStyle(.secondary)

            if opportunity.isSaved {
                Label(
                    "Saved opportunity",
                    systemImage: "bookmark.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onSave()
                dismiss()
            } label: {
                Label(
                    opportunity.isSaved
                        ? "Save Opportunity Again"
                        : "Save Opportunity",
                    systemImage: "bookmark"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(opportunity.isSaved)

            Button {
                onApply()
                dismiss()
            } label: {
                Label(
                    "Apply",
                    systemImage: "paperplane"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }

    private func nonBlank(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }
}
