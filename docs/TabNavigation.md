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

```swift
@StateObject private var tabNavigator = TabNavigator<AppTab, AppRoute>(initialTab: .feed)

TabView(selection: $tabNavigator.selectedTab) {
    ForEach(AppTab.allCases, id: \.self) { tab in
        NavigationStackWrapper(navigator: tabNavigator.navigator(for: tab)) {
            tab.tabContent
        }
        .withNavigator(tabNavigator.navigator(for: tab))
        .tabItem { tab.tabLabel }
        .tag(tab)
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
