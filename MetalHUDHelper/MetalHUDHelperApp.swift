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
            if #available(macOS 26.0, *) {
                MenuBarView(hudManager: hudManager)
                    .glassEffect(.regular)
            } else {
                MenuBarView(hudManager: hudManager)
            }
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                hudManager.checkHUDStatus()
                updateSharedStatus()
            }
        }
        .onOpenURL { url in
            handleURLScheme(url)
        }
        Settings {
            SettingsView(selectedTab: $selectedSettingsTab)
        }
    }
    
    private func handleURLScheme(_ url: URL) {
        guard url.scheme == "metalhudhelper" else { return }
        
        switch url.host {
        case "open":
            // Widget tapped - bring app to foreground and update status
            NSApp.activate(ignoringOtherApps: true)
            hudManager.checkHUDStatus()
            updateSharedStatus()
        default:
            break
        }
    }
    
    private func updateSharedStatus() {
        let sharedStatus: SharedHUDStatus
        switch hudManager.hudStatus {
        case .enabled:
            sharedStatus = .enabled
        case .disabled:
            sharedStatus = .disabled
        default:
            sharedStatus = .unknown
        }
        SharedHUDStatusManager.setCurrentStatus(sharedStatus)
    }
}
