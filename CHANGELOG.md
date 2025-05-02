# Changelog

All notable changes to MetalHUDHelper will be documented in this file.

---

## [1.0.0] - 2025-04-30
### Added
- macOS MenuBarExtra for toggling the Apple Metal Performance HUD without using the Terminal.
- Persistence across reboots via Global Defaults (`defaults write -g MetalForceHudEnabled`) 
- Start at Login setting so the MetalHUDHelper can be available on startup 
- Automated GitHub Actions pipeline to build, sign, notarize, and publish a `.dmg` on GitHub Releases.

