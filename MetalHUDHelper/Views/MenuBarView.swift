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
    statusRow
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

  /// macOS 27 draws no menu item image at all: not a SwiftUI `Label` icon,
  /// and not a native `NSMenuItem.image` either. An image interpolated into
  /// the item's text becomes part of the string rather than occupying the
  /// image slot, which is the one form that survives on both 26 and 27.
  /// Concatenating rather than tinting the whole row keeps the color on the
  /// glyph without dragging the label along with it.
  var statusRow: Text {
    let (name, color): (String, Color) =
      switch hudManager.hudStatus {
      case .enabled: ("checkmark.circle.fill", .green)
      case .disabled: ("xmark.circle.fill", .red)
      case .unknown: ("questionmark.circle.fill", .gray)
      }
    return Text(Image(systemName: name)).foregroundStyle(color)
      + Text(" \(statusText)")
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
