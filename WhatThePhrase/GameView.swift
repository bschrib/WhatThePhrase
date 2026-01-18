import SwiftUI
import AVFoundation

public struct GameView: View {
    @Binding var showCategories: Bool
    @Binding var selectedCategory: String?
    @Binding var timerDuration: Int
    @Binding var playAsTeams: Bool
    @Binding var isKidsMode: Bool
    @State private var showAlert: Bool = false
    @State private var isGameRunning: Bool = false
    @State private var currentWord: String = "TAP TO START"
    @State private var hasLoadedInitialWord = false
    @State private var timer: Timer? = nil
    @State private(set) var timeRemaining: Int = 60
    @State private var team1Score: Int = 0
    @State private var team2Score: Int = 0
    @State private var hasGameStarted: Bool = false
    @State private var isLoading: Bool = false
    @State private var wordRequestId = UUID()
    @State private var wordRequestTask: Task<Void, Never>?
    @StateObject private var audioPlayerController = AudioPlayerController()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var requestManager = RequestManager.shared

    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func playBuzzSound() {
        audioPlayerController.playSound(filename: "buzz", fileExtension: "wav")
    }

    private func cancelWordRequest() {
        wordRequestTask?.cancel()
        wordRequestTask = nil
    }

    private func startGame() {
        isGameRunning = true
        hasGameStarted = true
        cancelWordRequest()
        requestManager.resetUsedWords()
        timeRemaining = timerDuration
        team1Score = 0
        team2Score = 0
        hasLoadedInitialWord = false
        
        // Load the first word
        Task {
            await MainActor.run {
                self.isLoading = true
                self.currentWord = "TAP TO START"
            }
            await requestNextWord(category: selectedCategory ?? "")
        }
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining == 0 {
                playBuzzSound()
                stopGame()
                showAlert = true
            }
        }
    }

    private func stopGame() {
        isGameRunning = false
        showAlert = true
        playBuzzSound()
        timer?.invalidate()
        cancelWordRequest()
    }

    private func nextWord() {
        guard isGameRunning else { return }
        isLoading = true
        Task {
            await requestNextWord(category: selectedCategory ?? "")
        }
    }

    private func pass() async {
        await requestNextWord(category: selectedCategory ?? "")
    }

    private func addPointToTeam1() async {
        if isGameRunning {
            team1Score += 1
            await requestNextWord(category: selectedCategory ?? "")
        }
    }

    private func addPointToTeam2() async {
        if isGameRunning {
            team2Score += 1
            await requestNextWord(category: selectedCategory ?? "")
        }
    }

    private func teamButton(teamName: String, teamColor: Color, teamAction: @escaping () -> Void) -> some View {
        Button(action: {
            teamAction()
        }) {
            Text(teamName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(teamColor.gradient)
                }
        }
        .buttonStyle(.plain)
    }

    private func teamScoreView(teamColor: Color, score: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(teamColor.gradient)
                    .frame(width: 64, height: 64)
                
                Text("\(score.wrappedValue)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// Requests a new word for the given category. Generates a new request ID to
    /// cancel any in-flight requests and ensure only the latest word is displayed.
    @MainActor
    private func requestNextWord(category: String) async {
        let requestId = UUID()
        wordRequestId = requestId
        cancelWordRequest()
        wordRequestTask = Task { [requestId] in
            await asyncUpdateWord(category: category, requestId: requestId)
        }
        await wordRequestTask?.value
    }
    
    @MainActor
    private func asyncUpdateWord(category: String, requestId: UUID) async {
        // Guard: if this request is already stale, bail out
        guard requestId == wordRequestId else { return }
        
        self.isLoading = true
        // Only clear the word if we already have a word loaded
        if hasLoadedInitialWord {
            self.currentWord = ""
        }
        
        do {
            let word = try await requestManager.asyncGetRandomWord(category: category)
            // Guard: check again after await in case a newer request came in
            guard requestId == wordRequestId else { return }
            self.currentWord = word.uppercased()
            self.isLoading = false
            self.hasLoadedInitialWord = true
        } catch {
            // Guard: check before handling error
            guard requestId == wordRequestId else { return }
            print("❌ Error getting random word: \(error.localizedDescription)")
            // Try to get any word from any category as a fallback
            do {
                let fallbackWord = try await requestManager.asyncGetRandomWord(category: "")
                guard requestId == wordRequestId else { return }
                self.currentWord = fallbackWord.uppercased()
                self.isLoading = false
            } catch {
                guard requestId == wordRequestId else { return }
                // Last resort fallback
                self.currentWord = "TAP TO START"
                self.isLoading = false
            }
        }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Category Header Card
                VStack(spacing: 8) {
                    Text(selectedCategory ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(timeRemainingFormatted)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
                
                // Word Display Card
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.vertical, 20)
                    } else {
                        let displayWord = {
                            if !isGameRunning {
                                return "TAP TO START"
                            }
                            if currentWord.isEmpty {
                                return "TAP TO START"
                            }
                            return currentWord
                        }()
                        Text(displayWord)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .padding(.vertical, 24)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                }
                
                // Control Buttons Card
                VStack(spacing: 16) {
                    // Start/Stop Button
                    Button(action: {
                        if isGameRunning {
                            stopGame()
                        } else {
                            startGame()
                        }
                    }) {
                        Text(isGameRunning ? "Stop" : "Start")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isGameRunning ? Color.red.gradient : Color.accentColor.gradient)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    // Team/Correct Buttons
                    if playAsTeams {
                        HStack(spacing: 12) {
                            teamButton(teamName: "Team 1", teamColor: Color.red, teamAction: {
                                Task {
                                    await addPointToTeam1()
                                }
                            })
                            
                            teamButton(teamName: "Team 2", teamColor: Color.green, teamAction: {
                                Task {
                                    await addPointToTeam2()
                                }
                            })
                        }
                    } else {
                        Button(action: {
                            Task {
                                await addPointToTeam1()
                            }
                        }) {
                            Text("Correct")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.accentColor.gradient)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Pass Button
                    Button(action: {
                        Task {
                            await pass()
                        }
                    }) {
                        Text("Pass")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.gradient)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
                
                // Score Display Card
                HStack(spacing: 40) {
                    if playAsTeams {
                        teamScoreView(teamColor: Color.red, score: $team1Score)
                        teamScoreView(teamColor: Color.green, score: $team2Score)
                    } else {
                        teamScoreView(teamColor: Color.accentColor, score: $team1Score)
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
                
                // Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Go Back To Categories")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $showAlert) {
            let message: String
            if playAsTeams {
                if team1Score > team2Score {
                    message = "Team 1 won!"
                } else if team1Score < team2Score {
                    message = "Team 2 won!"
                } else {
                    message = "It's a tie!"
                }
            } else {
                message = "You scored \(team1Score) points!"
            }
            return Alert(title: Text("Time's Up!"),
                         message: Text(message),
                         dismissButton: .default(Text("OK")))
        }
        .onAppear {
            timeRemaining = timerDuration
            // Don't load words here - wait for game to start
        }
        .onChange(of: timerDuration) { oldValue, newValue in
            timeRemaining = newValue
        }
        .onDisappear {
            cancelWordRequest()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showCategories: .constant(false), 
                selectedCategory: .constant("Sample Category"), 
                timerDuration: .constant(60), 
                playAsTeams: .constant(false),
                isKidsMode: .constant(false))
    }
}
