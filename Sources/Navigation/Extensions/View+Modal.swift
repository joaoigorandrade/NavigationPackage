import SwiftUI

extension View {
    public func modalNavigation<Route: ModalRoute>(
        _ modalNavigator: ModalNavigator<Route>
    ) -> some View {
        self
            .sheet(item: Binding(
                get: { modalNavigator.activeSheet },
                set: { newValue in
                    if newValue == nil { modalNavigator.dismiss() }
                }
            )) { route in
                route.destination
            }
            #if os(iOS)
            .fullScreenCover(item: Binding(
                get: { modalNavigator.activeFullScreen },
                set: { newValue in
                    if newValue == nil { modalNavigator.dismiss() }
                }
            )) { route in
                route.destination
            }
            #endif
            .environmentObject(modalNavigator)
    }
}
