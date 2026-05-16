#!/usr/bin/env lua

-- ============================================================================
-- Dashboard Remove Item
-- Removes an item from ~/.config/hypr/data/dashboard.csv by generated row id
-- Then regenerates ~/.config/quickshell/data/dashboard.json
-- ============================================================================

local home = os.getenv("HOME")
local data_file = home .. "/.config/hypr/data/dashboard.csv"
local generator = home .. "/.config/hypr/generate.lua"

local function shell_quote(str)
    return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
end

local function run(cmd)
    return os.execute(cmd)
end

local function notify(title, message)
    run("notify-send " .. shell_quote(title) .. " " .. shell_quote(message) .. " >/dev/null 2>&1")
end

local function read_lines(path)
    local file = io.open(path, "r")

    if not file then
        return {}
    end

    local lines = {}

    for line in file:lines() do
        table.insert(lines, line)
    end

    file:close()

    return lines
end

local function write_lines(path, lines)
    local file = io.open(path, "w")

    if not file then
        notify("Dashboard", "Failed to write data file")
        os.exit(1)
    end

    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end

    file:close()
end

local id = tonumber(arg[1] or "")

if not id then
    notify("Dashboard", "Invalid item id")
    os.exit(1)
end

local lines = read_lines(data_file)
local output = {}
local current_id = 0
local removed = false

for index, line in ipairs(lines) do
    if index == 1 then
        table.insert(output, line)
    elseif line ~= "" then
        current_id = current_id + 1

        if current_id == id then
            removed = true
        else
            table.insert(output, line)
        end
    end
end

write_lines(data_file, output)

local result = run(shell_quote(generator) .. " >/dev/null 2>&1")

if removed then
    notify("Dashboard", "Item removed")
else
    notify("Dashboard", "Item not found")
end

if not (result == true or result == 0) then
    notify("Dashboard", "Regenerate failed")
end
