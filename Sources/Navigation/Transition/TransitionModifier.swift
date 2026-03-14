import SwiftUI

public struct TransitionModifier: ViewModifier {
    let style: NavigationTransitionStyle

    public func body(content: Content) -> some View {
        content
            .transition(style.transition)
            .animation(style.animation, value: UUID())
    }
}

extension View {
    public func navigationTransitionStyle(
        _ style: NavigationTransitionStyle
    ) -> some View {
        modifier(TransitionModifier(style: style))
    }
}
