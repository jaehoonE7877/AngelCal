import ProjectDescription

let project = Project(
    name: "Shared",
    targets: [
        .target(
            name: "Shared",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.shared",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: []
        )
    ]
)
