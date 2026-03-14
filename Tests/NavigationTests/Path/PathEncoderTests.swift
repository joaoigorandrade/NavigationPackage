import Testing
import Foundation
@testable import Navigation

@Suite("PathEncoder")
struct PathEncoderTests {
    @Test("Round-trip encode/decode routes")
    func roundTrip() {
        let encoder = PathEncoder<MockRoute>()
        let routes: [MockRoute] = [.home, .detail(id: 42), .profile(name: "Alice")]
        let data = encoder.encode(routes)
        #expect(data != nil)
        let decoded = encoder.decode(from: data!)
        #expect(decoded == routes)
    }

    @Test("Decode corrupt data returns nil")
    func corruptData() {
        let encoder = PathEncoder<MockRoute>()
        let data = "invalid json".data(using: .utf8)!
        let decoded = encoder.decode(from: data)
        #expect(decoded == nil)
    }

    @Test("Encode empty array")
    func emptyArray() {
        let encoder = PathEncoder<MockRoute>()
        let data = encoder.encode([])
        #expect(data != nil)
        let decoded = encoder.decode(from: data!)
        #expect(decoded == [])
    }
}
