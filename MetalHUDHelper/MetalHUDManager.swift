import AppKit
import Foundation
import SwiftUI

@MainActor
@Observable
class MetalHUDManager {

    var hudStatus: HUDStatus = .unknown
    var currentFPS: Int?
    var frontmostAppName: String?
    
    @ObservationIgnored
    @AppStorage("showFPSInMenuBar") private var showFPSInMenuBar = false
    
    private var logMonitor: Process?
    private var logPipe: Pipe?
    private var lastFPSUpdate: Date = .distantPast
    private var workspaceObserver: NSObjectProtocol?

    init() {
        checkHUDStatus()
        setupFrontmostAppTracking()
        startMonitoringIfNeeded()
    }
    
    deinit {
        stopFPSMonitoring()
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
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
            updateMonitoringState()
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
                updateMonitoringState()
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
    
    // MARK: - FPS Monitoring
    
    func startMonitoringIfNeeded() {
        if showFPSInMenuBar && hudStatus == .enabled {
            startFPSMonitoring()
        }
    }
    
    func updateMonitoringState() {
        if showFPSInMenuBar && hudStatus == .enabled {
            if logMonitor == nil {
                startFPSMonitoring()
            }
        } else {
            stopFPSMonitoring()
        }
    }
    
    private func setupFrontmostAppTracking() {
        // Update initial frontmost app
        updateFrontmostApp()
        
        // Listen for app activation changes
        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateFrontmostApp()
        }
    }
    
    private func updateFrontmostApp() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            frontmostAppName = frontApp.localizedName
        } else {
            frontmostAppName = nil
        }
    }
    
    func startFPSMonitoring() {
        // Don't start if already running
        guard logMonitor == nil else { return }
        
        print("Starting FPS monitoring...")
        
        let process = Process()
        process.launchPath = "/usr/bin/log"
        process.arguments = [
            "stream",
            "--predicate", "subsystem CONTAINS 'metal' OR subsystem CONTAINS 'Metal'",
            "--style", "compact"
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe() // Ignore stderr
        
        // Set up async reading
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            guard !data.isEmpty else { return }
            
            if let output = String(data: data, encoding: .utf8) {
                Task { @MainActor in
                    self.parseFPSFromLog(output)
                }
            }
        }
        
        do {
            try process.run()
            self.logMonitor = process
            self.logPipe = pipe
            print("FPS monitoring started successfully")
        } catch {
            print("Error starting FPS monitoring: \(error)")
            currentFPS = nil
        }
    }
    
    func stopFPSMonitoring() {
        guard let process = logMonitor else { return }
        
        print("Stopping FPS monitoring...")
        
        // Clear readability handler safely
        if let pipe = logPipe {
            do {
                pipe.fileHandleForReading.readabilityHandler = nil
            } catch {
                // File handle may already be closed, ignore error
            }
        }
        
        // Terminate the process
        if process.isRunning {
            process.terminate()
        }
        
        logMonitor = nil
        logPipe = nil
        currentFPS = nil
        
        print("FPS monitoring stopped")
    }
    
    private func parseFPSFromLog(_ logOutput: String) {
        // Debounce updates - only update once per second
        let now = Date()
        guard now.timeIntervalSince(lastFPSUpdate) >= 1.0 else { return }
        
        // Regex patterns to match FPS values
        // Using case-insensitive matching, so simplified patterns cover all variants
        let patterns = [
            #"fps[:\s]+(\d+\.?\d*)"#,  // Matches "fps: 60", "FPS 60", etc.
            #"(\d+\.?\d*)\s*fps"#       // Matches "60 fps", "60 FPS", etc.
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = logOutput as NSString
                if let match = regex.firstMatch(in: logOutput, range: NSRange(location: 0, length: nsString.length)) {
                    if match.numberOfRanges > 1 {
                        let fpsString = nsString.substring(with: match.range(at: 1))
                        if let fpsValue = Double(fpsString) {
                            currentFPS = Int(round(fpsValue))
                            lastFPSUpdate = now
                            return
                        }
                    }
                }
            }
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
