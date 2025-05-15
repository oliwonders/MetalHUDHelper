# Changelog

All notable changes to MetalHUDHelper will be documented in this file.

---

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
