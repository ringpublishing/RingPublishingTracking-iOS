// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingPublishingTracking",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RingPublishingTracking",
            targets: ["RingPublishingTracking"]
        ),
    ],
    targets: [
        .target(
            name: "RingPublishingTracking"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
