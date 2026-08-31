//
//  MetalHUDControlWidget.swift
//  MetalHUDHelperWidget
//

import AppIntents
import SwiftUI
import WidgetKit

@available(macOS 26.0, *)
struct MetalHUDControlWidget: ControlWidget {
    static let kind = "com.oliwonders.MetalHUDHelper.MetalHUDControlWidget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind, provider: Provider()) { isEnabled in
            ControlWidgetToggle(
                "Metal HUD",
                isOn: isEnabled,
                action: SetMetalHUDIntent()
            ) { isOn in
                Label(isOn ? "Metal HUD On" : "Metal HUD Off",
                      systemImage: isOn ? "cpu.fill" : "cpu")
            }
        }
        .displayName("Metal HUD")
        .description("Toggle Apple's Metal performance HUD.")
    }

    /// Reading the preference directly is allowed inside the sandbox, so the
    /// control reflects the real value without needing an App Group.
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }

        func currentValue() async throws -> Bool {
            MetalHUD.isEnabled()
        }
    }
}

/// The write itself is impossible here — a sandboxed process cannot modify the
/// global domain — so this only asks the app to do it.
@available(macOS 26.0, *)
struct SetMetalHUDIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle Metal HUD"
    static let description = IntentDescription("Turn Apple's Metal performance HUD on or off.")

    @Parameter(title: "Enabled")
    var value: Bool

    init() {}

    func perform() async throws -> some IntentResult {
        MetalHUD.post(value ? MetalHUD.Request.enable : MetalHUD.Request.disable)
        return .result()
    }
}
