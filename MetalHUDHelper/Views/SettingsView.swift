//
//  SettingsView.swift
//  MetalHUDHelper
//
//  Created by David Oliver on 4/14/25.
//

import AppKit
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
  @Binding var selectedTab: Int
  @Environment(\.dismiss) private var dismiss
  @AppStorage("selectedSettingsTab") private var selectedSettingsTab = SettingsTab.general

  var body: some View {
    TabView(selection: $selectedSettingsTab) {
      Tab("General", systemImage: "gear", value: .general) {
        GeneralSettingsTab()
      }
      Tab("About", systemImage: "info.circle", value: .about) {
        AboutTab()
      }
    }
    .scenePadding()
    .frame(maxWidth: 450, minHeight: 100)
  }
}

struct GeneralSettingsTab: View {
  @AppStorage("startAtLogin") private var startAtLogin = false

  var body: some View {
    Form {
      Section {
        LaunchAtLogin.Toggle("Start Metal HUD Helper at login")
        Text("Automatically launch the app when you sign in to your Mac.")
          .font(.footnote)
          .foregroundColor(.secondary)
          .padding(.leading, 4)
      }
    }
    .formStyle(.grouped)
    .padding()
  }
}

struct AboutTab: View {
  @State private var showAcknowledgments = false
  private let version =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .center, spacing: 16) {
        Image(nsImage: NSApp.applicationIconImage)
          .resizable()
          .frame(width: 128, height: 128)
          .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
          Text("Metal HUD Helper")
            .font(.custom("Futura", size: 22).weight(.bold))
          Text("Version \(version)")
            .foregroundStyle(.secondary)
        }
      }
      Divider()
      HStack(alignment: .center, spacing: 16) {
        Button("Acknowledgments") {
          showAcknowledgments = true
        }
        Button("Contact Me") {
          openEmail(to: "support@oliwonders.com")
        }
        Button("My Site") {
          openSite(address: "https://oliwonders.com")
        }

      }
      Divider()
      Text("© oli/wonders 2025. All rights reserved.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .sheet(isPresented: $showAcknowledgments) {
      AcknowledgmentsView()
    }
  }

  private func openEmail(to address: String) {
    let subject = "Support for Metal HUD Helper"
    let url = URL(
      string:
        "mailto:\(address)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    )
    if let url = url {
      NSWorkspace.shared.open(url)
    }
  }
  private func openSite(address: String) {
    let url = URL(string: address)
    if let url = url {
      NSWorkspace.shared.open(url)
    }
  }
}

struct AboutSettingsButton: View {
  @AppStorage("selectedSettingsTab") private var selectedSettingsTab = SettingsTab.general

  @Environment(\.openSettings) private var openSettings

  var body: some View {
    Button("About Metal HUD Helper…") {
      selectedSettingsTab = .about
      openSettings()
    }
  }
}

enum SettingsTab: Int {
  case general
  case about
}

struct AcknowledgmentsView: View {
  @Environment(\.dismiss) private var dismiss
  private let markdown = """
    **Acknowledgments**

    Portions of this software utilize the following copyrighted material, hereby acknowledged:

    **LaunchAtLogin**  
    Copyright © Sindre Sorhus (<sindresorhus@gmail.com>)  
    [sindresorhus.com](https://sindresorhus.com)

    **GPU Icons**  
    Created by [Good Ware](https://www.flaticon.com/authors/good-ware) —  via [Flaticon](https://www.flaticon.com/free-icons/gpu)
    """

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text(.init(markdown))
            .padding()
        }
      }

      Divider()

      HStack {
        Spacer()
        Button("Close") {
          dismiss()
        }
        .keyboardShortcut(.cancelAction)
        .padding()
      }
    }
    .frame(minWidth: 400, minHeight: 240)
  }
}

// Preview provider
struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(selectedTab: .constant(0))
  }
}
