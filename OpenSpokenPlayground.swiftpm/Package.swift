// swift-tools-version: 5.7

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
  name: "OpenSpoken",
  platforms: [
    .iOS("16.0")
  ],
  products: [
    .iOSApplication(
      name: "OpenSpoken",
      targets: ["AppModule"],
      displayVersion: "1.0",
      bundleVersion: "1",
      appIcon: .placeholder(icon: .mic),
      accentColor: .presetColor(.cyan),
      supportedDeviceFamilies: [
        .pad,
        .phone,
      ],
      supportedInterfaceOrientations: [
        .portrait,
        .landscapeRight,
        .landscapeLeft,
        .portraitUpsideDown(.when(deviceFamilies: [.pad])),
      ],
      capabilities: [
        .speechRecognition(purposeString: "Use speech recognition to trasncribe audio."),
        .microphone(purposeString: "Use micrphone input to transcribe audio."),
      ],
      appCategory: .utilities
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Amzd/ScrollViewProxy", .branch("master")),
    .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", .exact("0.1.4")),
  ],
  targets: [
    .executableTarget(
      name: "AppModule",
      dependencies: [
        .product(name: "ScrollViewProxy", package: "scrollviewproxy"),
        .product(name: "Introspect", package: "swiftui-introspect"),
      ],
      path: "."
    )
  ]
)
