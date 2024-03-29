import Foundation
import Combine

class RequestManager {
    private var usedWords: [String: Set<String>] = [:]
    
    let categories: [String] = [
        "Places & Spaces",
        "Travel & Transit",
        "Household Items",
        "Cuisine & Beverages",
        "Life On Earth",
        "Relatives & Relations",
        "Random",
        "Gadgets & Innovations",
        "Past Chronicles",
        "Pop Culture",
        "Games & Contests"
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
                throw NSError(domain: "com.roguedeveloper.WhatThePhrase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No words found"])
            }
        } else {
            throw NSError(domain: "com.roguedeveloper.WhatThePhrase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No words found"])
        }
    }

    func resetUsedWords() {
        usedWords.removeAll()
    }
}
