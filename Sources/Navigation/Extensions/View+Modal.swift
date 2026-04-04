import SwiftUI

extension View {
    @MainActor
    public func modalPresentation<Route: Routable>(
        _ navigator: Navigator<Route>
    ) -> some View {
        self
            .sheet(item: Binding(
                get: { navigator.activeSheet },
                set: { if $0 == nil { navigator.dismissSheet() } }
            )) { route in
                route.destination
                    .environmentObject(navigator)
            }
            #if os(iOS)
            .fullScreenCover(item: Binding(
                get: { navigator.activeFullScreenCover },
                set: { if $0 == nil { navigator.dismissFullScreenCover() } }
            )) { route in
                route.destination
                    .environmentObject(navigator)
            }
            #endif
    }
}
