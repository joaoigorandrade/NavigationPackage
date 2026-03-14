import SwiftUI

struct EdgeSwipeModifier<Route: Routable>: ViewModifier {
    @EnvironmentObject var navigator: Navigator<Route>
    let edgeWidth: CGFloat
    let threshold: CGFloat

    @GestureState private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.startLocation.x < edgeWidth {
                            state = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.startLocation.x < edgeWidth,
                           value.translation.width > threshold {
                            navigator.pop()
                        }
                    }
            )
            .offset(x: max(0, dragOffset))
            .animation(.interactiveSpring(), value: dragOffset)
    }
}

extension View {
    public func edgeSwipePop<Route: Routable>(
        routeType: Route.Type,
        edgeWidth: CGFloat = 20,
        threshold: CGFloat = 100
    ) -> some View {
        modifier(EdgeSwipeModifier<Route>(
            edgeWidth: edgeWidth,
            threshold: threshold
        ))
    }
}
