# API Reference

## Protocols

### Routable
Base protocol for all route types.
- Conforms to: `Hashable`, `Identifiable`
- Required: `var destination: some View { get }`

### CodableRoutable
Extends `Routable` with `Codable` for serialization.

### URLRoutable
Extends `CodableRoutable` with URL conversion.
- Required: `static func route(from url: URL) -> Self?`
- Required: `var urlRepresentation: URL? { get }`

### ModalRoute
Extends `Routable` with modal presentation style.
- Optional: `var presentationStyle: ModalPresentation { get }` (defaults to `.sheet`)

### TabRoute
Protocol for tab definitions.
- Conforms to: `Hashable`, `CaseIterable`, `Identifiable`
- Required: `var tabLabel: some View { get }`
- Required: `var tabContent: some View { get }`

## Classes

### Navigator\<Route: Routable\>
`@MainActor ObservableObject` — the central router.

**Properties:**
- `path: NavigationPath` — bound to NavigationStack
- `activeSheet: Route?` — currently presented sheet route
- `routeStack: TypedNavigationPath<Route>` — typed shadow stack (read-only)
- `history: [NavigationEvent<Route>]` — event log (read-only)
- `maxHistoryDepth: Int` — configurable limit
- `depth: Int`, `currentRoute: Route?`, `isEmpty: Bool`, `isSheetPresented: Bool`

**Methods:**
- `navigate(to:)`, `navigate(to: [Route])`
- `pop()`, `pop(count:)`
- `popToRoot()`, `popTo(_:) -> Bool`
- `replace(with:)`, `reset()`
- `canPop() -> Bool`
- `openSheet(_:)`, `dismissSheet()`

### ModalNavigator\<Route: ModalRoute\>
`@MainActor ObservableObject` — modal state manager.

**Properties:**
- `activeSheet: Route?`, `activeFullScreen: Route?`
- `modalStack: [Route]`, `isPresenting: Bool`, `currentModal: Route?`

**Methods:**
- `present(_:)`, `dismiss()`, `dismissAll()`

### TabNavigator\<Tab: TabRoute, Route: Routable\>
`@MainActor ObservableObject` — per-tab navigator orchestrator.

**Properties:**
- `selectedTab: Tab`, `navigators: [Tab: Navigator<Route>]`
- `currentNavigator: Navigator<Route>`

**Methods:**
- `switchTab(to:)`, `navigator(for:)`
- `resetCurrentTab()`, `resetAllTabs()`
- `navigate(to:inTab:)`

### DeepLinkHandler\<Route: URLRoutable\>
URL-to-route resolver.

**Methods:**
- `register(pattern:)`, `register(pathTemplate:schemes:handler:)`
- `handle(url:) -> Route?`, `handlePath(url:) -> [Route]?`
- `canHandle(url:) -> Bool`

### NavigationStateStore\<Route: CodableRoutable\>
Persistence manager.

**Methods:**
- `save(routes:)`, `restore() -> [Route]?`, `clear()`
- `bind(to:)`, `saveState(of:)`

## Structs & Enums

### NavigationStackWrapper\<Route, Root\>
SwiftUI `View` wrapping `NavigationStack` with automatic destination registration.

### NavigationAction\<Route\>
Enum: `.push`, `.pushMultiple`, `.pop`, `.popMultiple`, `.popToRoot`, `.replace`, `.reset`

### NavigationEvent\<Route\>
Timestamped event with `action`, `previousDepth`, `newDepth`.

### ModalPresentation
Enum: `.sheet`, `.fullScreenCover`

### NavigationTransitionStyle
Enum: `.default`, `.slide(edge:)`, `.fade(duration:)`, `.scale(anchor:)`, `.custom(AnyTransition)`

### BackNavigationPolicy
Enum: `.allowed`, `.disabled`, `.conditional(()->Bool)`, `.confirmationRequired(message:)`

### RestorationPolicy
Enum: `.always`, `.onBackground`, `.manual`, `.never`

### DeepLinkPattern\<Route\>
URL pattern with template, schemes, and handler.

## View Modifiers

- `.withNavigator(_:)` — inject navigator as environment object
- `.navigationRoute(_:)` — register navigation destination type
- `.onDeepLink(handler:navigator:replaceStack:)` — handle incoming URLs
- `.modalNavigation(_:)` — attach sheet/fullScreenCover bindings
- `.backNavigationPolicy(_:routeType:)` — control back navigation (iOS)
- `.navigationTransitionStyle(_:)` — apply custom transitions
- `.edgeSwipePop(routeType:edgeWidth:threshold:)` — custom swipe-to-pop (iOS)
- `.persistNavigation(store:navigator:)` — automatic state persistence
- `.optionalNavigator(_:)` — inject navigator for optional access

## Property Wrappers

### @OptionalNavigator\<Route\>
Access navigator from environment, returning `nil` if not present (instead of crashing).
