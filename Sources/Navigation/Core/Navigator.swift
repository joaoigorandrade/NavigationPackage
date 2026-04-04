import SwiftUI

@MainActor
public final class Navigator<Route: Routable>: ObservableObject {
    @Published public var path: [Route] = []
    @Published public var activeSheet: Route?
    @Published public var activeFullScreenCover: Route?
    @Published public private(set) var history: [NavigationEvent<Route>] = []

    public var maxHistoryDepth: Int

    public var depth: Int { path.count }
    public var currentRoute: Route? { path.last }
    public var isEmpty: Bool { path.isEmpty }
    public var isSheetPresented: Bool { activeSheet != nil }
    public var isFullScreenCoverPresented: Bool { activeFullScreenCover != nil }
    public var isAnyModalPresented: Bool { activeSheet != nil || activeFullScreenCover != nil }

    public init(maxHistoryDepth: Int = 100) {
        self.maxHistoryDepth = maxHistoryDepth
    }

    public func navigate(to route: Route, dismissModals: Bool = true) {
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path.append(route)
        recordEvent(.push(route), previousDepth: previousDepth)
    }

    public func navigate(to routes: [Route], dismissModals: Bool = true) {
        guard !routes.isEmpty else { return }
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path.append(contentsOf: routes)
        recordEvent(.pushMultiple(routes), previousDepth: previousDepth)
    }

    public func pop(dismissModals: Bool = true) {
        guard !isEmpty else { return }
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path.removeLast()
        recordEvent(.pop, previousDepth: previousDepth)
    }

    public func pop(count: Int, dismissModals: Bool = true) {
        guard count > 0, !isEmpty else { return }
        if dismissModals { dismissAllModals() }
        let actualCount = min(count, depth)
        let previousDepth = depth
        path.removeLast(actualCount)
        recordEvent(.popMultiple(actualCount), previousDepth: previousDepth)
    }

    public func popToRoot(dismissModals: Bool = true) {
        guard !isEmpty else { return }
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path.removeAll()
        recordEvent(.popToRoot, previousDepth: previousDepth)
    }

    @discardableResult
    public func popTo(_ route: Route, dismissModals: Bool = true) -> Bool {
        guard let index = path.lastIndex(of: route) else {
            return false
        }
        if dismissModals { dismissAllModals() }
        let countToPop = depth - index - 1
        if countToPop > 0 {
            pop(count: countToPop, dismissModals: false)
        }
        return true
    }

    public func replace(with routes: [Route], dismissModals: Bool = true) {
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path = routes
        recordEvent(.replace(routes), previousDepth: previousDepth)
    }

    public func reset(dismissModals: Bool = true) {
        if dismissModals { dismissAllModals() }
        let previousDepth = depth
        path.removeAll()
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

    public func openFullScreenCover(_ route: Route) {
        activeFullScreenCover = route
    }

    public func dismissFullScreenCover() {
        activeFullScreenCover = nil
    }

    public func dismissAllModals() {
        activeSheet = nil
        activeFullScreenCover = nil
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

extension Navigator where Route: ModalRoute {
    public func present(_ route: Route) {
        switch route.presentationStyle {
        case .sheet: openSheet(route)
        case .fullScreenCover: openFullScreenCover(route)
        }
    }

    public func dismiss() {
        if activeFullScreenCover != nil {
            dismissFullScreenCover()
        } else {
            dismissSheet()
        }
    }
}
