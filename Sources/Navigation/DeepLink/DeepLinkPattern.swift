import Foundation

public struct DeepLinkPattern<Route: URLRoutable> {
    public let pathTemplate: String
    public let schemes: Set<String>
    public let handler: (URL, [String: String]) -> Route?

    public init(
        pathTemplate: String,
        schemes: Set<String> = [],
        handler: @escaping (URL, [String: String]) -> Route?
    ) {
        self.pathTemplate = pathTemplate
        self.schemes = schemes
        self.handler = handler
    }

    func matches(url: URL) -> (Bool, [String: String]) {
        if !schemes.isEmpty, let scheme = url.scheme, !schemes.contains(scheme) {
            return (false, [:])
        }

        let templateParts = pathTemplate.split(separator: "/").map(String.init)
        let urlParts = Self.extractSegments(from: url)

        guard templateParts.count == urlParts.count else {
            return (false, [:])
        }

        var params: [String: String] = [:]
        for (template, actual) in zip(templateParts, urlParts) {
            if template.hasPrefix(":") {
                let key = String(template.dropFirst())
                params[key] = actual
            } else if template != actual {
                return (false, [:])
            }
        }

        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if let value = item.value {
                    params[item.name] = value
                }
            }
        }

        return (true, params)
    }

    static func extractSegments(from url: URL) -> [String] {
        var segments: [String] = []
        if let host = url.host, !host.isEmpty {
            segments.append(host)
        }
        segments.append(contentsOf: url.pathComponents.filter { $0 != "/" })
        return segments
    }
}
