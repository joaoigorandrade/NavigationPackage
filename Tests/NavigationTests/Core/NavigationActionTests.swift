import Testing
@testable import Navigation

@Suite("NavigationAction")
struct NavigationActionTests {
    @Test("Push action holds route")
    func pushAction() {
        let action = NavigationAction<MockRoute>.push(.home)
        if case .push(let route) = action {
            #expect(route == .home)
        } else {
            Issue.record("Expected push action")
        }
    }

    @Test("PushMultiple action holds routes")
    func pushMultipleAction() {
        let routes: [MockRoute] = [.home, .settings]
        let action = NavigationAction<MockRoute>.pushMultiple(routes)
        if case .pushMultiple(let stored) = action {
            #expect(stored.count == 2)
        } else {
            Issue.record("Expected pushMultiple action")
        }
    }

    @Test("PopMultiple action holds count")
    func popMultipleAction() {
        let action = NavigationAction<MockRoute>.popMultiple(3)
        if case .popMultiple(let count) = action {
            #expect(count == 3)
        } else {
            Issue.record("Expected popMultiple action")
        }
    }
}
