import SwiftUI

@MainActor
public final class ModalNavigator<Route: ModalRoute>: ObservableObject {
    @Published public var activeSheet: Route?
    @Published public var activeFullScreen: Route?
    @Published public private(set) var modalStack: [Route] = []

    public init() {}

    public func present(_ route: Route) {
        modalStack.append(route)
        switch route.presentationStyle {
        case .sheet:
            activeSheet = route
        case .fullScreenCover:
            activeFullScreen = route
        }
    }

    public func dismiss() {
        if activeFullScreen != nil {
            activeFullScreen = nil
        } else if activeSheet != nil {
            activeSheet = nil
        }
        _ = modalStack.popLast()
    }

    public func dismissAll() {
        activeSheet = nil
        activeFullScreen = nil
        modalStack.removeAll()
    }

    public var isPresenting: Bool {
        activeSheet != nil || activeFullScreen != nil
    }

    public var currentModal: Route? {
        modalStack.last
    }
}
