import SwiftUI

public protocol Routable: Hashable, Identifiable, Sendable {
    associatedtype Body: View
    @ViewBuilder var destination: Body { get }
}

extension Routable {
    public var id: Int {
        hashValue
    }
}

public protocol CodableRoutable: Routable, Codable {}
