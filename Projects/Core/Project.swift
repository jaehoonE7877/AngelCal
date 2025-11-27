import ProjectDescription

let project = Project(
    name: "Core",
    targets: [
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.core",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Data", path: "../Data"),
                .project(target: "Shared", path: "../Shared"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
