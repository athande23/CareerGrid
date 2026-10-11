
import SwiftUI

struct InterviewPreparationView: View {
    @State private var viewModel: InterviewPreparationViewModel
    @State private var showingAddQuestion = false
    @State private var newQuestion = ""
    @State private var newAnswer = ""
    @State private var newCategory: InterviewQuestionCategory = .general
    @State private var notesDraft = ""

    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: InterviewPreparationViewModel(
                repository: repository
            )
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
                        practiceContent
                    }
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadApplications()

                if let application = viewModel.selectedApplication {
                    notesDraft = application.notes ?? ""
                }
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
            .sheet(isPresented: $showingAddQuestion) {
                addQuestionSheet
            }
        }
        .tint(CareerGridStyle.primaryBlue)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checklist")
                .font(.system(size: 36))
                .foregroundStyle(CareerGridStyle.primaryBlue)
                .frame(width: 76, height: 76)
                .background(CareerGridStyle.primaryBlue.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text("Prepare for your interviews")
                .font(.title3.weight(.bold))

            Text("Apply for a job to access role-specific interview preparation.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var practiceContent: some View {
        VStack(spacing: 0) {
            applicationPicker

            if viewModel.selectedApplication == nil {
                selectApplicationState
            } else {
                selectedApplicationContent
            }
        }
    }

    private var applicationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose an application")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CareerGridStyle.secondaryText)

            Picker(
                "Application",
                selection: Binding(
                    get: { viewModel.selectedApplication?.id },
                    set: { id in
                        guard let id,
                              let application = viewModel.applications.first(
                                where: { $0.id == id }
                              ) else {
                            return
                        }

                        viewModel.selectApplication(application)
                        notesDraft = application.notes ?? ""
                    }
                )
            ) {
                ForEach(viewModel.applications, id: \.id) { application in
                    Text(
                        "\(application.opportunity.roleTitle) · \(application.opportunity.company.name)"
                    )
                    .tag(Optional(application.id))
                }
            }
            .pickerStyle(.menu)
            .tint(CareerGridStyle.primaryBlue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(CareerGridStyle.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, CareerGridStyle.horizontalPadding)
        .padding(.vertical, 14)
        .background(.white)
    }

    private var selectApplicationState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase")
                .font(.system(size: 32))
                .foregroundStyle(CareerGridStyle.primaryBlue)

            Text("Select an application")
                .font(.headline)

            Text("Choose a job above to view its interview preparation.")
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedApplicationContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                applicationHeader
                interviewProcessSection
                questionsSection
                notesSection
            }
            .padding(.horizontal, CareerGridStyle.horizontalPadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }

    private var applicationHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            CompanyLogoView(
                companyName: viewModel.selectedApplication?
                    .opportunity.company.name ?? ""
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(
                    viewModel.selectedApplication?
                        .opportunity.roleTitle ?? ""
                )
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)

                Text(
                    viewModel.selectedApplication?
                        .opportunity.company.name ?? ""
                )
                .font(.subheadline)
                .foregroundStyle(CareerGridStyle.secondaryText)

                if let stage = viewModel.selectedApplication?.currentStage {
                    Text(stage.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CareerGridStyle.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            CareerGridStyle.primaryBlue.opacity(0.10)
                        )
                        .clipShape(Capsule())
                        .padding(.top, 3)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var interviewProcessSection: some View {
        if let interviewProcess = viewModel.selectedApplication?
            .opportunity.interviewProcess,
           !interviewProcess.trimmingCharacters(
                in: .whitespacesAndNewlines
           ).isEmpty {
            detailCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Interview process", systemImage: "list.clipboard")
                        .font(.headline)

                    Text(interviewProcess)
                        .font(.subheadline)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interview questions")
                        .font(.system(size: 18, weight: .semibold))

                    Text("\(viewModel.interviewQuestions.count) questions")
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                }

                Spacer()

                Button {
                    newQuestion = ""
                    newAnswer = ""
                    newCategory = .general
                    showingAddQuestion = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            CareerGridStyle.primaryBlue.opacity(0.10)
                        )
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Add interview question")
            }

            if viewModel.interviewQuestions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(CareerGridStyle.primaryBlue)

                    Text("No questions yet")
                        .font(.subheadline.weight(.semibold))

                    Text("Add questions and example answers to practise for this role.")
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(22)
                .background(.white)
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
            } else {
                ForEach(viewModel.interviewQuestions, id: \.id) { question in
                    questionCard(question)
                }
            }
        }
    }

    private func questionCard(
        _ question: InterviewQuestionModel
    ) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 12) {
                Text("Example answer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CareerGridStyle.primaryBlue)

                Text(question.exampleAnswer)
                    .font(.subheadline)
                    .foregroundStyle(CareerGridStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(CareerGridStyle.border)

                HStack {
                    Text(question.category.displayName)
                        .font(.caption)
                        .foregroundStyle(CareerGridStyle.secondaryText)

                    Spacer()

                    Button(role: .destructive) {
                        viewModel.deleteQuestion(id: question.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .font(.caption.weight(.medium))
                    }
                }
            }
            .padding(.top, 12)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(question.category.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(CareerGridStyle.primaryBlue)

                Text(question.question)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Tap to reveal example answer")
                    .font(.caption)
                    .foregroundStyle(CareerGridStyle.secondaryText)
            }
        }
        .tint(CareerGridStyle.primaryBlue)
        .padding(16)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    private var notesSection: some View {
        detailCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Recruitment notes", systemImage: "note.text")
                    .font(.headline)

                Text("Keep reminders, recruiter details and preparation notes here.")
                    .font(.caption)
                    .foregroundStyle(CareerGridStyle.secondaryText)

                TextField(
                    "Add notes about the company or recruitment process...",
                    text: $notesDraft,
                    axis: .vertical
                )
                .lineLimit(4...8)
                .textFieldStyle(.roundedBorder)

                HStack {
                    Spacer()

                    Button {
                        viewModel.updateNotes(notes: notesDraft)
                    } label: {
                        Label("Save notes", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
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
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CareerGridStyle.cornerRadius)
                .stroke(CareerGridStyle.border, lineWidth: 1)
        }
    }

    private var addQuestionSheet: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField(
                        "Interview question",
                        text: $newQuestion,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("Example answer") {
                    TextField(
                        "Example answer",
                        text: $newAnswer,
                        axis: .vertical
                    )
                    .lineLimit(5...10)
                }

                Section("Category") {
                    Picker("Category", selection: $newCategory) {
                        ForEach(
                            InterviewQuestionCategory.allCases,
                            id: \.self
                        ) { category in
                            Text(category.displayName)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddQuestion = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addQuestion()
                    }
                    .disabled(
                        newQuestion.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        newAnswer.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        viewModel.selectedApplication == nil
                    )
                }
            }
        }
        .tint(CareerGridStyle.primaryBlue)
    }

    private func addQuestion() {
        let didSave = viewModel.addQuestion(
            question: newQuestion,
            exampleAnswer: newAnswer,
            category: newCategory
        )

        if didSave {
            showingAddQuestion = false
            newQuestion = ""
            newAnswer = ""
            newCategory = .general
        }
    }
}

#Preview("Practice") {
    InterviewPreparationView(
        repository: MockCareerGridRepository()
    )
}
