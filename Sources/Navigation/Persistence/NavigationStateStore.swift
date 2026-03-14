import SwiftUI
import Combine

@MainActor
public final class NavigationStateStore<Route: CodableRoutable> {
    public let storageKey: String
    public let policy: RestorationPolicy
    private let encoder = PathEncoder<Route>()
    private let defaults: UserDefaults

    public init(
        storageKey: String = "navigation.savedPath",
        policy: RestorationPolicy = .always,
        defaults: UserDefaults = .standard
    ) {
        self.storageKey = storageKey
        self.policy = policy
        self.defaults = defaults
    }

    public func save(routes: [Route]) {
        guard policy != .never else { return }
        guard let data = encoder.encode(routes) else { return }
        defaults.set(data, forKey: storageKey)
    }

    public func restore() -> [Route]? {
        guard policy != .never else { return nil }
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return encoder.decode(from: data)
    }

    public func clear() {
        defaults.removeObject(forKey: storageKey)
    }

    public func bind(to navigator: Navigator<Route>) {
        if let routes = restore() {
            navigator.replace(with: routes)
        }
    }

    public func saveState(of navigator: Navigator<Route>) {
        save(routes: navigator.routeStack.routes)
    }
}

extension View {
    public func persistNavigation<Route: CodableRoutable>(
        store: NavigationStateStore<Route>,
        navigator: Navigator<Route>
    ) -> some View {
        self.onChange(of: navigator.routeStack.count) { _ in
            if store.policy == .always {
                store.saveState(of: navigator)
            }
        }
        #if canImport(UIKit)
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willResignActiveNotification
        )) { _ in
            if store.policy == .onBackground || store.policy == .always {
                store.saveState(of: navigator)
            }
        }
        #elseif canImport(AppKit)
        .onReceive(NotificationCenter.default.publisher(
            for: NSApplication.willResignActiveNotification
        )) { _ in
            if store.policy == .onBackground || store.policy == .always {
                store.saveState(of: navigator)
            }
        }
        #endif
    }
}
