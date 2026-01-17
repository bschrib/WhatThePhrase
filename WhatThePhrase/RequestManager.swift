import Foundation
import Combine

final class UsedWordsStore: @unchecked Sendable {
    private var usedWords: [String: Set<String>] = [:]
    private let queue = DispatchQueue(label: "com.whatthephrase.usedwords", attributes: .concurrent)
    
    func getRandomWord(category: String, words: [String], continuation: CheckedContinuation<String, Error>) {
        queue.async(flags: .barrier) {
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
    
    func resetUsedWords() {
        queue.async(flags: .barrier) {
            self.usedWords.removeAll()
        }
    }
    
    func getUsedWordsState() -> [String: Set<String>] {
        return queue.sync {
            return usedWords
        }
    }
}

final class RequestManager: ObservableObject {
    static let shared = RequestManager()
    
    private let usedWordsStore = UsedWordsStore()
    @Published var isKidsMode: Bool = false
    
    // Cache for merged wordlists to avoid reloading on every request
    private var cachedWordlists: [String: [String]]? = nil
    private var cachedMode: Bool? = nil
    
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
    
    // Category to tag mapping for dynamic word generation
    private let categoryTagMap: [String: [String]] = [
        "Places & Spaces": ["place"],
        "Travel & Transit": ["vehicle"],
        "Household Items": ["furniture", "home"],
        "Cuisine & Beverages": ["food"],
        "Life On Earth": ["animal"],
        "Relatives & Relations": ["family"],
        "Gadgets & Innovations": ["invention"],
        "Past Chronicles": ["history"],
        "Pop Culture": ["entertainment"],
        "Games & Contests": ["sport"]
    ]
    
    // Kids category to tag mapping
    private let kidsCategoryTagMap: [String: [String]] = [
        "Animals": ["animal"],
        "Food": ["food"],
        "Toys & Games": ["toy"],
        "Home": ["home"],
        "Nature": ["nature"]
    ]
    
    var categories: [String] {
        return isKidsMode ? kidsCategories : regularCategories
    }
    
    /// Loads word bank JSON (tag-based word collection)
    private func loadWordBank() -> [String: [String]]? {
        let filename = isKidsMode ? "kids_wordbank" : "wordbank"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Could not find \(filename).json in main bundle - word bank not available")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let wordBank = try JSONDecoder().decode([String: [String]].self, from: data)
            print("✅ Loaded word bank with \(wordBank.count) tags")
            return wordBank
        } catch {
            print("⚠️ Error loading \(filename).json: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Merges base wordlists with tag-based word bank words
    private func mergeWordlistsWithBank(baseWordlists: [String: [String]], wordBank: [String: [String]]?) -> [String: [String]] {
        guard let wordBank = wordBank else {
            return baseWordlists
        }
        
        let tagMap = isKidsMode ? kidsCategoryTagMap : categoryTagMap
        var mergedWordlists = baseWordlists
        
        // First pass: merge tags for all categories except Random
        for (category, words) in baseWordlists {
            // Skip Random category - will handle separately
            if category == "Random" {
                continue
            }
            
            var mergedWords = Set(words) // Start with base words, use Set to dedupe
            
            // Get tags for this category
            if let tags = tagMap[category] {
                for tag in tags {
                    if let tagWords = wordBank[tag] {
                        mergedWords.formUnion(tagWords)
                    }
                }
            }
            
            mergedWordlists[category] = Array(mergedWords).sorted()
        }
        
        // Second pass: Build Random category from all other categories
        if let randomBaseWords = baseWordlists["Random"] {
            var randomWords = Set(randomBaseWords) // Start with Random's base words
            
            // Aggregate words from all other categories
            for (category, words) in mergedWordlists {
                if category != "Random" {
                    randomWords.formUnion(words)
                }
            }
            
            // Also include all words from all tags in the word bank
            for (_, tagWords) in wordBank {
                randomWords.formUnion(tagWords)
            }
            
            mergedWordlists["Random"] = Array(randomWords).sorted()
        }
        
        return mergedWordlists
    }
    
    func loadLocalWordlists() -> [String: [String]] {
        // Check cache first
        if let cached = cachedWordlists, cachedMode == isKidsMode {
            print("📦 Using cached wordlists")
            return cached
        }
        
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
            cachedWordlists = fallbackWordlists
            cachedMode = isKidsMode
            return fallbackWordlists
        }
        
        do {
            print("📄 Found \(filename).json at: \(url.path)")
            let data = try Data(contentsOf: url)
            let baseWordlists = try JSONDecoder().decode([String: [String]].self, from: data)
            
            // Validate that we have categories and words
            if baseWordlists.isEmpty {
                print("⚠️ Loaded empty wordlist from \(filename).json - using fallback")
                cachedWordlists = fallbackWordlists
                cachedMode = isKidsMode
                return fallbackWordlists
            }
            
            // Load word bank and merge
            let wordBank = loadWordBank()
            let mergedWordlists = mergeWordlistsWithBank(baseWordlists: baseWordlists, wordBank: wordBank)
            
            // Log each category and word count
            print("📊 Loaded categories and word counts (after merge):")
            for (category, words) in mergedWordlists.sorted(by: { $0.key < $1.key }) {
                let baseCount = baseWordlists[category]?.count ?? 0
                let addedCount = words.count - baseCount
                print("   - \(category): \(words.count) words (\(baseCount) base + \(addedCount) from word bank))")
                if words.isEmpty {
                    print("⚠️ Category '\(category)' has no words - using fallback")
                    cachedWordlists = fallbackWordlists
                    cachedMode = isKidsMode
                    return fallbackWordlists
                }
            }
            
            print("✅ Successfully loaded \(mergedWordlists.count) categories (merged with word bank)")
            
            // Cache the result
            cachedWordlists = mergedWordlists
            cachedMode = isKidsMode
            
            return mergedWordlists
            
        } catch {
            print("⚠️ Error loading \(filename).json: \(error.localizedDescription)")
            print("📝 Using fallback word lists with categories: \(fallbackWordlists.keys.sorted())")
            cachedWordlists = fallbackWordlists
            cachedMode = isKidsMode
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
        let usedWordsState = usedWordsStore.getUsedWordsState()
        for (cat, words) in usedWordsState {
            print("   - \(cat): \(words.count) words used")
        }
        
        // First try to get a word from the specified category
        guard let words = wordlists[category], !words.isEmpty else {
            print("❌ No words found in category '\(category)'")
            throw NSError(domain: "com.whatthephrase", code: 1, userInfo: [NSLocalizedDescriptionKey: "No words found in category \(category)"])
        }
        
        print("✅ Found \(words.count) words in category '\(category)'")
        
        // Thread-safe access to usedWords via Sendable helper
        return try await withCheckedThrowingContinuation { continuation in
            usedWordsStore.getRandomWord(category: category, words: words, continuation: continuation)
        }
    }

    func resetUsedWords() {
        usedWordsStore.resetUsedWords()
    }
    
    func setKidsMode(_ enabled: Bool) {
        isKidsMode = enabled
        resetUsedWords()
        // Clear cache when mode changes so new wordlists are loaded
        cachedWordlists = nil
        cachedMode = nil
    }
    
    func preloadWordlists() {
        // This forces the wordlists to be loaded and cached
        _ = loadLocalWordlists()
    }
}
