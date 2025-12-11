//
//  MetalHUDControlWidget.swift
//  MetalHUDHelperWidget
//
//  Created by David Oliver on 8/10/25.
//

import AppIntents
import SwiftUI
import WidgetKit
import Foundation

// Shared types for widget extension
public enum SharedHUDStatus: String, CaseIterable, Sendable {
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
    private static let statusKey = "MetalHUDStatus"
    
    private static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.oliwonders.MetalHUDHelper")
    }
    
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
}

// ControlWidget for Metal HUD toggle - available in macOS 26.0+ and iOS 18.0+
@available(macOS 26.0, iOS 18.0, *)
struct MetalHUDControlWidget: ControlWidget {
    static let kind: String = "com.oliwonders.MetalHUDHelper.MetalHUDControlWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: MetalHUDControlProvider()
        ) { value in
            ControlWidgetToggle(
                "Metal HUD",
                isOn: value.isEnabled,
                action: ToggleMetalHUDIntent()
            ) { isEnabled in
                Label {
                    Text("Metal HUD")
                } icon: {
                    Image(systemName: isEnabled ? "cpu.fill" : "cpu")
                        .foregroundStyle(isEnabled ? .green : .secondary)
                }
            }
        }
        .displayName("Metal HUD")
        .description("Toggle Metal HUD display on or off")
    }
}

@available(macOS 26.0, iOS 18.0, *)
extension MetalHUDControlWidget {
    struct Value {
        var isEnabled: Bool
    }

    struct MetalHUDControlProvider: AppIntentControlValueProvider {
        func previewValue(configuration: MetalHUDControlConfiguration) -> Value {
            MetalHUDControlWidget.Value(isEnabled: false)
        }

        func currentValue(configuration: MetalHUDControlConfiguration) async throws -> Value {
            let currentStatus = SharedHUDStatusManager.getCurrentStatus()
            return MetalHUDControlWidget.Value(isEnabled: currentStatus.isEnabled)
        }
    }
}

@available(macOS 26.0, iOS 18.0, *)
struct MetalHUDControlConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Metal HUD Configuration"
    static let description = IntentDescription("Configure Metal HUD control widget")
}

@available(macOS 26.0, iOS 18.0, *)
struct ToggleMetalHUDIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle Metal HUD"
    static let description = IntentDescription("Toggle Metal HUD display on or off")

    @Parameter(title: "HUD Enabled")
    var value: Bool

    init() {}

    func perform() async throws -> some IntentResult {
        // Update the shared status
        let newStatus: SharedHUDStatus = value ? .enabled : .disabled
        SharedHUDStatusManager.setCurrentStatus(newStatus)
        
        // Try to set the system preference
        await updateSystemHUDSetting(enabled: value)
        
        return .result()
    }
    
    private func updateSystemHUDSetting(enabled: Bool) async {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write", "-g", "MetalForceHudEnabled", enabled ? "1" : "0"]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error setting Metal HUD system preference: \(error)")
        }
    }
}
