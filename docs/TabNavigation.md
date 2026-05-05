# Tab Navigation

`TabNavigator` manages per-tab navigation with independent `Navigator` instances for each tab.

## Define Tabs

```swift
enum AppTab: TabRoute {
    case feed
    case search
    case profile

    @ViewBuilder
    var tabLabel: some View {
        switch self {
        case .feed: Label("Feed", systemImage: "house")
        case .search: Label("Search", systemImage: "magnifyingglass")
        case .profile: Label("Profile", systemImage: "person")
        }
    }

    @ViewBuilder
    var tabContent: some View {
        switch self {
        case .feed: FeedView()
        case .search: SearchView()
        case .profile: ProfileView()
        }
    }
}
```

## Setup

The simplest setup is `NavigationTabView`, a one-liner wrapper that builds a tab bar from a `TabNavigator`:

```swift
@StateObject private var tabNavigator = TabNavigator<AppTab, AppRoute>(initialTab: .feed)

var body: some View {
    NavigationTabView(tabNavigator)
}
```

`NavigationTabView` does the following automatically:

- builds one `NavigationStackWrapper` per tab using the tab's own `Navigator`
- injects each navigator into its tab's environment
- pops the active tab to root when the user re-taps it
- uses the iOS 18+ `Tab(value:role:content:label:)` initializer to avoid the iOS 18 `NavigationStack(path:) + tabItem` double-push bug
- honours `TabRoute.tabRole` (default `nil`), so a tab can opt into `.search` for the iOS 26 Liquid Glass search tab

### Customising re-tap behaviour

```swift
NavigationTabView(
    tabNavigator,
    popToRootOnReselect: true,           // default
    onReselect: { tab in
        // e.g. scroll-to-top — fired *after* popToRoot
        NotificationCenter.default.post(name: .scrollToTop, object: tab)
    }
)
```

Set `popToRootOnReselect: false` to opt out of automatic pop and handle the re-tap yourself in `onReselect`.

### Manual setup (if you need full control)

```swift
TabView(selection: $tabNavigator.selectedTab) {
    ForEach(AppTab.allCases, id: \.self) { tab in
        Tab(value: tab, role: tab.tabRole) {
            NavigationStackWrapper(navigator: tabNavigator.navigator(for: tab)) {
                tab.tabContent
            }
            .withNavigator(tabNavigator.navigator(for: tab))
        } label: {
            tab.tabLabel
        }
    }
}
```

## Tab Operations

```swift
// Switch tabs
tabNavigator.switchTab(to: .search)

// Access tab-specific navigator
tabNavigator.navigator(for: .feed)
tabNavigator.currentNavigator

// Reset
tabNavigator.resetCurrentTab()  // Pop to root on current tab
tabNavigator.resetAllTabs()     // Pop to root on all tabs

// Cross-tab navigation
tabNavigator.navigate(to: .settings, inTab: .profile)
```

## State Preservation

Each tab's navigation state is automatically preserved when switching tabs. The `Navigator` instances persist independently.
