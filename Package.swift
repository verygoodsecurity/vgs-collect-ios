// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "VGSCollectSDK",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "VGSFramework", targets: ["VGSFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.9.0")
    ],
    targets: [
        .target(
            name: "VGSFramework",
            dependencies: ["Alamofire"],
            path: "framework"
        )
    ]
)
