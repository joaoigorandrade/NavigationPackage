# Routing

## Routable Protocol

The foundation of the navigation system. Every route type must conform to `Routable`:

```swift
public protocol Routable: Hashable, Identifiable {
    associatedtype Body: View
    @ViewBuilder var destination: Body { get }
}
```

- **Hashable**: Required by `NavigationPath` for identity
- **Identifiable**: Required for SwiftUI list/ForEach usage (default `id` uses `hashValue`)
- **destination**: The view to render when this route is active

## CodableRoutable

Extends `Routable` with `Codable` for serialization (used by deep linking and state persistence):

```swift
public protocol CodableRoutable: Routable, Codable {}
```

## Route Design Patterns

### Associated Values for Data Passing

```swift
enum AppRoute: Routable {
    case list
    case detail(itemId: Int)
    case userProfile(userId: String, tab: ProfileTab)
    case search(query: String, filters: SearchFilters)
}
```

### Grouping Related Routes

```swift
enum SettingsRoute: Routable {
    case root
    case account
    case notifications
    case privacy
    case about
}
```

### NavigationAction and NavigationEvent

Every navigation operation is captured as a `NavigationAction`:

```swift
public enum NavigationAction<Route: Routable> {
    case push(Route)
    case pushMultiple([Route])
    case pop
    case popMultiple(Int)
    case popToRoot
    case replace([Route])
    case reset
}
```

Each action generates a `NavigationEvent` stored in `navigator.history`:

```swift
public struct NavigationEvent<Route: Routable>: Identifiable {
    public let id: UUID
    public let action: NavigationAction<Route>
    public let timestamp: Date
    public let previousDepth: Int
    public let newDepth: Int
}
```
