import Foundation

@MainActor
public struct TypedNavigationPath<Route: Routable> {
    private(set) var routes: [Route]

    public init() {
        self.routes = []
    }

    public init(_ routes: [Route]) {
        self.routes = routes
    }

    public var count: Int { routes.count }
    public var isEmpty: Bool { routes.isEmpty }
    public var current: Route? { routes.last }

    public mutating func push(_ route: Route) {
        routes.append(route)
    }

    public mutating func push(_ newRoutes: [Route]) {
        routes.append(contentsOf: newRoutes)
    }

    @discardableResult
    public mutating func pop() -> Route? {
        routes.popLast()
    }

    public mutating func pop(count: Int) {
        let removeCount = min(count, routes.count)
        routes.removeLast(removeCount)
    }

    public mutating func popToRoot() {
        routes.removeAll()
    }

    public mutating func replace(with newRoutes: [Route]) {
        routes = newRoutes
    }

    public func contains(_ route: Route) -> Bool {
        routes.contains(route)
    }

    public func route(at index: Int) -> Route? {
        guard routes.indices.contains(index) else { return nil }
        return routes[index]
    }
}
