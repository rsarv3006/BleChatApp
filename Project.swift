import ProjectDescription

let project = Project(
    name: "BleChatApp",
    targets: [
        .target(
            name: "BleChatApp",
            destinations: .iOS,
            product: .app,
            bundleId: "rjs.app.dev.BleChatApp",
            deploymentTargets: DeploymentTargets.iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "NSBluetoothAlwaysUsageDescription": "This app uses Bluetooth to connect to other devices.",
                    "NSBluetoothPeripheralUsageDescription": "This app uses Bluetooth to connect to other devices.",
                ]
            ),
            sources: ["BleChatApp/Sources/**"],
            resources: ["BleChatApp/Resources/**"],
            dependencies: [.target(name: "CbShared")]
        ),
        .target(
            name: "BleChatAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "rjs.app.dev.BleChatAppTests",
            deploymentTargets: DeploymentTargets.iOS("16.0"),
            infoPlist: .default,
            sources: ["BleChatApp/Tests/**"],
            resources: [],
            dependencies: [.target(name: "BleChatApp")]
        ),
        .target(
            name: "CbShared",
            destinations: .iOS,
            product: .framework,
            bundleId: "rjs.app.dev.CbShared",
            deploymentTargets: DeploymentTargets.iOS("16.0"),
            sources: ["CbShared/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "CbSharedTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "rjs.app.dev.CbSharedTests",
            deploymentTargets: DeploymentTargets.iOS("16.0"),
            sources: ["CbShared/Tests/**"],
            dependencies: [.target(name: "CbShared")]
        ),
    ]
)
