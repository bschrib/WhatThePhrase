# WhatThePhrase

A fun and engaging word guessing game for iOS, perfect for parties, family gatherings, or just having fun with friends. The game challenges players to guess words based on clues given by their teammates, with a countdown timer adding to the excitement.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [How to Play](#how-to-play)
- [Development Setup](#development-setup)
  - [Prerequisites](#prerequisites)
  - [Installing rbenv and Ruby](#installing-rbenv-and-ruby)
  - [Installing Dependencies](#installing-dependencies)
- [Fastlane & Deployment](#fastlane--deployment)
  - [Available Fastlane Lanes](#available-fastlane-lanes)
  - [Publishing to TestFlight](#publishing-to-testflight)
  - [Publishing to the App Store](#publishing-to-the-app-store)
  - [Code Signing with Match](#code-signing-with-match)
- [Codemagic CI/CD](#codemagic-cicd)
  - [Available Workflows](#available-workflows)
  - [Setting Up Codemagic](#setting-up-codemagic)
  - [Environment Variables](#environment-variables)
- [Project Structure](#project-structure)
- [Customization](#customization)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Multiple Categories**: Choose from a variety of categories including Places & Spaces, Food, Animals, and more
- **Kids Mode**: Special mode with simpler words and categories designed for younger players
- **Team Play**: Play with friends in team mode or practice solo
- **Customizable Timer**: Adjust the game duration to fit your preferences
- **Score Tracking**: Keep track of points for each team
- **Beautiful UI**: Clean, intuitive interface with smooth animations
- **Sound Effects**: Engaging audio feedback for game events

---

## Requirements

### For Playing the App
- iOS 15.0+
- iPhone or iPad

### For Development
- macOS (latest recommended)
- Xcode 13.0+ (latest recommended)
- Swift 5.5+
- Ruby 3.2.10 (managed via rbenv)
- Bundler
- 1Password CLI (for secure credential management)

---

## Quick Start

If you just want to build and run the app in Xcode:

1. Clone the repository
   ```bash
   git clone https://github.com/bschrib/WhatThePhrase.git
   cd WhatThePhrase
   ```
2. Open `WhatThePhrase.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (Cmd + R)

---

## How to Play

### Basic Gameplay

1. **Select a Category**: Choose from the available categories on the main screen
2. **Give Clues**: One player gives clues to their teammates without saying the actual word
3. **Guess the Word**: Teammates try to guess the word before time runs out
4. **Score Points**: Tap "Correct" when your team guesses correctly, or "Pass" to skip
5. **Win**: The team with the most points when time runs out wins!

### Controls

| Button | Action |
|--------|--------|
| **Correct** | Team guessed the word correctly (+1 point) |
| **Pass** | Skip to the next word (no penalty) |
| **Stop** | End the current game |

### Kids Mode

Enable Kids Mode in Settings for younger players. This will:
- Show simplified categories and words
- Use age-appropriate vocabulary
- Provide a more accessible gaming experience

---

## Development Setup

### Prerequisites

Before you begin, ensure you have the following installed:

1. **Xcode** - Install from the Mac App Store or [Apple Developer](https://developer.apple.com/xcode/)
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (if not already installed)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **1Password CLI** (for secure credential management)
   ```bash
   brew install --cask 1password-cli
   ```

### Installing rbenv and Ruby

This project uses **Ruby 3.2.10** managed via rbenv. This ensures consistent Ruby versions across development environments.

1. **Install rbenv and ruby-build**
   ```bash
   brew install rbenv ruby-build
   ```

2. **Initialize rbenv** (add to your shell profile)
   
   For **bash** (`~/.bash_profile` or `~/.bashrc`):
   ```bash
   echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
   source ~/.bash_profile
   ```
   
   For **zsh** (`~/.zshrc`):
   ```bash
   echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Install Ruby 3.2.10**
   ```bash
   rbenv install 3.2.10
   ```

4. **Verify Ruby version** (should automatically use 3.2.10 due to `.ruby-version` file)
   ```bash
   cd /path/to/WhatThePhrase
   ruby --version
   # Should output: ruby 3.2.10 (or similar)
   ```

   If the version doesn't match, set it manually:
   ```bash
   rbenv local 3.2.10
   ```

### Installing Dependencies

1. **Install Bundler** (Ruby dependency manager)
   ```bash
   gem install bundler
   ```

2. **Install project dependencies**
   ```bash
   bundle install
   ```

   This installs Fastlane and all required gems as specified in the `Gemfile`.

---

## Fastlane & Deployment

[Fastlane](https://fastlane.tools/) automates building, signing, and deploying the app. All fastlane commands should be run with `bundle exec` to ensure the correct gem versions are used.

### Available Fastlane Lanes

| Lane | Description | Command |
|------|-------------|---------|
| `beta` | Build and upload to TestFlight | `bundle exec fastlane beta` |
| `release` | Build and submit to App Store | `bundle exec fastlane release` |
| `upload_screenshots` | Upload screenshots only | `bundle exec fastlane upload_screenshots` |
| `develop` | Build for local development | `bundle exec fastlane develop` |
| `generate_appicon` | Generate app icons from source | `bundle exec fastlane generate_appicon` |
| `generate_launch_image` | Generate launch images | `bundle exec fastlane generate_launch_image` |

### Publishing to TestFlight

This project uses **1Password CLI** to securely inject the `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` environment variable. This avoids storing sensitive credentials in plain text.

#### Prerequisites

1. **Create an App-Specific Password**
   - Go to [appleid.apple.com](https://appleid.apple.com)
   - Sign in and navigate to Security > App-Specific Passwords
   - Generate a new password for "Fastlane"

2. **Store in 1Password**
   - Create an item in 1Password named `fastlaneAppleAppPassword` in your `production` vault
   - Store the app-specific password in the `password` field

3. **Verify 1Password CLI is authenticated**
   ```bash
   op signin
   ```

#### Deploy to TestFlight

```bash
op run --env-file=fastlane.op -- bundle exec fastlane beta
```

This command:
1. Reads the `fastlane.op` file which references `op://production/fastlaneAppleAppPassword/password`
2. 1Password CLI injects the password as `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
3. Fastlane syncs certificates via Match
4. Builds the app with an incremented build number
5. Uploads to TestFlight

### Publishing to the App Store

For a full App Store release:

```bash
op run --env-file=fastlane.op -- bundle exec fastlane release
```

This will:
- Sync certificates
- Build the app
- Upload binary, metadata, and screenshots
- Submit for review automatically

### Code Signing with Match

This project uses [Match](https://docs.fastlane.tools/actions/match/) for code signing. Certificates and provisioning profiles are stored in a private Git repository.

- **Certificate Repository**: `https://github.com/bschrib/fastlane`
- **Storage Mode**: Git

To sync certificates manually:
```bash
bundle exec fastlane match appstore
bundle exec fastlane match development
```

---

## Codemagic CI/CD

This project includes [Codemagic](https://codemagic.io/) configuration for automated builds and deployments. The configuration is defined in `codemagic.yaml`.

### Available Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `ios-develop` | Pull Requests | Builds the app for development/testing |
| `ios-beta` | Push to `main` or `release/*` | Builds and deploys to TestFlight |
| `ios-release` | Tags matching `v*` | Builds and submits to App Store |
| `ios-fastlane-beta` | Push to `fastlane-beta` | Alternative beta workflow using Fastlane |

### Setting Up Codemagic

1. **Connect your repository** to Codemagic at [codemagic.io](https://codemagic.io/)

2. **Configure environment variable groups** in Codemagic settings:

   - `app_store_credentials` - App Store Connect API credentials
   - `match_credentials` - Fastlane Match credentials (if using Match)
   - `fastlane_credentials` - Fastlane-specific credentials (for Fastlane workflow)

3. **Set up code signing** in Codemagic:
   - Go to your app settings → Code signing → iOS
   - Upload your certificates and provisioning profiles, OR
   - Use automatic code signing with App Store Connect API

### Environment Variables

Create these environment variable groups in Codemagic:

#### `app_store_credentials`
| Variable | Description |
|----------|-------------|
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | App Store Connect API Private Key (`.p8` contents) |

#### `match_credentials` (if using Fastlane Match)
| Variable | Description |
|----------|-------------|
| `MATCH_PASSWORD` | Password for Match certificate encryption |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64-encoded `username:token` for Match git repo |

#### `fastlane_credentials` (for Fastlane workflow)
| Variable | Description |
|----------|-------------|
| `FASTLANE_USER` | Apple ID email |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | App-specific password |

### Triggering Builds

- **Pull Requests**: Automatically triggers `ios-develop` workflow
- **Push to main**: Automatically triggers `ios-beta` workflow (TestFlight)
- **Create a tag**: Tag with `v1.2.3` format triggers `ios-release` workflow (App Store)

```bash
# Example: Create a release
git tag v1.2.0
git push origin v1.2.0
```

---

## Project Structure

```
WhatThePhrase/
├── WhatThePhrase/              # Main app source code
│   ├── Assets/
│   │   ├── Images/             # App icons and images
│   │   ├── Scripts/            # Utility scripts (e.g., word list generator)
│   │   ├── Sounds/             # Sound effects (buzz.wav)
│   │   └── WordLists/          # JSON word lists
│   │       ├── wordlists.json      # Standard word lists
│   │       └── kids_wordlists.json # Kids mode word lists
│   ├── Assets.xcassets/        # Xcode asset catalog
│   ├── ContentView.swift       # Main screen (category selection)
│   ├── GameView.swift          # Game interface (timer, score, words)
│   ├── SettingsView.swift      # App settings
│   ├── RequestManager.swift    # Word list and game state management
│   ├── AudioPlayerController.swift
│   ├── LaunchScreen.swift
│   └── WhatThePhrase.swift     # App entry point
├── WhatThePhrase.xcodeproj/    # Xcode project
├── WhatThePhraseUITests/       # UI tests
├── fastlane/                   # Fastlane configuration
│   ├── Fastfile                # Lane definitions
│   ├── Appfile                 # App identifiers and team IDs
│   ├── Matchfile               # Code signing configuration
│   └── README.md               # Auto-generated fastlane docs
├── metadata/                   # App Store metadata
├── screenshots/                # App Store screenshots
├── .maestro/                   # Maestro UI testing flows
├── Gemfile                     # Ruby dependencies
├── Gemfile.lock                # Locked gem versions
├── .ruby-version               # Ruby version (3.2.10)
├── fastlane.op                 # 1Password environment file
└── codemagic.yaml              # Codemagic CI/CD configuration
```

### Key Files

| File | Purpose |
|------|---------|
| `RequestManager.swift` | Manages word lists, categories, tracks used words, handles Kids Mode |
| `ContentView.swift` | Main screen with category selection grid |
| `GameView.swift` | Active game view with timer, current word, and score |
| `SettingsView.swift` | Game settings (timer duration, Kids Mode toggle) |
| `wordlists.json` | Standard word lists organized by category |
| `kids_wordlists.json` | Simplified word lists for younger players |

---

## Customization

### Adding New Word Lists

1. Create or edit JSON files in `WhatThePhrase/Assets/WordLists/`
2. Format as a dictionary with category names as keys and word arrays as values:
   ```json
   {
     "Category Name": ["word1", "word2", "word3"],
     "Another Category": ["word4", "word5"]
   }
   ```
3. Update `RequestManager.swift` if adding entirely new word list files

### Modifying Game Behavior

- **Timer Duration**: Adjust in `SettingsView.swift`
- **Game Modes**: Toggle between regular and Kids Mode in `RequestManager.swift`
- **UI Customization**: Modify the SwiftUI views directly

---

## Testing

### UI Testing with Maestro

This project includes [Maestro](https://maestro.mobile.dev/) flows for UI testing.

```bash
# Install Maestro
curl -Ls "https://get.maestro.mobile.dev" | bash

# Run the test flow
maestro test .maestro/flow.yaml
```

### Xcode UI Tests

UI tests are located in `WhatThePhraseUITests/`:

```bash
# Run from Xcode or command line
xcodebuild test -project WhatThePhrase.xcodeproj -scheme WhatThePhrase -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Troubleshooting

### Ruby/rbenv Issues

**Problem**: Wrong Ruby version being used
```bash
# Check which Ruby is active
which ruby
ruby --version

# Ensure rbenv is initialized in your shell
eval "$(rbenv init -)"

# Rehash after installing gems
rbenv rehash
```

**Problem**: `bundle install` fails
```bash
# Update bundler
gem install bundler

# Clear bundle cache and reinstall
rm -rf vendor/bundle
bundle install
```

### Fastlane Issues

**Problem**: Code signing errors
```bash
# Nuke and recreate certificates (use with caution)
bundle exec fastlane match nuke appstore
bundle exec fastlane match appstore
```

**Problem**: App-specific password not working
- Verify the password is correctly stored in 1Password
- Check that `op` CLI is authenticated: `op signin`
- Test the reference: `op read "op://production/fastlaneAppleAppPassword/password"`

### Build Issues

**Problem**: App crashes on launch
1. Clean build folder: Cmd + Shift + K
2. Delete Derived Data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Rebuild the project

**Problem**: Word lists not loading
- Ensure JSON files are included in the app target (check Target Membership in Xcode)
- Verify JSON syntax is valid
- Check console logs for loading errors

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Thanks to all contributors who have helped improve this project
- Special thanks to my daughter for the Kids Mode suggestion!

---

Made with care by Brandon Schreiber
