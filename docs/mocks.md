# Mock scheme

## How it works

```
FromBackInTime-Mock scheme
  → Mock build configuration
    → Mock.xcconfig (BASE_HOST = mock.local)
    → SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG MOCK
      → AppEnvironment.current == .mock
        → NetworkClientFactory returns MockNetworkClient
```

`MockNetworkClient` conforms to `NetworkClientType` and simulates a 300ms delay per request. It never touches URLSession.

## Components

| File | Purpose |
|------|---------|
| `MockDataProvider` | Protocol - `response(for:database:) -> Data?` |
| `MockDataRegistry` | Composite of providers. First non-nil wins. |
| `MockDatabase` | Shared in-memory state for cross-request consistency. |
| `MockNetworkClient` | `NetworkClientType` implementation that routes through the registry. |
| `Providers/*.swift` | One `MockDataProvider` per feature. |

## Adding mock data for a new feature

1. Create `Network/Mock/Providers/FooMockDataProvider.swift`:

```swift
struct FooMockDataProvider: MockDataProvider {
    func response(for request: Request, database: MockDatabase) -> Data? {
        switch request {
        case is FooRequests.List:
            return encode(FooResponses.ItemList(items: [...]))
        default:
            return nil
        }
    }
}
```

2. Register in `NetworkClientFactory.defaultMockRegistry()`:
```swift
registry.register(FooMockDataProvider())
```

3. Optionally extend `MockDatabase` with fields your provider reads/writes:
```swift
// MockDatabase.swift
var fooItems: [MockFooItem] = MockFooItem.defaults
```

## Presets

`MockDatabase.applyPreset(for:)` switches the entire database to a persona. Use this when the first request (e.g. login) identifies which scenario to test.

Example: call `database.applyPreset(for: "fresh")` to start as a brand-new user.

## Testing with mocks

In Xcode: select the **FromBackInTime-Mock** scheme and run.

From CLI:
```bash
xcodebuild -scheme FromBackInTime-Mock -configuration Mock \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```
