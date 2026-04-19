import Testing
import SwiftUI
@testable import Navigation

@Suite("TabBarCoordinator")
struct TabBarCoordinatorTests {
    @MainActor
    @Test("Selecting a tab resolved to .none does nothing")
    func test_select_noneAction_doesNothing() {
        let (sut, navigator) = makeSUT { _ in .none }
        sut.select(MockBarTab.home)
        #expect(navigator.isEmpty)
        #expect(navigator.isAnyModalPresented == false)
    }

    @MainActor
    @Test("Selecting a tab resolved to .push appends a route")
    func test_select_pushAction_appendsRoute() {
        let (sut, navigator) = makeSUT { tab in
            tab == .activity ? .push(.settings) : .none
        }
        sut.select(MockBarTab.activity)
        #expect(navigator.depth == 1)
        #expect(navigator.currentRoute == .settings)
    }

    @MainActor
    @Test("Selecting a tab resolved to .pushMany appends all routes")
    func test_select_pushManyAction_appendsAll() {
        let (sut, navigator) = makeSUT { _ in
            .pushMany([.home, .detail(id: 7)])
        }
        sut.select(MockBarTab.members)
        #expect(navigator.depth == 2)
        #expect(navigator.currentRoute == .detail(id: 7))
    }

    @MainActor
    @Test("Selecting a tab resolved to .replace replaces the stack")
    func test_select_replaceAction_replacesStack() {
        let (sut, navigator) = makeSUT { _ in .replace([.settings]) }
        navigator.navigate(to: .home)
        sut.select(MockBarTab.profile)
        #expect(navigator.depth == 1)
        #expect(navigator.currentRoute == .settings)
    }

    @MainActor
    @Test("Selecting a tab resolved to .popToRoot empties the stack")
    func test_select_popToRootAction_emptiesStack() {
        let (sut, navigator) = makeSUT { _ in .popToRoot }
        navigator.navigate(to: [.home, .settings])
        sut.select(MockBarTab.home)
        #expect(navigator.isEmpty)
    }

    @MainActor
    @Test("Selecting a tab resolved to .openSheet presents sheet")
    func test_select_openSheetAction_presentsSheet() {
        let (sut, navigator) = makeSUT { _ in .openSheet(.profile(name: "Ana")) }
        sut.select(MockBarTab.profile)
        #expect(navigator.activeSheet == .profile(name: "Ana"))
    }

    @MainActor
    @Test("Selecting a tab resolved to .openFullScreenCover presents cover")
    func test_select_openFullScreenCoverAction_presentsCover() {
        let (sut, navigator) = makeSUT { _ in .openFullScreenCover(.settings) }
        sut.select(MockBarTab.profile)
        #expect(navigator.activeFullScreenCover == .settings)
    }

    @MainActor
    @Test("Selecting a tab resolved to .custom invokes the block")
    func test_select_customAction_invokesBlock() {
        var invoked = 0
        let (sut, navigator) = makeSUT { _ in .custom { invoked += 1 } }
        sut.select(MockBarTab.activity)
        #expect(invoked == 1)
        #expect(navigator.isEmpty)
    }

    @MainActor
    @Test("Resolver is called with the selected tab")
    func test_select_callsResolverWithSelectedTab() {
        var received: [MockBarTab] = []
        let (sut, _) = makeSUT { tab in
            received.append(tab)
            return .none
        }
        sut.select(.activity)
        sut.select(.members)
        #expect(received == [.activity, .members])
    }

    @MainActor
    @Test("action(for:) returns resolver output without performing navigation")
    func test_action_returnsResolvedAction_withoutSideEffects() {
        let (sut, navigator) = makeSUT { _ in .push(.settings) }
        let action = sut.action(for: MockBarTab.activity)
        if case .push(let route) = action {
            #expect(route == .settings)
        } else {
            Issue.record("expected .push")
        }
        #expect(navigator.isEmpty)
    }
}

// MARK: - Helpers

private extension TabBarCoordinatorTests {
    @MainActor
    func makeSUT(
        resolve: @escaping (MockBarTab) -> TabSelectionAction<MockRoute>
    ) -> (TabBarCoordinator<MockBarTab, MockRoute>, Navigator<MockRoute>) {
        let navigator = Navigator<MockRoute>()
        let sut = TabBarCoordinator<MockBarTab, MockRoute>(
            navigator: navigator,
            resolve: resolve
        )
        return (sut, navigator)
    }
}

// MARK: - Test Doubles

enum MockBarTab: Hashable, CaseIterable {
    case home
    case activity
    case members
    case profile
}
