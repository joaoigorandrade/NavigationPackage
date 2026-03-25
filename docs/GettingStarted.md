# Getting Started

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/Navigation", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies.

## Define Your Routes

Create an enum conforming to `Routable`:

```swift
import Navigation
import SwiftUI

enum AppRoute: Routable {
    case home
    case profile(userId: String)
    case settings
    case contactSupport

    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeView()
        case .profile(let userId):
            ProfileView(userId: userId)
        case .settings:
            SettingsView()
        case .contactSupport:
            ContactSupportView()
        }
    }
}
```

## Set Up the Navigator

Create a `Navigator` at your app root and inject it into the environment:

```swift
@main
struct MyApp: App {
    @StateObject private var navigator = Navigator<AppRoute>()

    var body: some Scene {
        WindowGroup {
            NavigationStackWrapper(navigator: navigator) {
                HomeView()
            }
            .withNavigator(navigator)
        }
    }
}
```

## Navigate Between Screens

Access the navigator from any child view via `@EnvironmentObject`:

```swift
struct HomeView: View {
    @EnvironmentObject var navigator: Navigator<AppRoute>

    var body: some View {
        VStack {
            Button("View Profile") {
                navigator.navigate(to: .profile(userId: "123"))
            }
            Button("Settings") {
                navigator.navigate(to: .settings)
            }
            Button("Contact Support") {
                navigator.openSheet(.contactSupport)
            }
        }
    }
}
```

## Available Navigation Methods

```swift
navigator.navigate(to: .settings)           // Push one
navigator.navigate(to: [.home, .settings])   // Push multiple
navigator.pop()                              // Pop one
navigator.pop(count: 2)                      // Pop multiple
navigator.popToRoot()                        // Pop all
navigator.popTo(.home)                       // Pop to specific route
navigator.replace(with: [.home, .settings])  // Replace entire stack
navigator.reset()                            // Clear stack and history
navigator.openSheet(.contactSupport)         // Open route as sheet
navigator.dismissSheet()                     // Dismiss current sheet
```

## Inspect the Stack

```swift
navigator.depth          // Number of routes
navigator.currentRoute   // Top of stack (optional)
navigator.isEmpty        // Whether stack is empty
navigator.canPop()       // Whether pop is possible
navigator.history        // Array of NavigationEvent
```
