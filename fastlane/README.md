fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new beta build to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new build to the App Store (Public Release)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate screenshots using Snapshot

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload only screenshots (no build)

### ios develop

```sh
[bundle exec] fastlane ios develop
```

Build for local development

### ios build_local

```sh
[bundle exec] fastlane ios build_local
```

Build locally without certificates (for testing compilation)

### ios generate_appicon

```sh
[bundle exec] fastlane ios generate_appicon
```



### ios generate_launch_image

```sh
[bundle exec] fastlane ios generate_launch_image
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
