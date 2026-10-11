
import SwiftUI

struct OpportunityCardView: View {
    let opportunity: JobOpportunityModel
    var onTap: (() -> Void)? = nil

    private var deadlineHasPassed: Bool {
        guard let deadline = opportunity.applicationDeadline else {
            return false
        }

        return Calendar.current.startOfDay(for: deadline)
            < Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    CompanyLogoView(
                        companyName: opportunity.company.name
                    )

                    VStack(alignment: .leading, spacing: 5) {
                        Text(opportunity.roleTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        Text(opportunity.company.name)
                            .font(.subheadline)
                            .foregroundStyle(
                                CareerGridStyle.secondaryText
                            )

                        Text(opportunity.industry)
                            .font(.caption)
                            .foregroundStyle(
                                CareerGridStyle.primaryBlue
                            )
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }

                if let location = opportunity.location,
                   !location.trimmingCharacters(
                       in: .whitespacesAndNewlines
                   ).isEmpty {
                    Label(
                        location,
                        systemImage: "mappin.and.ellipse"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        CareerGridStyle.secondaryText
                    )
                }

                if let degree = opportunity.degreeRequirement,
                   !degree.trimmingCharacters(
                       in: .whitespacesAndNewlines
                   ).isEmpty {
                    Label(
                        degree,
                        systemImage: "graduationcap"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        CareerGridStyle.secondaryText
                    )
                }

                if let deadline = opportunity.applicationDeadline {
                    Divider()
                        .overlay(CareerGridStyle.border)

                    deadlineRow(deadline)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CareerGridStyle.surface)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: CareerGridStyle.cornerRadius
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: CareerGridStyle.cornerRadius
                )
                .stroke(CareerGridStyle.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .contentShape(
            RoundedRectangle(
                cornerRadius: CareerGridStyle.cornerRadius
            )
        )
    }

    private func deadlineRow(_ deadline: Date) -> some View {
        let deadlineText = deadline.formatted(
            date: .abbreviated,
            time: .omitted
        )

        return HStack(spacing: 6) {
            Image(systemName: "calendar")

            Text("Deadline: " + deadlineText)

            Spacer()

            if deadlineHasPassed {
                Text("Closed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }
        }
        .font(.caption)
        .foregroundStyle(
            deadlineHasPassed
                ? Color.red
                : CareerGridStyle.secondaryText
        )
    }
}
