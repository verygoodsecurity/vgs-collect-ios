

import PackageDescription

let package = Package(name: "VGSFramework",
                      platforms: [.iOS(.v12)],
                      products: [.library(name: "VGSFramework",
                                          targets: ["VGSFramework"])],
                      targets: [.target(name: "VGSFramework",
                                        path: "framework")],
                      swiftLanguageVersions: [.v5])
