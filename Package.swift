// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VGSCollectSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "VGSCollectSDK",
            targets: ["VGSCollectSDK"]
        )
    ],
    targets: [
        .target(
            name: "VGSCollectSDK",
            exclude: [
                "Info.plist",
                "VGSCollectSDK.h"
            ]
        ),
        .testTarget(
            name: "FrameworkTests",
            dependencies: ["VGSCollectSDK"],
            exclude: [
                "Info.plist"
            ]
        )
    ]
)
