import SwiftUI

struct SettingsView: View {
    @Binding var playAsTeams: Bool
    @Binding var timerDuration: Int
    @Binding var isKidsMode: Bool
    @Binding var kidsDifficulty: KidsDifficulty
    @StateObject private var requestManager = RequestManager.shared

    @Environment(\.dismiss) var dismiss

    private var difficultyDescription: String {
        switch kidsDifficulty {
        case .easy: return "Short, simple words for younger kids"
        case .medium: return "A wider mix of kid-friendly words"
        case .hard: return "Challenging words for older kids"
        }
    }

    func resetToDefaultSettings() {
        playAsTeams = true
        timerDuration = 60
        isKidsMode = false
        kidsDifficulty = .medium
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Game Mode Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Mode")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Kids Mode")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text("Age-appropriate word lists")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $isKidsMode)
                                    .labelsHidden()
                                    .accessibilityIdentifier("kidsModeToggle")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }

                            if isKidsMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Difficulty")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Picker("Difficulty", selection: $kidsDifficulty) {
                                        ForEach(KidsDifficulty.allCases, id: \.self) { difficulty in
                                            Text(difficulty.displayName).tag(difficulty)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .accessibilityIdentifier("kidsDifficultyPicker")
                                    Text(difficultyDescription)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Play As Teams")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text("Two teams compete")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $playAsTeams)
                                    .labelsHidden()
                                    .accessibilityIdentifier("playAsTeamsToggle")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    }
                    .animation(.easeInOut, value: isKidsMode)
                    .onChange(of: isKidsMode) { oldValue, newValue in
                        requestManager.isKidsMode = newValue
                        requestManager.resetUsedWords()
                    }
                    .onChange(of: kidsDifficulty) { oldValue, newValue in
                        requestManager.setKidsDifficulty(newValue)
                    }
                    
                    // Duration Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Duration")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Game Duration (seconds)")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            TextField("Enter duration", text: Binding(
                                get: { String(timerDuration) },
                                set: { input in
                                    if let intValue = Int(input) {
                                        timerDuration = intValue
                                    }
                                }
                            ))
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    }
                    
                    // Reset Button
                    Button(action: resetToDefaultSettings) {
                        Text("Reset to Default Settings")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Options")
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(playAsTeams: .constant(true), timerDuration: .constant(60), isKidsMode: .constant(true), kidsDifficulty: .constant(.medium))
    }
}
