# Repository Guidelines

## Project Structure & Module Organization

QBlocker is a macOS SwiftUI/AppKit menu bar app. Application source lives in `QBlocker/`, with the SwiftUI menu bar entry point in `StatusMenuController.swift` and launch/runtime setup in `AppDelegate.swift`. Keyboard interception is handled by `KeyListener.swift`; settings and persistence live in `AppSettings.swift`; HUD presentation is split between `HUDPresenter.swift` and `HUDView.swift`. App assets are in `QBlocker/Assets.xcassets/`, larger source assets are in `Assets/`, and the static marketing site is in `Website/`. There is no active test target.

## Build, Test, and Development Commands

Prefix shell commands with `rtk` when working from an agent session.

```bash
rtk xcodebuild -project QBlocker.xcodeproj -scheme QBlocker -configuration Debug -derivedDataPath /tmp/QBlockerDerivedData CODE_SIGNING_ALLOWED=NO build
```

Builds the app without requiring local code signing.

```bash
rtk open QBlocker.xcodeproj
```

Opens the project in Xcode for local running, signing, and UI inspection.

There is currently no dedicated test command.

## Coding Style & Naming Conventions

Use Swift 6 and macOS 14-compatible APIs. Prefer AppKit-native types and patterns already present in the codebase. Use 4-space indentation, `final` for classes not intended for subclassing, and `private` for implementation details. Name types in `UpperCamelCase`, methods and properties in `lowerCamelCase`, and keep file names aligned with their primary type, for example `StatusMenuController.swift`.

## Testing Guidelines

Do not add tests unless explicitly requested. Verify behavior with local builds and manual signed-runtime checks. For HUD or accessibility changes, verify in a signed local build because behavior depends on macOS permissions and display geometry.

## Commit & Pull Request Guidelines

Git history uses short, imperative commit messages such as `Add labels to the slider` and `Update changelog`. Keep commits focused and describe user-visible behavior. Pull requests should include a concise summary, testing notes, screenshots or screen recordings for UI changes, and linked issues when applicable. Mention any Accessibility permission or signing steps needed to reproduce behavior.

## Security & Configuration Tips

Do not commit signing identities, provisioning profiles, or personal Xcode settings. Accessibility permission is required for event interception; test that flow explicitly after changes to `KeyListener`, entitlements, or onboarding.
