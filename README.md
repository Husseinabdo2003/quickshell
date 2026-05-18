# Hyprland + Quickshell Desktop

A custom Wayland desktop setup built around Hyprland, Quickshell, Lua-generated Hyprland config, Pywal theming, and native Quickshell UI modules.

The active desktop UI lives in:

```text
~/.config/quickshell
```

The active Hyprland generator, generated config, and system scripts live in:

```text
~/.config/hypr
```

## Table Of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Layout](#repository-layout)
- [Quickshell Entry Point](#quickshell-entry-point)
- [Quickshell Modules](#quickshell-modules)
- [Shared Components](#shared-components)
- [Services](#services)
- [Hyprland Config](#hyprland-config)
- [Lua Generator](#lua-generator)
- [Scripts](#scripts)
- [IPC Commands](#ipc-commands)
- [Keybinds](#keybinds)
- [Data Flow](#data-flow)
- [Theme And Wallpaper Flow](#theme-and-wallpaper-flow)
- [Validation](#validation)
- [Troubleshooting](#troubleshooting)
- [Maintenance Notes](#maintenance-notes)

## Overview

This setup turns Hyprland into a full custom desktop environment:

- Hyprland manages windows, workspaces, input, keybinds, autostart, and session behavior.
- Quickshell renders the bar, popups, launcher, clipboard picker, notifications, OSDs, wallpaper picker, and overview.
- Lua source files generate Hyprland `.conf` files and Quickshell dashboard data.
- Pywal generates colors from the selected wallpaper.
- Shell IPC connects Hyprland keybinds to Quickshell UI actions.

The current workflow avoids Rofi for core desktop actions. The launcher, clipboard picker, dashboard, power menu, notification center, wallpaper picker, and overview are native Quickshell modules.

## Architecture

```text
Hyprland keybind
    -> qs ipc call ...
        -> Quickshell IpcHandler
            -> ShellState singleton
                -> popup/module opens, closes, or runs an action
```

For generated config:

```text
~/.config/hypr/lua/*.lua
    -> ~/.config/hypr/generate.lua
        -> ~/.config/hypr/generated/*.conf
        -> ~/.config/hypr/hyprpaper.conf
        -> ~/.config/hypr/hypridle.conf
        -> ~/.config/hypr/hyprlock.conf
        -> ~/.config/quickshell/data/dashboard.json
```

For wallpaper/theme changes:

```text
Quickshell wallpaper picker
    -> ~/.config/hypr/scripts/wallpaper-picker.lua
        -> hyprpaper wallpaper
        -> wal -i
        -> update-theme.lua
        -> generate.lua
```

## Repository Layout

### Quickshell

```text
~/.config/quickshell
|-- shell.qml
|-- README.md
|-- components/
|-- data/
|   `-- dashboard.json
|-- modules/
|   |-- bar/
|   |-- clipboard/
|   |-- controlCenter/
|   |-- dashboard/
|   |-- launcher/
|   |-- notifications/
|   |-- osd/
|   |-- overview/
|   |-- powermenu/
|   `-- wallpaperPicker/
|-- services/
|-- theme/
`-- widgets/
```

### Hyprland

```text
~/.config/hypr
|-- hyprland.conf
|-- hypridle.conf
|-- hyprlock.conf
|-- hyprpaper.conf
|-- generate.lua
|-- data/
|   `-- dashboard.csv
|-- generated/
|   |-- appearance.conf
|   |-- autostart.conf
|   |-- env.conf
|   |-- input.conf
|   |-- keybinds.conf
|   |-- monitors.conf
|   |-- variables.conf
|   `-- windowrules.conf
|-- lua/
`-- scripts/
```

## Quickshell Entry Point

Main file:

```text
~/.config/quickshell/shell.qml
```

It loads:

- `TopBar`
- `PowerMenu`
- `VolumeOSD`
- `BrightnessOSD`
- `LockOSD`
- `PowerProfileOSD`
- `NotificationPopup`
- `NotificationCenter`
- `WallpaperPicker`
- `AppLauncher`
- `ClipboardPicker`
- `WorkspaceOverview`

It also exposes shell-level IPC:

```bash
qs ipc call shell toggleOverview
qs ipc call shell openOverview
qs ipc call shell closeOverview
qs ipc call shell showPowerProfileOsd
```

## Quickshell Modules

### Bar

Path:

```text
modules/bar/
```

The bar is split into:

- `LeftSection.qml`: workspaces and tray.
- `CenterSection.qml`: clock and media controls.
- `RightSection.qml`: CPU, RAM, network, audio, battery, keyboard, power.
- `TopBar.qml`: panel window and dashboard attachment point.

### Launcher

Path:

```text
modules/launcher/
```

Native app launcher backed by `DesktopEntries`.

IPC:

```bash
qs ipc call launcher toggle
qs ipc call launcher open
qs ipc call launcher close
```

Important files:

- `AppLauncher.qml`: panel UI and app launch behavior.
- `LauncherState.qml`: app loading, search, categories, selection.
- `LauncherList.qml`: result list.
- `LauncherItem.qml`: individual app row/card.

### Clipboard

Path:

```text
modules/clipboard/
```

Native clipboard picker backed by `cliphist`.

IPC:

```bash
qs ipc call clipboard toggle
qs ipc call clipboard open
qs ipc call clipboard close
qs ipc call clipboard reload
qs ipc call clipboard copyMode
qs ipc call clipboard deleteMode
qs ipc call clipboard deleteAll
```

Important files:

- `ClipboardPicker.qml`: UI and keyboard navigation.
- `ClipboardState.qml`: list/copy/delete/wipe commands.
- `ClipboardItem.qml`: row display.

### Dashboard

Path:

```text
modules/dashboard/
```

Task, project, and exam tracker.

IPC:

```bash
qs ipc call dashboard toggle
qs ipc call dashboard open
qs ipc call dashboard close
qs ipc call dashboard reload
```

Important files:

- `Dashboard.qml`: popup window and orchestration.
- `DashboardState.qml`: active category and filtering.
- `DashboardActions.qml`: add/remove actions through Lua scripts.
- `DashboardList.qml`: grouped item display.
- `DashboardAddPopup.qml`: add-item form.
- `UniCard.qml`: dashboard item card.

### Notifications

Path:

```text
modules/notifications/
```

Native notification popup and notification center.

IPC:

```bash
qs ipc call notificationCenter toggle
qs ipc call notificationCenter open
qs ipc call notificationCenter close
qs ipc call notificationCenter clear
```

Important files:

- `NotificationPopup.qml`: transient toast stack.
- `NotificationCenter.qml`: grouped notification panel.
- `NotificationGroupCard.qml`: grouped notification UI.
- `NotificationCard.qml`: notification rendering.
- `services/NotificationService.qml`: notification server, snapshots, grouping, dismissal.

### Wallpaper Picker

Path:

```text
modules/wallpaperPicker/
```

Native wallpaper picker backed by:

```text
~/.config/hypr/scripts/wallpaper-picker.lua
```

IPC:

```bash
qs ipc call wallpaperPicker toggle
qs ipc call wallpaperPicker open
qs ipc call wallpaperPicker close
qs ipc call wallpaperPicker restore
```

Important files:

- `WallpaperPicker.qml`: panel UI.
- `WallpaperActions.qml`: list/apply/restore processes.
- `WallpaperList.qml`: horizontal wallpaper list.
- `WallpaperCard.qml`: wallpaper preview card.

### Overview

Path:

```text
modules/overview/
```

Workspace overview with live window previews and drag-to-workspace behavior.

IPC:

```bash
qs ipc call shell toggleOverview
```

Important files:

- `WorkspaceOverview.qml`: fullscreen overview window.
- `WorkspacePreview.qml`: workspace tile.
- `WindowPreview.qml`: window preview and drag/focus behavior.
- `OverviewConfig.qml`: pinned special workspace labels.

### Power Menu

Path:

```text
modules/powermenu/
```

IPC:

```bash
qs ipc call powerMenu toggle
qs ipc call powerMenu open
qs ipc call powerMenu close
```

Actions:

- Lock: `loginctl lock-session`
- Suspend: `systemctl suspend`
- Reboot: `systemctl reboot`
- Shutdown: `systemctl poweroff`

### OSDs

Path:

```text
modules/osd/
```

IPC:

```bash
qs ipc call volumeOsd show
qs ipc call volumeOsd raise
qs ipc call volumeOsd lower
qs ipc call volumeOsd toggleMute

qs ipc call brightnessOsd show
qs ipc call brightnessOsd raise
qs ipc call brightnessOsd lower

qs ipc call lockOsd caps
qs ipc call lockOsd num

qs ipc call powerProfileOsd show
qs ipc call powerProfileOsd refresh
```

## Shared Components

Path:

```text
components/
```

Common UI building blocks:

- `ActionButton.qml`
- `AnimatedPopupCard.qml`
- `Badge.qml`
- `BarActionPill.qml`
- `BarInfoPill.qml`
- `BarMediaPill.qml`
- `BarPill.qml`
- `Card.qml`
- `Divider.qml`
- `FormInput.qml`
- `HeadingText.qml`
- `IconButton.qml`
- `MetaText.qml`
- `PopupBackdrop.qml`
- `SearchBox.qml`
- `Slider.qml`
- `TitleText.qml`

## Services

Path:

```text
services/
```

Singletons:

- `ShellState.qml`: global popup, OSD, and overview state.
- `NotificationService.qml`: notification server and grouping.
- `DashboardData.qml`: reads generated dashboard JSON.

Module file:

```text
services/qmldir
```

## Hyprland Config

Main file:

```text
~/.config/hypr/hyprland.conf
```

It sources generated files:

```text
source = ~/.cache/wal/colors-hyprland.conf
source = ~/.config/hypr/generated/env.conf
source = ~/.config/hypr/generated/variables.conf
source = ~/.config/hypr/generated/monitors.conf
source = ~/.config/hypr/generated/autostart.conf
source = ~/.config/hypr/generated/windowrules.conf
source = ~/.config/hypr/generated/keybinds.conf
source = ~/.config/hypr/generated/appearance.conf
source = ~/.config/hypr/generated/input.conf
```

Do not manually edit generated files unless you are testing something temporarily. Make persistent changes in `~/.config/hypr/lua/`.

## Lua Generator

Main generator:

```bash
lua ~/.config/hypr/generate.lua
```

Source modules:

```text
~/.config/hypr/lua/appearance.lua
~/.config/hypr/lua/autostart.lua
~/.config/hypr/lua/dashboard.lua
~/.config/hypr/lua/env.lua
~/.config/hypr/lua/hypridle.lua
~/.config/hypr/lua/hyprlock.lua
~/.config/hypr/lua/hyprpaper.lua
~/.config/hypr/lua/input.lua
~/.config/hypr/lua/keybinds.lua
~/.config/hypr/lua/monitors.lua
~/.config/hypr/lua/variables.lua
~/.config/hypr/lua/windowrules.lua
```

Generated outputs:

```text
~/.config/hypr/generated/*.conf
~/.config/hypr/hyprpaper.conf
~/.config/hypr/hypridle.conf
~/.config/hypr/hyprlock.conf
~/.config/quickshell/data/dashboard.json
```

## Scripts

Path:

```text
~/.config/hypr/scripts/
```

Active scripts:

- `dashboard-add.lua`: appends dashboard item data and regenerates.
- `dashboard-remove.lua`: removes dashboard item data and regenerates.
- `power-profile-toggle.lua`: cycles power profile and shows Quickshell OSD.
- `screenshot.lua`: screenshot modes for full, region, copy, edit, and window.
- `update-theme.lua`: converts Pywal colors into Quickshell and GTK/Rofi theme files.
- `wallpaper-picker.lua`: applies wallpaper, runs Pywal, updates theme, regenerates Hypr config.

## IPC Commands

Common commands:

```bash
qs ipc call launcher toggle
qs ipc call clipboard toggle
qs ipc call clipboard deleteMode
qs ipc call dashboard toggle
qs ipc call powerMenu toggle
qs ipc call wallpaperPicker toggle
qs ipc call notificationCenter toggle
qs ipc call shell toggleOverview
```

OSD commands:

```bash
qs ipc call volumeOsd raise
qs ipc call volumeOsd lower
qs ipc call volumeOsd toggleMute
qs ipc call brightnessOsd raise
qs ipc call brightnessOsd lower
qs ipc call lockOsd caps
qs ipc call lockOsd num
qs ipc call shell showPowerProfileOsd
```

## Keybinds

Source:

```text
~/.config/hypr/lua/keybinds.lua
```

Generated:

```text
~/.config/hypr/generated/keybinds.conf
```

Current primary bindings:

| Key | Action |
| --- | --- |
| `SUPER + T` | Open terminal |
| `SUPER + B` | Open browser |
| `SUPER + D` | Toggle app launcher |
| `SUPER + TAB` | Toggle workspace overview |
| `SUPER + E` | Open file manager |
| `SUPER + L` | Lock session |
| `SUPER + ESCAPE` | Toggle power menu |
| `SUPER + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + X` | Toggle floating |
| `SUPER + M` | Exit Hyprland |
| `SUPER + 1..9` | Switch workspace |
| `SUPER + SHIFT + 1..9` | Move window to workspace |
| `SUPER + Left/Right` | Move to previous/next workspace |
| `Print` | Full screenshot |
| `SHIFT + Print` | Region screenshot |
| `CTRL + Print` | Region screenshot to clipboard |
| `ALT + Print` | Active window screenshot |
| `SUPER + Print` | Screenshot editor |
| `SUPER + V` | Clipboard picker |
| `SUPER + SHIFT + V` | Clipboard delete mode |
| `SUPER + ALT + V` | Clear clipboard history |
| `SUPER + N` | Notification center |
| `SUPER + A` | Dashboard |
| `SUPER + Space` | Switch keyboard layout |
| `SUPER + P` | Cycle power profile |
| `SUPER + SHIFT + W` | Wallpaper picker |

Media and hardware keys:

| Key | Action |
| --- | --- |
| `XF86AudioRaiseVolume` | Raise volume and show OSD |
| `XF86AudioLowerVolume` | Lower volume and show OSD |
| `XF86AudioMute` | Toggle mute and show OSD |
| `XF86MonBrightnessUp` | Raise brightness and show OSD |
| `XF86MonBrightnessDown` | Lower brightness and show OSD |
| `XF86AudioPlay` | Play/pause media |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `Caps_Lock` | Show Caps Lock OSD |
| `Num_Lock` | Show Num Lock OSD |

## Data Flow

### Dashboard

Source data:

```text
~/.config/hypr/data/dashboard.csv
```

Generated Quickshell data:

```text
~/.config/quickshell/data/dashboard.json
```

Add/remove flow:

```text
Dashboard UI
    -> DashboardActions.qml
        -> dashboard-add.lua or dashboard-remove.lua
            -> dashboard.csv
            -> generate.lua
            -> dashboard.json
            -> DashboardData.qml reload
```

### Notifications

```text
NotificationServer
    -> NotificationService.qml
        -> NotificationPopup.qml
        -> NotificationCenter.qml
```

Notifications are snapshotted before display so popups can outlive the raw notification object safely.

### Clipboard

```text
wl-paste --watch cliphist store
    -> cliphist list
    -> ClipboardState.qml
    -> cliphist decode | wl-copy
```

## Theme And Wallpaper Flow

Wallpaper picker module:

```text
modules/wallpaperPicker/
```

Backend script:

```text
~/.config/hypr/scripts/wallpaper-picker.lua
```

Theme updater:

```text
~/.config/hypr/scripts/update-theme.lua
```

Generated Quickshell theme:

```text
~/.config/quickshell/theme/WalTheme.qml
```

Wallpaper flow:

```text
Select wallpaper
    -> write ~/.cache/current-wallpaper
    -> copy to ~/Pictures/wallpaper.png
    -> apply through hyprpaper IPC
    -> run wal -i
    -> regenerate WalTheme.qml
    -> regenerate Hyprland config
```

## Validation

Check Quickshell loads:

```bash
timeout 4s quickshell --path ~/.config/quickshell/shell.qml --no-color
```

Check running Quickshell instances:

```bash
qs list
```

Check Hyprland config errors:

```bash
hyprctl configerrors
```

Regenerate Hyprland and dashboard data:

```bash
lua ~/.config/hypr/generate.lua
```

Reload Hyprland:

```bash
hyprctl reload
```

Check Lua syntax:

```bash
find ~/.config/hypr -path ~/.config/hypr/old-backup -prune -o -name '*.lua' -print -exec luac -p {} \;
```

Check Markdown and whitespace in this repo:

```bash
git diff --check
```

## Troubleshooting

### Quickshell IPC Fails

Check whether Quickshell is running:

```bash
qs list
```

Restart Quickshell:

```bash
qs kill
quickshell
```

### Hyprland Reports Config Errors

Run:

```bash
hyprctl configerrors
```

If the error is in `generated/*.conf`, edit the corresponding Lua file in `~/.config/hypr/lua/`, then regenerate:

```bash
lua ~/.config/hypr/generate.lua
hyprctl reload
```

### Wallpaper Does Not Apply

Check:

```bash
pgrep -x hyprpaper
cat ~/.cache/current-wallpaper
hyprctl monitors -j
```

Run the backend directly:

```bash
~/.config/hypr/scripts/wallpaper-picker.lua /path/to/wallpaper.png
```

Log file:

```text
~/.cache/wallpaper-picker.log
```

### Dashboard Does Not Update

Regenerate data:

```bash
lua ~/.config/hypr/generate.lua
qs ipc call dashboard reload
```

Check source data:

```text
~/.config/hypr/data/dashboard.csv
```

Check generated data:

```text
~/.config/quickshell/data/dashboard.json
```

### Clipboard Picker Is Empty

Check that cliphist watchers are running from Hyprland autostart:

```bash
pgrep -af 'wl-paste.*cliphist'
cliphist list
```

### Power Profile OSD Does Not Show

Check:

```bash
powerprofilesctl get
qs ipc call shell showPowerProfileOsd
```

Script log:

```text
~/.cache/power-profile-toggle.log
```

### Screenshots Fail

Required tools:

```text
grim
slurp
wl-copy
jq
notify-send
swappy
```

Run:

```bash
~/.config/hypr/scripts/screenshot.lua full
~/.config/hypr/scripts/screenshot.lua region
~/.config/hypr/scripts/screenshot.lua copy
~/.config/hypr/scripts/screenshot.lua window
~/.config/hypr/scripts/screenshot.lua edit
```

## Maintenance Notes

- Edit Quickshell UI in `~/.config/quickshell`.
- Edit Hyprland source config in `~/.config/hypr/lua`.
- Regenerate Hyprland config after Lua source changes.
- Avoid editing `~/.config/hypr/generated/*.conf` directly.
- Keep active scripts in `~/.config/hypr/scripts`.
- Old backup files under `~/.config/hypr/old-backup` are reference material, not active config.
- The Quickshell repo may show deleted root-level Lua files; the active Lua scripts are in `~/.config/hypr/scripts`.

## Recent Cleanup

Recent maintenance included:

- Centralized media player state in `widgets/MediaPlayerState.qml`.
- Fixed notification group expansion duplication.
- Rebuilt notification groups when tracked notification count changes.
- Allowed overview to show more than five normal workspaces.
- Made wallpaper picker paths use `$HOME`.
- Standardized `services/qmldir`.
- Improved Hypr Lua path handling.
- Added screenshot command success checks.
- Made wallpaper script detect the active monitor.
- Quoted the `qs` path in the power profile script.

## Quick Recovery Commands

```bash
lua ~/.config/hypr/generate.lua
hyprctl configerrors
hyprctl reload
timeout 4s quickshell --path ~/.config/quickshell/shell.qml --no-color
```
