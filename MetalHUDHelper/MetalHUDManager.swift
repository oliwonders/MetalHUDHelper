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

        if result.output.lowercased() == "1"
            || result.output.lowercased() == "true"
        {
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
        let newValue = hudStatus == .enabled ? "NO" : "YES"
        let result = executeCommand(
            "defaults write -g MetalForceHudEnabled -bool \(newValue)"
        )

        if result.success {
            hudStatus = hudStatus == .enabled ? .disabled : .enabled
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
}

// MARK: - private methods
extension MetalHUDManager {

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
