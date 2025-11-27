import ProjectDescription

let project = Project(
    name: "AngelCal",
    targets: [
        .target(
            name: "AngelCal",
            destinations: .iOS,
            product: .app,
            bundleId: "com.angelcal.app",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            dependencies: [
                .project(target: "DSKit", path: "../DSKit"),
                .external(name: "ComposableArchitecture"),
                .external(name: "Supabase"),
            ]
        )
    ]
)
