//
//  MenuBarView.swift
//  MetalHUDHelper
//
//  Created by David Oliver on 4/19/25.
//

import SwiftUI

struct MenuBarView: View {
  @Bindable var hudManager: MetalHUDManager
  @State private var showingAuthOverlay: Bool = false

  var body: some View {
    Text(statusText)
      .font(.headline)
    Divider()
    Button(hudActionText) {
      if hudManager.hudStatus == .needsAuth {
        showingAuthOverlay = true
      } else {
        hudManager.toggleHUD()
      }
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
    if showingAuthOverlay {
      AuthorizationOverlay(
        message: "Administrator privileges are required to enable or disable the Apple Metal HUD.",
        onAuthorize: {
          hudManager.authorizeAndToggleHUD()
        },
        onCancel: {
          showingAuthOverlay = false
        }
      )
    }
  }

  var statusText: String {
    switch hudManager.hudStatus {
    case .unknown:
      return "Checking status..."
    case .enabled:
      return "Metal HUD is enabled"
    case .disabled:
      return "Metal HUD is disabled"
    case .needsAuth:
      return "Authorization required"
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
    case .needsAuth:
      return "Enable Metal HUD"
    }
  }
}

#Preview {
  MenuBarView(hudManager: .init())
    .environment(MetalHUDManager())
}
