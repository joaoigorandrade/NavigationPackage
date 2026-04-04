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
                    .navigationBarBackButtonHidden(navigator.depth < 1)
                    .environmentObject(navigator)
                    .environment(\.transitionNamespace, transitionNS)
                }
                .environment(\.transitionNamespace, transitionNS)
        }
        .sheet(item: sheetBinding) { route in
            route.destination
                .modifier(SelfSizingSheetModifier())
                .environmentObject(navigator)
                .environment(\.transitionNamespace, transitionNS)
        }
        #if os(iOS)
        .fullScreenCover(item: fullScreenCoverBinding) { route in
            route.destination
                .environmentObject(navigator)
                .environment(\.transitionNamespace, transitionNS)
        }
        #endif
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

    private var fullScreenCoverBinding: Binding<Route?> {
        Binding(
            get: { navigator.activeFullScreenCover },
            set: { newValue in
                if newValue == nil {
                    navigator.dismissFullScreenCover()
                }
            }
        )
    }
}
