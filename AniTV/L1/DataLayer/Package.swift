// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]),
    ],
    dependencies: [
        .package(name: "Common", path: "../../L0/Common"),
        .package(url: "https://github.com/ivlevAstef/DITranquillity.git", .upToNextMajor(from: "4.5.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataLayer",
            dependencies: ["Common", "DITranquillity"]
        ),
        .testTarget(
            name: "DataLayerTests",
            dependencies: ["DataLayer"]),
    ]
)
