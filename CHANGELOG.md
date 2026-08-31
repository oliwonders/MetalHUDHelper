# Changelog

All notable changes to MetalHUDHelper will be documented in this file.

---

## [1.2.1] - 2026-08-31

### Fixed

- The status glyph next to "Metal HUD is enabled" disappeared on macOS 27 Golden Gate and never rendered in color on macOS 26. The glyph now renders on both macOS 26 Tahoe and 27 Golden Gate (beta 7).

### Added

- The About tab now shows the build date alongside the version.

### Changed

- The release workflow commits the version numbers it derives from the tag back to `main`, so the project file records what was actually released instead of drifting until bumped it by hand.

## [1.2.0] - 2026-08-31

### Fixed

- The HUD could stay off even while the menu bar reported it as enabled. `MetalForceHudEnabled` can exist in two preference host scopes, and a per-host value silently takes precedence over the global one, so a stale per-host setting overrode every write the app made. Toggling now clears any per-host value, keeping the global domain as the single source of truth.
- The reported status now reflects what Metal actually reads. The status check consulted only the global domain, so it could not see a per-host value shadowing it and would report "enabled" while the HUD was off.

### Changed

- The HUD preference is now read and written through `CFPreferences` directly instead of shelling out to `/bin/bash` and `defaults`. Reads go through the same resolution Metal performs, so the reported status cannot drift, and the app no longer depends on spawning a subprocess.

### Removed

- The `AuthorizationOverlay` view, the `.needsAuth` HUD state, and the `authorizeAndToggleHUD()` AppleScript ("with administrator privileges") code path.

## [1.1.3] - 2025-07-13

### Changed

- Menu bar and Settings UI refreshed for the new HIG: glass effect on the menu bar view and Settings buttons, button styles matched to their actions, an image representing HUD status, and icons on the About buttons for clarity.

### Removed

- The experimental App Intent for toggling the HUD. An intent cannot call out to a shell script, which is how the toggle worked at the time.
- macOS 26-specific code, for CI compatibility.

## [1.1.1] / [1.1.2] - 2025-06-25

No code changes. Both tags point at the same commit (`8c1a647`), which predates 1.1.0 — they were re-tags made while working through the icon and archive build failures that 1.1.0 resolved. Neither was published as a release.

## [1.1.0] - 2025-07-07

### Added

- New app icon authored with Icon Composer (`AppIcon.icon`).

### Changed

- Project settings updated for Xcode 26.
- `CFBundleGetInfoString` added to `Info.plist` ("Menubar tool to toggle Apple's Metal HUD").

### Fixed

- Missing app icon in archived builds. Icon Composer's `.icon` file did not populate `CFBundleIconName` in `Info.plist`, leaving it empty.

### Removed

- The superseded `MenuBarIconColor` and `MenuBarIconMono` iconsets.
- Explicit `com.apple.security.app-sandbox` and `com.apple.security.files.user-selected.read-only` keys from the entitlements file, which is now empty. Both were already governed by the corresponding build settings.

## [1.0.2] - 2025-05-15

### Added

- Initial Homebrew Cask support with automatic version bumping from tags
- GitHub Actions workflow for notarizing and releasing `.dmg` and `.app.zip`
- Livecheck support in the Cask for update discovery

### Changed

- Internal versioning now uses the git tag (e.g. `v1.2.0`) to update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`
- Release job now includes automatic upload to GitHub and auto-updates the Cask repo

## [1.0.1] - 2025-05-03

### Changed

- source formatting
- fixed issue that Settings/About dialog would not always be promoted forefront

## [1.0.0] - 2025-05-03

### Added

- macOS MenuBarExtra for toggling the Apple Metal Performance HUD without using the Terminal.
- Persistence across reboots via Global Defaults (`defaults write -g MetalForceHudEnabled`)
- Start at Login setting so the MetalHUDHelper can be available on startup
- Automated GitHub Actions pipeline to build, sign, notarize, and publish a `.dmg` on GitHub Releases.
