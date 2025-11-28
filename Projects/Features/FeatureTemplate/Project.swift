import ProjectDescription

let project = Project(
    name: "FeatureTemplate",
    targets: [
        .target(
            name: "FeatureTemplate",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featuretemplate",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
