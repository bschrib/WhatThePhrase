import Foundation
import Combine

class RequestManager: ObservableObject {
    static let shared = RequestManager()
    
    private var usedWords: [String: Set<String>] = [:]
    private let queue = DispatchQueue(label: "com.whatthephrase.requestmanager", attributes: .concurrent)
    @Published var isKidsMode: Bool = false
    
    private init() {}
    
    private let kidsCategories: [String] = [
        "Animals",
        "Food",
        "Toys & Games",
        "Home",
        "Nature"
    ]
    
    private let regularCategories: [String] = [
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
    
    var categories: [String] {
        return isKidsMode ? kidsCategories : regularCategories
    }
    
    func loadLocalWordlists() -> [String: [String]] {
        let filename = isKidsMode ? "kids_wordlists" : "wordlists"
        print("\n📂 Loading wordlist: \(filename)")
        
        // Fallback word lists
        let fallbackWordlists: [String: [String]] = isKidsMode ? [
            "Animals": ["cat", "dog", "bird", "fish", "frog", "bear", "lion", "duck", "cow", "pig"],
            "Food": ["apple", "banana", "pizza", "cake", "milk", "juice", "bread", "cheese", "egg", "rice"],
            "Toys & Games": ["ball", "doll", "car", "block", "puzzle", "cards", "swing", "slide", "bike", "dice"],
            "Home": ["bed", "chair", "table", "door", "window", "light", "bath", "sink", "sofa", "lamp"],
            "Nature": ["tree", "flower", "grass", "sun", "moon", "star", "rain", "snow", "wind", "rock"]
        ] : [
            "Places & Spaces": ["beach", "mountain", "city", "park", "school", "home", "store", "restaurant", "airport", "hospital"],
            "Travel & Transit": ["car", "bus", "train", "airplane", "bicycle", "taxi", "subway", "boat", "scooter", "walking"],
            "Household Items": ["chair", "table", "lamp", "couch", "bed", "desk", "shelf", "mirror", "clock", "picture"],
            "Cuisine & Beverages": ["pizza", "hamburger", "salad", "soup", "sandwich", "coffee", "tea", "juice", "water", "soda"],
            "Life On Earth": ["tree", "flower", "ocean", "mountain", "river", "animal", "bird", "fish", "insect", "plant"]
        ]
        
        // First try to load from main bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Could not find \(filename).json in main bundle - using fallback word lists")
            print("📝 Fallback categories: \(fallbackWordlists.keys.sorted())")
            return fallbackWordlists
        }
        
        do {
            print("📄 Found \(filename).json at: \(url.path)")
            let data = try Data(contentsOf: url)
            let wordlists = try JSONDecoder().decode([String: [String]].self, from: data)
            
            // Validate that we have categories and words
            if wordlists.isEmpty {
                print("⚠️ Loaded empty wordlist from \(filename).json - using fallback")
                return fallbackWordlists
            }
            
            // Log each category and word count
            print("📊 Loaded categories and word counts:")
            for (category, words) in wordlists.sorted(by: { $0.key < $1.key }) {
                print("   - \(category): \(words.count) words")
                if words.isEmpty {
                    print("⚠️ Category '\(category)' has no words - using fallback")
                    return fallbackWordlists
                }
            }
            
            print("✅ Successfully loaded \(wordlists.count) categories from \(filename).json")
            return wordlists
            
        } catch {
            print("⚠️ Error loading \(filename).json: \(error.localizedDescription)")
            print("📝 Using fallback word lists with categories: \(fallbackWordlists.keys.sorted())")
            return fallbackWordlists
        }
    }

    func asyncGetRandomWord(category: String) async throws -> String {
        print("\n=== Getting random word for category: \(category) ===")
        let wordlists = loadLocalWordlists()
        
        // Debug: Print available categories and word counts
        print("📋 Available categories in wordlists: \(wordlists.keys.sorted())")
        print("🔍 Looking for category: '\(category)'")
        
        // Debug: Print current used words state
        print("📝 Current used words state:")
        queue.sync {
            for (cat, words) in usedWords {
                print("   - \(cat): \(words.count) words used")
            }
        }
        
        // First try to get a word from the specified category
        guard let words = wordlists[category] as? [String], !words.isEmpty else {
            print("❌ No words found in category '\(category)'")
            throw NSError(domain: "com.whatthephrase", code: 1, userInfo: [NSLocalizedDescriptionKey: "No words found in category \(category)"])
        }
        
        print("✅ Found \(words.count) words in category '\(category)'")
        
        // Thread-safe access to usedWords
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "com.whatthephrase", code: 2, userInfo: [NSLocalizedDescriptionKey: "RequestManager deallocated"]))
                    return
                }
                
                // Filter out used words
                let used = self.usedWords[category, default: []]
                let unusedWords = words.filter { !used.contains($0) }
                
                print("   - \(unusedWords.count) unused words available")
                
                if !unusedWords.isEmpty {
                    let randomWord = unusedWords.randomElement()!
                    self.usedWords[category, default: []].insert(randomWord)
                    print("🎯 Selected word: '\(randomWord)' from unused words")
                    continuation.resume(returning: randomWord)
                } else {
                    print("⚠️ No unused words left in category '\(category)' - resetting used words")
                    // Reset used words for this category and try again
                    self.usedWords[category] = []
                    if let randomWord = words.randomElement() {
                        self.usedWords[category] = [randomWord]
                        print("🔄 Reset used words and selected: '\(randomWord)'")
                        continuation.resume(returning: randomWord)
                    } else {
                        continuation.resume(throwing: NSError(domain: "com.whatthephrase", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to select a word"]))
                    }
                }
            }
        }
        
        // If we get here, try to find any word from any category
        print("⚠️ Couldn't find word in category '\(category)' - trying any available word")
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "com.whatthephrase", code: 2, userInfo: [NSLocalizedDescriptionKey: "RequestManager deallocated"]))
                    return
                }
                
                for (cat, catWords) in wordlists {
                    if let words = catWords as? [String], !words.isEmpty {
                        let used = self.usedWords[cat, default: []]
                        let unusedWords = words.filter { !used.contains($0) }
                        
                        if let randomWord = unusedWords.randomElement() {
                            self.usedWords[cat, default: []].insert(randomWord)
                            print("🎲 Selected random word '\(randomWord)' from category '\(cat)'")
                            continuation.resume(returning: randomWord)
                            return
                        } else if let randomWord = words.randomElement() {
                            self.usedWords[cat] = [randomWord] // Reset and use one word
                            print("🔄 Reset and selected random word '\(randomWord)' from category '\(cat)'")
                            continuation.resume(returning: randomWord)
                            return
                        }
                    }
                }
                
                // Last resort: return a default word based on the mode
                let defaultWord = self.isKidsMode ? "rainbow" : "word"
                print("⚠️ No words available at all - using fallback word: '\(defaultWord)'")
                continuation.resume(returning: defaultWord)
            }
        }
    }

    func resetUsedWords() {
        usedWords.removeAll()
    }
    
    func setKidsMode(_ enabled: Bool) {
        isKidsMode = enabled
        resetUsedWords()
    }
    
    func preloadWordlists() {
        // This forces the wordlists to be loaded and cached
        _ = loadLocalWordlists()
    }
}
