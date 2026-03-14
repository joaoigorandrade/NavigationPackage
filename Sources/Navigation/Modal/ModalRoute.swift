import SwiftUI

public protocol ModalRoute: Routable {
    var presentationStyle: ModalPresentation { get }
}

extension ModalRoute {
    public var presentationStyle: ModalPresentation { .sheet }
}
