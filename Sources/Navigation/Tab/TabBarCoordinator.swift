import SwiftUI

public enum TabSelectionAction<Route: Routable> {
    case none
    case push(Route)
    case pushMany([Route])
    case replace([Route])
    case popToRoot
    case openSheet(Route)
    case openFullScreenCover(Route)
    case custom(() -> Void)
}

@MainActor
public final class TabBarCoordinator<Tab: Hashable, Route: Routable>: ObservableObject {
    private let navigator: Navigator<Route>
    private let resolve: (Tab) -> TabSelectionAction<Route>

    public init(
        navigator: Navigator<Route>,
        resolve: @escaping (Tab) -> TabSelectionAction<Route>
    ) {
        self.navigator = navigator
        self.resolve = resolve
    }

    public func select(_ tab: Tab) {
        perform(resolve(tab))
    }

    public func action(for tab: Tab) -> TabSelectionAction<Route> {
        resolve(tab)
    }

    private func perform(_ action: TabSelectionAction<Route>) {
        switch action {
        case .none:
            return
        case .push(let route):
            navigator.navigate(to: route)
        case .pushMany(let routes):
            navigator.navigate(to: routes)
        case .replace(let routes):
            navigator.replace(with: routes)
        case .popToRoot:
            navigator.popToRoot()
        case .openSheet(let route):
            navigator.openSheet(route)
        case .openFullScreenCover(let route):
            navigator.openFullScreenCover(route)
        case .custom(let block):
            block()
        }
    }
}
