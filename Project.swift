import ProjectDescription

// Minimal root project to accompany existing Workspace.swift
// Keeps targets empty to avoid 중복 생성; workspace manifests handle actual modules.
let project = Project(
    name: "AngelCalRoot",
    packages: [],
    settings: .settings(),
    targets: []
)
