import SwiftUI

struct SettingsView: View {
    @Binding var playAsTeams: Bool
    @Binding var timerDuration: Int
    @Binding var isKidsMode: Bool
    @StateObject private var requestManager = RequestManager.shared
    
    @Environment(\.dismiss) var dismiss

    func resetToDefaultSettings() {
        playAsTeams = true
        timerDuration = 60
        isKidsMode = false
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Mode")) {
                    Toggle("Kids Mode", isOn: $isKidsMode)
                        .onChange(of: isKidsMode) { oldValue, newValue in
                            requestManager.isKidsMode = newValue
                            requestManager.resetUsedWords()
                        }
                    Toggle("Play As Teams", isOn: $playAsTeams)
                }

                Section(header: Text("Duration (seconds)")) {
                    TextField("Enter duration", text: Binding(
                        get: { String(timerDuration) },
                        set: { input in
                            if let intValue = Int(input) {
                                timerDuration = intValue
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                }

                Button(action: resetToDefaultSettings) {
                    Text("Return To Default Settings")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing:
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(playAsTeams: .constant(true), timerDuration: .constant(60), isKidsMode: .constant(false))
    }
}
