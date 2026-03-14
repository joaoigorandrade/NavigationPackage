import Testing
import Foundation
@testable import Navigation

@Suite("NavigationStateStore")
struct NavigationStateStoreTests {
    @MainActor
    @Test("Save and restore routes")
    func saveAndRestore() {
        let defaults = UserDefaults(suiteName: "test.persistence.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "test.path",
            policy: .always,
            defaults: defaults
        )
        let routes: [MockRoute] = [.home, .detail(id: 1), .settings]
        store.save(routes: routes)
        let restored = store.restore()
        #expect(restored == routes)
        defaults.removePersistentDomain(forName: defaults.description)
    }

    @MainActor
    @Test("Restore returns nil when no saved state")
    func restoreEmpty() {
        let defaults = UserDefaults(suiteName: "test.empty.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "nonexistent",
            defaults: defaults
        )
        let restored = store.restore()
        #expect(restored == nil)
    }

    @MainActor
    @Test("Clear removes saved state")
    func clear() {
        let defaults = UserDefaults(suiteName: "test.clear.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "test.clear",
            defaults: defaults
        )
        store.save(routes: [.home])
        store.clear()
        #expect(store.restore() == nil)
    }

    @MainActor
    @Test("Never policy does not save")
    func neverPolicy() {
        let defaults = UserDefaults(suiteName: "test.never.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "test.never",
            policy: .never,
            defaults: defaults
        )
        store.save(routes: [.home])
        #expect(store.restore() == nil)
    }

    @MainActor
    @Test("Bind restores state to navigator")
    func bindToNavigator() {
        let defaults = UserDefaults(suiteName: "test.bind.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "test.bind",
            defaults: defaults
        )
        store.save(routes: [.home, .settings])
        let navigator = Navigator<MockRoute>()
        store.bind(to: navigator)
        #expect(navigator.depth == 2)
        #expect(navigator.currentRoute == .settings)
    }

    @MainActor
    @Test("SaveState captures navigator state")
    func saveState() {
        let defaults = UserDefaults(suiteName: "test.savestate.\(UUID().uuidString)")!
        let store = NavigationStateStore<MockRoute>(
            storageKey: "test.savestate",
            defaults: defaults
        )
        let navigator = Navigator<MockRoute>()
        navigator.navigate(to: [.home, .detail(id: 42)])
        store.saveState(of: navigator)
        let restored = store.restore()
        #expect(restored == [.home, .detail(id: 42)])
    }
}
