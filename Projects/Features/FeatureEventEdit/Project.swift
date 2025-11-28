import ProjectDescription

let project = Project(
    name: "FeatureEventEdit",
    targets: [
        .target(
            name: "FeatureEventEdit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featureeventedit",
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
