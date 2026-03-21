import Foundation

public enum NavigationAction<Route: Routable>: Sendable {
    case push(Route)
    case pushMultiple([Route])
    case pop
    case popMultiple(Int)
    case popToRoot
    case replace([Route])
    case reset
}
