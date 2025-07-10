// ToggleHUDIntent.swift
// MetalHUDHelper
//
// Created for App Intents integration.

import AppIntents
import Foundation

struct ToggleHUDIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Metal HUD"
    static var description = IntentDescription("Enable or disable the Apple Metal HUD.")

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = MetalHUDManager()
        manager.checkHUDStatus()
        if manager.hudStatus == .needsAuth {
            // For security, App Intents should avoid prompting for authentication. We return a failure.
            return .result(dialog: "Authorization required to toggle HUD.")
        } else {
            manager.toggleHUD()
            return .result(dialog: manager.hudStatus == .enabled ? "Metal HUD Enabled" : "Metal HUD Disabled")
        }
    }
}

struct MetalHUDShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: ToggleHUDIntent(),
                phrases: ["Toggle Metal HUD", "Turn Metal HUD on or off"],
                shortTitle: "Toggle Metal HUD",
                systemImageName: "cpu"
            )
            .suggestedInvocationPhrase("Toggle Metal HUD")
        ]
    }
}
