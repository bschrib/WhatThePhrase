import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var score = 0
    @Published var currentPhrase: String = "Tap to Start"
    
    var categories: [String] = [
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
    
    private var selectedCategory: String?
    private var requestManager = RequestManager()
    private var cancellable: AnyCancellable?
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func moveToNextPhrase() {
        if currentPhrase != "Tap to Start" {
            score += 1
        }
        
        if let category = selectedCategory {
            requestManager.getRandomWord(category: category) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let word):
                        self.currentPhrase = word
                    case .failure(let error):
                        print("Error: \(error)")
                        self.currentPhrase = "Error"
                    }
                }
            }
        } else {
            currentPhrase = "No more phrases"
        }
    }
}
