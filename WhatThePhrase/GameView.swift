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
                .font(.system(size: 24))
                .padding()
                .background(teamColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private func teamScoreView(teamColor: Color, score: Binding<Int>) -> some View {
        ZStack {
            Circle()
                .fill(teamColor)
                .frame(width: 50, height: 50)
            
            Text("\(score.wrappedValue)")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundColor(.white)
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
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
                .opacity(isLoading ? 1 : 0)
                .frame(height: 50)
            Text(selectedCategory ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)

            ZStack {
                let displayWord = isGameRunning
                    ? (currentWord.isEmpty ? "TAP TO START" : currentWord)
                    : "TAP TO START"
                Text(displayWord)
                    .font(.system(size:24))
            }
            .padding(.bottom, 5)


            Text(timeRemainingFormatted)
                .font(.system(size: 24))
                .padding(.bottom, 10)

            Button(action: {
                if isGameRunning {
                    stopGame()
                } else {
                    startGame()
                }
            }) {
                Text(isGameRunning ? "Stop" : "Start")
                    .font(.system(size: 24))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .contentShape(Rectangle())

            if playAsTeams {
                HStack {
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
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Button(action: {
                Task {
                    await pass()
                }
            }) {
                Text("Pass")
                    .font(.system(size: 24))
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)

            HStack(spacing: 30) {
                            if playAsTeams {
                                teamScoreView(teamColor: Color.red, score: $team1Score)
                                teamScoreView(teamColor: Color.green, score: $team2Score)
                            } else {
                                teamScoreView(teamColor: Color.blue, score: $team1Score)
                            }
                        }
                        .padding(.top, 20)
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


            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back To Categories")
                    .font(.system(size: 18))
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
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
