// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Screens",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Configurations",
            targets: ["Configurations"]
        ),
        .library(
            name: "App",
            targets: ["App"]
        ),
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]
        ),
        .library(
            name: "MainScreen",
            targets: ["MainScreen"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: .init(1, 7, 3))),
        .package(path: "../../L2/ServiceLayer"),
        .package(url: "https://github.com/ivlevAstef/DITranquillity.git", .upToNextMajor(from: "4.5.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(path: "../../L0/Components")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Configurations",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DITranquillity"
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Configurations",
                "AppDependencies",
                "DITranquillity",
                "MainScreen"
            ]
        ),
        .target(
            name: "AppDependencies",
            dependencies: [
                "ServiceLayer"
            ]
        ),
        .target(
            name: "MainScreen",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AppDependencies",
                "DITranquillity",
                "ServiceLayer",
                "Kingfisher",
                "Components"
            ],
            resources: [.process("Resources")]
        ),
    ]
)
