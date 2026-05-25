#!/usr/bin/env lua

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
        notify("Dashboard", "Failed to update task")
        os.exit(1)
    end

    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end

    file:close()
end

local function split_pipe(line)
    local parts = {}

    for part in string.gmatch(line, "([^|]*)|?") do
        table.insert(parts, part)

        if #parts == 8 then
            break
        end
    end

    while #parts < 8 do
        table.insert(parts, "")
    end

    return parts
end

local id = clean(arg[1])
local next_status = clean(arg[2])

if id == "" then
    notify("Dashboard", "Invalid task id")
    os.exit(1)
end

if next_status ~= "done" then
    next_status = "upcoming"
end

local lines = read_lines(data_file)
local output = {}
local updated = false

for index, line in ipairs(lines) do
    if index == 1 or line == "" then
        table.insert(output, line)
    else
        local parts = split_pipe(line)

        if clean(parts[1]) == id then
            parts[8] = next_status
            table.insert(output, table.concat(parts, "|"))
            updated = true
        else
            table.insert(output, line)
        end
    end
end

if not updated then
    notify("Dashboard", "Task not found")
    os.exit(1)
end

write_lines(data_file, output)

local result = run(shell_quote(generator) .. " >/dev/null 2>&1")

if result == true or result == 0 then
    notify("Dashboard", next_status == "done" and "Task completed" or "Task reopened")
else
    notify("Dashboard", "Task updated but regenerate failed")
end
