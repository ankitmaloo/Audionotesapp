# Repository Guidelines

## Project Structure & Module Organization
- `AudionotesApp/AudionotesApp/`: SwiftUI app entry (`AudionotesAppApp.swift`), views (`NotesView.swift`, `RecordingView.swift`), models (`Note.swift`, `NotesManager.swift`), assets (`Assets.xcassets`), and app config (`Info.plist`, `.entitlements`).
- `AudionotesApp/AudioCapService/`: CoreAudio capture and processing utilities (e.g., `AudioCapService.swift`, `ProcessTap.swift`, `CoreAudioUtils.swift`).
- `AudionotesApp/AudionotesApp.xcodeproj`: Xcode project, schemes, and build settings.

## Build, Test, and Development Commands
- Open in Xcode: `open AudionotesApp/AudionotesApp.xcodeproj`
- Build (CLI): `xcodebuild -project AudionotesApp/AudionotesApp.xcodeproj -scheme AudionotesApp -configuration Debug -destination 'platform=macOS' build`
- Test (if tests exist): `xcodebuild -project AudionotesApp/AudionotesApp.xcodeproj -scheme AudionotesApp -destination 'platform=macOS' test`
- Run: Prefer Xcode (Cmd+R) for debugging, microphone permissions, and UI iteration.

## Coding Style & Naming Conventions
- Language: Swift; 4‑space indentation, no tabs; follow Xcode’s default brace style.
- Naming: Types in UpperCamelCase; methods/properties in lowerCamelCase. Filenames match the primary type (e.g., `NotesManager.swift`, `AudioCapService.swift`).
- Patterns: SwiftUI views end with `View`; services/managers end with `Service`/`Manager`.
- Keep functions small; prefer value semantics and explicit access control.

## Testing Guidelines
- Framework: XCTest. Place tests under `AudionotesAppTests/`, name files `FeatureNameTests.swift`, methods `test_*`.
- Focus: Core logic in `NotesManager` and audio pipeline; inject dependencies to isolate CoreAudio.
- Run via Xcode’s Test navigator or the CLI command above. Keep warnings at zero.

## Commit & Pull Request Guidelines
- Commits: Use Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`). Write imperative, present‑tense subject lines.
- PRs: Provide a clear summary, linked issues, and screenshots/GIFs for UI changes. Keep changes focused and update docs when behavior changes.

## Security & Configuration Tips
- Secrets: Do not commit API keys. `geminiAPIKey` is stored via `@AppStorage`; use local settings during development.
- Permissions: Microphone access requires `NSMicrophoneUsageDescription` and sandbox entitlements; avoid changes without discussion.
