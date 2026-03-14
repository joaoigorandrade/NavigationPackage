import Testing
import Foundation
@testable import Navigation

@Suite("DeepLinkPattern")
struct DeepLinkPatternTests {
    @Test("Static path matches exactly")
    func staticPath() {
        let pattern = DeepLinkPattern<MockURLRoute>(
            pathTemplate: "settings",
            handler: { _, _ in .home }
        )
        let url = URL(string: "app://settings")!
        let (matched, params) = pattern.matches(url: url)
        #expect(matched)
        #expect(params.isEmpty)
    }

    @Test("Parameterized path extracts values")
    func parameterizedPath() {
        let pattern = DeepLinkPattern<MockURLRoute>(
            pathTemplate: "profile/:name",
            handler: { _, params in
                params["name"].map { .profile(name: $0) }
            }
        )
        let url = URL(string: "app://profile/Alice")!
        let (matched, params) = pattern.matches(url: url)
        #expect(matched)
        #expect(params["name"] == "Alice")
    }

    @Test("Wrong path length fails match")
    func wrongLength() {
        let pattern = DeepLinkPattern<MockURLRoute>(
            pathTemplate: "a/b/c",
            handler: { _, _ in .home }
        )
        let url = URL(string: "app://a/b")!
        let (matched, _) = pattern.matches(url: url)
        #expect(!matched)
    }

    @Test("Scheme filter works")
    func schemeFilter() {
        let pattern = DeepLinkPattern<MockURLRoute>(
            pathTemplate: "home",
            schemes: Set(["myapp"]),
            handler: { _, _ in .home }
        )
        let validURL = URL(string: "myapp://home")!
        let invalidURL = URL(string: "other://home")!
        #expect(pattern.matches(url: validURL).0)
        #expect(!pattern.matches(url: invalidURL).0)
    }

    @Test("Query parameters are extracted")
    func queryParams() {
        let pattern = DeepLinkPattern<MockURLRoute>(
            pathTemplate: "search",
            handler: { _, params in
                params["q"] != nil ? .home : nil
            }
        )
        let url = URL(string: "app://search?q=test&page=1")!
        let (matched, params) = pattern.matches(url: url)
        #expect(matched)
        #expect(params["q"] == "test")
        #expect(params["page"] == "1")
    }
}
