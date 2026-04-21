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

    @MainActor
    @Test("pushed destination can keep the native back button hidden")
    func test_pushedDestination_withCustomBackChrome_keepsNativeBackButtonHidden() async {
        let navigator = Navigator<TestRoute>()
        let recorder = BackButtonRecorder()
        let sut = makeSUT(navigator: navigator, recorder: recorder)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: sut)
        window.makeKeyAndVisible()

        navigator.navigate(to: .customBack)

        for _ in 0..<40 where recorder.isBackButtonHidden == nil {
            await Task.yield()
        }

        #expect(recorder.isBackButtonHidden == true)
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

    @MainActor
    func makeSUT(
        navigator: Navigator<TestRoute>,
        recorder: BackButtonRecorder
    ) -> some View {
        NavigationStackWrapper(navigator: navigator) {
            Text("Root")
        }
        .environment(\.testBackButtonRecorder, recorder)
    }
}

// MARK: - Test Doubles

@MainActor
private final class NavigatorRecorder {
    var recordedNavigator: Navigator<MockRoute>?
}

@MainActor
private final class BackButtonRecorder {
    var isBackButtonHidden: Bool?
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

private enum TestRoute: Routable {
    case customBack

    @ViewBuilder
    var destination: some View {
        switch self {
        case .customBack:
            TestRouteDestination()
        }
    }
}

private struct TestRouteDestination: View {
    @Environment(\.testBackButtonRecorder) private var recorder

    var body: some View {
        Text("Custom Back")
            
            .background(BackButtonVisibilityReader(recorder: recorder))
    }
}

private struct BackButtonVisibilityReader: UIViewRepresentable {
    let recorder: BackButtonRecorder?

    func makeUIView(context: Context) -> InspectionView {
        let view = InspectionView()
        view.onResolve = { [weak recorder] hostingView in
            DispatchQueue.main.async {
                recorder?.isBackButtonHidden = hostingView.parentViewController?.navigationItem.hidesBackButton
            }
        }
        return view
    }

    func updateUIView(_ uiView: InspectionView, context: Context) {}
}

private final class InspectionView: UIView {
    var onResolve: ((UIView) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onResolve?(self)
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: next, next: { $0?.next })
            .first { $0 is UIViewController } as? UIViewController
    }
}

private struct TestBackButtonRecorderKey: EnvironmentKey {
    static let defaultValue: BackButtonRecorder? = nil
}

private extension EnvironmentValues {
    var testBackButtonRecorder: BackButtonRecorder? {
        get { self[TestBackButtonRecorderKey.self] }
        set { self[TestBackButtonRecorderKey.self] = newValue }
    }
}
#endif
