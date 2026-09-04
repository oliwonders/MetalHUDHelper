//
//  MetalHUDControlWidget.swift
//  MetalHUDHelperWidget
//

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
        .displayName("Toggle Metal HUD")
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
