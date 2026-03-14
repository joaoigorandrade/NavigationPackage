import SwiftUI
import Testing
@testable import Navigation

enum MockRoute: CodableRoutable {
    case home
    case detail(id: Int)
    case profile(name: String)
    case settings

    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            Text("Home")
        case .detail(let id):
            Text("Detail \(id)")
        case .profile(let name):
            Text("Profile \(name)")
        case .settings:
            Text("Settings")
        }
    }
}
