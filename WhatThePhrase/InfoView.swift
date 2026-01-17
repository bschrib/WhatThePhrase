import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("How to Play")
                        .font(.headline)
                        .padding(.top)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Select a category from the main screen")
                            Text("2. Tap 'Start' to begin the game")
                            Text("3. One person prompts others to guess the word shown")
                            Text("4. When someone guesses correctly, tap 'Correct' or the team button")
                            Text("5. Tap 'Pass' to skip a word and get a new one")
                            Text("6. Accumulate points before time runs out!")
                        }
                        .font(.body)
                    }
                    
                    Section(header: Text("Scoring")
                        .font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Each correct guess earns 1 point")
                            Text("• Points are tracked throughout the game")
                            Text("• When time runs out, the team (or player) with the most points wins")
                        }
                        .font(.body)
                    }
                    
                    Section(header: Text("Game Modes")
                        .font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Play As Teams")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("When enabled, two teams compete against each other. Tap the red or green button when your team guesses correctly.")
                                .font(.body)
                                .padding(.bottom, 4)
                            
                            Text("Individual Mode")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("When teams are disabled, everyone plays together. Tap 'Correct' when anyone guesses the word.")
                                .font(.body)
                                .padding(.bottom, 4)
                            
                            Text("Kids Mode")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Kids Mode uses age-appropriate word lists that are easier and more suitable for children. Enable this in Settings.")
                                .font(.body)
                        }
                    }
                    
                    Section(header: Text("Timer")
                        .font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Set your preferred game duration in Settings")
                            Text("• Default is 60 seconds")
                            Text("• A sound plays when time runs out")
                        }
                        .font(.body)
                    }
                }
                .padding()
            }
            .navigationTitle("How to Play")
            .navigationBarItems(trailing:
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
