//
//  VirtualMachineGuard.swift
//  MetalHUDHelper
//
//  Keeps the HUD off inside a virtual machine, where enabling it crashes
//  every Metal app.
//

import AppKit

/// Apple's HUD library re-enters itself on the paravirtualized GPU driver and
/// trips a recursive-lock check, so any Metal app crashes on its first frame
/// once the HUD is on. The fault is inside macOS and there is no workaround;
/// the only safe state in a virtual machine is off. See the README.
enum VirtualMachineGuard {

    /// `kern.hv_vmm_present` is 1 when a hypervisor is underneath the OS.
    static var isVirtualMachine: Bool {
        #if DEBUG
        // Lets the guard be exercised on real hardware:
        // set MHH_FORCE_VM=1 in the scheme's environment variables.
        if ProcessInfo.processInfo.environment["MHH_FORCE_VM"] == "1" { return true }
        #endif

        var present: Int32 = 0
        var size = MemoryLayout<Int32>.size
        guard sysctlbyname("kern.hv_vmm_present", &present, &size, nil, 0) == 0 else {
            return false
        }
        return present == 1
    }

    // MARK: - presentation

    /// The user asked to turn the HUD on. It is refused.
    @MainActor
    static func presentEnableBlocked() {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "The Metal HUD can’t be enabled in a virtual machine"
        alert.informativeText = """
            Enabling the Metal HUD on a Mac running inside a virtual machine makes \
            Metal apps crash on their first frame. This is a fault in macOS, not in \
            Metal HUD Helper, and there is no workaround.

            The HUD has been left off. It works normally on real hardware.
            """
        alert.addButton(withTitle: "OK")
        show(alert)
    }

    /// The HUD is already on in a virtual machine, by whatever means.
    /// Returns true if the user chose to turn it off.
    @MainActor
    static func presentHUDAlreadyOn() -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "The Metal HUD is on, and this is a virtual machine"
        alert.informativeText = """
            With the HUD on inside a virtual machine, Metal apps crash on their \
            first frame. Turn it off to stop the crashes.
            """
        alert.addButton(withTitle: "Turn HUD Off")
        alert.addButton(withTitle: "Leave On")
        return show(alert) == .alertFirstButtonReturn
    }

    @MainActor
    @discardableResult
    private static func show(_ alert: NSAlert) -> NSApplication.ModalResponse {
        NSApp.activate()
        return alert.runModal()
    }
}
