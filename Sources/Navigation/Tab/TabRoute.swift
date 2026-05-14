import SwiftUI

public protocol TabRoute: Hashable, CaseIterable, Identifiable {
    associatedtype TabLabel: View
    associatedtype TabContent: View

    @MainActor @ViewBuilder var tabLabel: TabLabel { get }
    @MainActor @ViewBuilder var tabContent: TabContent { get }
}

extension TabRoute {
    public var id: Int { hashValue }

    public var tabRole: TabRole? { nil }
}
