# MetalHUDHelper

A macOS menu bar app for toggling the Apple Metal performance HUD. Avoids having to execute a command via the Terminal.

![screenshot](images/metalhudhelper.png)

When you want to see the performance HUD, just enable using **MetalHUDHelper** and restart the game or application.

The app is eliminates the need to execute these commands from the terminal:

`defaults write -g MetalForceHudEnabled -bool YES` to enable and `defaults write -g MetalForceHudEnabled -bool NO` to disable.

### Reference

[Discover the Metal Performance HUD WWDC Talk](https://developer.apple.com/videos/play/tech-talks/110339)

## Features

- One-click toggle enabling/disabling the Metal performance HUD
- Status persists after reboot
- App can start on login by enabling "Start at Login" via settings

> **Note**: after toggling, you need quit and relaunch the target application(s) for the changes to take effect

## Requirements

macOS 15.0 or later

## Installation

1. Download the latest `.dmg` from the [Releases](https://github.com/oliwonders/MetalHUDHelper/releases) page
2. Drag **MetalHUDHelper** to your `Applications` folder
3. Launch the app
4. Click the menu bar icon to toggle the Metal Performance HUD on or off
5. Restart any game or application to see the HUD

## Support

Report issues at [GitHub Issues](https://github.com/oliwonders/MetalHUDHelper/issues) page or email [support](mailto:support@oliwonders.com).

Enjoy!

Created by [oli/wonders](https://oliwonders.com)
