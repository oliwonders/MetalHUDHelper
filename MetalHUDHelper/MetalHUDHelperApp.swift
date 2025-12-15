import AppKit
import Security
import SwiftUI

@main
struct MetalHUDHelperApp: App {

    @Bindable private var hudManager: MetalHUDManager
    @AppStorage("selectedSettingsTab") private var selectedSettingsTab = 0
    @AppStorage("showFPSInMenuBar") private var showFPSInMenuBar = false
    @Environment(\.scenePhase) private var scenePhase

    var iconName = "MenuBarIconMono"

    init() {
        self._hudManager = Bindable(MetalHUDManager())
        iconName =
            hudManager.hudStatus == .enabled
            ? "MenuBarIconMono" : "MenuBarIconMono"
    }

    var body: some Scene {
        MenuBarExtra("Metal HUD Helper") {
            MenuBarView(hudManager: hudManager)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                hudManager.checkHUDStatus()
            }
        }
        .onChange(of: showFPSInMenuBar) {
            hudManager.updateMonitoringState()
        }
        Settings {
            SettingsView(selectedTab: $selectedSettingsTab)
        }
    }
    
    @ViewBuilder
    private var menuBarLabel: some View {
        if showFPSInMenuBar, let fps = hudManager.currentFPS {
            Text("\(fps) FPS")
                .font(.system(.body, design: .monospaced))
        } else {
            Image(systemName: hudManager.hudStatus == .enabled ? "cpu.fill" : "cpu")
        }
    }
}
