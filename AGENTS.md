# WhatThePhrase Agent Instructions

This document provides context and guidelines for AI agents working on the WhatThePhrase iOS application.

## Project Overview

WhatThePhrase is a "Catch Phrase"-style party game iOS application built with SwiftUI. Players select a category and try to get their teammates to guess words before time runs out.

## Tech Stack

- **Language**: Swift / SwiftUI
- **Minimum iOS Version**: Check `Info.plist` for deployment target
- **Backend**: Firebase (Analytics)
- **CI/CD**: Fastlane
- **Distribution**: TestFlight / App Store

## Project Structure

```
WhatThePhrase/
├── WhatThePhrase/              # Main app source code
│   ├── Assets/
│   │   ├── Images/             # App icons and images
│   │   ├── Scripts/            # Utility scripts (e.g., word list generation)
│   │   ├── Sounds/             # Audio files (buzz.wav)
│   │   └── WordLists/          # Category word lists (wordlists.json)
│   ├── Assets.xcassets/        # Xcode asset catalog
│   ├── ContentView.swift       # Main category selection screen
│   ├── GameView.swift          # Game play screen
│   ├── SettingsView.swift      # User settings
│   ├── RequestManager.swift    # Word list loading and management
│   ├── AudioPlayerController.swift
│   └── WhatThePhrase.swift     # App entry point
├── WhatThePhrase.xcodeproj/    # Xcode project
├── fastlane/                   # CI/CD configuration
├── metadata/                   # App Store metadata
└── screenshots/                # App Store screenshots
```

## Build & Deployment

### TestFlight Deployment

This project uses **TestFlight** for beta testing. Always deploy to TestFlight for testing before submitting to the App Store.

**Fastlane Commands:**
```bash
# Deploy to TestFlight
fastlane beta

# Build only
fastlane build

# Generate screenshots
fastlane screenshots

# Full App Store release
fastlane release
```

### Signing & Certificates

The project uses **fastlane match** for certificate and provisioning profile management.

**Certificate Storage**: Certificates are stored in a private Git repository (`https://github.com/bschrib/fastlane`)

**Required Credentials**:
- App Store Connect API Key (stored in `projectConfig.json`)
- Apple Developer account access

### Configuration Files

#### projectConfig.json

**Location**: Project root (`../projectConfig.json` relative to fastlane)

This file contains sensitive App Store Connect API credentials and should:
- **NEVER** be committed to source control
- Be added to `.gitignore`
- Be provided separately by the project owner

**Required Keys**:
```json
{
  "APP_STORE_CONNECT_API_KEY_KEY_ID": "YOUR_KEY_ID",
  "APP_STORE_CONNECT_API_KEY_ISSUER_ID": "YOUR_ISSUER_ID",
  "APP_STORE_CONNECT_API_KEY_KEY": "BASE64_ENCODED_KEY",
  "is_key_content_base64": true,
  "APP_STORE_CONNECT_API_KEY_IN_HOUSE": "false"
}
```

**Setup Instructions**:
1. Create `projectConfig.json` in the project root
2. Obtain API key from App Store Connect
3. Populate the required fields
4. Ensure the file is in `.gitignore`

## Development Guidelines

### Adding New Categories

1. Edit `WhatThePhrase/Assets/WordLists/wordlists.json`
2. Add category name to `categories` array in `RequestManager.swift`
3. Ensure at least 30+ words per category for good gameplay

### Word List Format

```json
{
  "Category Name": [
    "word1",
    "word2",
    "word3"
  ]
}
```

### Code Style

- Use SwiftUI best practices
- Follow Apple's Human Interface Guidelines
- Use `@AppStorage` for user preferences
- Handle async operations with Swift concurrency (`async/await`)

## Testing

### UI Tests
Located in `WhatThePhraseUITests/`

Run UI tests:
```bash
# Via Xcode
xcodebuild test -scheme WhatThePhraseScreenShots

# Via fastlane
fastlane snapshot
```

### Maestro Flows
Located in `.maestro/flow.yaml`

## Security Notes

### Files to Keep Secret
- `projectConfig.json` - App Store Connect API credentials
- Any `.p8` files - Apple API keys
- Any `.p12` files - Distribution certificates
- `GoogleService-Info.plist` - Firebase config (already committed, but be careful with production keys)

### Git-crypt
This project uses **git-crypt** for encrypting sensitive files. Files matching patterns in `.gitattributes` are automatically encrypted.

## Common Tasks

### Update App Version
1. Update version in Xcode project settings
2. Fastlane will auto-increment build number

### Add New Screens
1. Create new SwiftUI View file
2. Add navigation from relevant parent view
3. Update any analytics tracking

### Modify Game Settings
Settings are stored via `@AppStorage`:
- `playAsTeams` - Team play mode
- `timerDuration` - Game duration in seconds

## Troubleshooting

### Build Failures
1. Clean build folder (Cmd+Shift+K)
2. Delete DerivedData
3. Verify certificates with `fastlane match`

### Signing Issues
```bash
# Sync certificates
fastlane sync_certificates

# Force re-download
fastlane match --readonly false
```

## Contact

For project access and credentials, contact the repository owner.
