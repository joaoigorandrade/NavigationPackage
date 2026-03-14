import Testing
import Foundation
@testable import Navigation

@Suite("URLRoutable")
struct URLRoutableTests {
    @Test("Route from URL creates correct route")
    func routeFromURL() {
        let url = URL(string: "app://item/99")!
        let route = MockURLRoute.route(from: url)
        #expect(route == .item(id: 99))
    }

    @Test("URL representation round-trips")
    func urlRepresentation() {
        let route = MockURLRoute.profile(name: "Bob")
        let url = route.urlRepresentation
        #expect(url != nil)
        let restored = MockURLRoute.route(from: url!)
        #expect(restored == route)
    }

    @Test("Home route from empty path")
    func homeFromEmptyPath() {
        let url = URL(string: "app://")!
        let route = MockURLRoute.route(from: url)
        #expect(route == .home)
    }

    @Test("Invalid profile URL returns nil")
    func invalidProfile() {
        let url = URL(string: "app://profile")!
        let route = MockURLRoute.route(from: url)
        #expect(route == nil)
    }
}
