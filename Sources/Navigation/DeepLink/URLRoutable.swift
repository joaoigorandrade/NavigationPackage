import Foundation

public protocol URLRoutable: CodableRoutable {
    static func route(from url: URL) -> Self?
    var urlRepresentation: URL? { get }
}
