import SwiftUI

/// Drop-in tab bar that wires a `TabNavigator` into SwiftUI's `TabView` with
/// per-tab `NavigationStack`s, environment-injected navigators, and re-tap
/// pop-to-root behaviour.
///
/// Built on the iOS 18+ `Tab(value:role:content:label:)` initializer to avoid
/// the legacy `tabItem` + `NavigationStack(path:)` double-push bug
/// (FB13834839 / Apple forum 759542).
///
/// ```swift
/// NavigationTabView(tabNavigator) // simplest case
///
/// NavigationTabView(tabNavigator, onReselect: { tab in
///     scrollToTop(tab)
/// })
/// ```
public struct NavigationTabView<Tab: TabRoute, Route: Routable>: View {
    @ObservedObject private var tabNavigator: TabNavigator<Tab, Route>
    private let popToRootOnReselect: Bool
    private let onReselect: ((Tab) -> Void)?

    public init(
        _ tabNavigator: TabNavigator<Tab, Route>,
        popToRootOnReselect: Bool = true,
        onReselect: ((Tab) -> Void)? = nil
    ) {
        self.tabNavigator = tabNavigator
        self.popToRootOnReselect = popToRootOnReselect
        self.onReselect = onReselect
    }

    public var body: some View {
        TabView(selection: selectionBinding) {
            ForEach(Array(Tab.allCases), id: \.self) { tab in
                SwiftUI.Tab(value: tab, role: tab.tabRole) {
                    NavigationStackWrapper(navigator: tabNavigator.navigator(for: tab)) {
                        tab.tabContent
                    }
                    .environmentObject(tabNavigator.navigator(for: tab))
                } label: {
                    tab.tabLabel
                }
            }
        }
    }

    private var selectionBinding: Binding<Tab> {
        Binding(
            get: { tabNavigator.selectedTab },
            set: { newTab in
                tabNavigator.handleSelection(
                    newTab,
                    popToRootOnReselect: popToRootOnReselect,
                    onReselect: onReselect
                )
            }
        )
    }
}
