import SwiftUI

struct SettingsView: View {
    @Binding var playAsTeams: Bool
    @Binding var timerDuration: Int
    @Binding var kidMode: Bool

    @Environment(\.dismiss) var dismiss

    func resetToDefaultSettings() {
        playAsTeams = true
        timerDuration = 60
        kidMode = false
    }

    var body: some View {
        NavigationView {
            Form {
                Toggle("Play As Teams", isOn: $playAsTeams)

                Toggle("Kid Mode", isOn: $kidMode)

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
        SettingsView(playAsTeams: .constant(true), timerDuration: .constant(60), kidMode: .constant(false))
    }
}
