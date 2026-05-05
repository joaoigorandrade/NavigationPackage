import SwiftUI

@MainActor
public final class TabNavigator<Tab: TabRoute, Route: Routable>: ObservableObject {
    @Published public var selectedTab: Tab
    public private(set) var navigators: [Tab: Navigator<Route>] = [:]

    public init(initialTab: Tab) {
        self.selectedTab = initialTab
        for tab in Tab.allCases {
            navigators[tab] = Navigator<Route>()
        }
    }

    public func switchTab(to tab: Tab) {
        selectedTab = tab
    }

    public func navigator(for tab: Tab) -> Navigator<Route> {
        if let existing = navigators[tab] {
            return existing
        }
        let new = Navigator<Route>()
        navigators[tab] = new
        return new
    }

    public var currentNavigator: Navigator<Route> {
        navigator(for: selectedTab)
    }

    public func resetCurrentTab() {
        currentNavigator.popToRoot()
    }

    public func resetAllTabs() {
        for navigator in navigators.values {
            navigator.popToRoot()
        }
    }

    public func navigate(to route: Route, inTab tab: Tab) {
        switchTab(to: tab)
        navigator(for: tab).navigate(to: route)
    }

    /// Handles a selection event from the tab bar. If the user re-taps the
    /// already-selected tab, pops that tab's stack to root (when enabled) and
    /// invokes `onReselect`. Otherwise switches to the new tab.
    ///
    /// Extracted so the binding logic of `NavigationTabView` is unit-testable
    /// without instantiating a SwiftUI view hierarchy.
    public func handleSelection(
        _ newTab: Tab,
        popToRootOnReselect: Bool = true,
        onReselect: ((Tab) -> Void)? = nil
    ) {
        if newTab == selectedTab {
            if popToRootOnReselect {
                navigator(for: newTab).popToRoot()
            }
            onReselect?(newTab)
        } else {
            selectedTab = newTab
        }
    }
}
