# Networking

## Protocol

`NetworkClientType` defines the contract:

```swift
protocol NetworkClientType {
    func request<T: Decodable>(_ request: Request) async throws -> T
    func requestData(from url: URL) async throws -> Data
    func uploadMultipart<T: Decodable>(request: MultipartRequest) async throws -> T
    func upload(_ data: Data, with request: Request) async throws
    func validate(response: URLResponse) async throws
    func decode<T: Decodable>(with type: T.Type, and data: Data) throws -> T
}
```

Two implementations:
- `NetworkClient` - live, uses `URLSession`.
- `MockNetworkClient` - in-memory, see `docs/mocks.md`.

## Request protocol

Every endpoint is a struct conforming to `Request`:

```swift
protocol Request {
    var fullPath: String? { get }    // override entire URL (external APIs)
    var path: String { get }         // appended to BASE_HOST
    var method: RequestMethod { get }
    var httpBody: Encodable? { get }
    var queries: [String: String]? { get }
    var headers: [String: String] { get }
    var needAuth: Bool { get }
}
```

Defaults in `Request+Extension.swift`:
- `method` = `.GET`
- `needAuth` = `true` (injects `Authorization: Bearer <token>`)
- `headers` = Accept + Content-Type + auth header when needed

## Validation

`NetworkClient+Validate.swift` maps HTTP status codes:

| Status | NetworkError | Side effect |
|--------|-------------|-------------|
| 200–299 | - | decode response |
| 401 | `.unauthorized` | posts `.unauthorizedAccess` notification |
| 402 | `.payment` | - |
| 403 | `.deviceInvalidated` | posts `.deviceInvalidated` notification |
| 409 | `.conflict` | - |
| 400–499 | `.clientError` (or decoded `NetworkErrorModel`) | - |
| 500+ | `.serverError` | - |

## Error handling

`NetworkError.isSessionEnded` returns `true` for `.unauthorized` and `.deviceInvalidated`. Stores should check this before writing to `state.error` - session-ended errors are handled globally via NotificationCenter.

## Adding token refresh

When you add an auth flow, enhance `NetworkClient+Validate.swift`:
1. On 401, attempt `AuthRequests.RefreshToken` with an `NSLock` to prevent thundering herd.
2. On success, retry the original request with the new token.
3. On failure, post `.unauthorizedAccess` and throw.

See chewick-iOS's `NetworkClient+Validate.swift` for the full pattern.
