import SwiftUI

@MainActor
@propertyWrapper
public struct OptionalNavigator<Route: Routable>: DynamicProperty {
    @Environment(\.optionalNavigatorStorage) private var storage

    public init() {}

    public var wrappedValue: Navigator<Route>? {
        storage as? Navigator<Route>
    }
}

private struct OptionalNavigatorKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AnyObject? = nil
}

extension EnvironmentValues {
    var optionalNavigatorStorage: AnyObject? {
        get { self[OptionalNavigatorKey.self] }
        set { self[OptionalNavigatorKey.self] = newValue }
    }
}

extension View {
    public func optionalNavigator<Route: Routable>(
        _ navigator: Navigator<Route>
    ) -> some View {
        self.environment(\.optionalNavigatorStorage, navigator)
    }
}
