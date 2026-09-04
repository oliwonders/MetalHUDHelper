//
//  MetalHUDShared.swift
//  MetalHUDHelper
//
//  Compiled into both the app and the Control Center widget extension.
//

import Foundation

/// The contract between the app and the Control Center control.
///
/// The widget extension is sandboxed; the app is not. A sandboxed process can
/// *read* the global preference domain but cannot write it — the write is
/// dropped and `CFPreferencesAppSynchronize` returns false. So the control
/// renders state from its own read, and asks the app to perform the write.
enum MetalHUD {

    static let preferenceKey = "MetalForceHudEnabled"

    /// `CFString` is not `Sendable`, so the constant is stored as a `String`
    /// and bridged at each use rather than held as a static.
    static var preferenceCFKey: CFString { preferenceKey as CFString }

    /// Darwin notifications cross the sandbox boundary and need no entitlement,
    /// but they carry no payload. One name per desired state, rather than a
    /// single "toggle", keeps the request idempotent: a duplicate delivery
    /// cannot flip the HUD back.
    enum Request {
        static let enable = "com.oliwonders.MetalHUDHelper.enableHUD"
        static let disable = "com.oliwonders.MetalHUDHelper.disableHUD"

        static var all: [String] { [enable, disable] }
    }

    /// Reads through the same resolution Metal performs, so the reported value
    /// cannot drift from what Metal actually uses. Safe inside the sandbox.
    static func isEnabled() -> Bool {
        let value = CFPreferencesCopyAppValue(preferenceCFKey, kCFPreferencesAnyApplication)
        return (value as? NSNumber)?.boolValue == true
    }

    /// Re-reads after asking `cfprefsd` to drop what it has cached. Without the
    /// synchronize, a reader in another process keeps seeing its own stale copy
    /// and a successful write looks like a failure.
    static func isEnabledUncached() -> Bool {
        _ = CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        return isEnabled()
    }

    /// Polls until the preference reaches `desired`, which is how a caller that
    /// cannot write finds out whether anyone acted on its request.
    static func awaitState(_ desired: Bool, timeout: Duration = .milliseconds(1500)) async -> Bool {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            if isEnabledUncached() == desired { return true }
            try? await Task.sleep(for: .milliseconds(50))
        }
        return isEnabledUncached() == desired
    }

    static func post(_ request: String) {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(request as CFString),
            nil,
            nil,
            true
        )
    }
}
