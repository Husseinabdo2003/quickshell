#!/usr/bin/env lua

-- ============================================================================
-- Theme Updater for Hyprland / Rofi / Quickshell
-- Replaces: update-theme.sh
-- Reads: ~/.cache/wal/colors.sh
-- Writes:
--   ~/.config/wal/theme.css
--   ~/.config/wal/theme.rasi
--   ~/.config/quickshell/theme/WalTheme.qml
-- ============================================================================

local home = os.getenv("HOME")

local wal_colors = home .. "/.cache/wal/colors.sh"
local out_dir = home .. "/.config/wal"

local gtk_theme = out_dir .. "/theme.css"
local rofi_theme = out_dir .. "/theme.rasi"
local quickshell_theme = home .. "/.config/quickshell/theme/WalTheme.qml"

local function trim(str)
    return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shell_quote(str)
    return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
end

local function run(cmd)
    return os.execute(cmd)
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local content = file:read("*a")
    file:close()

    return content
end

local function write_file(path, content)
    local file = io.open(path, "w")
    if not file then
        print("Failed to write: " .. path)
        os.exit(1)
    end

    file:write(content)
    file:close()
end

local function notify(title, message)
    run("notify-send " .. shell_quote(title) .. " " .. shell_quote(message) .. " >/dev/null 2>&1")
end

local function parse_wal_colors(path)
    local content = read_file(path)

    if not content then
        notify("Theme update failed", "Could not read Pywal colors")
        os.exit(1)
    end

    local colors = {}

    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("^%s*([%w_]+)='([^']+)'%s*$")

        if not key then
            key, value = line:match('^%s*([%w_]+)="([^"]+)"%s*$')
        end

        if key and value then
            colors[key] = value
        end
    end

    return colors
end

local function require_color(colors, key)
    local value = colors[key]

    if not value or value == "" then
        notify("Theme update failed", "Missing color: " .. key)
        os.exit(1)
    end

    return value
end

local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    if not r or not g or not b then
        return nil
    end

    return r, g, b
end

local function hex_to_qt_rgba(hex, alpha)
    local r, g, b = hex_to_rgb(hex)

    if not r then
        notify("Theme update failed", "Invalid hex color: " .. tostring(hex))
        os.exit(1)
    end

    return string.format(
        "Qt.rgba(%.6f, %.6f, %.6f, %.2f)",
        r / 255,
        g / 255,
        b / 255,
        alpha
    )
end

if not file_exists(wal_colors) then
    notify("Theme update failed", "Pywal colors.sh not found")
    os.exit(1)
end

run("mkdir -p " .. shell_quote(out_dir))
run("mkdir -p " .. shell_quote(home .. "/.config/quickshell/theme"))

local colors = parse_wal_colors(wal_colors)

local background = require_color(colors, "background")
local foreground = require_color(colors, "foreground")

local color0 = require_color(colors, "color0")
local color1 = require_color(colors, "color1")
local color2 = require_color(colors, "color2")
local color3 = require_color(colors, "color3")
local color4 = require_color(colors, "color4")
local color5 = require_color(colors, "color5")
local color6 = require_color(colors, "color6")
local color7 = require_color(colors, "color7")
local color8 = require_color(colors, "color8")
local color9 = require_color(colors, "color9")
local color10 = require_color(colors, "color10")
local color11 = require_color(colors, "color11")
local color12 = require_color(colors, "color12")
local color13 = require_color(colors, "color13")
local color14 = require_color(colors, "color14")
local color15 = require_color(colors, "color15")

local gtk_content = string.format([[
@define-color bg %s;
@define-color fg %s;

@define-color color0 %s;
@define-color color1 %s;
@define-color color2 %s;
@define-color color3 %s;
@define-color color4 %s;
@define-color color5 %s;
@define-color color6 %s;
@define-color color7 %s;
@define-color color8 %s;
@define-color color9 %s;
@define-color color10 %s;
@define-color color11 %s;
@define-color color12 %s;
@define-color color13 %s;
@define-color color14 %s;
@define-color color15 %s;

@define-color accent %s;
@define-color border %s;
@define-color muted %s;
@define-color surface %s;
]], background, foreground,
    color0, color1, color2, color3, color4, color5, color6, color7,
    color8, color9, color10, color11, color12, color13, color14, color15,
    color5, color4, color6, color0
)

local rofi_content = string.format([[
* {
    bg:              %s00;
    module-bg:       %sbf;
    module-hover:    %s8c;
    border-main:     %s;
    accent:          %s;
    text-main:       %s;
    text-active:     %s;
    muted:           %s;
    transparent:     #00000000;
}
]], background, color0, color5, color4, color5, foreground, foreground, color6)

local surface_075 = hex_to_qt_rgba(color0, 0.75)
local accent_055 = hex_to_qt_rgba(color5, 0.55)
local urgent_075 = hex_to_qt_rgba(color1, 0.75)
local fg_muted = hex_to_qt_rgba(foreground, 0.65)

local quickshell_content = string.format([[
pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: "%s"
    readonly property color fg: "%s"
    readonly property color surface: "%s"
    readonly property color border: "%s"
    readonly property color accent: "%s"
    readonly property color urgent: "%s"

    readonly property color transparentBg: "transparent"
    readonly property color surfaceAlpha: %s
    readonly property color accentAlpha: %s
    readonly property color urgentAlpha: %s
    readonly property color fgMuted: %s
}
]], background, foreground, color0, color4, color5, color1,
    surface_075, accent_055, urgent_075, fg_muted
)

write_file(gtk_theme, gtk_content)
write_file(rofi_theme, rofi_content)
write_file(quickshell_theme, quickshell_content)

print("Theme updated")
