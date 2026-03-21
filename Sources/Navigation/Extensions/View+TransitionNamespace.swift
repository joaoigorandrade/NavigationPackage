import SwiftUI

private struct TransitionNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    public var transitionNamespace: Namespace.ID? {
        get { self[TransitionNamespaceKey.self] }
        set { self[TransitionNamespaceKey.self] = newValue }
    }
}

extension View {
    public func transitionNamespace(_ namespace: Namespace.ID) -> some View {
        self.environment(\.transitionNamespace, namespace)
    }
}
