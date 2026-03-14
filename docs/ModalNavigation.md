# Modal Navigation

Modals are managed separately from the push navigation stack via `ModalNavigator`.

## ModalRoute Protocol

```swift
public protocol ModalRoute: Routable {
    var presentationStyle: ModalPresentation { get }
}
```

`ModalPresentation` can be `.sheet` (default) or `.fullScreenCover` (iOS only).

## Define Modal Routes

```swift
enum AppModal: ModalRoute {
    case confirm(message: String)
    case editProfile
    case fullScreenMedia(id: Int)

    var presentationStyle: ModalPresentation {
        switch self {
        case .fullScreenMedia: return .fullScreenCover
        default: return .sheet
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .confirm(let message): ConfirmView(message: message)
        case .editProfile: EditProfileView()
        case .fullScreenMedia(let id): MediaView(id: id)
        }
    }
}
```

## Setup

```swift
@StateObject private var modalNavigator = ModalNavigator<AppModal>()

NavigationStackWrapper(navigator: navigator) {
    ContentView()
}
.modalNavigation(modalNavigator)
```

## Present and Dismiss

```swift
@EnvironmentObject var modalNavigator: ModalNavigator<AppModal>

// Present
modalNavigator.present(.editProfile)
modalNavigator.present(.fullScreenMedia(id: 42))

// Dismiss
modalNavigator.dismiss()      // Dismiss current
modalNavigator.dismissAll()   // Dismiss all

// Inspect
modalNavigator.isPresenting   // Bool
modalNavigator.currentModal   // Current modal route
modalNavigator.modalStack     // All presented modals
```

## Nested Navigation in Modals

A modal can contain its own `NavigationStackWrapper` with a separate `Navigator`, enabling full push/pop navigation within the modal.
