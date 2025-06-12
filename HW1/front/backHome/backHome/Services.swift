import SwiftUI



final class QuizAPIService {
    static let shared = QuizAPIService()
    private let baseURL = "http://127.0.0.1:8000"

    func fetchAllQuestions(completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/questions/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let questions = try JSONDecoder().decode([Question].self, from: data)
                completion(.success(questions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func createQuestion(_ question: Question, completion: @escaping (Result<Question, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/questions/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try JSONEncoder().encode(question)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let newQuestion = try JSONDecoder().decode(Question.self, from: data)
                completion(.success(newQuestion))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateQuestion(_ question: Question, completion: @escaping (Result<Question, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/questions/\(question.id)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try JSONEncoder().encode(question)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let updated = try JSONDecoder().decode(Question.self, from: data)
                completion(.success(updated))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func deleteQuestion(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/questions/\(id)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }




    enum NetworkError: Error {
        case invalidURL
        case noData
    }
}

