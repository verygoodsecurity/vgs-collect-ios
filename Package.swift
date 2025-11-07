// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VGSCollectSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VGSCollectSDK",
            targets: ["VGSCollectSDK"]),
        .library(
          name: "VGSCardIOCollector",
          targets: ["VGSCardIOCollector"]),
        .library(
          name: "VGSBlinkCardCollector",
          targets: ["VGSBlinkCardCollector"])
    ],
    dependencies: [
        // Updated to new requirement API (exact:) to silence deprecation warnings.
        .package(url: "https://github.com/verygoodsecurity/CardIOSDK-iOS.git", exact: "5.5.7"),
        .package(url: "https://github.com/blinkcard/blinkcard-swift-package", exact: "2.12.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VGSCollectSDK",
            exclude: [
              "Info.plist",
              "VGSCollectSDK.h"
            ],
            // Added processing of Resources directory (including CardIcon.xcassets) to silence unhandled resource warning.
            resources: [
              .copy("PrivacyInfo.xcprivacy"),
              .process("Resources")
            ]),
        .testTarget(
            name: "FrameworkTests",
            dependencies: ["VGSCollectSDK"],
            exclude: [
              "Info.plist",
              "FrameworkTests.xctestplan"
            ],
            resources: [.process("Resources")]),
        .target(
          name: "VGSCardIOCollector",
          dependencies: ["VGSCollectSDK",
                         .product(name: "CardIOSDK", package: "CardIOSDK-iOS")],
          path: "Sources/VGSCardIOCollector/"),
        .target(
            name: "VGSBlinkCardCollector",
            dependencies: ["VGSCollectSDK",
                      .product(name: "BlinkCard", package: "blinkcard-swift-package")],
            path: "Sources/VGSBlinkCardCollector/")
        ]
)
