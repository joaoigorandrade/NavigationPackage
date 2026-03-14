import SwiftUI

public enum NavigationTransitionStyle {
    case `default`
    case slide(edge: Edge = .trailing)
    case fade(duration: Double = 0.3)
    case scale(anchor: UnitPoint = .center)
    case custom(AnyTransition)

    var transition: AnyTransition {
        switch self {
        case .default:
            return .identity
        case .slide(let edge):
            return .move(edge: edge)
        case .fade:
            return .opacity
        case .scale(let anchor):
            return .scale(scale: 0, anchor: anchor).combined(with: .opacity)
        case .custom(let transition):
            return transition
        }
    }

    var animation: Animation? {
        switch self {
        case .default:
            return nil
        case .slide:
            return .easeInOut(duration: 0.3)
        case .fade(let duration):
            return .easeInOut(duration: duration)
        case .scale:
            return .spring(response: 0.35, dampingFraction: 0.8)
        case .custom:
            return .easeInOut(duration: 0.3)
        }
    }
}
