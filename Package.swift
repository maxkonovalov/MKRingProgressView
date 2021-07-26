// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MKRingProgressView",
    platforms: [.iOS(.v9), .tvOS(.v9)],
    products: [
        .library(name: "MKRingProgressView", targets: ["MKRingProgressView"])
    ],
    targets: [
        .target(name: "MKRingProgressView", path: "MKRingProgressView")
    ]
)
