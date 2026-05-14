#!/usr/bin/env lua

local home = os.getenv("HOME") or "/home/hussein"

local cache_file = home .. "/.cache/power-profile-mode"
local log_file = home .. "/.cache/power-profile-toggle.log"

local qs_candidates = {
    "/usr/bin/qs",
    "/usr/local/bin/qs",
    home .. "/.local/bin/qs"
}

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function log(message)
    local file = io.open(log_file, "a")

    if file then
        file:write(os.date("[%F %T] ") .. tostring(message) .. "\n")
        file:close()
    end
end

local function run(command)
    local handle = io.popen(command .. " 2>&1")

    if not handle then
        log("FAILED TO START: " .. command)
        return "", false
    end

    local output = handle:read("*a") or ""
    local ok = handle:close()

    output = trim(output)

    log("COMMAND: " .. command)
    log("OUTPUT: " .. output)
    log("OK: " .. tostring(ok))

    return output, ok == true
end

local function write_file(path, content)
    local file = io.open(path, "w")

    if not file then
        log("FAILED TO WRITE: " .. path)
        return false
    end

    file:write(content .. "\n")
    file:close()

    return true
end

local function file_exists(path)
    local file = io.open(path, "r")

    if file then
        file:close()
        return true
    end

    return false
end

local function find_qs()
    local path = run("command -v qs")

    if path ~= "" then
        return path
    end

    for _, candidate in ipairs(qs_candidates) do
        if file_exists(candidate) then
            return candidate
        end
    end

    return ""
end

local function normalize_profile(profile)
    profile = trim(profile)

    if profile == "performance" then
        return "performance"
    end

    if profile == "power-saver" then
        return "power-saver"
    end

    if profile == "balanced" then
        return "balanced"
    end

    return "balanced"
end

local function next_profile_from(current)
    if current == "balanced" then
        return "power-saver"
    end

    if current == "power-saver" then
        return "performance"
    end

    if current == "performance" then
        return "balanced"
    end

    return "balanced"
end

local function show_osd()
    local qs = find_qs()

    if qs == "" then
        log("QS NOT FOUND")
        return
    end

    log("QS FOUND: " .. qs)

    -- Run in the background so Hyprland keybind does not wait.
os.execute(qs .. " ipc call shell showPowerProfileOsd >/dev/null 2>&1 &")
end

log("========== START ==========")

local current = normalize_profile(run("powerprofilesctl get"))
local next_profile = next_profile_from(current)

log("CURRENT PROFILE: " .. current)
log("NEXT PROFILE: " .. next_profile)

local _, set_ok = run("powerprofilesctl set " .. next_profile)

local final_profile = current

if set_ok then
    final_profile = normalize_profile(run("powerprofilesctl get"))

    if final_profile == "" then
        final_profile = next_profile
    end

    log("PROFILE SET OK: " .. final_profile)
else
    log("PROFILE SET FAILED")
end

write_file(cache_file, final_profile)
show_osd()

log("========== END ==========")