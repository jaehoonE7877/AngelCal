import ProjectDescription

let project = Project(
    name: "FeatureSearch",
    targets: [
        .target(
            name: "FeatureSearch",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.featuresearch",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
