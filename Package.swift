// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataClient",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "CoreDataClient",
            targets: ["CoreDataClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoreDataClient",
            dependencies: []),
        .testTarget(
            name: "CoreDataClientTests",
            dependencies: ["CoreDataClient"]),
    ]
)
