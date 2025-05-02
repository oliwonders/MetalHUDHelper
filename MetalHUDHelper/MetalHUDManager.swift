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

    // Check if Metal HUD is currently enabled
    func checkHUDStatus() {
        let result = executeCommand(
            "defaults read -g MetalForceHudEnabled 2>/dev/null || echo 0"
        )

        if !result.success {
            print("needs authentication!")
            hudStatus = .needsAuth
        } else if result.output.lowercased() == "1"
            || result.output.lowercased() == "true"
        {
            print("hud enabled")
            hudStatus = .enabled
        } else {
            print("hud disabled")
            hudStatus = .disabled
        }
    }

    // Toggle HUD status
    func toggleHUD() {
        let newValue = hudStatus == .enabled ? "NO" : "YES"
        let result = executeCommand(
            "defaults write -g MetalForceHudEnabled -bool \(newValue)"
        )

        if !result.success {
            // Need authorization
            hudStatus = .needsAuth
        } else {
            // Toggle succeeded, update status
            hudStatus = hudStatus == .enabled ? .disabled : .enabled
        }
    }

    // Authorize and toggle HUD with admin privileges
    func authorizeAndToggleHUD() {
        // Determine desired state (we want to enable if currently disabled or needs auth)
        let newValue = hudStatus == .enabled ? "NO" : "YES"

        // Run with admin privileges
        let scriptText = """
            do shell script "defaults write -g MetalForceHudEnabled -bool \(newValue)" with administrator privileges
            """

        var error: NSDictionary?
        if let script = NSAppleScript(source: scriptText) {
            script.executeAndReturnError(&error)

            if error == nil {
                hudStatus = newValue == "YES" ? .enabled : .disabled
            }
        }
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
    case needsAuth
}

// MARK: - private methods
extension MetalHUDManager {

    //    private func getEnvironmentVariableState(name: String) -> Bool {
    //        let result = executeCommand("launchctl getenv \(name)")
    //        return result.output == "1"
    //    }
    //
    //    private func setEnvironmentVariable(name: String, value: String) {
    //        let result = executeCommand("launchctl setenv \(name) \(value)")
    //        if result.success {
    //            print("Successfully set \(name) to \(value)")
    //        } else {
    //            print("Failed to set environment variable \(name)")
    //        }
    //    }    
    //    private func checkCurrentStates() {
    //        // Run these after init to avoid triggering the didSet during initialization
    //        self.hudStatus = getEnvironmentVariableState(name: "MTL_HUD_ENABLED")
    //        print("isHUDEnabled via environment string: \(isHUDEnabled)")
    //        self.isHUDLoggingEnabled = getEnvironmentVariableState(
    //            name: "MTL_HUD_LOGGING_ENABLED"
    //        )
    //        print(
    //            "isHUDLoggingEnabled via environment string: \(isHUDLoggingEnabled)"
    //        )
    //        self.isGlobalHUDEnabled = getGlobalDefaultsState(
    //            key: "MetalForceHudEnabled"
    //        )
    //        print("isGlobalHUDEnabled via defaults: \(isGlobalHUDEnabled)")
    //    }


    private func executeCommand(_ command: String) -> (
        success: Bool, output: String
    ) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            task.waitUntilExit()
            return (
                task.terminationStatus == 0,
                output.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } catch {
            print("Error executing command: \(error)")
            return (false, "")
        }
    }
}
