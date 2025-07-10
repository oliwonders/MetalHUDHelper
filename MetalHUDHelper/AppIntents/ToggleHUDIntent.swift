// ToggleHUDIntent.swift
// MetalHUDHelper
//
// Created for App Intents integration.

import AppIntents
import Foundation

struct ToggleHUDIntent: AppIntent {
    static let title: LocalizedStringResource = "Toggle Metal HUD"
    static let description = IntentDescription(
        "Enable or disable the Apple Metal HUD."
    )

    @MainActor
    func perform() async throws -> some IntentResult {
        //let manager = MetalHUDManager()
        metalHUDManager.checkHUDStatus()
        if metalHUDManager.hudStatus == .needsAuth {
            // For security, App Intents should avoid prompting for authentication. We return a failure.
            return .result(dialog: "Authorization required to toggle HUD.")
        } else {
            metalHUDManager.toggleHUD()
            return .result(
                dialog: metalHUDManager.hudStatus == .enabled
                    ? "Metal HUD Enabled" : "Metal HUD Disabled"
            )
        }
    }
    @Dependency
    private var metalHUDManager: MetalHUDManager!
}

struct MetalHUDShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {

        AppShortcut(
            intent: ToggleHUDIntent(),
            phrases: [
                "Toggle Metal HUD in \(.applicationName)",
                "Turn Metal HUD on or off in \(.applicationName)",
                "Toggle \(.applicationName)"
            ],
            shortTitle: "Toggle Metal HUD",
            systemImageName: "cpu"
        )

    }
}
