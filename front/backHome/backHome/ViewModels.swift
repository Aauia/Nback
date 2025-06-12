import SwiftUI
import Foundation

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadQuestions() {
        isLoading = true
        QuizAPIService.shared.fetchAllQuestions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let questions):
                    self?.questions = questions
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func delete(question: Question) {
        QuizAPIService.shared.deleteQuestion(id: question.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.questions.removeAll { $0.id == question.id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

