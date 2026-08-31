# MetalHUDHelper

[![Homebrew Cask](https://img.shields.io/badge/Homebrew-metalhudhelper-6f4e99?logo=homebrew&logoColor=white)](https://brew.sh/)

A macOS menu bar app for toggling the Apple Metal performance HUD system wide. Avoids having to execute commands via the Terminal.

![screenshot](images/metalhudhelper.png)

When you want to see the performance HUD, just enable using **MetalHUDHelper** and restart the game or application.

The app eliminates the need to execute these commands from the terminal:

`defaults write -g MetalForceHudEnabled -bool YES` to enable and `defaults write -g MetalForceHudEnabled -bool NO` to disable.

### How it works

**MetalHUDHelper** reads and writes the `MetalForceHudEnabled` preference in the global domain (`~/Library/Preferences/.GlobalPreferences.plist`) through `CFPreferences` directly, rather than shelling out to `defaults`. This is a user-owned preference, so toggling never requires administrator privileges.

Reads go through the same preference resolution Metal itself performs. macOS can hold this key in two host scopes, and a per-host value silently takes precedence over the global one, so the app clears any per-host value when you toggle — keeping the global domain authoritative.

### Reference

[Discover the Metal Performance HUD WWDC Talk](https://developer.apple.com/videos/play/tech-talks/110339)

## Features

- One-click toggle enabling/disabling the Metal performance HUD system wide
- Status persists after reboot
- App can start on login by enabling "Start at Login" via settings

> **Note**: after toggling, you need quit and relaunch the target application(s) for the changes to take effect

### Troubleshooting

If the HUD still does not appear after relaunching, check for a stale per-host value, which overrides the global setting:

```sh
# should report that the domain/default pair does not exist
defaults -currentHost read -g MetalForceHudEnabled

# clears it if it is set
defaults -currentHost delete -g MetalForceHudEnabled
```

Toggling in **MetalHUDHelper** clears this for you, so you should only need this if the HUD was set up by other means.

## Requirements

macOS 15.0 or later

## Installation

You can install **MetalHUDHelper** using either of the following options:

### Option 1: Manual install via dmg

1. Download the latest `.dmg` from the [Releases](https://github.com/oliwonders/MetalHUDHelper/releases) page
2. Drag **MetalHUDHelper** to your `Applications` folder

### Option 2: Homebrew

```sh
brew tap oliwonders/tap
brew install --cask metalhudhelper
```

Then launch **MetalHUDHelper** from your Applications folder.

> After installing, click the menu bar icon and toggle the Metal Performance HUD on or off. Restart any game or application to see the HUD take effect.

## Support

Report issues at [GitHub Issues](https://github.com/oliwonders/MetalHUDHelper/issues) page or email [support](mailto:support@oliwonders.com).

Enjoy!

Created by [oli/wonders](https://oliwonders.com)
