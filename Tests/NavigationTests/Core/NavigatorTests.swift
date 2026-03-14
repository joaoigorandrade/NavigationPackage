import Testing
import SwiftUI
@testable import Navigation

@Suite("Navigator Core")
struct NavigatorTests {
    @MainActor
    @Test("Initial state is empty")
    func initialState() {
        let navigator = Navigator<MockRoute>()
        #expect(navigator.isEmpty)
        #expect(navigator.depth == 0)
        #expect(navigator.currentRoute == nil)
        #expect(navigator.history.isEmpty)
    }

    @MainActor
    @Test("Push adds route to stack")
    func pushRoute() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: .home)
        #expect(navigator.depth == 1)
        #expect(navigator.currentRoute == .home)
        #expect(!navigator.isEmpty)
    }

    @MainActor
    @Test("Push multiple routes")
    func pushMultiple() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings, .detail(id: 1)])
        #expect(navigator.depth == 3)
        #expect(navigator.currentRoute == .detail(id: 1))
    }

    @MainActor
    @Test("Pop removes last route")
    func popRoute() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: .home)
        navigator.navigate(to: .settings)
        navigator.pop()
        #expect(navigator.depth == 1)
        #expect(navigator.currentRoute == .home)
    }

    @MainActor
    @Test("Pop on empty does nothing")
    func popEmpty() {
        let navigator = Navigator<MockRoute>()
        navigator.pop()
        #expect(navigator.isEmpty)
    }

    @MainActor
    @Test("Pop multiple routes")
    func popMultiple() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings, .detail(id: 1)])
        navigator.pop(count: 2)
        #expect(navigator.depth == 1)
        #expect(navigator.currentRoute == .home)
    }

    @MainActor
    @Test("Pop count exceeding stack depth pops all")
    func popExceedingDepth() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings])
        navigator.pop(count: 10)
        #expect(navigator.isEmpty)
    }

    @MainActor
    @Test("PopToRoot clears entire stack")
    func popToRoot() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings, .detail(id: 1)])
        navigator.popToRoot()
        #expect(navigator.isEmpty)
    }

    @MainActor
    @Test("PopTo navigates to specific route")
    func popToRoute() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings, .detail(id: 1), .profile(name: "Alice")])
        let success = navigator.popTo(.settings)
        #expect(success)
        #expect(navigator.depth == 2)
        #expect(navigator.currentRoute == .settings)
    }

    @MainActor
    @Test("PopTo returns false for missing route")
    func popToMissing() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: .home)
        let success = navigator.popTo(.settings)
        #expect(!success)
        #expect(navigator.depth == 1)
    }

    @MainActor
    @Test("Replace swaps entire stack")
    func replaceStack() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings])
        navigator.replace(with: [.detail(id: 1), .detail(id: 2)])
        #expect(navigator.depth == 2)
        #expect(navigator.currentRoute == .detail(id: 2))
    }

    @MainActor
    @Test("Reset clears stack and history")
    func reset() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .settings])
        navigator.reset()
        #expect(navigator.isEmpty)
        #expect(navigator.history.count == 1)
    }

    @MainActor
    @Test("CanPop returns correct value")
    func canPop() {
        let navigator = Navigator<MockRoute>()
        #expect(!navigator.canPop())
        navigator.navigate(to: .home)
        #expect(navigator.canPop())
    }

    @MainActor
    @Test("History tracks all events")
    func historyTracking() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: .home)
        navigator.navigate(to: .settings)
        navigator.pop()
        #expect(navigator.history.count == 3)
    }

    @MainActor
    @Test("History respects maxHistoryDepth")
    func historyMaxDepth() {
        let navigator = Navigator<MockRoute>(maxHistoryDepth: 3)
        for i in 0..<10 {
            navigator.navigate(to: .detail(id: i))
        }
        #expect(navigator.history.count == 3)
    }

    @MainActor
    @Test("Navigate with empty array does nothing")
    func navigateEmptyArray() {
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [])
        #expect(navigator.isEmpty)
        #expect(navigator.history.isEmpty)
    }
}
