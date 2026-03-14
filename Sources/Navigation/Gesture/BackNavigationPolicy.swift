import SwiftUI

public enum BackNavigationPolicy {
    case allowed
    case disabled
    case conditional(@MainActor () -> Bool)
    case confirmationRequired(message: String)
}

#if os(iOS)
struct BackNavigationPolicyModifier<Route: Routable>: ViewModifier {
    let policy: BackNavigationPolicy
    @EnvironmentObject var navigator: Navigator<Route>
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""

    func body(content: Content) -> some View {
        switch policy {
        case .allowed:
            content

        case .disabled:
            content
                .navigationBarBackButtonHidden(true)

        case .conditional(let condition):
            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if condition() {
                                navigator.pop()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }

        case .confirmationRequired(let message):
            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            confirmationMessage = message
                            showConfirmation = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
                .alert("Confirm", isPresented: $showConfirmation) {
                    Button("Leave", role: .destructive) {
                        navigator.pop()
                    }
                    Button("Stay", role: .cancel) {}
                } message: {
                    Text(confirmationMessage)
                }
        }
    }
}
#endif

extension View {
    #if os(iOS)
    public func backNavigationPolicy<Route: Routable>(
        _ policy: BackNavigationPolicy,
        routeType: Route.Type
    ) -> some View {
        modifier(BackNavigationPolicyModifier<Route>(policy: policy))
    }
    #else
    public func backNavigationPolicy<Route: Routable>(
        _ policy: BackNavigationPolicy,
        routeType: Route.Type
    ) -> some View {
        self
    }
    #endif
}
