# WhatThePhrase 🎮

A fun and engaging word guessing game for iOS, perfect for parties, family gatherings, or just having fun with friends. The game challenges players to guess words based on clues given by their teammates, with a countdown timer adding to the excitement. Now featuring a special Kids Mode with age-appropriate words!

![App Screenshot](Assets/Images/AppLaunchScreen.png)

## Features ✨

- **Multiple Game Modes**: Regular mode and Kids Mode with age-appropriate words
- **Team Play**: Play with friends in team mode or practice solo
- **Customizable Timer**: Adjust the game duration to fit your preferences
- **Score Tracking**: Keep track of points for each team
- **Beautiful UI**: Clean, intuitive interface with smooth animations
- **Multiple Categories**: Various categories to choose from in both modes
- **Sound Effects**: Engaging audio feedback for game events

## Requirements 📋

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation 🚀

1. Clone the repository
   ```bash
   git clone https://github.com/bschrib/WhatThePhrase.git
   ```
2. Open `WhatThePhrase.xcodeproj` in Xcode
3. Build and run the project on your device or simulator

## How to Play 🎮

1. **Start the Game**:
   - Select a category from the main screen
   - Choose between Regular or Kids Mode in Settings
   - Set your preferred timer duration

2. **Gameplay**:
   - One player gives clues to their teammates without saying the actual word
   - Teammates try to guess the word before time runs out
   - Score points for each correct guess
   - The team with the most points when time runs out wins!

3. **Controls**:
   - **Correct**: Tap when your team guesses the word correctly
   - **Pass**: Skip to the next word if the current one is too difficult
   - **Stop**: End the current game

### Kids Mode 👶

Enable Kids Mode in Settings for younger players. This will:
- Show simplified categories and words
- Use age-appropriate vocabulary
- Provide a more accessible gaming experience

## Project Structure 🏗️

The project follows the MVVM (Model-View-ViewModel) architecture pattern.

### Key Files

#### Models
- **`RequestManager.swift`**: Manages word lists, categories, and game state
  - Handles loading word lists from JSON files
  - Tracks used words to avoid repeats
  - Manages Kids Mode functionality

#### Views
- **`ContentView.swift`**: Main screen displaying category selection
- **`GameView.swift`**: Game interface with timer, score, and word display
- **`SettingsView.swift`**: App settings including game mode and timer duration

#### Assets
- **`WordLists/`**: Contains JSON files with word lists
  - `wordlists.json`: Standard word lists for regular play
  - `kids_wordlists.json`: Simplified word lists for Kids Mode
- **`Assets.xcassets/`**: App icons, colors, and other assets
- **`Sounds/`**: Sound effects (e.g., buzz.wav for timer end)

## Customization 🎨

### Adding New Word Lists

1. Create a new JSON file in the `WordLists` directory
2. The JSON should be a dictionary where keys are category names and values are arrays of words:
   ```json
   {
     "Category Name": ["word1", "word2", "word3"],
     "Another Category": ["word4", "word5"]
   }
   ```
3. Update the `RequestManager` to include the new word list if needed

### Modifying Game Behavior

- **Timer Duration**: Adjust in `SettingsView.swift`
- **Game Modes**: Toggle between regular and Kids Mode in `RequestManager.swift`
- **UI Customization**: Modify the views in their respective SwiftUI files

## Troubleshooting 🛠️

### Common Issues

1. **Words not loading**:
   - Ensure JSON files are included in the app target
   - Check console logs for loading errors

2. **App crashes on launch**:
   - Clean build folder (Cmd + Shift + K)
   - Delete derived data
   - Rebuild the project

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments 🙏

- Thanks to all contributors who have helped improve this project
- Special thanks to my daughter for the Kids Mode suggestion!

---

Made with ❤️ by Brandon Schreiber
