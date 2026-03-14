import Testing
import SwiftUI
@testable import Navigation

@Suite("Routable Protocol")
struct RoutableTests {
    @Test("Route conforms to Hashable")
    func hashableConformance() {
        let route1 = MockRoute.home
        let route2 = MockRoute.home
        #expect(route1 == route2)
    }

    @Test("Routes with different values are not equal")
    func differentRoutes() {
        let route1 = MockRoute.detail(id: 1)
        let route2 = MockRoute.detail(id: 2)
        #expect(route1 != route2)
    }

    @Test("Route provides stable identity")
    func identifiable() {
        let route = MockRoute.settings
        let id = route.id
        #expect(id == route.id)
    }

    @Test("Route can be used in sets")
    func setUsage() {
        var routes: Set<MockRoute> = []
        routes.insert(.home)
        routes.insert(.home)
        routes.insert(.settings)
        #expect(routes.count == 2)
    }
}
