import Foundation

public struct NavigationEvent<Route: Routable>: Identifiable, Sendable {
    public let id: UUID
    public let action: NavigationAction<Route>
    public let timestamp: Date
    public let previousDepth: Int
    public let newDepth: Int

    init(
        action: NavigationAction<Route>,
        previousDepth: Int,
        newDepth: Int
    ) {
        self.id = UUID()
        self.action = action
        self.timestamp = Date()
        self.previousDepth = previousDepth
        self.newDepth = newDepth
    }
}
