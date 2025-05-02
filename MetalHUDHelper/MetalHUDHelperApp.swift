import AppKit
import Security
import SwiftUI

@main
struct MetalHUDHelperApp: App {

    @Bindable private var hudManager: MetalHUDManager
    @AppStorage("selectedSettingsTab") private var selectedSettingsTab = 0
    @Environment(\.scenePhase) private var scenePhase

    var iconName = "MenuBarIconMono"

    init() {
        self._hudManager = Bindable(MetalHUDManager())
        iconName =
            hudManager.hudStatus == .enabled
            ? "MenuBarIconMono" : "MenuBarIconMono"
    }
    
    var body: some Scene {
        MenuBarExtra(
            "Metal HUD Helper",
            systemImage: hudManager.hudStatus == .enabled ? "cpu.fill" : "cpu"
        ) {
            MenuBarView(hudManager: hudManager)
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                hudManager.checkHUDStatus()
            }
        }
        Settings {
            SettingsView(selectedTab: $selectedSettingsTab)
        }
    }
}
