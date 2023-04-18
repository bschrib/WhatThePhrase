import SwiftUI

public struct Category: Identifiable {
    public let id = UUID()
    public let name: String
}

struct CategoryName: Identifiable {
    let id = UUID()
    let name: String
}

struct ContentView: View {
    @State private var selectedCategory: CategoryName? = nil
    @State private var showSettings: Bool = false
    @State private var playAsTeams: Bool = true
    @State private var timerDuration: Int = 60
    @State private var showCategories: Bool = false

    private var requestManager = RequestManager()
    private var categories: [Category] {
        requestManager.categories.map { Category(name: $0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(categories) { category in
                            Button(action: {
                                selectedCategory = CategoryName(name: category.name)
                            }) {
                                Text(category.name)
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
                            .sheet(item: $selectedCategory) { (categoryName: CategoryName) in
                                GameView(showCategories: $showCategories, selectedCategory: .constant(categoryName.name), timerDuration: $timerDuration)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(playAsTeams: $playAsTeams, timerDuration: $timerDuration)
            }
            .navigationTitle("Select Category")
            .navigationBarItems(trailing:
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title)
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
