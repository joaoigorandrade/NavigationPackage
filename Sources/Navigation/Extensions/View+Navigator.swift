import SwiftUI

extension View {
    public func withNavigator<Route: Routable>(
        _ navigator: Navigator<Route>
    ) -> some View {
        self.environmentObject(navigator)
    }
}
