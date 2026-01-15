# WhatThePhrase

A fun and engaging word guessing game for iOS, perfect for parties, family gatherings, or just having fun with friends. The game challenges players to guess words based on clues given by their teammates, with a countdown timer adding to the excitement.

## Features

- **Multiple Categories**: Choose from a variety of categories including Places & Spaces, Food, Animals, and more
- **Kids Mode**: Special mode with simpler words and categories designed for younger players
- **Team Play**: Play with friends in team mode or practice solo
- **Customizable Timer**: Adjust the game duration to fit your preferences
- **Score Tracking**: Keep track of points for each team
- **Beautiful UI**: Clean, intuitive interface with smooth animations

## Project Structure

The project follows the MVVM (Model-View-ViewModel) architecture pattern. Here's an overview of the main components:

### Models
- **RequestManager.swift**: Manages word lists, categories, and game state
  - Handles loading word lists from JSON files
  - Tracks used words to avoid repeats
  - Manages Kids Mode functionality

### Views
- **ContentView.swift**: Main screen displaying category selection
- **GameView.swift**: Game interface with timer, score, and word display
- **SettingsView.swift**: App settings including game mode and timer duration

### Assets
- **WordLists/**: Contains JSON files with word lists
  - `wordlists.json`: Standard word lists for regular play
  - `kids_wordlists.json`: Simplified word lists for Kids Mode
- **Assets.xcassets/**: App icons, colors, and other assets
- **Sounds/**: Sound effects (e.g., buzz.wav for timer end)

## Adding New Word Lists

1. Create a new JSON file in the `WordLists` directory
2. The JSON should be a dictionary where keys are category names and values are arrays of words
3. Update the `RequestManager` to include the new word list if needed

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `WhatThePhrase.xcodeproj` in Xcode
3. Build and run the project on your device or simulator

## How to Play

1. Select a category from the main screen
2. One player gives clues to their teammates without saying the actual word
3. Teammates try to guess the word before time runs out
4. Score points for each correct guess
5. The team with the most points when time runs out wins!

### Kids Mode

Enable Kids Mode in Settings for younger players. This will:
- Show simplified categories and words
- Use a more colorful and engaging interface
- Provide age-appropriate content

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details
