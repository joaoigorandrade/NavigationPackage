import SwiftUI

public struct NavigationStackWrapper<Route: Routable, Root: View>: View {
    @ObservedObject var navigator: Navigator<Route>
    @Namespace private var transitionNS
    let root: () -> Root

    public init(
        navigator: Navigator<Route>,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.navigator = navigator
        self.root = root
    }

    public var body: some View {
        NavigationStack(path: $navigator.path) {
            root()
                .navigationDestination(for: Route.self) { route in
                    LazyDestination {
                        route.destination
                    }
                    .environment(\.transitionNamespace, transitionNS)
                }
                .environment(\.transitionNamespace, transitionNS)
        }
    }
}
