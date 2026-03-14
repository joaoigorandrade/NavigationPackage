import SwiftUI

extension View {
    public func navigationRoute<Route: Routable>(
        _ type: Route.Type
    ) -> some View {
        self.navigationDestination(for: type) { route in
            LazyDestination {
                route.destination
            }
        }
    }
}
