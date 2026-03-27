import SwiftUI
import Firebase

struct CategorySelection: Identifiable {
    let id = UUID()
    let name: String
}

struct ContentView: View {
    @State private var selectedCategoryItem: CategorySelection? = nil
    @State private var showSettings: Bool = false
    @State private var showInfo: Bool = false
    @AppStorage("playAsTeams") private var playAsTeams: Bool = true
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("isKidsMode") private var isKidsMode: Bool = false
    @AppStorage("kidsDifficulty") private var kidsDifficultyRaw: String = KidsDifficulty.medium.rawValue
    @StateObject private var requestManager = RequestManager.shared

    private var kidsDifficultyBinding: Binding<KidsDifficulty> {
        Binding(
            get: { KidsDifficulty(rawValue: kidsDifficultyRaw) ?? .medium },
            set: { kidsDifficultyRaw = $0.rawValue }
        )
    }
    
    private var categories: [String] {
        requestManager.categories
    }
    
    init() {
        // Ensure the manager's kids mode and difficulty are in sync with user defaults
        let manager = RequestManager.shared
        manager.isKidsMode = isKidsMode
        manager.kidsDifficulty = KidsDifficulty(rawValue: kidsDifficultyRaw) ?? .medium
        // Preload wordlists in the background
        DispatchQueue.global(qos: .userInitiated).async {
            manager.preloadWordlists()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed Header with buttons and title
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.accentColor)
                        }
                        .accessibilityIdentifier("infoButton")
                        
                        Spacer()
                        
                        Text("Select Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.accentColor)
                        }
                        .accessibilityIdentifier("settingsButton")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    
                    // Brand Title
                    HStack(spacing: 4) {
                        Text("What")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("The")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                        Text("Phrase")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                }
                
                // Scrollable Category List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategoryItem = CategorySelection(name: category)
                                Analytics.logEvent("category_selected", parameters: ["category_name": category])
                            }) {
                                HStack {
                                    Text(category)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(item: $selectedCategoryItem) { categoryItem in
                GameView(showCategories: Binding(
                    get: { selectedCategoryItem != nil },
                    set: { if !$0 { selectedCategoryItem = nil } }
                ),
                selectedCategory: .constant(categoryItem.name),
                timerDuration: $timerDuration,
                playAsTeams: $playAsTeams,
                isKidsMode: $isKidsMode)
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(playAsTeams: $playAsTeams,
                            timerDuration: $timerDuration,
                            isKidsMode: $isKidsMode,
                            kidsDifficulty: kidsDifficultyBinding)
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
            }
        }
        .onAppear {
            // Ensure wordlists are loaded when view appears
            RequestManager.shared.preloadWordlists()
        }
        .onChange(of: isKidsMode) { oldValue, newValue in
            let manager = RequestManager.shared
            manager.isKidsMode = newValue
            manager.resetUsedWords()
            DispatchQueue.global(qos: .userInitiated).async {
                manager.preloadWordlists()
            }
        }
        .onChange(of: kidsDifficultyRaw) { oldValue, newValue in
            let manager = RequestManager.shared
            manager.setKidsDifficulty(KidsDifficulty(rawValue: newValue) ?? .medium)
            DispatchQueue.global(qos: .userInitiated).async {
                manager.preloadWordlists()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
