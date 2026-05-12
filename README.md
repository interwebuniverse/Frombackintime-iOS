# FromBackInTime

iOS app for sending video messages to the future. Time-released video messages, scheduled email delivery, and the Critical Timed Message ("dead man's switch") flow for releasing sensitive information on schedule.

## Requirements

- Xcode 16.1+
- iOS 18.1+
- Swift 5.0+

## Getting started

Open `FromBackInTime.xcodeproj` in Xcode. Two schemes are available:

| Scheme | What it does |
|--------|-------------|
| **FromBackInTime** | Builds against the live API (`BASE_HOST` from Development.xcconfig) |
| **FromBackInTime-Mock** | Builds with `MockNetworkClient`, all data is in-memory, no network |

Run the Mock scheme to see the app run end-to-end with mock data, no backend required.

## Architecture

- **Networking** - protocol-based `NetworkClient` with validation, error mapping, multipart uploads, and a full mock layer
- **Mock scheme** - compile-time flag swaps to `MockNetworkClient` with in-memory data, presets, and simulated delay
- **Dependency injection** - `DependencyContainer` owns repositories and creates Stores, injected via SwiftUI `.environment`
- **Store pattern** - `@Observable` state management per feature with async actions and loading/error states
- **Design system** - semantic color tokens (dark/light auto-switch), typography scale, button styles
- **Localization** - type-safe `L10n` enum backed by `Localizable.strings`
- **Router** - `NavigationStack` path-based routing with sheet and fullscreen cover support

## Project structure

```
FromBackInTime/
├── App/                    # Entry point, DI, config, router
├── Network/
│   ├── Client/             # Live URLSession client + validation + errors
│   ├── Mock/               # MockNetworkClient + registry + database + providers
│   ├── Request/            # Request protocol + multipart
│   └── Repository/         # One folder per feature (repo + requests + responses)
├── Store/                  # One folder per feature (state + store + UI models)
├── Screens/                # SwiftUI views, one folder per feature
├── Extensions/             # Grouped by framework: Color, Font, Foundation, UIKit, View
├── Helpers/                # Keychain, Haptics, Clipboard, File, URL
├── Reusable/               # Button styles, Preview container, Blur, Loader, Scroll
└── Files/                  # Assets.xcassets, Info.plist
```

## Documentation

| Doc | What it covers |
|-----|---------------|
| `CLAUDE.md` | Full architecture reference, conventions, structure |
| `docs/feature-checklist.md` | Code templates for adding a new feature |
| `docs/networking.md` | Network client, validation, error handling |
| `docs/mocks.md` | Mock scheme, providers, database, presets |
| `docs/di.md` | DependencyContainer usage and wiring |
