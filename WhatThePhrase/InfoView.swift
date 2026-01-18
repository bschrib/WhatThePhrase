import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // How to Play Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            instructionRow(number: "1", text: "Select a category from the main screen")
                            instructionRow(number: "2", text: "Tap 'Start' to begin the game")
                            instructionRow(number: "3", text: "One person prompts others to guess the word shown")
                            instructionRow(number: "4", text: "When someone guesses correctly, tap 'Correct' or the team button")
                            instructionRow(number: "5", text: "Tap 'Pass' to skip a word and get a new one")
                            instructionRow(number: "6", text: "Accumulate points before time runs out!")
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    
                    // Scoring Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scoring")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint(text: "Each correct guess earns 1 point")
                            bulletPoint(text: "Points are tracked throughout the game")
                            bulletPoint(text: "When time runs out, the team (or player) with the most points wins")
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    
                    // Game Modes Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Modes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            modeCard(title: "Play As Teams", description: "When enabled, two teams compete against each other. Tap the red or green button when your team guesses correctly.")
                            modeCard(title: "Individual Mode", description: "When teams are disabled, everyone plays together. Tap 'Correct' when anyone guesses the word.")
                            modeCard(title: "Kids Mode", description: "Kids Mode uses age-appropriate word lists that are easier and more suitable for children. Enable this in Settings.")
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    
                    // Timer Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Timer")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint(text: "Set your preferred game duration in Settings")
                            bulletPoint(text: "Default is 60 seconds")
                            bulletPoint(text: "A sound plays when time runs out")
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("How To Play")
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .frame(width: 28, height: 28)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                }
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func bulletPoint(text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func modeCard(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
