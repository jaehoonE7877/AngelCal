import ProjectDescription

let project = Project(
    name: "FeatureSettings",
    targets: [
        .target(
            name: "FeatureSettings",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featuresettings",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "FeatureTemplate", path: "../FeatureTemplate"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
