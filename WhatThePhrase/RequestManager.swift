import Foundation
import Combine

class RequestManager {
    private var usedWords: [String: Set<String>] = [:]
    
    let categories: [String] = [
        "Geography",
        "Transportation",
        "Around The House",
        "Food/Drink",
        "Plants/Animals",
        "Family",
        "Everything",
        "Tech/Inventions",
        "History Buff",
        "Entertainment",
        "Sports/Games"
    ]
    
    let categoryKeywords: [String: String] = [
        "Geography": "country",
        "Transportation": "vehicle",
        "Around The House": "furniture",
        "Food/Drink": "food",
        "Plants/Animals": "animal",
        "Family": "family",
        "Everything": "random",
        "Tech/Inventions": "invention",
        "History Buff": "history",
        "Entertainment": "entertainment",
        "Sports/Games": "sport"
    ]

    func loadLocalWordlists() -> [String: [String]] {
        if let url = Bundle.main.url(forResource: "wordlists", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let wordlists = try? decoder.decode([String: [String]].self, from: data) {
                return wordlists
            }
        }
        return [:]
    }

    
    func asyncGetRandomWord(category: String) async throws -> String {
        let wordlists = loadLocalWordlists()
        
        if let words = wordlists[category] {
            let unusedWords = words.filter { !usedWords[category, default: []].contains($0) }
            if let randomWord = unusedWords.randomElement() {
                usedWords[category, default: []].insert(randomWord)
                return randomWord
            } else {
                throw NSError(domain: "com.example.catchphrase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No words found"])
            }
        } else {
            throw NSError(domain: "com.example.catchphrase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No words found"])
        }
    }

    func resetUsedWords() {
        usedWords.removeAll()
    }

    func getRandomWord(category: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let keyword = categoryKeywords[category] else { return }
        let url = createURL(for: keyword)

        _ = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Word].self, decoder: JSONDecoder())
            .tryMap { words -> String in
                print("Fetched words: \(words)") // Add this line to print fetched words
                if let randomWord = words.randomElement() {
                    return randomWord.word
                } else {
                    throw NSError(domain: "com.example.catchphrase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No words found"])
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .finished:
                    break
                }
            }, receiveValue: { word in
                DispatchQueue.main.async {
                    completion(.success(word))
                }
            })
    }
    
    private func createURL(for category: String) -> URL {
        let baseUrl = "https://api.datamuse.com/words?"
        let query = "ml=\(category)"
        let urlString = baseUrl + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
}

struct Word: Codable {
    let word: String
}
