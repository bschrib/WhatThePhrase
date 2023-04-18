import SwiftUI

struct SettingsView: View {
    @Binding var playAsTeams: Bool
    @Binding var timerDuration: Int

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Toggle("Play As Teams", isOn: $playAsTeams)

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
        SettingsView(playAsTeams: .constant(true), timerDuration: .constant(60))
    }
}
