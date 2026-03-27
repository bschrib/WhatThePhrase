# WhatThePhrase

SwiftUI party word-guessing game for iOS. Players guess words from clues with a countdown timer.

## Build Tooling

**Fastlane is the primary build tool.** Use fastlane lanes instead of raw `xcodebuild` commands whenever possible. Ruby managed via `rbenv` (version pinned in `.ruby-version`).

```bash
eval "$(rbenv init -)"
bundle exec fastlane <lane>
```

### Available Lanes

| Lane | Purpose |
|------|---------|
| `build_local` | Build for simulator, no signing — use for compilation checks |
| `develop` | Dev build with match signing |
| `beta` | Build + upload to TestFlight |
| `release` | Build + upload to App Store + submit for review |
| `screenshots` | Generate App Store screenshots via XCUITest |
| `upload_screenshots` | Upload screenshots only (no build) |
| `generate_appicon` | Generate app icon assets |

### Secrets / 1Password Integration

Credentials are injected via 1Password CLI using `fastlane.op`:

```bash
source <(op inject -i fastlane.op --account=3W2HMD2KKRGNBNJI3UD2NQ726A)
```

- **Account**: `my.1password.com` (bschrib@gmail.com) — NOT the Foxen account
- **Vault**: `production`
- **Item**: `fastlaneAppleAppPassword`
  - `password` — Apple app-specific password (`FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`)
  - `matchRepoPassword` — Match cert repo decryption key (`MATCH_PASSWORD`)
  - `p8Key` — App Store Connect API key (`APP_STORE_CONNECT_API_KEY_KEY`)

### Deploy Workflow

```bash
eval "$(rbenv init -)"
source <(op inject -i fastlane.op --account=3W2HMD2KKRGNBNJI3UD2NQ726A)

# TestFlight
bundle exec fastlane beta

# App Store
bundle exec fastlane release
```

### Screenshots

```bash
bundle exec fastlane screenshots   # generates to screenshots/
bundle exec fastlane upload_screenshots  # uploads to App Store Connect
```

Snapfile configures device list and output directory. Screenshot tests live in `WhatThePhraseUIScreenshotTests` target (compiles `WhatThePhraseUITests/WhatThePhraseUITests.swift`).

## Testing

- **XCUITest**: `WhatThePhraseUITests/` — UI tests including screenshot generation
- **Maestro**: `.maestro/` — smoke tests for basic flows
- **Scheme**: `WhatThePhraseScreenShots` for screenshot tests, `WhatThePhrase` for app builds
- Tests use accessibility identifiers: `kidsModeToggle`, `playAsTeamsToggle`, `kidsDifficultyPicker`, `settingsButton`, `infoButton`

Run tests via XcodeBuildMCP `test_sim` or:
```bash
bundle exec fastlane screenshots  # runs screenshot tests
```

## CI/CD

Codemagic is configured (`codemagic.yaml`) but currently broken. Use local fastlane lanes for deployment.

## Project Structure

- `WhatThePhrase/` — main app source (SwiftUI)
- `WhatThePhrase/Assets/WordLists/` — bundled JSON word lists
- `WhatThePhraseUITests/` — XCUITest suite
- `fastlane/` — Fastfile, Snapfile, SnapshotHelper
- `.maestro/` — Maestro UI test flows
- `fastlane.op` — 1Password secret references for CI/deploy
