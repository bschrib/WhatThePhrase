# WhatThePhrase - Source Code

This directory contains the main source code for the WhatThePhrase iOS app.

> **Note**: For comprehensive documentation including development setup, deployment instructions, and contribution guidelines, see the [main README](../README.md) in the project root.

## Directory Structure

```
WhatThePhrase/
├── Assets/
│   ├── Images/         # App icons and images
│   ├── Scripts/        # Utility scripts
│   ├── Sounds/         # Sound effects
│   └── WordLists/      # JSON word list files
├── Assets.xcassets/    # Xcode asset catalog
├── ContentView.swift   # Main screen (category selection)
├── GameView.swift      # Game interface
├── SettingsView.swift  # App settings
├── RequestManager.swift # Game state management
├── AudioPlayerController.swift
├── LaunchScreen.swift
├── WhatThePhrase.swift # App entry point
├── Info.plist          # App configuration
└── GoogleService-Info.plist # Firebase configuration
```

## Key Components

### Views

| File | Description |
|------|-------------|
| `ContentView.swift` | Main screen with category selection grid |
| `GameView.swift` | Active game view with timer, current word, and score controls |
| `SettingsView.swift` | Settings screen (timer duration, Kids Mode toggle) |
| `LaunchScreen.swift` | App launch screen |

### Models & Controllers

| File | Description |
|------|-------------|
| `RequestManager.swift` | Manages word lists, categories, tracks used words, handles Kids Mode |
| `AudioPlayerController.swift` | Handles sound effects playback |
| `FirebaseDelegate.swift` | Firebase integration |

### Word Lists

Word lists are stored as JSON files in `Assets/WordLists/`:

- `wordlists.json` - Standard word lists for regular play
- `kids_wordlists.json` - Simplified word lists for Kids Mode

To add new categories or words, edit these JSON files following this format:

```json
{
  "Category Name": ["word1", "word2", "word3"],
  "Another Category": ["word4", "word5"]
}
```

## Architecture

The app follows a simplified **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Word lists (JSON) and game state
- **Views**: SwiftUI views (`ContentView`, `GameView`, `SettingsView`)
- **ViewModel**: `RequestManager` handles business logic and state management
