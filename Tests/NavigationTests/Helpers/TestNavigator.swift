import SwiftUI
import Testing
@testable import Navigation

enum MockModalRoute: ModalRoute {
    case alert
    case detail(id: Int)
    case fullScreenDetail

    var presentationStyle: ModalPresentation {
        switch self {
        case .fullScreenDetail: return .fullScreenCover
        default: return .sheet
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .alert:
            Text("Alert")
        case .detail(let id):
            Text("Modal Detail \(id)")
        case .fullScreenDetail:
            Text("Full Screen")
        }
    }
}

enum MockURLRoute: URLRoutable {
    case home
    case profile(name: String)
    case item(id: Int)

    static func route(from url: URL) -> MockURLRoute? {
        var segments: [String] = []
        if let host = url.host, !host.isEmpty {
            segments.append(host)
        }
        segments.append(contentsOf: url.pathComponents.filter { $0 != "/" })
        guard let first = segments.first else { return .home }
        switch first {
        case "home":
            return .home
        case "profile":
            return segments.count > 1 ? .profile(name: segments[1]) : nil
        case "item":
            guard segments.count > 1, let id = Int(segments[1]) else { return nil }
            return .item(id: id)
        default:
            return nil
        }
    }

    var urlRepresentation: URL? {
        switch self {
        case .home: URL(string: "app://home")
        case .profile(let name): URL(string: "app://profile/\(name)")
        case .item(let id): URL(string: "app://item/\(id)")
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .home: Text("Home")
        case .profile(let name): Text("Profile \(name)")
        case .item(let id): Text("Item \(id)")
        }
    }
}
