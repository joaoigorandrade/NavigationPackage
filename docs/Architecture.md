# Architecture

## Overview

Navigation is a protocol-based navigation framework built on SwiftUI's `NavigationStack` for iOS 16+. Users define their own route types by conforming to provided protocols; the package supplies the infrastructure.

## Core Design Decisions

### Protocol-Based Routes

Instead of a pre-built `Route` enum, the package defines a `Routable` protocol. This keeps the API decoupled from application-specific navigation logic and lets the compiler enforce type safety.

### Dual-Tracked Path

`Navigator` maintains two parallel representations of the navigation stack:

- **`NavigationPath`** (SwiftUI's type-erased path) for binding to `NavigationStack`
- **`TypedNavigationPath<Route>`** (typed shadow stack) for programmatic inspection, history, and serialization

All mutations go through `Navigator` methods to keep both in sync.

### ObservableObject Pattern

iOS 16 baseline requires `ObservableObject` + `@Published` (not `@Observable` which is iOS 17+). The `Navigator` is injected via `.environmentObject()`.

### Separation of Concerns

- **Stack navigation** is managed by `Navigator`
- **Modal presentation** is managed by `ModalNavigator` (independent from the push stack)
- **Tab management** is handled by `TabNavigator`, which orchestrates per-tab `Navigator` instances

## Module Structure

```
Core/        - Routable protocol, Navigator, NavigationStackWrapper
Path/        - TypedNavigationPath, PathEncoder (serialization)
DeepLink/    - URLRoutable, DeepLinkHandler, pattern matching
Modal/       - ModalNavigator, ModalRoute, presentation styles
Tab/         - TabNavigator, TabRoute
Transition/  - NavigationTransitionStyle, built-in transitions
Persistence/ - NavigationStateStore, RestorationPolicy
Gesture/     - BackNavigationPolicy, EdgeSwipeModifier
Extensions/  - View modifiers for navigator, destinations, deep links, modals
```

## Data Flow

```
URL arrives via onOpenURL
    -> DeepLinkHandler.handle(url:)
    -> Returns Route
    -> Navigator.navigate(to:) or Navigator.replace(with:)
    -> NavigationPath updated (triggers SwiftUI re-render)
    -> NavigationEvent logged to history
    -> NavigationStateStore.save() (if policy allows)
```

## Thread Safety

`Navigator`, `ModalNavigator`, and `TabNavigator` are all `@MainActor`-isolated. All property access and mutations happen on the main thread. `DeepLinkHandler` performs pure computation and is not actor-isolated; the final navigation call is `@MainActor`.
