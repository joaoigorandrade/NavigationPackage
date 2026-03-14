import SwiftUI

public protocol TabRoute: Hashable, CaseIterable, Identifiable {
    associatedtype TabLabel: View
    associatedtype TabContent: View

    @ViewBuilder var tabLabel: TabLabel { get }
    @ViewBuilder var tabContent: TabContent { get }
}

extension TabRoute {
    public var id: Int { hashValue }
}
