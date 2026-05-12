# FromBackInTime

iOS app for time-released video messages and the Critical Timed Message ("dead man's switch") flow.

## Architecture

```
Request → NetworkClient → Repository → Store → State → View
           ↑ swapped via                      ↑ UI models only
           NetworkClientFactory               (never DTOs)
```

- **NetworkClientType** protocol - `NetworkClient` (live) or `MockNetworkClient` (mock) selected at compile time via `AppEnvironment`.
- **Repository** (one per feature) - protocol + live class. Takes `NetworkClientType`. No mock repo class needed.
- **Store** (one per feature) - plain `@Observable` class in `Store/`. Acts as the view model: calls repository, maps DTOs → UI models via StoreUI types. No base class or protocol.
- **DependencyContainer** - owns `networkClient` + all repositories; factory methods create Stores.
- **Store injection** - two patterns:
  - **Global stores** (auth, profile): created in `FromBackInTimeApp.init()`, stored as `@State`, injected via `.environment()`. Views read with `@Environment(AuthStore.self)`.
  - **Per-screen stores** (transactions, payments): created in `RouterDestinationView` via `container.makeXStore()`, passed as init parameters to the view.

## Project structure

```
FromBackInTime/
├── App/
│   ├── FromBackInTimeApp.swift          # @main entry point
│   ├── DependencyContainer.swift        # DI: repositories + store factories
│   ├── Config/
│   │   ├── AppConfig.swift              # reads xcconfig values
│   │   ├── AppEnvironment.swift         # live / mock via #if MOCK
│   │   └── Configurations/
│   │       ├── Development.xcconfig
│   │       ├── Mock.xcconfig
│   │       └── Release.xcconfig
│   └── Router/
│       ├── Router.swift                 # NavigationStack path + sheets
│       ├── Router+Extension.swift       # withAppRouter() modifier
│       ├── Router+Sheet.swift           # sheet/fullscreen modifiers
│       ├── RouterDestination.swift      # enum of all destinations (pure data)
│       └── RouterDestinationView.swift  # resolves destination → View, injects stores
├── Network/
│   ├── Client/
│   │   ├── NetworkClient.swift          # live URLSession client
│   │   ├── NetworkClient+Decode.swift
│   │   ├── NetworkClient+Validate.swift # status code → error + notifications
│   │   ├── NetworkClientFactory.swift   # returns live or mock client
│   │   ├── NetworkClientType.swift      # protocol
│   │   ├── NetworkError.swift           # error enum + isSessionEnded
│   │   ├── NetworkErrorModel.swift      # decoded API error body
│   │   ├── NetworkLogger.swift
│   │   ├── EmptyResponse.swift
│   │   └── BaseResponse.swift           # generic { data, message } wrapper
│   ├── Mock/
│   │   ├── MockNetworkClient.swift      # in-memory client, no network
│   │   ├── MockDataProvider.swift       # protocol for mock providers
│   │   ├── MockDataRegistry.swift       # composite of providers
│   │   ├── MockDatabase.swift           # shared mutable mock state
│   │   └── Providers/
│   │       └── ExampleMockDataProvider.swift
│   ├── Request/
│   │   ├── Request.swift                # protocol
│   │   ├── Request+Extension.swift      # defaults (headers, auth)
│   │   ├── Request+URLRequest.swift     # URL builder
│   │   ├── RequestMethod.swift          # GET/POST/PUT/DELETE/PATCH
│   │   └── Multipart/                   # file upload support
│   └── Repository/
│       └── Example/                     # one folder per feature
│           ├── ExampleRepository.swift  # protocol + live impl
│           ├── ExampleRequests.swift    # request structs
│           └── ExampleResponses.swift   # response DTOs
├── Store/                               # business logic layer
│   └── Example/                         # one folder per feature
│       ├── ExampleStore.swift           # @Observable view model
│       ├── ExampleState.swift           # state struct (plain, no protocol)
│       ├── ExampleStoreUI.swift         # view-friendly models
│       └── ExampleStoreUI+Item.swift    # DTO → UI model mapping
├── Screens/                             # pure views only
│   ├── LaunchView.swift
│   ├── OnboardingView.swift
│   └── Example/
│       └── ExampleView.swift
├── Extensions/
│   ├── Color/
│   │   └── Color+App.swift              # semantic color tokens (dark/light)
│   ├── Font/
│   │   ├── Font+App.swift               # Font.app(_:) SwiftUI extension
│   │   └── UIFont+App.swift             # UIFont.app(_:) UIKit extension
│   ├── Typography/
│   │   └── AppTypography.swift          # heading/body/label/caption tokens
│   ├── Localization/
│   │   ├── L10n.swift                   # type-safe localization keys enum
│   │   └── String+Localization.swift    # .localized property
│   ├── Foundation/                      # String, Date, JSON, Task, Error, etc.
│   ├── UIKit/                           # UIApplication, UIDevice, UIImage, etc.
│   ├── View/                            # SwiftUI View modifiers
│   └── NotificationCenter/              # listen/send helpers
├── Helpers/
│   ├── Keychain/                        # @Keychain property wrapper
│   ├── Clipboard.swift
│   ├── Execute.swift
│   ├── FileHelper.swift
│   ├── Haptics.swift
│   ├── SwipeGestureManager.swift
│   └── URLHelper.swift
├── Reusable/
│   ├── Button/
│   │   ├── PrimaryButtonStyle.swift     # .primaryButton()
│   │   ├── SecondaryButtonStyle.swift   # .secondaryButton()
│   │   └── TextButtonStyle.swift        # .textButton()
│   ├── Preview/
│   │   └── PreviewContainer.swift       # wraps views for Xcode Previews
│   ├── Blur/
│   ├── Loader/
│   ├── Scroll/
│   └── Spacer/
├── Localization/
│   └── en.lproj/
│       └── Localizable.strings          # English strings (old-style .strings)
└── Files/  (Assets.xcassets, Info.plist)
```

## Build schemes

| Scheme | Config | What it does |
|--------|--------|-------------|
| **FromBackInTime** | Debug | Hits real API at `BASE_HOST` from Development.xcconfig |
| **FromBackInTime-Mock** | Mock | Uses `MockNetworkClient` - no network, in-memory data |

The Mock scheme sets `SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG MOCK`, which flips `AppEnvironment.current` to `.mock`.

## Adding a new feature

1. **Repository folder** - create `Network/Repository/Foo/` with:
   - `FooRequests.swift` (enum namespace, struct per endpoint)
   - `FooResponses.swift` (Codable DTOs, optionals)
   - `FooRepository.swift` (protocol + live class)
2. **Mock provider** - `Network/Mock/Providers/FooMockDataProvider.swift`
3. **Register provider** - add `registry.register(FooMockDataProvider())` in `NetworkClientFactory.defaultMockRegistry()`
4. **Wire in DI** - add `fooRepository` + `makeFooStore()` in `DependencyContainer`
5. **Store folder** - create `Store/Foo/` with:
   - `FooStore.swift` - `@Observable` class with `var state = FooState()`
   - `FooState.swift` - plain struct holding UI models + loading/error
   - `FooStoreUI.swift` - UI model types (`enum FooStoreUI { struct Item { ... } }`)
   - `FooStoreUI+Item.swift` - DTO→UI mapping (`init(from:)` on each UI model)
6. **View** - `Screens/Foo/FooView.swift` - receives store as init parameter
7. **Route** - add case in `App/Router/RouterDestination`
8. **Inject** - in `App/Router/RouterDestinationView`, create store and pass to view:
   - Per-screen: `FooView(store: container.makeFooStore())`
   - Global: create in `FromBackInTimeApp.init()`, inject via `.environment()`

## Design system

### Colors (`Extensions/Color/Color+App.swift`)
- Semantic tokens: `Color.appPrimary`, `.appSecondary`, `.appBackground`, `.appSurface`, `.appCardBackground`, `.appBorder`, `.appAccent`, `.appError`, `.appSuccess`, etc.
- All tokens auto-switch between light and dark mode.
- Raw palette: `neutral50`–`neutral950`, `brand50`–`brand700`.
- To rebrand: swap hex values in the raw palette section - semantic tokens adapt automatically.

### Typography (`Extensions/Typography/AppTypography.swift`)
- Tokens: `.heading1`–`.heading6`, `.bodyL`/`.bodyM`/`.bodyS`/`.bodyXS`, `.labelL`/`.labelS`/`.labelXS`, `.caption`
- Uses system font by default. Set `customFontName` in `AppTypography` to switch to a bundled font.
- Apply via `Text("Hello").appFont(.heading3)` or `.font(.app(.bodyM))`.

### Spacing & Radius (`Extensions/Foundation/AppSpacing.swift`)
- `AppSpacing.xs` (4) through `AppSpacing.xxxxl` (48) - use instead of hardcoded padding/spacing values.
- `AppRadius.sm` (8) through `AppRadius.xl` (20) + `AppRadius.full` (pill) - use instead of hardcoded corner radii.

### BaseResponse (`Network/Client/BaseResponse.swift`)
- Generic `BaseResponse<T>` for APIs that wrap responses in `{ "data": ..., "message": "..." }`.
- Adjust fields to match your API envelope. Use in repositories: `let response: BaseResponse<Foo> = try await client.request(...)` then access `response.data`.

### Button styles (`Reusable/Button/`)
- `Button("Go") { }.primaryButton()` - filled, full-width, supports `leftIcon:`, `rightIcon:`, `isLoading:`
- `Button("Cancel") { }.secondaryButton()` - neutral background
- `Button("Skip") { }.textButton()` - text-only, accent color

### Localization (`Extensions/Localization/`)
- Type-safe keys: `L10n.commonOk.localized` → looks up `"common.ok"` in `Localizable.strings`.
- Format strings: `L10n.someFormat.localized(with: value)` for `%@` / `%d` placeholders.
- Raw string access: `"some.key".localized` via `String+Localization.swift`.
- Strings file: `Files/Localization/en.lproj/Localizable.strings` (old-style `.strings`, not String Catalog).
- To add a new string: add key to `Localizable.strings`, add matching case to `L10n` enum.
- Keys use dot notation grouped by feature: `"feature.key_name"`.

### Previews
- Wrap in `PreviewContainer { YourView() }` to get mock DI + Router + NavigationStack.

## Mock scheme details

- `MockNetworkClient` satisfies `NetworkClientType`. It never hits the network.
- `MockDataProvider` protocol returns `Data?` for a given `Request`.
- `MockDataRegistry` is a composite - iterates providers until one returns non-nil.
- `MockDatabase` holds shared mutable state across providers so sequences stay consistent.
- Presets (`MockDatabase.applyPreset(for:)`) let you switch between user personas.
- Add mock data for a feature by:
  1. Creating a `FooMockDataProvider: MockDataProvider`
  2. Pattern-matching on concrete request types
  3. Returning `encode(FooResponses.Bar(...))` built from `database` fields

## Image generation (fal.ai MCP)

Project-scoped MCP server is configured in `.mcp.json`. It uses fal.ai for image generation across GPT Image 2, Nano Banana 2, FLUX.2, Imagen 4, Ideogram V3, Seedream, etc. - one API key, swap models by ID.

To activate it locally:

1. Get an API key at https://fal.ai/dashboard/keys
2. Export it in your shell profile: `export FAL_KEY="fal_..."`
3. Restart Claude Code in the project root - it will pick up `.mcp.json` and prompt to approve the server.

The `.mcp.json` references `${FAL_KEY}` so the key never gets committed.

## Writing style (no AI slop)

When writing ANY text in this project - code comments, docs, commit messages, PR bodies, UI strings, localized strings - follow these rules:

- **No em-dashes (`—`) or en-dashes (`–`).** Use a regular hyphen `-`, a comma, a period, or a colon. Never use Unicode dashes.
- **No letter-spaced "tracked" headers** like `H E A D E R` or `T I T L E`. Write headers normally: `Header`, `Title`. Do not insert spaces between letters for emphasis, ever, anywhere (UI, comments, docs).
- **No `tracking()` / `kerning()` modifiers** applied to text just to spread letters apart for an "AI-styled" look.
- Keep prose plain and direct. No marketing fluff, no "seamlessly", "leverages", "delve", "robust", "comprehensive", etc.
- App is non-export-compliance by default: `ITSAppUsesNonExemptEncryption = false` in `Info.plist`. Leave it that way unless the app actually uses non-exempt encryption.

## Conventions

- **Namespacing**: `FooRequests.Bar`, `FooResponses.Bar`, `FooStoreUI.Bar` - enums group related types.
- **DTOs are optional**: response fields are `var x: T?`. UI models are non-optional.
- **Mapping lives on StoreUI side**: `FooStoreUI.Bar.init(from: FooResponses.Bar)`.
- **State holds UI models**: never raw DTOs.
- **Store actions**: set `state.isLoading = true`, `state.error = nil`, `defer { state.isLoading = false }`, call repo, map, catch.
- **Session errors**: check `error.isSessionEnded` - skip setting `state.error` for those (global handler takes over).
- **No mock repository classes**: mock happens at the client layer.
- **Store lives in `Store/`**, views live in `Screens/`. Views receive stores via init, never create them.
- **Global vs per-screen stores**: global → `.environment()` from App, per-screen → init param from `RouterDestinationView`.
- **Localized strings**: always use `L10n.caseName.localized`, never hardcoded user-facing text.
- **Folder rules**: Extensions grouped by framework (`Foundation/`, `UIKit/`, `View/`). Single-file helpers live flat in `Helpers/`. One subfolder per multi-file concern only.

## Skills

The starter ships with a reusable Claude skill at `skills/`:

- **`skills/demo/`** — `/demo` workflow. Records a screen-recorded walkthrough of an app flow, saves it to `~/Documents/` as a `.mov`. Has a `scripts/record-demo.sh` recorder wrapper + a `DemoRecorder.swift.template` UITest template. See `skills/demo/SKILL.md` for the full interactive flow Claude should follow (ask for flow → ask for mock data persona → generate UITest → run recorder → restore any patches).

Open `scripts/record-demo.sh` and update `SCHEME`, `BUNDLE_ID`, and the default `TEST_ID` as needed; everything else is generic.
