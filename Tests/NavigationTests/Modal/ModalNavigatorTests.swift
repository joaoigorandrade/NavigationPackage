import Testing
import SwiftUI
@testable import Navigation

@Suite("Navigator Modal Presentation")
struct NavigatorModalTests {
    @MainActor
    @Test("Initial state has no modals")
    func initialState() {
        let navigator = Navigator<MockModalRoute>()
        #expect(!navigator.isAnyModalPresented)
        #expect(!navigator.isSheetPresented)
        #expect(!navigator.isFullScreenCoverPresented)
    }

    @MainActor
    @Test("present(.sheet) sets activeSheet")
    func presentSheet() {
        let navigator = Navigator<MockModalRoute>()
        navigator.present(.alert)
        #expect(navigator.activeSheet == .alert)
        #expect(navigator.activeFullScreenCover == nil)
        #expect(navigator.isSheetPresented)
    }

    @MainActor
    @Test("present(.fullScreenCover) sets activeFullScreenCover")
    func presentFullScreen() {
        let navigator = Navigator<MockModalRoute>()
        navigator.present(.fullScreenDetail)
        #expect(navigator.activeFullScreenCover == .fullScreenDetail)
        #expect(navigator.activeSheet == nil)
        #expect(navigator.isFullScreenCoverPresented)
    }

    @MainActor
    @Test("dismiss() removes fullScreenCover first")
    func dismissFullScreenFirst() {
        let navigator = Navigator<MockModalRoute>()
        navigator.openFullScreenCover(.fullScreenDetail)
        navigator.dismiss()
        #expect(!navigator.isAnyModalPresented)
    }

    @MainActor
    @Test("dismiss() falls through to sheet when no fullScreenCover")
    func dismissSheetFallthrough() {
        let navigator = Navigator<MockModalRoute>()
        navigator.openSheet(.alert)
        navigator.dismiss()
        #expect(!navigator.isSheetPresented)
    }

    @MainActor
    @Test("dismissAllModals clears both surfaces")
    func dismissAll() {
        let navigator = Navigator<MockModalRoute>()
        navigator.openSheet(.alert)
        navigator.openFullScreenCover(.fullScreenDetail)
        navigator.dismissAllModals()
        #expect(!navigator.isAnyModalPresented)
    }

    @MainActor
    @Test("openSheet and openFullScreenCover are independent")
    func independentSurfaces() {
        let navigator = Navigator<MockModalRoute>()
        navigator.openSheet(.alert)
        navigator.openFullScreenCover(.fullScreenDetail)
        #expect(navigator.activeSheet == .alert)
        #expect(navigator.activeFullScreenCover == .fullScreenDetail)
    }
}
