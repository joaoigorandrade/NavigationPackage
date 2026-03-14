import SwiftUI

extension View {
    public func onDeepLink<Route: URLRoutable>(
        handler: DeepLinkHandler<Route>,
        navigator: Navigator<Route>,
        replaceStack: Bool = false
    ) -> some View {
        self.onOpenURL { url in
            if replaceStack {
                if let routes = handler.handlePath(url: url) {
                    navigator.replace(with: routes)
                }
            } else {
                if let route = handler.handle(url: url) {
                    navigator.navigate(to: route)
                }
            }
        }
    }
}
