// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UberSegmentedControl",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "UberSegmentedControl",
            targets: ["UberSegmentedControl"]
        ),
    ],
    targets: [
        .target(
            name: "UberSegmentedControl",
            dependencies: []
        ),
        .testTarget(
            name: "UberSegmentedControlTests",
            dependencies: ["UberSegmentedControl"]
        ),
    ]
)
