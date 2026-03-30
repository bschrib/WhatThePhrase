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

- **Account**: `my.1password.com` (bschrib@gmail.com, ID: `3W2HMD2KKRGNBNJI3UD2NQ726A`) — NOT the Foxen account
- **Vault**: `production`
- **Item**: `fastlaneAppleAppPassword`
  - `password` — Apple app-specific password (`FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`)
  - `matchRepoPassword` — Match cert repo decryption key (`MATCH_PASSWORD`)
  - `p8Key` — App Store Connect API key content (`ASC_KEY_RAW`)
  - `keyId` — API key ID (`ASC_KEY_ID`)
  - `issuerId` — API issuer ID (`ASC_ISSUER_ID`)
- **Vault**: `Private` — Apple ID password at item ID `64tlrskwd3uh3a2dcdxdpkllz4` (`FASTLANE_PASSWORD`)

### Deploy Workflow

The p8 key from 1Password loses its newlines, so it must be written to a temp file before fastlane can use it:

```bash
eval "$(rbenv init -)"
source <(op inject -i fastlane.op --account=3W2HMD2KKRGNBNJI3UD2NQ726A)

# Write p8 key to temp file with proper PEM formatting
P8_TMPFILE=$(mktemp /tmp/asc_key_XXXXXX.p8)
echo "$ASC_KEY_RAW" | sed 's/-----BEGIN PRIVATE KEY----- /-----BEGIN PRIVATE KEY-----\n/' | sed 's/ -----END PRIVATE KEY-----/\n-----END PRIVATE KEY-----/' | fold -w 64 > "$P8_TMPFILE"
export ASC_KEY_PATH="$P8_TMPFILE"

# TestFlight
bundle exec fastlane beta

# App Store (includes screenshots upload + submit for review)
bundle exec fastlane release

# Cleanup
rm -f "$P8_TMPFILE"
```

1Password CLI sessions time out after ~10 minutes of inactivity. If you get `authorization timeout`, re-auth with `op signin --account=3W2HMD2KKRGNBNJI3UD2NQ726A`.

### Screenshots

```bash
bundle exec fastlane screenshots         # generates to screenshots/
bundle exec fastlane upload_screenshots   # uploads to App Store Connect (overwrites existing)
```

- Snapfile configures device list (iPhone 17 Pro Max for 6.9" App Store size) and output directory
- Screenshot tests live in `WhatThePhraseUIScreenshotTests` target (compiles `WhatThePhraseUITests/WhatThePhraseUITests.swift`)
- The `release` lane uploads screenshots with `overwrite_screenshots: true` so fresh screenshots always replace stale ones
- Xcode 26 dropped `-testplan` flag support — don't add it back to snapshot/Fastfile

## Testing

- **XCUITest**: `WhatThePhraseUITests/` — UI tests including screenshot generation
- **Maestro**: `.maestro/` — smoke tests for basic flows
- **Scheme**: `WhatThePhraseScreenShots` for screenshot tests, `WhatThePhrase` for app builds
- Tests use accessibility identifiers: `kidsModeToggle`, `playAsTeamsToggle`, `kidsDifficultyPicker`, `settingsButton`, `infoButton`

Run tests via XcodeBuildMCP `test_sim` or:
```bash
bundle exec fastlane screenshots  # runs screenshot tests
```

## Git / SSH

SSH is managed by 1Password agent. If `git push` fails with "Permission denied (publickey)", set the socket:
```bash
SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" git push origin main
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
