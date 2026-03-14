import Testing
import SwiftUI
@testable import Navigation

enum MockTab: TabRoute {
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
        case .feed: Text("Feed")
        case .search: Text("Search")
        case .profile: Text("Profile")
        }
    }
}

@Suite("TabNavigator")
struct TabNavigatorTests {
    @MainActor
    @Test("Initial tab is set correctly")
    func initialTab() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        #expect(tabNav.selectedTab == .feed)
    }

    @MainActor
    @Test("Creates navigator for each tab")
    func navigatorsCreated() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        #expect(tabNav.navigators.count == MockTab.allCases.count)
    }

    @MainActor
    @Test("Switch tab changes selection")
    func switchTab() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.switchTab(to: .search)
        #expect(tabNav.selectedTab == .search)
    }

    @MainActor
    @Test("Each tab has independent navigator")
    func independentNavigators() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.navigator(for: .feed).navigate(to: .home)
        tabNav.navigator(for: .search).navigate(to: .settings)
        #expect(tabNav.navigator(for: .feed).depth == 1)
        #expect(tabNav.navigator(for: .search).depth == 1)
        #expect(tabNav.navigator(for: .profile).depth == 0)
    }

    @MainActor
    @Test("ResetCurrentTab only resets selected tab")
    func resetCurrentTab() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.navigator(for: .feed).navigate(to: .home)
        tabNav.navigator(for: .search).navigate(to: .settings)
        tabNav.resetCurrentTab()
        #expect(tabNav.navigator(for: .feed).isEmpty)
        #expect(!tabNav.navigator(for: .search).isEmpty)
    }

    @MainActor
    @Test("ResetAllTabs clears all navigators")
    func resetAllTabs() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.navigator(for: .feed).navigate(to: .home)
        tabNav.navigator(for: .search).navigate(to: .settings)
        tabNav.resetAllTabs()
        for tab in MockTab.allCases {
            #expect(tabNav.navigator(for: tab).isEmpty)
        }
    }

    @MainActor
    @Test("Navigate to route in specific tab")
    func crossTabNavigation() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.navigate(to: .settings, inTab: .profile)
        #expect(tabNav.selectedTab == .profile)
        #expect(tabNav.navigator(for: .profile).depth == 1)
    }

    @MainActor
    @Test("Tab navigation state preserved on switch")
    func statePreserved() {
        let tabNav = TabNavigator<MockTab, MockRoute>(initialTab: .feed)
        tabNav.navigator(for: .feed).navigate(to: [.home, .detail(id: 1)])
        tabNav.switchTab(to: .search)
        tabNav.switchTab(to: .feed)
        #expect(tabNav.navigator(for: .feed).depth == 2)
        #expect(tabNav.navigator(for: .feed).currentRoute == .detail(id: 1))
    }
}
