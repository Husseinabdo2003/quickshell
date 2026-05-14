#!/usr/bin/env lua

-- ============================================================================
-- Wallpaper Picker Backend for Hyprland / Hyprpaper / Pywal / Quickshell
-- Replaces: wallpaper-picker.sh
--
-- Usage:
--   wallpaper-picker.lua /path/to/wallpaper.png
-- ============================================================================

local home = os.getenv("HOME") or "/home/hussein"

local log_file = home .. "/.cache/wallpaper-picker.log"
local current_wallpaper = home .. "/Pictures/wallpaper.png"
local current_wallpaper_cache = home .. "/.cache/current-wallpaper"
local update_theme = home .. "/.config/hypr/scripts/update-theme.lua"
local hypr_config_dir = home .. "/.config/hypr"
local monitor = "eDP-1"

local function trim(str)
    return tostring(str or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function shell_quote(str)
    return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
end

local function run(cmd)
    return os.execute(cmd)
end

local function read_cmd(cmd)
    local handle = io.popen(cmd)

    if not handle then
        return nil
    end

    local result = handle:read("*a")
    handle:close()

    if not result then
        return nil
    end

    return trim(result)
end

local function notify(message)
    run(
        "notify-send "
            .. shell_quote("Wallpaper")
            .. " "
            .. shell_quote(message)
            .. " >/dev/null 2>&1"
    )
end

local function write_file(path, content)
    local file = io.open(path, "w")

    if not file then
        return false
    end

    file:write(content)
    file:close()

    return true
end

local function append_file(path, content)
    local file = io.open(path, "a")

    if not file then
        return false
    end

    file:write(content .. "\n")
    file:close()

    return true
end

local function log(message)
    append_file(log_file, message)
end

local function file_exists(path)
    local file = io.open(path, "r")

    if file then
        file:close()
        return true
    end

    return false
end

local function is_executable(path)
    local result = os.execute("[ -x " .. shell_quote(path) .. " ]")
    return result == true or result == 0
end

local function command_exists(cmd)
    local result = os.execute("command -v " .. shell_quote(cmd) .. " >/dev/null 2>&1")
    return result == true or result == 0
end

local function expand_home(path)
    if not path then
        return nil
    end

    if path:sub(1, 2) == "~/" then
        return home .. path:sub(2)
    end

    return path
end

local function has_supported_extension(path)
    local lower = path:lower()

    return lower:match("%.jpg$")
        or lower:match("%.jpeg$")
        or lower:match("%.png$")
        or lower:match("%.webp$")
end

local function fail(message)
    log("ERROR: " .. message)
    notify(message)
    os.exit(1)
end

local function check_dependencies()
    local required = {
        "wal",
        "hyprctl",
        "hyprpaper",
        "pgrep",
        "notify-send",
        "cp",
        "lua",
    }

    local missing = {}

    for _, cmd in ipairs(required) do
        if not command_exists(cmd) then
            table.insert(missing, cmd)
        end
    end

    if #missing > 0 then
        fail("Missing: " .. table.concat(missing, ", "))
    end
end

local function ensure_parent_dirs()
    run("mkdir -p " .. shell_quote(home .. "/.cache"))
    run("mkdir -p " .. shell_quote(home .. "/Pictures"))
end

local function start_log()
    local now = read_cmd("date")

    write_file(log_file, "========== " .. tostring(now) .. " ==========\n")
    log("PATH=" .. tostring(os.getenv("PATH")))
end

local function copy_wallpaper(selected)
    local cmd = "cp "
        .. shell_quote(selected)
        .. " "
        .. shell_quote(current_wallpaper)

    local result = run(cmd)

    if not (result == true or result == 0) then
        fail("Failed to copy wallpaper")
    end

    log("Copied to: " .. current_wallpaper)
end

local function run_pywal(selected)
    local cmd = "wal -i "
        .. shell_quote(selected)
        .. " -q >> "
        .. shell_quote(log_file)
        .. " 2>&1"

    local result = run(cmd)

    if not (result == true or result == 0) then
        fail("Pywal failed")
    end

    log("wal finished")
end

local function run_theme_update()
    if not is_executable(update_theme) then
        fail("Theme script missing")
    end

    local cmd = shell_quote(update_theme)
        .. " >> "
        .. shell_quote(log_file)
        .. " 2>&1"

    local result = run(cmd)

    if not (result == true or result == 0) then
        fail("Theme update failed")
    end

    log("theme updated")
end

local function run_hypr_generate()
    local cmd = "cd "
        .. shell_quote(hypr_config_dir)
        .. " && lua generate.lua >> "
        .. shell_quote(log_file)
        .. " 2>&1"

    local result = run(cmd)

    if not (result == true or result == 0) then
        fail("Hypr config generation failed")
    end

    log("hypr config regenerated")
    log("hyprlock.conf regenerated with latest pywal colors")
end

local function ensure_hyprpaper_running()
    local result = run("pgrep -x hyprpaper >/dev/null 2>&1")

    if result == true or result == 0 then
        return
    end

    log("hyprpaper was not running, starting it")

    run("hyprpaper >/dev/null 2>&1 &")
    run("sleep 0.5")
end

local function apply_wallpaper(path)
    ensure_hyprpaper_running()

    local cmd = "hyprctl hyprpaper wallpaper "
        .. shell_quote(monitor .. "," .. path)
        .. " >> "
        .. shell_quote(log_file)
        .. " 2>&1"

    local result = run(cmd)

    if not (result == true or result == 0) then
        fail("Hyprpaper wallpaper failed")
    end

    log("hyprpaper wallpaper applied through IPC: " .. path)
end

-- ============================================================================
-- Main
-- ============================================================================

ensure_parent_dirs()
start_log()
check_dependencies()

local selected = expand_home(arg[1])

if not selected or selected == "" then
    fail("No wallpaper selected")
end

if not file_exists(selected) then
    fail("Wallpaper not found")
end

if not has_supported_extension(selected) then
    fail("Unsupported wallpaper format")
end

log("Selected: " .. selected)

if not write_file(current_wallpaper_cache, selected .. "\n") then
    fail("Failed to write current wallpaper cache")
end

copy_wallpaper(selected)

-- Apply wallpaper first so there is no delay while pywal/theme generation runs.
apply_wallpaper(selected)

-- Then update colors/configs after the wallpaper is already visible.
run_pywal(selected)
run_theme_update()
run_hypr_generate()

notify("Wallpaper changed")
log("Done")

os.exit(0)