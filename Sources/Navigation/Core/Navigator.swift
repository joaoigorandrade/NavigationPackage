import SwiftUI

@MainActor
public final class Navigator<Route: Routable>: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var activeSheet: Route?
    @Published public private(set) var routeStack = TypedNavigationPath<Route>()
    @Published public private(set) var history: [NavigationEvent<Route>] = []

    public var maxHistoryDepth: Int

    public var depth: Int { routeStack.count }
    public var currentRoute: Route? { routeStack.current }
    public var isEmpty: Bool { routeStack.isEmpty }
    public var isSheetPresented: Bool { activeSheet != nil }

    public init(maxHistoryDepth: Int = 100) {
        self.maxHistoryDepth = maxHistoryDepth
    }

    public func navigate(to route: Route) {
        let previousDepth = depth
        path.append(route)
        routeStack.push(route)
        recordEvent(.push(route), previousDepth: previousDepth)
    }

    public func navigate(to routes: [Route]) {
        guard !routes.isEmpty else { return }
        let previousDepth = depth
        for route in routes {
            path.append(route)
            routeStack.push(route)
        }
        recordEvent(.pushMultiple(routes), previousDepth: previousDepth)
    }

    public func pop() {
        guard !isEmpty else { return }
        let previousDepth = depth
        path.removeLast()
        routeStack.pop()
        recordEvent(.pop, previousDepth: previousDepth)
    }

    public func pop(count: Int) {
        guard count > 0, !isEmpty else { return }
        let actualCount = min(count, depth)
        let previousDepth = depth
        path.removeLast(actualCount)
        routeStack.pop(count: actualCount)
        recordEvent(.popMultiple(actualCount), previousDepth: previousDepth)
    }

    public func popToRoot() {
        guard !isEmpty else { return }
        let previousDepth = depth
        path = NavigationPath()
        routeStack.popToRoot()
        recordEvent(.popToRoot, previousDepth: previousDepth)
    }

    @discardableResult
    public func popTo(_ route: Route) -> Bool {
        guard let index = routeStack.routes.lastIndex(of: route) else {
            return false
        }
        let countToPop = depth - index - 1
        if countToPop > 0 {
            pop(count: countToPop)
        }
        return true
    }

    public func replace(with routes: [Route]) {
        let previousDepth = depth
        path = NavigationPath()
        routeStack.popToRoot()
        for route in routes {
            path.append(route)
            routeStack.push(route)
        }
        recordEvent(.replace(routes), previousDepth: previousDepth)
    }

    public func reset() {
        let previousDepth = depth
        path = NavigationPath()
        routeStack.popToRoot()
        history.removeAll()
        recordEvent(.reset, previousDepth: previousDepth)
    }

    public func canPop() -> Bool {
        !isEmpty
    }

    public func openSheet(_ route: Route) {
        activeSheet = route
    }

    public func dismissSheet() {
        activeSheet = nil
    }

    func syncPathFromNavigationStack(_ newPath: NavigationPath) {
        let previousDepth = depth
        let newDepth = newPath.count

        guard newDepth != previousDepth else { return }

        path = newPath

        let popCount = previousDepth - newDepth

        guard popCount > 0 else {
            assertionFailure("System pushed routes outside Navigator — this shouldn't happen.")
            return
        }

        if newDepth == 0 {
            routeStack.popToRoot()
            recordEvent(.popToRoot, previousDepth: previousDepth)
        } else {
            routeStack.pop(count: popCount)
            recordEvent(popCount == 1 ? .pop : .popMultiple(popCount), previousDepth: previousDepth)
        }
    }

    private func recordEvent(_ action: NavigationAction<Route>, previousDepth: Int) {
        let event = NavigationEvent(
            action: action,
            previousDepth: previousDepth,
            newDepth: depth
        )
        history.append(event)
        if history.count > maxHistoryDepth {
            history.removeFirst(history.count - maxHistoryDepth)
        }
    }
}
