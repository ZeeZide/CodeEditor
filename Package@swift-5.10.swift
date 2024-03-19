// swift-tools-version:5.10

import PackageDescription

let package = Package(
  
  name: "CodeEditor",

  platforms: [
    .macOS(.v10_15), .iOS(.v13), .visionOS(.v1), .watchOS(.v7), .tvOS(.v12)
  ],

  products: [
    .library(name: "CodeEditor", targets: [ "CodeEditor" ])
  ],
  
  dependencies: [
    // Temporary, until upstream PR is merged.
    //.package(url: "https://github.com/raspu/Highlightr", from: "2.1.2")
    .package(url: "https://github.com/helje5/Highlightr", from: "3.0.2")
  ],
           
  targets: [
    .target(name: "CodeEditor", dependencies: [ "Highlightr" ])
  ]
)
