import SwiftUI

struct Choice: Codable, Identifiable {
    var  id: Int
    var choice_text: String
    var is_correct: Bool
}

struct Question: Codable, Identifiable {
    let id: Int
    let question_text: String
    let choices: [Choice]
}

