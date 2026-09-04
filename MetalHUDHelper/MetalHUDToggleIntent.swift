//
//  MetalHUDToggleIntent.swift
//  MetalHUDHelper
//
//  Compiled into both the app and the Control Center widget extension. It has
//  to exist in the app too: when the extension cannot get the job done it asks
//  to continue in the foreground, and the continuation runs in the app.
//

import AppIntents
import Foundation

@available(macOS 26.0, *)
struct SetMetalHUDIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle Metal HUD"
    static let description = IntentDescription("Turn Apple's Metal performance HUD on or off.")

    /// `.foreground(.dynamic)` keeps this in the background for the normal case
    /// and lets it pull the app forward only when the write went nowhere.
    static var supportedModes: IntentModes { [.background, .foreground(.dynamic)] }

    @Parameter(title: "Enabled")
    var value: Bool

    init() {}

    func perform() async throws -> some IntentResult {
        // The extension is sandboxed and cannot write the global domain, so it
        // asks the app to. If the app is not running nobody is listening, and
        // the preference simply never changes.
        MetalHUD.post(value ? MetalHUD.Request.enable : MetalHUD.Request.disable)
        if await MetalHUD.awaitState(value) {
            return .result()
        }

        try await continueInForeground(
            IntentDialog("Metal HUD Helper needs to be running to change this. Open it?")
        )

        // Running in the app now. Re-send, since the request that was posted a
        // moment ago had no listener, and give the app a beat to come up.
        MetalHUD.post(value ? MetalHUD.Request.enable : MetalHUD.Request.disable)
        guard await MetalHUD.awaitState(value, timeout: .seconds(5)) else {
            throw SetMetalHUDError.couldNotReachApp
        }
        return .result()
    }
}

enum SetMetalHUDError: Error, CustomLocalizedStringResourceConvertible {
    case couldNotReachApp

    var localizedStringResource: LocalizedStringResource {
        "Could not reach Metal HUD Helper. Open the app and try again."
    }
}
