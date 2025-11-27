import ProjectDescription

let baseSettings: SettingsDictionary = .init()
    .automaticCodeSigning(devTeam: "RFHV927M8S")

let project = Project(
    name: "AngelCal",
    options: .options(
        defaultKnownRegions: ["ko"],
        xcodeProjectName: "AngelCal"
    ),
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
                    "SupabaseURL": "$(SUPABASE_URL)",
                    "SupabaseAnonKey": "$(SUPABASE_ANON_KEY)",
                ]
            ),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .project(target: "Data", path: "../Data"),
                .project(target: "SwiftDataClient", path: "../SwiftDataClient"),
                .project(target: "SupabaseClient", path: "../SupabaseClient"),
                .project(target: "FeatureMain", path: "../Features/FeatureMain"),
                .project(target: "DSKit", path: "../DSKit"),
                .external(name: "ComposableArchitecture"),
                .external(name: "Supabase"),
            ],
            settings: .settings(
                base: baseSettings,
                configurations: [
                    .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Secrets.xcconfig")
                ]
            )
        )
    ]
)
