# Custom Transitions

Apply custom transition animations to navigation destinations.

## NavigationTransitionStyle

```swift
public enum NavigationTransitionStyle {
    case `default`
    case slide(edge: Edge)
    case fade(duration: Double)
    case scale(anchor: UnitPoint)
    case custom(AnyTransition)
}
```

## Built-in Presets

```swift
.slideFromTrailing   // Slide from right
.slideFromLeading    // Slide from left
.slideFromBottom     // Slide from bottom
.fadeIn              // Fade with 0.3s duration
.scaleUp             // Scale from center with opacity
.fadeDuration(0.5)   // Custom fade duration
```

## Usage

Apply to any view that appears as a navigation destination:

```swift
struct DetailView: View {
    var body: some View {
        Text("Detail")
            .navigationTransitionStyle(.fadeIn)
    }
}
```

## Custom Transitions

Use `AnyTransition` for fully custom animations:

```swift
let myTransition = AnyTransition.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
)

view.navigationTransitionStyle(.custom(myTransition))
```
