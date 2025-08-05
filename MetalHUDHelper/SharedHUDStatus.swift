//
//  SharedHUDStatus.swift
//  MetalHUDHelper
//
//  Created for Widget Extension integration
//

import Foundation

public enum SharedHUDStatus: String, CaseIterable {
    case unknown = "unknown"
    case enabled = "enabled" 
    case disabled = "disabled"
    
    var displayText: String {
        switch self {
        case .unknown:
            return "Checking status..."
        case .enabled:
            return "Metal HUD is enabled"
        case .disabled:
            return "Metal HUD is disabled"
        }
    }
    
    var systemImage: String {
        switch self {
        case .unknown:
            return "questionmark.circle.fill"
        case .enabled:
            return "cpu.fill"
        case .disabled:
            return "cpu"
        }
    }
    
    var isEnabled: Bool {
        return self == .enabled
    }
}

public class SharedHUDStatusManager {
    private static let userDefaults = UserDefaults(suiteName: "group.com.oliwonders.MetalHUDHelper")
    private static let statusKey = "MetalHUDStatus"
    
    public static func getCurrentStatus() -> SharedHUDStatus {
        guard let userDefaults = userDefaults,
              let statusString = userDefaults.string(forKey: statusKey),
              let status = SharedHUDStatus(rawValue: statusString) else {
            return .unknown
        }
        return status
    }
    
    public static func setCurrentStatus(_ status: SharedHUDStatus) {
        userDefaults?.set(status.rawValue, forKey: statusKey)
    }
    
    public static func checkSystemHUDStatus() -> SharedHUDStatus {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "defaults read -g MetalForceHudEnabled 2>/dev/null || echo 0"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedOutput.lowercased() == "1" || trimmedOutput.lowercased() == "true" {
                    return .enabled
                } else {
                    return .disabled
                }
            }
        } catch {
            print("Error checking HUD status: \(error)")
        }
        
        return .unknown
    }
}