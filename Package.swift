// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppTracking",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "AppTracking",
            targets: ["AppTracking"]),
    ],
    targets: [
        .target(
            name: "AppTracking",
            dependencies: []),
//        .testTarget(
//            name: "AppTrackingTests",
//            dependencies: ["AppTracking"]),
    ]
)
