import SwiftUI
import AVFoundation

public struct GameView: View {
    @Binding var showCategories: Bool
    @Binding var selectedCategory: String?
    @Binding var timerDuration: Int
    @State private var showAlert: Bool = false
    @State private var isGameRunning: Bool = false
    @State private var currentWord: String = ""
    @State private var timer: Timer? = nil
    @State private(set) var timeRemaining: Int = 60
    @State private var team1Score: Int = 0
    @State private var team2Score: Int = 0
    @StateObject private var audioPlayerController = AudioPlayerController()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    var requestManager = RequestManager()

    func playBuzzSound() {
        audioPlayerController.playSound(filename: "buzz", fileExtension: "wav")
    }

    private func startGame() {
        isGameRunning = true
        requestManager.resetUsedWords()
        timeRemaining = timerDuration
        team1Score = 0
        team2Score = 0
        Task {
            try? await asyncUpdateWord(category: selectedCategory ?? "")
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
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
    }

    private func pass() async {
        try? await asyncUpdateWord(category: selectedCategory ?? "")
    }

    private func addPointToTeam1() async {
        if isGameRunning {
            team1Score += 1
            try? await asyncUpdateWord(category: selectedCategory ?? "")
        }
    }

    private func addPointToTeam2() async {
        if isGameRunning {
            team2Score += 1
            try? await asyncUpdateWord(category: selectedCategory ?? "")
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
    
    @MainActor
    func asyncUpdateWord(category: String) async throws {
        do {
            currentWord = try await requestManager.asyncGetRandomWord(category: selectedCategory ?? "")
        } catch {
            print("Error fetching word: \(error.localizedDescription)")
        }
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(selectedCategory ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)

            ZStack {
                Text("placeholder")
                    .font(.system(size:24))
                    .opacity(0) // Set opacity to 0 to make it invisible
                
                if isGameRunning {
                    Text(currentWord)
                        .font(.system(size:24))
                }
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
                teamScoreView(teamColor: Color.red, score: $team1Score)
                teamScoreView(teamColor: Color.green, score: $team2Score)
            }
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                let message: String
                if team1Score > team2Score {
                    message = "Team 1 won!"
                } else if team1Score < team2Score {
                    message = "Team 2 won!"
                } else {
                    message = "It's a tie!"
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
            Task {
                try? await asyncUpdateWord(category: selectedCategory ?? "")
            }
        }
        .onChange(of: timerDuration) { newValue in
            timeRemaining = newValue
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showCategories: .constant(false), selectedCategory: .constant("Sample Category"), timerDuration: .constant(60))
    }
}
