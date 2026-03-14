import Foundation

public final class DeepLinkHandler<Route: URLRoutable> {
    private var patterns: [DeepLinkPattern<Route>] = []

    public init() {}

    public func register(pattern: DeepLinkPattern<Route>) {
        patterns.append(pattern)
    }

    public func register(
        pathTemplate: String,
        schemes: Set<String> = [],
        handler: @escaping (URL, [String: String]) -> Route?
    ) {
        patterns.append(DeepLinkPattern(
            pathTemplate: pathTemplate,
            schemes: schemes,
            handler: handler
        ))
    }

    public func handle(url: URL) -> Route? {
        for pattern in patterns {
            let (matched, params) = pattern.matches(url: url)
            if matched, let route = pattern.handler(url, params) {
                return route
            }
        }
        return Route.route(from: url)
    }

    public func handlePath(url: URL) -> [Route]? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard !pathComponents.isEmpty else { return nil }

        var routes: [Route] = []
        var currentPath = ""

        for component in pathComponents {
            currentPath += "/\(component)"
            if let partialURL = URL(string: (url.scheme ?? "app") + "://" + (url.host ?? "") + currentPath),
               let route = handle(url: partialURL) {
                routes.append(route)
            }
        }

        return routes.isEmpty ? nil : routes
    }

    public func canHandle(url: URL) -> Bool {
        for pattern in patterns {
            let (matched, _) = pattern.matches(url: url)
            if matched { return true }
        }
        return Route.route(from: url) != nil
    }
}
