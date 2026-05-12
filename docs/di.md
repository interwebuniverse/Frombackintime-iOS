# Dependency injection

## DependencyContainer

Single `@Observable` class created once at app launch. Injected into the SwiftUI view hierarchy via `.environment(container)`.

```swift
@main
struct FromBackInTimeApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            // ...
            .environment(container)
        }
    }
}
```

## What it owns

1. **Environment** - `AppEnvironment.current` (live or mock).
2. **Network client** - created by `NetworkClientFactory.make(environment:)`.
3. **Repositories** - one per feature, all initialized with the same `networkClient`.

## Factory methods

Short-lived, per-screen Stores are created via factory methods:

```swift
func makeFooStore() -> FooStore {
    FooStore(repository: fooRepository)
}
```

Views call the factory inside `.task`:

```swift
@Environment(DependencyContainer.self) private var container
@State private var store: FooStore?

.task {
    if store == nil {
        let s = container.makeFooStore()
        store = s
        await s.loadItems()
    }
}
```

## Adding a new dependency

1. Add `let fooRepository: FooRepositoryType` property.
2. Initialize it in `init()`: `self.fooRepository = FooRepository(client: networkClient)`.
3. Add `func makeFooStore() -> FooStore`.

No manual wiring needed for mock mode - the `networkClient` is already a `MockNetworkClient` when `environment == .mock`.
