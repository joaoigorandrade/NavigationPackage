import Testing
import SwiftUI
@testable import Navigation

@Suite("ModalNavigator")
struct ModalNavigatorTests {
    @MainActor
    @Test("Initial state has no modals")
    func initialState() {
        let navigator = ModalNavigator<MockModalRoute>()
        #expect(!navigator.isPresenting)
        #expect(navigator.currentModal == nil)
        #expect(navigator.modalStack.isEmpty)
    }

    @MainActor
    @Test("Present sheet sets activeSheet")
    func presentSheet() {
        let navigator = ModalNavigator<MockModalRoute>()
        navigator.present(.alert)
        #expect(navigator.activeSheet == .alert)
        #expect(navigator.activeFullScreen == nil)
        #expect(navigator.isPresenting)
        #expect(navigator.modalStack.count == 1)
    }

    @MainActor
    @Test("Present fullscreen sets activeFullScreen")
    func presentFullScreen() {
        let navigator = ModalNavigator<MockModalRoute>()
        navigator.present(.fullScreenDetail)
        #expect(navigator.activeFullScreen == .fullScreenDetail)
        #expect(navigator.activeSheet == nil)
        #expect(navigator.isPresenting)
    }

    @MainActor
    @Test("Dismiss removes current modal")
    func dismiss() {
        let navigator = ModalNavigator<MockModalRoute>()
        navigator.present(.alert)
        navigator.dismiss()
        #expect(!navigator.isPresenting)
        #expect(navigator.modalStack.isEmpty)
    }

    @MainActor
    @Test("DismissAll clears everything")
    func dismissAll() {
        let navigator = ModalNavigator<MockModalRoute>()
        navigator.present(.alert)
        navigator.present(.detail(id: 1))
        navigator.dismissAll()
        #expect(!navigator.isPresenting)
        #expect(navigator.modalStack.isEmpty)
    }

    @MainActor
    @Test("CurrentModal returns last presented")
    func currentModal() {
        let navigator = ModalNavigator<MockModalRoute>()
        navigator.present(.alert)
        navigator.present(.detail(id: 5))
        #expect(navigator.currentModal == .detail(id: 5))
    }
}
