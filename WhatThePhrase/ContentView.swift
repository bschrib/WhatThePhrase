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
    @StateObject private var requestManager = RequestManager.shared
    
    private var categories: [String] {
        requestManager.categories
    }
    
    init() {
        // Ensure the manager's kids mode is in sync with user defaults
        let manager = RequestManager.shared
        manager.isKidsMode = isKidsMode
        // Preload wordlists in the background
        DispatchQueue.global(qos: .userInitiated).async {
            manager.preloadWordlists()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategoryItem = CategorySelection(name: category)
                                Analytics.logEvent("category_selected", parameters: ["category_name": category])
                            }) {
                                Text(category)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .listRowInsets(EdgeInsets())
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
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
                            isKidsMode: $isKidsMode)
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
            }
            .navigationTitle("Select Category")
            .navigationBarItems(
                leading:
                    Button(action: {
                        showInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title)
                    },
                trailing:
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title)
                    }
            )
        }
        .onAppear {
            // Ensure wordlists are loaded when view appears
            RequestManager.shared.preloadWordlists()
        }
        .onChange(of: isKidsMode) { oldValue, newValue in
            let manager = RequestManager.shared
            manager.isKidsMode = newValue
            manager.resetUsedWords()
            // Preload the new wordlists in the background
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
