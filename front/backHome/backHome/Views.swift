import SwiftUI

struct QuizListView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                } else {
                    List {
                        ForEach(viewModel.questions) { question in
                            VStack(alignment: .leading) {
                                Text(question.question_text).font(.headline)
                                ForEach(question.choices) { choice in
                                    HStack {
                                        Text("- \(choice.choice_text)")
                                        if choice.is_correct {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.leading)
                                }
                                HStack {
                                    Spacer()
                                    Button(role: .destructive) {
                                        viewModel.delete(question: question)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quiz")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddQuestionView { newQuestion in
                    QuizAPIService.shared.createQuestion(newQuestion) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let created):
                                viewModel.questions.append(created)
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadQuestions()
            }
        }
    }
}
