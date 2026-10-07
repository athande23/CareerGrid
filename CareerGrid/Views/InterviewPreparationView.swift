import SwiftUI

struct InterviewPreparationView: View {
    
    @State private var viewModel: InterviewPreparationViewModel
    @State private var showingAddQuestion = false
    @State private var newQuestion = ""
    @State private var newAnswer = ""
    @State private var newCategory: InterviewQuestionCategory = .general
    
    init(repository: CareerGridRepository) {
        _viewModel = State(
            initialValue: InterviewPreparationViewModel(
                repository: repository
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading applications...")
                } else if viewModel.applications.isEmpty {
                    emptyState
                } else {
                    practiceContent
                }
            }
            .navigationTitle("Practice")
            .onAppear {
                viewModel.loadApplications()
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: {
                        viewModel.errorMessage != nil
                    },
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
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 40))
            
            Text("No applications")
                .font(.headline)
            
            Text("Apply for a job to start preparing for interviews.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var practiceContent: some View {
        VStack(spacing: 0) {
            applicationPicker
            
            Divider()
            
            if viewModel.selectedApplication == nil {
                selectApplicationState
            } else {
                selectedApplicationContent
            }
        }
    }
    
    private var applicationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Application")
                .font(.headline)
            
            Picker(
                "Application",
                selection: Binding(
                    get: {
                        viewModel.selectedApplication?.id
                    },
                    set: { id in
                        guard let id else {
                            return
                        }
                        
                        if let application = viewModel.applications.first(
                            where: { $0.id == id }
                        ) {
                            viewModel.selectApplication(application)
                        }
                    }
                )
            ) {
                ForEach(
                    viewModel.applications,
                    id: \.id
                ) { application in
                    Text(
                        "\(application.opportunity.roleTitle) - \(application.opportunity.company.name)"
                    )
                    .tag(Optional(application.id))
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
    
    private var selectApplicationState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase")
                .font(.system(size: 36))
            
            Text("Select an application")
                .font(.headline)
            
            Text("Choose a job above to view interview preparation.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
    
    private var selectedApplicationContent: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                applicationHeader
                
                interviewProcessSection
                
                questionsSection
                
                notesSection
            }
            .padding()
        }
    }
    
    private var applicationHeader: some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            Text(
                viewModel.selectedApplication?
                    .opportunity.roleTitle ?? ""
            )
            .font(.title2)
            .fontWeight(.bold)
            
            Text(
                viewModel.selectedApplication?
                    .opportunity.company.name ?? ""
            )
            .font(.title3)
            .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var interviewProcessSection: some View {
        if let interviewProcess = viewModel.selectedApplication?
            .opportunity.interviewProcess,
           !interviewProcess.isEmpty {
            
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Text("Interview Process")
                    .font(.headline)
                
                Text(interviewProcess)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var questionsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            HStack {
                Text("Interview Questions")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    newQuestion = ""
                    newAnswer = ""
                    newCategory = .general
                    showingAddQuestion = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            if viewModel.interviewQuestions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                    
                    Text("No questions yet")
                        .font(.subheadline)
                    
                    Text("Add questions to practise for this role.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.08))
                )
            } else {
                ForEach(
                    viewModel.interviewQuestions,
                    id: \.id
                ) { question in
                    questionCard(question)
                }
            }
        }
    }
    
    private func questionCard(
        _ question: InterviewQuestionModel
    ) -> some View {
        DisclosureGroup {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                Text(question.exampleAnswer)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(question.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        viewModel.deleteQuestion(
                            id: question.id
                        )
                    } label: {
                        Label(
                            "Delete",
                            systemImage: "trash"
                        )
                        .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(question.question)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(question.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.08))
        )
    }
    
    private var notesSection: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text("Recruitment Notes")
                .font(.headline)
            
            TextField(
                "Add notes about the company or recruitment process...",
                text: Binding(
                    get: {
                        viewModel.selectedApplication?.notes ?? ""
                    },
                    set: { newValue in
                        viewModel.updateNotes(
                            notes: newValue
                        )
                    }
                ),
                axis: .vertical
            )
            .lineLimit(4...8)
            .textFieldStyle(.roundedBorder)
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
                
                Section("Example Answer") {
                    TextField(
                        "Example answer",
                        text: $newAnswer,
                        axis: .vertical
                    )
                    .lineLimit(5...10)
                }
                
                Section("Category") {
                    Picker(
                        "Category",
                        selection: $newCategory
                    ) {
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
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        showingAddQuestion = false
                    }
                }
                
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Add") {
                        addQuestion()
                    }
                    .disabled(
                        newQuestion
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty ||
                        newAnswer
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty ||
                        viewModel.selectedApplication == nil
                    )
                }
            }
        }
    }
    
    private func addQuestion() {
        viewModel.addQuestion(
            question: newQuestion,
            exampleAnswer: newAnswer,
            category: newCategory
        )
        
        showingAddQuestion = false
    }
}

#Preview("Practice") {
    InterviewPreparationView(
        repository: MockCareerGridRepository()
    )
}
