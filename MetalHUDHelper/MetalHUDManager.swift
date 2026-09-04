import AppKit
import Foundation
import WidgetKit

@MainActor
@Observable
class MetalHUDManager {

    var hudStatus: HUDStatus = .unknown

    init() {
        checkHUDStatus()
        observeControlRequests()
    }

    // MARK: - public functions
    // Check if Metal HUD is currently enabled.
    func checkHUDStatus() {
        // Resolved the same way Metal resolves it, which puts any per-host
        // value ahead of the global one, so the reported status cannot drift
        // from what Metal actually reads.
        if MetalHUD.isEnabled() {
            print("hud enabled")
            hudStatus = .enabled
        } else {
            print("hud disabled")
            hudStatus = .disabled
        }
    }

    func toggleHUD() {
        setHUD(enabled: hudStatus != .enabled)
    }

    // Writing the value to the global domain
    // (~/Library/Preferences/.GlobalPreferences.plist) is user-owned and
    // does not require administrator privileges.
    func setHUD(enabled: Bool) {
        CFPreferencesSetValue(
            MetalHUD.preferenceCFKey,
            enabled as CFBoolean,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )

        // A per-host value takes precedence over the global one, so a stale
        // one would shadow the write above. Clear it to keep the global
        // domain as the single source of truth.
        CFPreferencesSetValue(
            MetalHUD.preferenceCFKey,
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
        reloadControls()
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

    // MARK: - Control Center

    /// The Control Center control is sandboxed and cannot write the preference
    /// itself, so it posts a Darwin notification and the app performs the write.
    private func observeControlRequests() {
        let darwinCenter = CFNotificationCenterGetDarwinNotifyCenter()

        // A Darwin callback is a bare C function pointer and cannot capture
        // context, so it re-posts onto NotificationCenter where it can.
        let callback: CFNotificationCallback = { _, _, name, _, _ in
            guard let name = name?.rawValue as String? else { return }
            NotificationCenter.default.post(name: Notification.Name(name), object: nil)
        }

        for request in MetalHUD.Request.all {
            CFNotificationCenterAddObserver(
                darwinCenter,
                nil,
                callback,
                request as CFString,
                nil,
                .deliverImmediately
            )

            // The manager lives for the lifetime of the app, so these are
            // never torn down; the closure holds self weakly regardless.
            let enabled = request == MetalHUD.Request.enable
            NotificationCenter.default.addObserver(
                forName: Notification.Name(request),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in self?.setHUD(enabled: enabled) }
            }
        }
    }

    private func reloadControls() {
        if #available(macOS 26.0, *) {
            ControlCenter.shared.reloadAllControls()
        }
    }
}

enum HUDStatus {
    case unknown
    case enabled
    case disabled
}
