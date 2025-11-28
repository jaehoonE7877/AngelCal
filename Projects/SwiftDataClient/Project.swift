import ProjectDescription

let project = Project(
    name: "SwiftDataClient",
    targets: [
        .target(
            name: "SwiftDataClient",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.swiftdataclient",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Shared", path: "../Shared"),
            ]
        )
    ]
)
