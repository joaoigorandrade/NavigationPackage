import Testing
@testable import Navigation

@Suite("TypedNavigationPath")
struct TypedNavigationPathTests {
    @MainActor
    @Test("Empty path has correct state")
    func emptyPath() {
        let path = TypedNavigationPath<MockRoute>()
        #expect(path.isEmpty)
        #expect(path.count == 0)
        #expect(path.current == nil)
    }

    @MainActor
    @Test("Push adds route")
    func push() {
        var path = TypedNavigationPath<MockRoute>()
        path.push(.home)
        #expect(path.count == 1)
        #expect(path.current == .home)
    }

    @MainActor
    @Test("Push multiple routes")
    func pushMultiple() {
        var path = TypedNavigationPath<MockRoute>()
        path.push([.home, .settings, .detail(id: 1)])
        #expect(path.count == 3)
        #expect(path.current == .detail(id: 1))
    }

    @MainActor
    @Test("Pop removes last route")
    func pop() {
        var path = TypedNavigationPath<MockRoute>()
        path.push(.home)
        path.push(.settings)
        let popped = path.pop()
        #expect(popped == .settings)
        #expect(path.count == 1)
    }

    @MainActor
    @Test("Pop from empty returns nil")
    func popEmpty() {
        var path = TypedNavigationPath<MockRoute>()
        let popped = path.pop()
        #expect(popped == nil)
    }

    @MainActor
    @Test("Pop count removes multiple")
    func popCount() {
        var path = TypedNavigationPath<MockRoute>()
        path.push([.home, .settings, .detail(id: 1)])
        path.pop(count: 2)
        #expect(path.count == 1)
        #expect(path.current == .home)
    }

    @MainActor
    @Test("PopToRoot clears all")
    func popToRoot() {
        var path = TypedNavigationPath<MockRoute>()
        path.push([.home, .settings])
        path.popToRoot()
        #expect(path.isEmpty)
    }

    @MainActor
    @Test("Replace swaps routes")
    func replace() {
        var path = TypedNavigationPath<MockRoute>()
        path.push(.home)
        path.replace(with: [.settings, .detail(id: 1)])
        #expect(path.count == 2)
        #expect(path.current == .detail(id: 1))
    }

    @MainActor
    @Test("Contains finds route")
    func contains() {
        var path = TypedNavigationPath<MockRoute>()
        path.push([.home, .settings])
        #expect(path.contains(.home))
        #expect(!path.contains(.detail(id: 1)))
    }

    @MainActor
    @Test("Route at index")
    func routeAtIndex() {
        var path = TypedNavigationPath<MockRoute>()
        path.push([.home, .settings, .detail(id: 1)])
        #expect(path.route(at: 0) == .home)
        #expect(path.route(at: 1) == .settings)
        #expect(path.route(at: 5) == nil)
    }
}
