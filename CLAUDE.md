# FromBackInTime

iOS app for time-released video messages and the Critical Timed Message ("dead man's switch") flow.

## Backend binding status (0→1)

The app is bound to the FromBackInTime backend. `MockAppStore` is now backed by
real repositories in the live scheme and still runs seeded/in-memory in the Mock
scheme.

- **Auth**: Supabase anonymous sign-in on launch (`AuthStore.ensureSession`),
  token in Keychain, injected as Bearer on every call. Apple + Google sign-in
  are fully wired in the onboarding auth gate (`OBAuthGateView`): Apple via
  native `SignInWithAppleButton` + nonce (`SignInCrypto`), Google via Supabase
  hosted OAuth PKCE in `ASWebAuthenticationSession` (`GoogleAuthSession`,
  callback scheme `frombackintime://auth-callback`). Needs Supabase dashboard
  config: enable Apple provider (client ID = bundle ID), Google provider (web
  client ID + secret), and add the callback URL to allowed redirect URLs.
- **Session lifecycle**: `NetworkClient` retries once after a 401 by refreshing
  the token through `SessionRefresher` (actor, dedupes concurrent refreshes;
  Supabase rotates refresh tokens). If refresh fails it clears the session and
  posts `.unauthorizedAccess`; `AuthStore` self-heals to a fresh anonymous
  session and posts `.sessionReplaced`, which `FromBackInTimeApp` listens to
  and reloads user data. On cold launch `AuthStore` restores
  `is_anonymous`/`sub`/`email` from the stored JWT claims (`JWT.payload`).
  If the session that *dropped* was a real (non-anonymous) one, `AuthState.sessionExpired`
  is set so `RootView` presents a "sign back in" `SignInSheet` instead of
  silently swapping the vault for an empty anonymous one (which reads as data
  loss). A reinstall that wipes the onboarding flag but keeps the Keychain
  session skips onboarding (the launch `.task` calls `completeOnboarding` when a
  signed-in session is restored). Sign-out leaves the user in the app as
  anonymous (no forced re-onboarding); only delete-account resets onboarding.
- **Sign-in gates (no orphaned data)**: Apple/Google sign-in mints a NEW
  Supabase user, so anything created anonymously would orphan on upgrade. All
  creates (add person, save any message) therefore require a real account:
  anonymous users get `SignInSheet` (shared `SignInControls` with the
  onboarding gate) and the action retries after sign-in. The backend also
  403-gates finalize/CTM-arm with a "Sign in..." message the app surfaces.
- **Wired to backend**: recipients (list/create/edit/delete — delete handles
  the 409 while armed/scheduled messages exist), messages
  (list/create/finalize/**edit via PATCH**/delete + detail with decrypted body
  and presigned playback `media` URL), CTM (arm + one-time access code; check-in
  + snooze via the Home card that shows whenever a switch is armed), profile
  (GET/PATCH /v1/me — onboarding pushes name/timezone/notifPrefs at finish;
  delete account, sign out). Editing a scheduled message's who/when/occasion is
  `EditMessageView` (sheet from `MessageDetailView`, `store.updateMessage` →
  PATCH); media itself is not editable (re-record to replace).
- **All media is real capture and real playback**: photo (`PhotosPicker` →
  JPEG), voice (`AVAudioRecorder` → m4a), video (camera via `MoviePicker`,
  5-min cap, real content-type of the clip — quicktime/mp4, both backend-allowed);
  presigned-PUT upload to R2 then finalize (failed saves roll back the draft).
  A `.savingOverlay` veils the composer while a large upload runs so it never
  looks frozen. Capture is permission-gated via `MediaPermission`
  (`ensure(_:)`: not-determined → ask; denied → the shared `.permissionAlert`
  offers Open Settings). Voice recording that captures nothing (denied/interrupted)
  never fakes a save — `saveMessage` rejects a media message with no bytes, and
  the composer resets to idle with a message. `MessageDetailView` fetches the
  detail on open, sets `AVAudioSession` to `.playback` (audible with the mute
  switch on), caches its `AVPlayer`, and plays media via
  `VideoPlayer`/`AVPlayer`/`AsyncImage`.
- **Error surfacing**: backend error envelope `{error:{code,message}}` decodes
  into `NetworkErrorModel` (LocalizedError), so alerts show the backend's
  actual message (including 402 paywall text). Every composer/write shows a
  saving state and an error alert instead of fire-and-forget. Home/Library/People
  each show three states off `store.isInitialLoading`/`store.error`: a
  `LoadingStateView` spinner on first load (never a false "empty"), a
  `LoadErrorView` with retry when the first load failed, and the real
  empty/content states otherwise; all three are pull-to-refresh. Delivery-date
  pickers start at tomorrow so "today" can't trip the past-date 400.
- **Onboarding flow edges**: "I already have an account" (hookOpen) marks
  `OnboardingState.isReturningUser` — the auth gate then goes straight into the
  app on sign-in or skip. "Record my first message" sets
  `AppState.pendingFirstCreate` and RootView opens the create sheet after the
  swap. Apple's first-auth given name backfills the greeting name.
- **Config**: `SupabaseConfig` holds the project URL + publishable key.
  `BASE_HOST` = `api.frombackintime.com`.
- **Remaining (infra/verification, not code)**: Supabase provider config for
  Apple + Google (see Auth above); Apple Developer App ID needs the Sign in
  with Apple capability (entitlements file is already wired in the project);
  the backend commit adding the playback `media` field to GET /v1/messages/:id
  needs push + Dokploy deploy (iOS treats it as optional until then).

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

### Main-shell look (`Screens/Main/`)
The post-onboarding app has its own token set in `AppShellTheme` (kept separate
from onboarding's `OnboardingTheme`):
- **Canvas**: `AppBackground` is the onboarding sky (`ob-sky-quiz` by default;
  pass `image:` to vary) under a soft top-white + bottom-canvas veil so titles
  and opaque cards stay crisp while the clouds ground the floating tab bar. Used
  behind every main screen and sheet. (`AppShellTheme.canvasTop/canvasBottom`
  remain the fallback tones for scrims.)
- **Home is built to feel alive, not a bare list**: a time-of-day greeting
  title (`greetingTitle`, uses `AuthStore.state.profileName`), a blue "Your next
  message" spotlight card with a live countdown (or an invite card when nothing
  is scheduled), quick stat tiles, the CTM check-in, an "Ideas to record"
  horizontal row (`HomeIdea.all`) that opens Create pre-set to a kind, the
  people strip, and the upcoming feed.
- **Accent** `#2563EB` (refined sky-blue), **gold** `#DF9E30` (CTM/premium),
  `title` bluish-charcoal, `subtitle`/`faint` cool grays. `accentSoft`/`goldSoft`
  are the tint washes behind icons.
- **Cards**: white, `cardRadius` 22, hairline `cardBorder` + soft `cardShadow`.
  `AppCard` applies all three; stat tiles replicate it inline.
- **Icons — icons8 "Puffy Outline", not SF Symbols.** The main shell speaks one
  icon language: icons8 **Puffy Outline** (`puffy`) — soft, rounded, hand-drawn
  monochrome line icons — imported as **template** images (`app-ic-*` at
  512px; `app-tab-*` at 1x/2x/3x for the tab bar). Because they're monochrome
  they tint like any template: render with `AppIcon(name:size:color:)`. Tab bar
  uses `app-tab-home/people/library` via a styled `UITabBarAppearance` (accent
  active, gray inactive). `AppScreen` renders a **custom header** (bare plus/gear
  + big rounded title) and hides the system nav bar — iOS 26 wraps every real
  toolbar item in a "glass" capsule that can't be removed per-item, so keeping
  the actions in-content is the only way to get bare icons on the sky.
  People/Library use `AppSearchField` (custom, icons8 magnifier) instead of
  `.searchable`; pushed detail screens re-show the nav bar with
  `.toolbar(.visible, for: .navigationBar)` so back buttons work.
  `MessageMedium.glyph` maps
  each medium to its `app-ic-*`. To add an icon: pull from the icons8 MCP
  (platform `puffy`), drop a 512px template imageset named
  `app-ic-<thing>` (Contents.json `template-rendering-intent: template`), use via
  `AppIcon` (platform `puffy` for outline; `puffy-filled` exists if a filled
  variant is ever wanted). Tab icons additionally need 1x/2x/3x (25/50/75px) so
  the bar renders them at point size.

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
