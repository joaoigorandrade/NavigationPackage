import SwiftUI
import Testing
@testable import Navigation
#if canImport(UIKit)
import UIKit

@Suite("NavigationStackWrapper")
struct NavigationStackWrapperTests {
    @MainActor
    @Test("root view receives navigator environment object")
    func test_rootView_receivesNavigatorEnvironmentObject() async {
        let navigator = Navigator<MockRoute>()
        let recorder = NavigatorRecorder()
        let sut = makeSUT(navigator: navigator, recorder: recorder)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: sut)
        window.makeKeyAndVisible()

        for _ in 0..<20 where recorder.recordedNavigator == nil {
            await Task.yield()
        }

        #expect(recorder.recordedNavigator === navigator)
    }
}

// MARK: - Helpers

private extension NavigationStackWrapperTests {
    @MainActor
    func makeSUT(
        navigator: Navigator<MockRoute> = Navigator<MockRoute>(),
        recorder: NavigatorRecorder = NavigatorRecorder()
    ) -> some View {
        NavigationStackWrapper(navigator: navigator) {
            RootEnvironmentObserver(recorder: recorder)
        }
    }
}

// MARK: - Test Doubles

@MainActor
private final class NavigatorRecorder {
    var recordedNavigator: Navigator<MockRoute>?
}

private struct RootEnvironmentObserver: View {
    @EnvironmentObject private var navigator: Navigator<MockRoute>

    let recorder: NavigatorRecorder

    var body: some View {
        Color.clear
            .onAppear {
                recorder.recordedNavigator = navigator
            }
    }
}
#endif
