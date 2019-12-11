// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "VGSCollectSDK",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(name: "VGSFramework", targets: ["VGSFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("4.9.1"))
    ],
    targets: [
        .target(
            name: "VGSFramework",
            dependencies: ["Alamofire"],
            path: "framework",
            exclude: [
                "Tests",
                "Carthage",
                "Podfile",
                "Podfile.lock",
                "../demoapp"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
