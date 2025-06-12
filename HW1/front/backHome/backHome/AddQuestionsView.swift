
import Foundation
import SwiftUI

struct AddQuestionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var questionText = ""
    @State private var choices: [Choice] = [
        Choice(id: 1, choice_text: "", is_correct: false),
        Choice(id: 2, choice_text: "", is_correct: false)
    ]

    var onSave: (Question) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextField("Question Text", text: $questionText)
                }

                Section(header: Text("Choices")) {
                    ForEach(choices.indices, id: \.self)  { index in
                        VStack(alignment: .leading) {
                            TextField("Choice Text", text: $choices[index].choice_text)
                            Toggle("Correct", isOn: $choices[index].is_correct)
                        }
                    }
                    Button("Add Choice") {
                        choices.append(Choice(id: choices.count + 1, choice_text: "", is_correct: false))
                    }
                }
            }
            .navigationTitle("Add Question")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newQuestion = Question(id: 0, question_text: questionText, choices: choices)
                        onSave(newQuestion)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
