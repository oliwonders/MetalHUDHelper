//
//  MenuBarView.swift
//  MetalHUDHelper
//
//  Created by David Oliver on 4/19/25.
//

import AppKit
import SwiftUI

struct MenuBarView: View {
  @Bindable var hudManager: MetalHUDManager

  var body: some View {
    Label {
      Text(statusText)
    } icon: {
      Image(nsImage: statusIcon)
    }
    .font(.headline)
    Divider()
    Button(hudActionText) {
      hudManager.toggleHUD()
    }
    Divider()
    CustomSettingsLink()
    AboutSettingsButton()
    Divider()

    Button("Quit") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        hudManager.checkHUDStatus()
      }
    }
  }

  /// `MenuBarExtra(.menu)` renders through AppKit, which drops a SwiftUI
  /// `Image` supplied as a `Label` icon and templates whatever it does keep.
  /// Build the symbol as an `NSImage` so the glyph survives, and mark it
  /// non-template so the status color does too.
  var statusIcon: NSImage {
    let (name, color): (String, NSColor) =
      switch hudManager.hudStatus {
      case .enabled: ("checkmark.circle.fill", .systemGreen)
      case .disabled: ("xmark.circle.fill", .systemRed)
      case .unknown: ("questionmark.circle.fill", .systemGray)
      }

    let configuration = NSImage.SymbolConfiguration(
      pointSize: NSFont.systemFontSize,
      weight: .regular
    )
    .applying(NSImage.SymbolConfiguration(paletteColors: [color]))

    guard
      let symbol = NSImage(
        systemSymbolName: name,
        accessibilityDescription: statusText
      ),
      let icon = symbol.withSymbolConfiguration(configuration)
    else {
      return NSImage()
    }
    icon.isTemplate = false
    return icon
  }

  var statusText: String {
    switch hudManager.hudStatus {
    case .unknown:
      return "Checking status..."
    case .enabled:
      return "Metal HUD is enabled"
    case .disabled:
      return "Metal HUD is disabled"
    }
  }

  var hudActionText: String {
    switch hudManager.hudStatus {
    case .unknown:
      return "Check Status"
    case .enabled:
      return "Disable Metal HUD"
    case .disabled:
      return "Enable Metal HUD"
    }
  }
}

#Preview {
  MenuBarView(hudManager: .init())
    .environment(MetalHUDManager())
}
