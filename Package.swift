// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VGSCollectSDK",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VGSCollectSDK",
            targets: ["VGSCollectSDK", "VGSPaymentCards"]),
				.library(
						name: "VGSCardScanCollector",
						targets: ["VGSCardScanCollector"]
			),
			.library(
				name: "VGSCardIOCollector",
				targets: ["VGSCardIOCollector"]),
			.library(
				name: "VGSPaymentCards",
				targets: ["VGSPaymentCards"])
    ],
    dependencies: [
			.package(
				name: "CardScan",
				url: "https://github.com/getbouncer/cardscan-ios.git",
				.exact("2.0.9")
			),
			.package(
						name: "CardIOSDK",
						url: "https://github.com/verygoodsecurity/CardIOSDK-iOS.git",
						.exact("5.5.5")
			)
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VGSCollectSDK",
  					exclude: [
							"VGSCollectSDK.h"
	 				]),
        .target(name: "VGSPaymentCards",
                path: "Sources/ VGSPaymentCards/",
                exclude:  [
									"Info.plist",
                  "VGSPaymentCards.h"
                ]
        ),
        .testTarget(
            name: "FrameworkTests",
            dependencies: ["VGSCollectSDK"]
				),
				.target(
						name: "VGSCardScanCollector",
						dependencies: ["VGSCollectSDK",
											.product(name: "CardScan", package: "CardScan")],
						path: "Sources/VGSCardScanCollector/"
		 ),
			.target(
				name: "VGSCardIOCollector",
				dependencies: ["VGSCollectSDK",
											 .product(name: "CardIOSDK", package: "CardIOSDK")],
				path: "Sources/VGSCardIOCollector/")
		]
)
