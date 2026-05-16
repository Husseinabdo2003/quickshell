#!/usr/bin/env lua

-- ============================================================================
-- Dashboard Add Item
-- Adds an item to ~/.config/hypr/data/dashboard.csv
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

local function clean(str)
    str = tostring(str or "")
    str = str:gsub("\n", " ")
    str = str:gsub("|", "/")
    str = str:gsub("^%s+", "")
    str = str:gsub("%s+$", "")

    return str
end

local function ensure_file()
    run("mkdir -p " .. shell_quote(home .. "/.config/hypr/data"))

    local file = io.open(data_file, "r")

    if file then
        file:close()
        return
    end

    file = io.open(data_file, "w")
    file:write("category|type|title|course|date|priority|status\n")
    file:close()
end

local function append_file(path, line)
    local file = io.open(path, "a")

    if not file then
        notify("Dashboard", "Failed to open data file")
        os.exit(1)
    end

    file:write(line .. "\n")
    file:close()
end

local category = clean(arg[1])
local item_type = clean(arg[2])
local title = clean(arg[3])
local course = clean(arg[4])
local date = clean(arg[5])
local priority = clean(arg[6])
local status = clean(arg[7])

if category == "" then category = "todo" end
if item_type == "" then item_type = "task" end
if priority == "" then priority = "medium" end
if status == "" then status = "upcoming" end

if title == "" then
    notify("Dashboard", "Title is required")
    os.exit(1)
end

ensure_file()

local line = table.concat({
    category,
    item_type,
    title,
    course,
    date,
    priority,
    status,
}, "|")

append_file(data_file, line)

local result = run(shell_quote(generator) .. " >/dev/null 2>&1")

if result == true or result == 0 then
    notify("Dashboard", "Item added")
else
    notify("Dashboard", "Item added but regenerate failed")
end