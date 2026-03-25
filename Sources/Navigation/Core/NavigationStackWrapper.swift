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
        NavigationStack(path: pathBinding) {
            root()
                .navigationDestination(for: Route.self) { route in
                    LazyDestination {
                        route.destination
                    }
                    .navigationBarBackButtonHidden(navigator.depth <= 1)
                    .environmentObject(navigator)
                    .environment(\.transitionNamespace, transitionNS)
                }
                .environment(\.transitionNamespace, transitionNS)
        }
        .sheet(item: sheetBinding) { route in
            route.destination
                .presentationSizing(.fitted)
                .environmentObject(navigator)
                .environment(\.transitionNamespace, transitionNS)
        }
    }

    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { navigator.path },
            set: { navigator.syncPathFromNavigationStack($0) }
        )
    }

    private var sheetBinding: Binding<Route?> {
        Binding(
            get: { navigator.activeSheet },
            set: { newValue in
                if newValue == nil {
                    navigator.dismissSheet()
                }
            }
        )
    }
}
