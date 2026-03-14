# Deep Linking

## URLRoutable Protocol

Extend your route with URL support:

```swift
public protocol URLRoutable: CodableRoutable {
    static func route(from url: URL) -> Self?
    var urlRepresentation: URL? { get }
}
```

## Implementation Example

```swift
enum AppRoute: URLRoutable {
    case home
    case profile(name: String)
    case item(id: Int)

    static func route(from url: URL) -> AppRoute? {
        var segments: [String] = []
        if let host = url.host, !host.isEmpty {
            segments.append(host)
        }
        segments.append(contentsOf: url.pathComponents.filter { $0 != "/" })

        guard let first = segments.first else { return .home }
        switch first {
        case "profile":
            return segments.count > 1 ? .profile(name: segments[1]) : nil
        case "item":
            guard segments.count > 1, let id = Int(segments[1]) else { return nil }
            return .item(id: id)
        default:
            return nil
        }
    }

    var urlRepresentation: URL? {
        switch self {
        case .home: URL(string: "myapp://home")
        case .profile(let name): URL(string: "myapp://profile/\(name)")
        case .item(let id): URL(string: "myapp://item/\(id)")
        }
    }
}
```

## DeepLinkHandler

Register URL patterns for automatic route resolution:

```swift
let handler = DeepLinkHandler<AppRoute>()

handler.register(
    pathTemplate: "item/:id",
    schemes: Set(["myapp"]),
    handler: { url, params in
        guard let idStr = params["id"], let id = Int(idStr) else { return nil }
        return .item(id: id)
    }
)
```

### Pattern Syntax

- Static segments: `"settings"` matches `/settings`
- Parameters: `":name"` captures the segment value
- Query parameters are automatically extracted

## SwiftUI Integration

```swift
NavigationStackWrapper(navigator: navigator) {
    HomeView()
}
.onDeepLink(handler: handler, navigator: navigator)
```

Use `replaceStack: true` to replace the entire navigation stack instead of pushing:

```swift
.onDeepLink(handler: handler, navigator: navigator, replaceStack: true)
```

## URL Structure Note

For custom scheme URLs (`myapp://profile/Alice`), the first segment after `://` is the URL host. The `DeepLinkPattern` matcher handles this automatically by combining host and path components.
