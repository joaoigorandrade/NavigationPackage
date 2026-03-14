# State Persistence

Save and restore navigation state across app launches.

## Requirements

Your routes must conform to `CodableRoutable` (which adds `Codable` to `Routable`).

## NavigationStateStore

```swift
let store = NavigationStateStore<AppRoute>(
    storageKey: "app.navigation",
    policy: .always
)
```

## Restoration Policies

- **`.always`** - Save on every navigation change
- **`.onBackground`** - Save when the app enters background
- **`.manual`** - Only save when explicitly called
- **`.never`** - Disable persistence

## Manual Save/Restore

```swift
// Save current state
store.saveState(of: navigator)

// Restore state
store.bind(to: navigator)

// Clear saved state
store.clear()
```

## Automatic Persistence

Use the `.persistNavigation()` view modifier:

```swift
NavigationStackWrapper(navigator: navigator) {
    ContentView()
}
.persistNavigation(store: store, navigator: navigator)
```

This automatically saves on navigation changes (if policy is `.always`) and when the app enters background (if policy is `.onBackground` or `.always`).

## Handling Version Changes

If your `Route` enum changes between app versions (added/removed cases, changed associated values), saved state will fail to decode. `restore()` returns `nil` in this case, falling back to an empty stack. Consider versioning your storage keys for major route changes.
