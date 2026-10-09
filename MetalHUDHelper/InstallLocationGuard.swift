//
//  InstallLocationGuard.swift
//  MetalHUDHelper
//
//  Offers to move the app into Applications when it is launched from
//  somewhere else, such as a mounted disk image or the Desktop.
//

import AppKit

/// The Control Center control needs the app at a stable, readable path. From a
/// disk image or a translocated copy the path is read-only and random, and in a
/// TCC-protected folder like ~/Desktop or ~/Downloads the control renders but
/// can't toggle, because linkd can't read its intent metadata. Installing in
/// Applications avoids all of these.
enum InstallLocationGuard {

    private static let suppressKey = "suppressMoveToApplications"

    /// True when the bundle sits in /Applications or ~/Applications (or a
    /// folder inside either).
    static var isInApplications: Bool {
        let path = Bundle.main.bundleURL.resolvingSymlinksInPath().path
        let userApplications = FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Applications").path
        return path.hasPrefix("/Applications/") || path.hasPrefix(userApplications + "/")
    }

    /// Call once at launch, after NSApp exists.
    @MainActor
    static func offerMoveIfNeeded() {
        #if DEBUG
        // Xcode runs from DerivedData, which works fine for development.
        let skip = true
        #else
        let skip = false
        #endif

        guard !skip, !isInApplications,
              !UserDefaults.standard.bool(forKey: suppressKey) else { return }

        let alert = NSAlert()
        alert.messageText = "Move Metal HUD Helper to the Applications folder?"
        alert.informativeText = """
            Metal HUD Helper is running from outside Applications. From there, \
            the Control Center control can fail to toggle the HUD, and macOS may \
            run the app from a temporary location.
            """
        alert.addButton(withTitle: "Move to Applications")
        alert.addButton(withTitle: "Not Now")
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "Don’t ask again"

        NSApp.activate()
        let response = alert.runModal()
        if alert.suppressionButton?.state == .on {
            UserDefaults.standard.set(true, forKey: suppressKey)
        }
        guard response == .alertFirstButtonReturn else { return }

        do {
            let installed = try install()
            relaunch(from: installed)
        } catch {
            let failure = NSAlert(error: error)
            failure.messageText = "Couldn’t move Metal HUD Helper"
            failure.runModal()
        }
    }

    // MARK: - moving

    /// Copies the running bundle into /Applications, falling back to
    /// ~/Applications when that isn't writable.
    private static func install() throws -> URL {
        let fm = FileManager.default
        let source = Bundle.main.bundleURL
        let name = source.lastPathComponent

        let systemApplications = URL(filePath: "/Applications", directoryHint: .isDirectory)
        let userApplications = fm.homeDirectoryForCurrentUser
            .appending(path: "Applications", directoryHint: .isDirectory)

        var lastError: Error?
        for directory in [systemApplications, userApplications] {
            do {
                try fm.createDirectory(at: directory, withIntermediateDirectories: true)
                let destination = directory.appending(path: name)
                if fm.fileExists(atPath: destination.path) {
                    try fm.trashItem(at: destination, resultingItemURL: nil)
                }
                try fm.copyItem(at: source, to: destination)
                trashOriginalIfPossible(source)
                return destination
            } catch {
                lastError = error
            }
        }
        throw lastError ?? CocoaError(.fileWriteUnknown)
    }

    /// A disk image or translocated copy is read-only and can't be trashed,
    /// which is fine: only a real, writable original is cleaned up.
    private static func trashOriginalIfPossible(_ url: URL) {
        let isReadOnly = (try? url.resourceValues(forKeys: [.volumeIsReadOnlyKey]))?
            .volumeIsReadOnly ?? true
        guard !isReadOnly, !url.path.contains("/AppTranslocation/") else { return }
        try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
    }

    private static func relaunch(from url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, _ in
            DispatchQueue.main.async { NSApp.terminate(nil) }
        }
    }
}
