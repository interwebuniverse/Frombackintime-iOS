# Adding a new feature

Step-by-step. Copy the `Screens/Example/` folder and the matching network files as a starting point.

## Network layer

All three files live together in `Network/Repository/Foo/`.

### 1. Requests - `Network/Repository/Foo/FooRequests.swift`

```swift
enum FooRequests {
    struct List: Request {
        var path: String { "/v1/foo" }
        var method: RequestMethod { .GET }
    }

    struct Create: Request {
        let body: Body
        var path: String { "/v1/foo" }
        var method: RequestMethod { .POST }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let name: String
        }
    }
}
```

### 2. Responses - `Network/Repository/Foo/FooResponses.swift`

```swift
enum FooResponses {
    struct Item: Codable {
        var id: String?
        var name: String?
        var createdAt: String?
    }

    struct ItemList: Codable {
        var items: [Item]?
    }
}
```

### 3. Repository - `Network/Repository/Foo/FooRepository.swift`

```swift
protocol FooRepositoryType {
    func list() async throws -> FooResponses.ItemList
    func create(name: String) async throws -> FooResponses.Item
}

final class FooRepository: FooRepositoryType {
    private let client: NetworkClientType
    init(client: NetworkClientType) { self.client = client }

    func list() async throws -> FooResponses.ItemList {
        try await client.request(FooRequests.List())
    }

    func create(name: String) async throws -> FooResponses.Item {
        try await client.request(FooRequests.Create(body: .init(name: name)))
    }
}
```

### 4. Mock provider - `Network/Mock/Providers/FooMockDataProvider.swift`

```swift
struct FooMockDataProvider: MockDataProvider {
    func response(for request: Request, database: MockDatabase) -> Data? {
        switch request {
        case is FooRequests.List:
            return encode(FooResponses.ItemList(items: [
                .init(id: "1", name: "Mock item")
            ]))
        case let create as FooRequests.Create:
            return encode(FooResponses.Item(
                id: UUID().uuidString,
                name: create.body.name
            ))
        default:
            return nil
        }
    }
}
```

### 5. Register provider

In `NetworkClientFactory.defaultMockRegistry()`:
```swift
registry.register(FooMockDataProvider())
```

### 6. Wire DI

In `DependencyContainer`:
```swift
@ObservationIgnored let fooRepository: FooRepositoryType

// in init:
self.fooRepository = FooRepository(client: networkClient)

// factory:
func makeFooStore() -> FooStore {
    FooStore(repository: fooRepository)
}
```

## Screen layer

### 7. UI model - `Screens/Foo/FooUI.swift`

```swift
enum FooUI {
    struct Item: Equatable, Hashable, Identifiable {
        let id: String
        let name: String
    }
}
```

### 8. Mapping - `Screens/Foo/FooUI+Mapping.swift`

```swift
extension FooUI.Item {
    init(from response: FooResponses.Item) {
        self.init(
            id: response.id ?? UUID().uuidString,
            name: response.name ?? ""
        )
    }
}
```

### 9. State - `Screens/Foo/FooState.swift`

```swift
struct FooState: StoreState {
    var items: [FooUI.Item] = []
    var isLoading = false
    var error: String? = nil
}
```

### 10. Store - `Screens/Foo/FooStore.swift`

```swift
@MainActor @Observable
final class FooStore: Store<FooState> {
    private let repository: FooRepositoryType

    init(repository: FooRepositoryType) {
        self.repository = repository
        super.init(state: FooState())
    }

    func loadItems() async {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }

        do {
            let response = try await repository.list()
            state.items = (response.items ?? []).map(FooUI.Item.init(from:))
        } catch {
            if !error.isSessionEnded {
                state.error = error.localizedDescription
            }
        }
    }
}
```

### 11. View - `Screens/Foo/FooView.swift`

```swift
struct FooView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var store: FooStore?

    var body: some View {
        Group {
            if let store {
                List(store.state.items) { item in
                    Text(item.name)
                }
                .refreshable { await store.loadItems() }
            } else {
                ProgressView()
            }
        }
        .task {
            if store == nil {
                let s = container.makeFooStore()
                store = s
                await s.loadItems()
            }
        }
    }
}
```

### 12. Route

Add to `App/Router/RouterDestination`:
```swift
case foo
// in id:
case .foo: return "foo"
// in view(for:):
case .foo: FooView()
```
