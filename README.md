# Hyprland + Quickshell Setup

A custom Wayland desktop setup built around **Hyprland**, **Quickshell**, **Lua-generated Hyprland configs**, **Pywal theming**, and a fully custom popup/launcher/dashboard system.

This configuration replaces the usual external menu workflow with native Quickshell UI modules for the app launcher, clipboard history, wallpaper picker, power menu, notifications, dashboard, OSDs, and workspace overview.

---

## Table of Contents

- [Overview](#overview)
- [Main Features](#main-features)
- [Architecture](#architecture)
- [Quickshell Structure](#quickshell-structure)
- [Hyprland Structure](#hyprland-structure)
- [Core Quickshell Files](#core-quickshell-files)
- [Shared Components](#shared-components)
- [Services](#services)
- [Modules](#modules)
- [Hyprland Lua Generator](#hyprland-lua-generator)
- [Scripts](#scripts)
- [Keybinds](#keybinds)
- [Theme System](#theme-system)
- [Wallpaper System](#wallpaper-system)
- [Clipboard System](#clipboard-system)
- [Dashboard System](#dashboard-system)
- [Notification System](#notification-system)
- [Power Profile OSD](#power-profile-osd)
- [Lock Screen](#lock-screen)
- [Troubleshooting](#troubleshooting)
- [Backup Commands](#backup-commands)
- [Future Improvements](#future-improvements)

---

## Overview

This setup is designed to make Hyprland feel like a complete custom desktop environment rather than just a window manager.

The main idea is:

- Hyprland handles windows, workspaces, keybinds, and system-level behavior.
- Quickshell handles the visible desktop UI.
- Lua generates the Hyprland configuration files.
- Pywal extracts colors from the current wallpaper.
- Generated theme files update Quickshell, Hyprland, Hyprlock, and related visuals.

The setup is modular. Most features live in their own Quickshell module or Lua config file, making the system easier to edit and extend.

---

## Main Features

### Quickshell UI

- Custom top bar.
- Custom app launcher replacing Rofi.
- Custom clipboard picker replacing Rofi clipboard menus.
- Custom dashboard for university/project tasks.
- Custom wallpaper picker.
- Custom power menu.
- Notification popup and notification center.
- Workspace overview with live window previews.
- Volume, brightness, lock-state, and power-profile OSDs.
- Media controls that only appear when media exists.
- Shared popup manager through `ShellState.qml`.

### Hyprland

- Lua-based config generator.
- Modular generated config files.
- Custom keybinds.
- Pywal-based colors.
- Lock screen that follows wallpaper/theme colors.
- Screenshot system.
- Power profile toggle.
- Wallpaper switching pipeline.
- Default Hyprland fallback wallpaper disabled.

### Removed/Replaced

- Rofi app launcher replaced with Quickshell launcher.
- Rofi clipboard picker replaced with Quickshell clipboard picker.
- Rofi removed from active workflow.
- Thunderbird removed.
- Hyprland default splash/logo fallback disabled.

---

## Architecture

The setup is split into two main parts:

```text
~/.config/quickshell/
    Quickshell UI, modules, services, components, theme files

~/.config/hypr/
    Hyprland configs, Lua generator, scripts, generated files
```

The Hyprland side starts Quickshell, Hyprpaper, Hypridle, clipboard watchers, and the rest of the environment.

Quickshell then provides the desktop UI and responds to IPC calls such as:

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

---

## Quickshell Structure

Expected structure:

```text
~/.config/quickshell/
├── shell.qml
├── components/
│   ├── ActionButton.qml
│   ├── AnimatedPopupCard.qml
│   ├── Badge.qml
│   ├── BarActionPill.qml
│   ├── Card.qml
│   ├── Divider.qml
│   ├── HeadingText.qml
│   ├── IconButton.qml
│   ├── MetaText.qml
│   ├── PopupBackdrop.qml
│   ├── PopupPanel.qml
│   ├── SearchBox.qml
│   └── TitleText.qml
├── services/
│   ├── ShellState.qml
│   ├── NotificationService.qml
│   └── other service files
├── theme/
│   ├── Theme.qml
│   └── WalTheme.qml
├── modules/
│   ├── bar/
│   ├── clipboard/
│   ├── dashboard/
│   ├── launcher/
│   ├── notifications/
│   ├── osd/
│   ├── overview/
│   ├── powermenu/
│   └── wallpaperPicker/
└── data/
    └── dashboard.json
```

---

## Hyprland Structure

Expected structure:

```text
~/.config/hypr/
├── hyprland.conf
├── hyprpaper.conf
├── hyprlock.conf
├── hypridle.conf
├── generate.lua
├── lua/
│   ├── appearance.lua
│   ├── autostart.lua
│   ├── dashboard.lua
│   ├── env.lua
│   ├── hypridle.lua
│   ├── hyprlock.lua
│   ├── hyprpaper.lua
│   ├── input.lua
│   ├── keybinds.lua
│   ├── monitors.lua
│   ├── variables.lua
│   └── windowrules.lua
├── generated/
│   ├── appearance.conf
│   ├── autostart.conf
│   ├── env.conf
│   ├── input.conf
│   ├── keybinds.conf
│   ├── monitors.conf
│   ├── variables.conf
│   └── windowrules.conf
├── scripts/
│   ├── dashboard-add.lua
│   ├── dashboard-remove.lua
│   ├── power-profile-toggle.lua
│   ├── screenshot.lua
│   ├── update-theme.lua
│   └── wallpaper-picker.lua
└── data/
    └── dashboard.csv
```

---

## Core Quickshell Files

### `shell.qml`

Main Quickshell entry point.

It loads all main modules:

- `TopBar`
- `PowerMenu`
- OSD modules
- `NotificationPopup`
- `NotificationCenter`
- `WallpaperPicker`
- `Dashboard`
- `AppLauncher`
- `ClipboardPicker`
- `WorkspaceOverview`

It also exposes the main shell IPC target:

```qml
IpcHandler {
    target: "shell"
}
```

Important IPC calls:

```bash
qs ipc call shell toggleOverview
qs ipc call shell openOverview
qs ipc call shell closeOverview
qs ipc call shell showPowerProfileOsd
```

---

## Shared Components

### `Card.qml`

The base visual container used across the setup.

Used for:

- Launcher panel
- Power menu panel
- Clipboard panel
- Dashboard panel
- Notification cards
- Wallpaper cards
- OSD containers

It provides consistent rounded corners, borders, background color, and theme integration.

### `AnimatedPopupCard.qml`

Reusable animated popup card.

Used for centered popups such as:

- App launcher
- Clipboard picker
- Power menu

It handles:

- Open/close opacity.
- Open/close scale.
- Layer caching for smoother animations.
- Shared popup color/border/radius settings.

### `PopupBackdrop.qml`

Reusable dimmed full-screen background.

Used by:

- Launcher
- Clipboard picker
- Power menu
- Wallpaper picker
- Workspace overview

It provides:

- Theme-consistent dim overlay.
- Click outside to close.
- Shared fade animation.

### `SearchBox.qml`

Reusable search input.

Used by:

- Launcher
- Clipboard picker
- Wallpaper picker

It handles text input, focus, and `onAccepted` behavior.

### `BarActionPill.qml`

Reusable pill button for the top bar.

Used by media actions and small bar controls.

### Text Components

- `HeadingText.qml`: large section titles.
- `TitleText.qml`: item titles.
- `MetaText.qml`: muted/subtitle text.
- `Badge.qml`: small pill labels/counts.
- `IconButton.qml`: icon-only buttons.
- `ActionButton.qml`: text buttons.
- `Divider.qml`: visual separator.

These keep the UI visually consistent.

---

## Services

### `ShellState.qml`

The global UI state manager.

It controls which popup is open and prevents overlapping windows.

Main state properties:

```qml
property bool launcherOpen
property bool dashboardOpen
property bool powerMenuOpen
property bool notificationCenterOpen
property bool wallpaperPickerOpen
property bool clipboardOpen
property bool overviewOpen
```

It provides open/close/toggle functions like:

```qml
openLauncher()
closeLauncher()
toggleLauncher()

openClipboard()
closeClipboard()
toggleClipboard()

openDashboard()
closeDashboard()
toggleDashboard()
```

The key behavior is that opening one main popup closes the others.

### `NotificationService.qml`

Manages notifications.

Responsible for:

- Receiving notifications.
- Grouping notifications by app.
- Expanding/collapsing groups.
- Dismissing notifications.
- Clearing app groups.
- Clearing all notifications.

Used by:

- Notification popup.
- Notification center.
- Notification group cards.

---

## Modules

## Bar Module

Folder:

```text
~/.config/quickshell/modules/bar/
```

### `TopBar.qml`

Main top panel.

It hosts:

- Workspaces.
- Current window title.
- Media module.
- Media previous/next controls.
- System indicators.
- Tray.
- Dashboard/launcher controls depending on configuration.

The dashboard component itself should not be instantiated inside `TopBar.qml`; it should only exist once in `shell.qml` to avoid duplicate IPC handlers.

### `Media.qml`

Displays current media information from MPRIS.

Usually shows:

- Track title.
- Artist.
- Play/pause state.

### `MediaPrev.qml` and `MediaNext.qml`

Previous and next media buttons.

They should only be visible when an MPRIS player has a valid track loaded.

This prevents the previous/next controls from always showing when nothing is playing.

### `Tray.qml`

System tray module.

Displays tray icons when available.

---

## Launcher Module

Folder:

```text
~/.config/quickshell/modules/launcher/
```

### `AppLauncher.qml`

Custom Quickshell app launcher replacing Rofi.

Features:

- Opens with `SUPER + D`.
- Uses `DesktopEntries.applications.values`.
- Search input.
- Categories.
- Keyboard navigation.
- Click/Enter to launch apps.
- Uses `PopupBackdrop` and `AnimatedPopupCard`.
- Uses `ShellState.launcherOpen`.

IPC:

```bash
qs ipc call launcher toggle
qs ipc call launcher open
qs ipc call launcher close
```

### `LauncherState.qml`

State and filtering logic for the launcher.

Responsible for:

- Loading desktop entries.
- Retrying initial load if entries are empty.
- Filtering by search query.
- Filtering by category.
- Managing selected index.
- Moving selection up/down.

The retry logic fixes the bug where the first launcher open showed no apps.

### `LauncherItem.qml`

Visual app item.

Displays:

- App icon.
- App name.
- Metadata/comment.
- Selected/hover states.

### `LauncherHeader.qml`

Top section of the launcher.

Usually contains title, result count, and close button.

### `LauncherCategories.qml`

Category selector for filtering apps.

---

## Clipboard Module

Folder:

```text
~/.config/quickshell/modules/clipboard/
```

### `ClipboardPicker.qml`

Custom clipboard picker replacing Rofi clipboard menus.

Modes:

- Copy mode: `SUPER + V`
- Delete mode: `SUPER + SHIFT + V`

Features:

- Search clipboard history.
- Keyboard navigation.
- Enter/click to copy selected item.
- Delete selected item in delete mode.
- Delete all option.
- Uses shared `PopupBackdrop` and `AnimatedPopupCard`.
- Uses `ShellState.clipboardOpen`.

IPC:

```bash
qs ipc call clipboard toggle
qs ipc call clipboard open
qs ipc call clipboard close
qs ipc call clipboard copyMode
qs ipc call clipboard deleteMode
qs ipc call clipboard deleteAll
qs ipc call clipboard reload
```

### `ClipboardState.qml`

Clipboard logic.

Responsible for:

- Running `cliphist list`.
- Filtering clipboard items.
- Copying selected item using `cliphist decode | wl-copy`.
- Deleting selected item using `cliphist delete`.
- Wiping clipboard history using `cliphist wipe`.

### `ClipboardItem.qml`

Visual list item for clipboard history.

Uses:

- `Card`
- `TitleText`
- `MetaText`
- `Badge`

---

## Dashboard Module

Folder:

```text
~/.config/quickshell/modules/dashboard/
```

The dashboard is a custom university/project panel.

It is designed to show:

- University tasks.
- Project deadlines.
- Quiz dates.
- Exam dates.
- Other schedule entries.

### `Dashboard.qml`

Main dashboard popup.

Features:

- Slides down when opened.
- Slides up smoothly when closed.
- Uses manual cached animation for smoothness.
- Uses `ShellState.dashboardOpen`.
- Loads dashboard data from generated Quickshell data.
- Has add item popup.
- Has remove item actions.

IPC:

```bash
qs ipc call dashboard toggle
qs ipc call dashboard open
qs ipc call dashboard close
```

### `DashboardState.qml`

Controls dashboard view state.

Responsible for:

- Active category.
- Add category.
- Default type.
- Filtering dashboard items.
- Category titles.

### `DashboardActions.qml`

Connects UI actions to backend scripts.

Used for:

- Adding items.
- Removing items.
- Reloading dashboard data.

### `DashboardData.qml`

Loads generated dashboard JSON data.

The Hyprland Lua generator creates:

```text
~/.config/quickshell/data/dashboard.json
```

from dashboard data.

### Other Dashboard Components

- `DashboardHeader.qml`
- `DashboardTabs.qml`
- `DashboardCategoryHeader.qml`
- `DashboardList.qml`
- `DashboardAddPopup.qml`

These split the dashboard UI into reusable parts.

---

## Power Menu Module

Folder:

```text
~/.config/quickshell/modules/powermenu/
```

### `PowerMenu.qml`

Custom full-screen power menu.

Actions:

- Lock
- Suspend
- Reboot
- Shutdown

Uses:

- `ShellState.powerMenuOpen`
- `PopupBackdrop`
- `AnimatedPopupCard`

IPC:

```bash
qs ipc call powerMenu toggle
qs ipc call powerMenu open
qs ipc call powerMenu close
```

### `PowerAction.qml`

Individual power button.

All power actions use the same visual style as the lock action, with no aggressive red danger styling.

---

## Notification Module

Folder:

```text
~/.config/quickshell/modules/notifications/
```

### `NotificationPopup.qml`

Shows live notification popups.

Behavior:

- New notifications slide in.
- Multiple notifications stack.
- New notifications push old ones down.
- Old notifications slide out individually.

### `NotificationCenter.qml`

Notification side panel.

Features:

- Opens with `SUPER + N`.
- Groups notifications by app.
- Clear all button.
- Uses old styling preserved from the original design.
- Uses `ShellState.notificationCenterOpen`.
- Uses manual cached slide animation for smooth close behavior.

IPC:

```bash
qs ipc call notificationCenter toggle
qs ipc call notificationCenter open
qs ipc call notificationCenter close
qs ipc call notificationCenter clear
```

### `NotificationGroupCard.qml`

A grouped notification card.

Allows:

- Expanding group.
- Collapsing group.
- Clearing group.
- Dismissing individual notifications.

---

## Wallpaper Picker Module

Folder:

```text
~/.config/quickshell/modules/wallpaperPicker/
```

### `WallpaperPicker.qml`

Custom bottom wallpaper picker.

Features:

- Opens with `SUPER + SHIFT + W`.
- Slides from the bottom.
- Search wallpapers.
- Scroll through wallpapers.
- Click to apply wallpaper.
- Uses old styling preserved.
- Uses `ShellState.wallpaperPickerOpen`.
- Uses `PopupBackdrop`.

IPC:

```bash
qs ipc call wallpaperPicker toggle
qs ipc call wallpaperPicker open
qs ipc call wallpaperPicker close
qs ipc call wallpaperPicker restore
```

### `WallpaperActions.qml`

Backend action bridge.

Responsible for:

- Listing wallpapers.
- Reading current wallpaper.
- Applying selected wallpaper.
- Restoring wallpaper at startup.

### `WallpaperList.qml`

Displays wallpaper cards.

### `WallpaperHeader.qml`

Top section of the wallpaper picker.

---

## OSD Modules

Folder:

```text
~/.config/quickshell/modules/osd/
```

### `VolumeOSD.qml`

Shows volume changes.

Triggered by:

```bash
qs ipc call volumeOsd raise
qs ipc call volumeOsd lower
qs ipc call volumeOsd toggleMute
```

### `BrightnessOSD.qml`

Shows brightness changes.

Triggered by:

```bash
qs ipc call brightnessOsd raise
qs ipc call brightnessOsd lower
```

### `LockOSD.qml`

Shows lock-state changes such as Caps Lock and Num Lock.

Triggered by:

```bash
qs ipc call lockOsd caps
qs ipc call lockOsd num
```

### `PowerProfileOSD.qml`

Shows the current power profile after toggling.

Reads:

```text
~/.cache/power-profile-mode
```

or falls back to:

```bash
powerprofilesctl get
```

The OSD is triggered by:

```bash
qs ipc call shell showPowerProfileOsd
```

---

## Overview Module

Folder:

```text
~/.config/quickshell/modules/overview/
```

### `WorkspaceOverview.qml`

Full-screen workspace overview.

Features:

- Opens with `SUPER + TAB`.
- Shows normal workspaces.
- Shows special workspaces.
- Uses `PopupBackdrop`.
- Uses `ShellState.overviewOpen`.
- Supports window focus from overview.
- Supports drag behavior for windows.

IPC:

```bash
qs ipc call shell toggleOverview
```

### `WorkspacePreview.qml`

Shows each workspace tile.

Responsible for:

- Workspace title.
- Windows inside workspace.
- Drop/focus interactions.

### `WindowPreview.qml`

Shows individual window preview inside overview.

Uses Hyprland/Wayland screencopy when possible.

It includes guards to avoid zero-size screencopy buffer warnings.

### `OverviewConfig.qml`

Configuration for pinned special workspaces and labels.

---

# Hyprland Lua Generator

The Hyprland config is generated from Lua modules.

Main entry point:

```text
~/.config/hypr/generate.lua
```

It generates:

```text
~/.config/hypr/generated/env.conf
~/.config/hypr/generated/variables.conf
~/.config/hypr/generated/monitors.conf
~/.config/hypr/generated/autostart.conf
~/.config/hypr/generated/windowrules.conf
~/.config/hypr/generated/appearance.conf
~/.config/hypr/generated/keybinds.conf
~/.config/hypr/generated/input.conf
~/.config/hypr/hyprpaper.conf
~/.config/hypr/hypridle.conf
~/.config/hypr/hyprlock.conf
~/.config/quickshell/data/dashboard.json
```

Run generation manually:

```bash
cd ~/.config/hypr
lua generate.lua
hyprctl reload
```

---

## Hyprland Config Files

### `hyprland.conf`

Main Hyprland entry file.

It sources:

- Pywal colors.
- Environment config.
- Variables.
- Monitor config.
- Autostart config.
- Window rules.
- Keybinds.
- Appearance config.
- Input config.

### `lua/env.lua`

Generates environment variables.

Used for:

- Wayland session settings.
- Nvidia variables.
- Browser Wayland support.

### `lua/variables.lua`

Defines reusable command variables such as:

- Terminal.
- Menu command.
- Screenshot script.
- Power profile script.
- Wallpaper picker command.

### `lua/monitors.lua`

Generates monitor layout.

Current basic behavior:

```conf
monitor = ,preferred,auto,1
```

### `lua/autostart.lua`

Starts background services.

Important services:

- `hypridle`
- `hyprpaper`
- `quickshell`
- `wl-paste --type text --watch cliphist store`
- `wl-paste --type image --watch cliphist store`

### `lua/windowrules.lua`

Sets workspace rules for apps.

Examples:

- VS Code to workspace 4.
- Discord to workspace 5.
- Spotify to special workspace `music`.

### `lua/keybinds.lua`

Generates all keybinds.

Important keybinds include:

```text
SUPER + T             terminal
SUPER + B             Brave
SUPER + D             Quickshell launcher
SUPER + TAB           workspace overview
SUPER + E             Files
SUPER + L             lock session
SUPER + S             Spotify
SUPER + C             VS Code
SUPER + ESC           power menu
SUPER + SHIFT + W     wallpaper picker
SUPER + V             clipboard copy mode
SUPER + SHIFT + V     clipboard delete mode
SUPER + N             notification center
SUPER + P             power profile toggle
```

### `lua/appearance.lua`

Generates visual settings.

Controls:

- Gaps.
- Borders.
- Blur.
- Window opacity.
- Animations.
- Hyprland fallback background.

It disables Hyprland default fallback visuals:

```conf
disable_hyprland_logo = yes
disable_splash_rendering = yes
force_default_wallpaper = 0
background_color = rgb(000000)
```

This prevents the original Hyprland wallpaper/logo from appearing when no wallpaper daemon is running.

### `lua/input.lua`

Generates keyboard and touchpad input settings.

Includes:

```conf
kb_layout = us,ara
natural_scroll = true
```

### `lua/hyprpaper.lua`

Generates Hyprpaper config.

Controls:

- `ipc`
- `splash`
- preloaded wallpapers
- startup wallpaper

### `lua/hyprlock.lua`

Generates Hyprlock config.

The lock screen follows wallpaper/theme colors.

### `lua/hypridle.lua`

Generates Hypridle config.

Controls:

- Lock after idle.
- DPMS off after idle.
- Suspend after longer idle.

### `lua/dashboard.lua`

Generates dashboard JSON for Quickshell.

Output:

```text
~/.config/quickshell/data/dashboard.json
```

---

## Scripts

Folder:

```text
~/.config/hypr/scripts/
```

### `wallpaper-picker.lua`

Backend script for wallpaper switching.

Flow:

1. Validate selected wallpaper.
2. Save selected path to cache.
3. Copy selected wallpaper to `~/Pictures/wallpaper.png`.
4. Apply wallpaper through Hyprpaper IPC.
5. Run Pywal.
6. Update theme files.
7. Regenerate Hyprland/Hyprlock configs.

Important: this script currently uses:

```bash
hyprctl hyprpaper wallpaper "eDP-1,/path/to/wallpaper"
```

without `reload` and without `,cover`, because the installed Hyprpaper version rejects those IPC forms.

### `update-theme.lua`

Generates theme files from Pywal colors.

Outputs include:

- GTK theme CSS.
- Quickshell `WalTheme.qml`.

After removing Rofi from the active workflow, Rofi theme generation is no longer needed.

### `power-profile-toggle.lua`

Cycles power profile using `powerprofilesctl`.

Cycle:

```text
balanced -> power-saver -> performance -> balanced
```

Writes current profile to:

```text
~/.cache/power-profile-mode
```

Then triggers Quickshell OSD.

### `screenshot.lua`

Screenshot helper.

Modes:

- full
- region
- copy
- edit
- window

Uses tools such as:

- `grim`
- `slurp`
- `wl-copy`
- `swappy`
- `jq`

### `dashboard-add.lua`

Adds dashboard items to the dashboard data source.

### `dashboard-remove.lua`

Removes dashboard items from the dashboard data source.

---

## Keybinds

Common keybinds:

```text
SUPER + T             Open terminal
SUPER + B             Open Brave
SUPER + D             Open Quickshell launcher
SUPER + TAB           Open workspace overview
SUPER + E             Open Files
SUPER + L             Lock session
SUPER + S             Open Spotify
SUPER + C             Open VS Code
SUPER + ESC           Open power menu
SUPER + SHIFT + W     Open wallpaper picker
SUPER + V             Open clipboard copy mode
SUPER + SHIFT + V     Open clipboard delete mode
SUPER + N             Open notification center
SUPER + P             Toggle power profile
PRINT                 Full screenshot
SHIFT + PRINT         Region screenshot
CTRL + PRINT          Copy region screenshot
ALT + PRINT           Window screenshot
SUPER + PRINT         Edit screenshot in Swappy
```

Media/system keys:

```text
XF86AudioRaiseVolume      Volume up OSD
XF86AudioLowerVolume      Volume down OSD
XF86AudioMute             Toggle mute OSD
XF86MonBrightnessUp       Brightness up OSD
XF86MonBrightnessDown     Brightness down OSD
XF86AudioPlay             Play/pause
XF86AudioNext             Next track
XF86AudioPrev             Previous track
```

---

## Theme System

Theme flow:

```text
Wallpaper selected
      ↓
wal -i wallpaper
      ↓
~/.cache/wal/colors.sh
      ↓
update-theme.lua
      ↓
Quickshell WalTheme.qml
      ↓
Hyprland/Hyprlock regenerated
```

Important theme files:

```text
~/.config/quickshell/theme/Theme.qml
~/.config/quickshell/theme/WalTheme.qml
~/.config/wal/theme.css
```

### `Theme.qml`

Static design tokens:

- margins
- bar height
- radius
- font sizes
- pill colors

### `WalTheme.qml`

Generated dynamic colors from the current wallpaper.

Used by Quickshell components and modules.

Contains:

- background
- foreground
- surface
- border
- accent
- urgent
- alpha variants

---

## Wallpaper System

Wallpaper picker flow:

```text
Quickshell WallpaperPicker
      ↓
WallpaperActions.qml
      ↓
~/.config/hypr/scripts/wallpaper-picker.lua
      ↓
Hyprpaper IPC + Pywal + theme regeneration
```

The current wallpaper path is stored in:

```text
~/.cache/current-wallpaper
```

The stable copied wallpaper is:

```text
~/Pictures/wallpaper.png
```

This stable path is useful for:

- startup wallpaper
- lock screen background
- generated configs

Hyprland fallback was changed to black so the original default Hyprland wallpaper does not show if Hyprpaper is killed.

---

## Clipboard System

Clipboard is powered by:

```bash
cliphist
wl-paste
wl-copy
```

Autostart watchers:

```bash
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
```

Main commands:

```bash
qs ipc call clipboard toggle
qs ipc call clipboard deleteMode
qs ipc call clipboard deleteAll
```

Modes:

- Copy mode: copy selected item into clipboard.
- Delete mode: delete selected item from history.
- Delete all: wipe clipboard history.

---

## Dashboard System

Dashboard data is generated into:

```text
~/.config/quickshell/data/dashboard.json
```

It can display categories such as:

- University
- Projects
- Quizzes
- Exams
- Deadlines

Backend scripts manage adding/removing items.

The dashboard uses a custom manual slide animation because that gave the smoothest close behavior.

---

## Notification System

Notification behavior:

- Notification popups stack correctly.
- New notification pushes existing notification down.
- Notifications do not all restart their animations when a new one arrives.
- Notification center keeps the old preferred style.
- Notification center uses manual cached slide animation for smooth closing.

---

## Power Profile OSD

The power profile script:

```text
~/.config/hypr/scripts/power-profile-toggle.lua
```

writes the current mode to:

```text
~/.cache/power-profile-mode
```

Then triggers:

```bash
qs ipc call shell showPowerProfileOsd
```

The OSD reads the cached mode and displays:

- Performance
- Balanced
- Power Saver

---

## Lock Screen

Hyprlock config is generated from Lua.

Features:

- Wallpaper background.
- Blur.
- Transparent overlay.
- Large time display.
- Date display.
- Username label.
- Centered password input.
- Colors generated from Pywal.

Hypridle triggers lock/suspend behavior.

---

## Troubleshooting

### Quickshell IPC target not found

Check whether the module is loaded in `shell.qml`:

```bash
grep -n "ClipboardPicker\|AppLauncher\|Dashboard\|WallpaperPicker" ~/.config/quickshell/shell.qml
```

Restart Quickshell hard:

```bash
pkill -9 quickshell
sleep 1
quickshell
```

Check logs:

```bash
qs log -f
```

### Duplicate IPC handler warning

Example:

```text
Handler was registered but will not be used because another handler is registered for target dashboard
```

This means the same module was loaded twice.

Find duplicates:

```bash
grep -R -n "Dashboard {" ~/.config/quickshell
```

Only one dashboard instance should exist, normally in `shell.qml`.

### Launcher empty on first open

Fixed by retrying `DesktopEntries.applications.values` in `LauncherState.qml`.

If it comes back, restart Quickshell:

```bash
pkill -9 quickshell
sleep 1
quickshell
```

### Hyprpaper invalid request

This setup uses:

```bash
hyprctl hyprpaper wallpaper "eDP-1,/path/to/wallpaper"
```

Do not use:

```bash
hyprctl hyprpaper reload ...
hyprctl hyprpaper preload ...
...,cover
```

because the installed Hyprpaper version rejected those IPC requests.

### Original Hyprland wallpaper appears

The fallback is disabled through:

```conf
disable_hyprland_logo = yes
disable_splash_rendering = yes
force_default_wallpaper = 0
background_color = rgb(000000)
```

Generated by `lua/appearance.lua`.

### Zero-sized buffer warnings in overview

Warnings like:

```text
Cannot create zero-sized buffer
Backbuffer creation failed for screencopy
```

come from screencopy window previews.

`WindowPreview.qml` should guard screencopy so it only runs when:

- overview is open
- window exists
- capture handle exists
- preview size is greater than 1x1

---

## Backup Commands

Create full stable backup:

```bash
mkdir -p ~/.config/quickshell-backups ~/.config/hypr-backups

cp -r ~/.config/quickshell \
  ~/.config/quickshell-backups/quickshell-stable-$(date +%F-%H-%M)

cp -r ~/.config/hypr \
  ~/.config/hypr-backups/hypr-stable-$(date +%F-%H-%M)
```

Regenerate Hyprland config:

```bash
cd ~/.config/hypr
lua generate.lua
hyprctl reload
```

Restart Quickshell:

```bash
pkill -9 quickshell
sleep 1
quickshell
```

Restart Hyprpaper:

```bash
pkill hyprpaper
hyprpaper >/dev/null 2>&1 &
```

---

## Future Improvements

Possible next improvements:

- Add confirmation before clipboard `Delete all`.
- Componentize shared scrollable list frame.
- Add richer launcher categories.
- Add app pinning/favorites to launcher.
- Add dashboard editing UI without touching raw data files.
- Add wallpaper transition support using `swww` if smoother live switching is desired.
- Add notification search/filtering.
- Add settings panel for theme, blur, opacity, and animations.
- Add proper README screenshots.
- Add install script for dependencies.

---

## Dependencies

Main dependencies used by this setup:

```text
hyprland
quickshell
hyprpaper
hyprlock
hypridle
pywal / wal
cliphist
wl-clipboard
playerctl
grim
slurp
swappy
jq
kitty
brave-browser
nautilus
spotify
powerprofilesctl
```

Optional or app-specific:

```text
VS Code
Discord
OBS
Inkscape
VLC
MPV
Bluetooth tools
GNOME Settings tools
```

---

## Notes

This setup is intentionally modular. When editing it, prefer changing the source Lua/QML files rather than generated files.

For Hyprland:

```text
Edit:      ~/.config/hypr/lua/*.lua
Generate:  ~/.config/hypr/generated/*.conf
```

For Quickshell:

```text
Edit: ~/.config/quickshell/**/*.qml
```

The generated files are outputs, not the main source of truth.

---

## Current Project Status

Stable completed systems:

- Popup manager.
- Shared popup backdrop.
- Shared animated popup card.
- App launcher.
- Clipboard picker.
- Dashboard.
- Power menu.
- Notification center.
- Wallpaper picker.
- Workspace overview.
- Power profile OSD.
- Wallpaper/theme pipeline.
- Rofi removal.
- Hyprland fallback wallpaper removal.

This is now a complete custom Hyprland + Quickshell desktop environment.
