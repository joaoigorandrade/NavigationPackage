import Testing
import Foundation
@testable import Navigation

@Suite("DeepLinkHandler")
struct DeepLinkHandlerTests {
    @Test("Handle valid URL returns route")
    func handleValidURL() {
        let handler = DeepLinkHandler<MockURLRoute>()
        let url = URL(string: "app://profile/Alice")!
        let route = handler.handle(url: url)
        #expect(route == .profile(name: "Alice"))
    }

    @Test("Handle item URL with integer ID")
    func handleItemURL() {
        let handler = DeepLinkHandler<MockURLRoute>()
        let url = URL(string: "app://item/42")!
        let route = handler.handle(url: url)
        #expect(route == .item(id: 42))
    }

    @Test("Handle unknown URL returns nil if no fallback")
    func handleUnknownURL() {
        let handler = DeepLinkHandler<MockURLRoute>()
        let url = URL(string: "app://unknown/path")!
        let route = handler.handle(url: url)
        #expect(route == nil)
    }

    @Test("CanHandle returns correct value")
    func canHandle() {
        let handler = DeepLinkHandler<MockURLRoute>()
        let validURL = URL(string: "app://profile/Bob")!
        let invalidURL = URL(string: "app://profile")!
        #expect(handler.canHandle(url: validURL))
        #expect(!handler.canHandle(url: invalidURL))
    }

    @Test("Registered pattern takes priority")
    func registeredPattern() {
        let handler = DeepLinkHandler<MockURLRoute>()
        handler.register(
            pathTemplate: "special/:id",
            handler: { _, params in
                guard let idStr = params["id"], let id = Int(idStr) else { return nil }
                return .item(id: id * 10)
            }
        )
        let url = URL(string: "app://special/5")!
        let route = handler.handle(url: url)
        #expect(route == .item(id: 50))
    }
}
