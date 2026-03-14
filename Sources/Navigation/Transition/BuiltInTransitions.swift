import SwiftUI

extension NavigationTransitionStyle {
    public static var slideFromTrailing: NavigationTransitionStyle {
        .slide(edge: .trailing)
    }

    public static var slideFromLeading: NavigationTransitionStyle {
        .slide(edge: .leading)
    }

    public static var slideFromBottom: NavigationTransitionStyle {
        .slide(edge: .bottom)
    }

    public static var fadeIn: NavigationTransitionStyle {
        .fade(duration: 0.3)
    }

    public static var scaleUp: NavigationTransitionStyle {
        .scale(anchor: .center)
    }

    public static func fadeDuration(_ duration: Double) -> NavigationTransitionStyle {
        .fade(duration: duration)
    }
}
