import AppKit
import Foundation

@MainActor
@Observable
class MetalHUDManager {

    var hudStatus: HUDStatus = .unknown

    init() {
        checkHUDStatus()
    }

    // MARK: - public functions
    // Check if Metal HUD is currently enabled.
    func checkHUDStatus() {
        // CFPreferencesCopyAppValue walks the full preference search list,
        // which puts the per-host value ahead of the global one. That is the
        // same resolution Metal performs, so the reported status cannot drift
        // from what Metal actually reads.
        let value = CFPreferencesCopyAppValue(
            Self.hudKey,
            kCFPreferencesAnyApplication
        )

        if (value as? NSNumber)?.boolValue == true {
            print("hud enabled")
            hudStatus = .enabled
        } else {
            print("hud disabled")
            hudStatus = .disabled
        }
    }

    // Toggle HUD status. Writing the value to the global domain
    // (~/Library/Preferences/.GlobalPreferences.plist) is user-owned and
    // does not require administrator privileges.
    func toggleHUD() {
        let newValue = hudStatus != .enabled

        CFPreferencesSetValue(
            Self.hudKey,
            newValue as CFBoolean,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )

        // A per-host value takes precedence over the global one, so a stale
        // one would shadow the write above. Clear it to keep the global
        // domain as the single source of truth.
        CFPreferencesSetValue(
            Self.hudKey,
            nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )

        guard CFPreferencesAppSynchronize(kCFPreferencesAnyApplication) else {
            print("error setting hud status")
            return
        }

        // Re-read rather than assume, so the menu reflects what actually landed.
        checkHUDStatus()
    }

    func openConsoleWithMetalFilter() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "Console", "--args", "--filter", "metal"]

        do {
            try task.run()
            print("Opening Console.app with Metal filter")
        } catch {
            print("Error opening Console.app: \(error)")
        }
    }
}

enum HUDStatus {
    case unknown
    case enabled
    case disabled
}

// MARK: - private constants
extension MetalHUDManager {
    fileprivate static let hudKey = "MetalForceHudEnabled" as CFString
}
