# WhatThePhrase - Agent Development Guide

## Project Overview
WhatThePhrase is an iOS application (Catch Phrase-style word guessing game) built with SwiftUI. This document provides guidance for AI agents and developers working on this project.

---

## Technology Stack

- **Language:** Swift 5.0
- **UI Framework:** SwiftUI
- **Minimum iOS Version:** 16.4
- **Package Manager:** Swift Package Manager (SPM)
- **CI/CD:** Fastlane
- **Analytics:** Firebase (Analytics, Crashlytics, App Distribution)
- **Secrets Management:** git-crypt

---

## Project Structure

```
WhatThePhrase/
├── WhatThePhrase/                    # Main app source
│   ├── Assets/
│   │   ├── Images/                   # App icons and images
│   │   ├── Sounds/                   # Audio files (buzz.wav)
│   │   ├── WordLists/                # Category word lists (JSON)
│   │   └── Scripts/                  # Utility scripts
│   ├── Assets.xcassets/              # Asset catalogs
│   ├── WhatThePhrase.swift           # App entry point (@main)
│   ├── ContentView.swift             # Main category selection view
│   ├── GameView.swift                # Game play view
│   ├── SettingsView.swift            # Settings/preferences
│   ├── RequestManager.swift          # Word list management
│   ├── AudioPlayerController.swift   # Sound playback
│   ├── LaunchScreen.swift            # Launch screen UI
│   ├── FirebaseDelegate.swift        # Firebase configuration
│   └── GoogleService-Info.plist      # Firebase config (encrypted)
├── WhatThePhraseUITests/             # UI tests
├── fastlane/                         # Fastlane configuration
├── metadata/                         # App Store metadata
├── projectConfig.json                # Build configuration (encrypted)
└── AGENTS.md                         # This file
```

---

## Build & Deployment

### TestFlight Distribution
This project uses **TestFlight** for beta distribution. Builds are pushed via Fastlane.

```bash
# Push beta build to TestFlight
bundle exec fastlane beta

# Submit to App Store
bundle exec fastlane release
```

### Fastlane Lanes
- `beta` - Build and upload to TestFlight
- `release` - Build and submit to App Store
- `build` - Create signed IPA
- `sync_certificates` - Sync code signing certificates via Match
- `screenshots` - Generate App Store screenshots
- `generate_appicon` - Generate app icons from source image

---

## Code Signing & Secrets

### Code Signing
- **Method:** Manual signing with Fastlane Match
- **Team ID:** E328JY49Z9
- **Bundle ID:** com.roguedeveloper.WhatThePhrase
- **Profile:** `match AppStore com.roguedeveloper.WhatThePhrase`

### Secrets Management
This project uses **git-crypt** to encrypt sensitive files. The following files are encrypted:
- `projectConfig.json` - App Store Connect API keys and configuration
- `GoogleService-Info.plist` - Firebase configuration

### Required Configuration Files

#### projectConfig.json
Place this file in the project root directory. It should contain:

```json
{
  "APP_STORE_CONNECT_API_KEY_KEY_ID": "<your-key-id>",
  "APP_STORE_CONNECT_API_KEY_ISSUER_ID": "<your-issuer-id>",
  "APP_STORE_CONNECT_API_KEY_KEY": "<base64-encoded-key>",
  "is_key_content_base64": true,
  "APP_STORE_CONNECT_API_KEY_IN_HOUSE": "false"
}
```

#### Signing Key Setup
If you need to provide a signing key:

1. Generate an App Store Connect API key from [App Store Connect](https://appstoreconnect.apple.com/access/api)
2. Download the `.p8` file
3. Base64 encode the key content
4. Add to `projectConfig.json`
5. The file is already in `.gitattributes` for git-crypt encryption

**Note:** The `projectConfig.json` file is git-crypt encrypted. To add new secrets:
1. Ensure you have git-crypt unlocked
2. Add your configuration
3. Commit - the file will be automatically encrypted

---

## Development Guidelines

### Adding New Categories
1. Add category name to `RequestManager.categories` array
2. Add word list to `WhatThePhrase/Assets/WordLists/wordlists.json`

### Adding New Settings
1. Use `@AppStorage` for persistent preferences
2. Add UI toggle/control in `SettingsView.swift`
3. Pass setting to relevant views via `@Binding`

### Word List Format
```json
{
  "Category Name": [
    "word1",
    "word2",
    "..."
  ]
}
```

---

## Common Tasks

### Running Tests
```bash
# UI Tests
xcodebuild test -scheme WhatThePhraseUIScreenshotTests -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Generating Screenshots
```bash
bundle exec fastlane screenshots
```

### Incrementing Build Number
Fastlane automatically increments build numbers during the build process.

---

## Environment Setup

### Prerequisites
1. Xcode 14.3+
2. Ruby (for Fastlane)
3. Bundler (`gem install bundler`)
4. git-crypt (for secrets)

### Initial Setup
```bash
# Install Ruby dependencies
bundle install

# Unlock git-crypt (requires GPG key)
git-crypt unlock

# Sync code signing certificates
bundle exec fastlane sync_certificates
```

### GPG Keys for git-crypt
Current authorized GPG keys:
- `70D0D5FA8C94A68ED80B78FCC18E62643A11F1E5`
- `A4E21580DFDAEDC0DE252B8CA668E72830BD6C99`

To add a new collaborator:
```bash
git-crypt add-gpg-user <GPG-KEY-ID>
```

---

## Files to Never Modify Directly
- `WhatThePhrase.xcodeproj/project.pbxproj` - Use Xcode for project changes
- Encrypted files without git-crypt unlocked

## Files Safe to Modify
- Swift source files (`.swift`)
- Word lists (`wordlists.json`)
- Fastlane configuration
- Metadata files

---

## Troubleshooting

### Build Failures
1. Ensure certificates are synced: `bundle exec fastlane sync_certificates`
2. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Check projectConfig.json is properly decrypted

### Code Signing Issues
- Verify Team ID matches in Xcode project settings
- Ensure Match repository is accessible
- Check provisioning profile is valid

### Firebase Issues
- Ensure `GoogleService-Info.plist` is decrypted
- Verify Firebase project settings match bundle ID
