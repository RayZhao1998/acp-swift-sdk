// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "acp-swift-sdk",
  platforms: [.macOS(.v12)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ACP",
      targets: ["ACP"]
    ),
    .executable(
      name: "ACPKimiExample",
      targets: ["Example"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ACP",
    ),
    .executableTarget(
      name: "Example",
      dependencies: ["ACP"]
    ),
    .testTarget(
      name: "ACPTests",
      dependencies: ["ACP"]
    ),
  ]
)
