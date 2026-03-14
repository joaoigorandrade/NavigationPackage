// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Navigation", targets: ["Navigation"])
    ],
    targets: [
        .target(name: "Navigation"),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"]
        )
    ]
)
