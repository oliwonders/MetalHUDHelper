//
//  AuthorizationOverlay.swift
//  MetalHUDHelper
//
//  Created by David Oliver on 4/11/25.
//
import SwiftUI

struct AuthorizationOverlay: View {
  var message: String
  var onAuthorize: () -> Void
  var onCancel: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "lock.shield")
        .font(.system(size: 40))
        .foregroundColor(.blue)
        .padding(.bottom, 8)

      Text("Authorization Required")
        .font(.headline)

      Text(message)
        .multilineTextAlignment(.center)
        .frame(maxWidth: 300)

      HStack(spacing: 12) {
        Button("Cancel") {
          onCancel()
        }
        .keyboardShortcut(.cancelAction)

        Button("Authorize") {
          onAuthorize()
        }
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.borderedProminent)
      }
      .padding(.top, 8)
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(NSColor.windowBackgroundColor))
        .shadow(radius: 10)
    )
    .frame(width: 350)
  }
}
