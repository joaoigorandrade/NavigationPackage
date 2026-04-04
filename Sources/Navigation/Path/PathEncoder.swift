import Foundation

public struct PathEncoder<Route: CodableRoutable> {
    public init() {}

    public func encode(_ routes: [Route]) -> Data? {
        try? JSONEncoder().encode(routes)
    }

    public func decode(from data: Data) -> [Route]? {
        try? JSONDecoder().decode([Route].self, from: data)
    }
}
