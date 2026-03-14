import SwiftUI

public struct PathEncoder<Route: CodableRoutable> {
    public init() {}

    public func encode(_ routes: [Route]) -> Data? {
        try? JSONEncoder().encode(routes)
    }

    public func decode(from data: Data) -> [Route]? {
        try? JSONDecoder().decode([Route].self, from: data)
    }

    public func encodePath(_ path: NavigationPath) -> Data? {
        guard let representation = path.codable else { return nil }
        return try? JSONEncoder().encode(representation)
    }

    public func decodePath(from data: Data) -> NavigationPath? {
        guard let representation = try? JSONDecoder().decode(
            NavigationPath.CodableRepresentation.self,
            from: data
        ) else {
            return nil
        }
        return NavigationPath(representation)
    }
}
