-- Static source checks for yno hub.
-- This is not a Roblox runtime test; it catches release regressions before publishing.

local sourcePath = arg[1] or "yno.lua"
local file, openError = io.open(sourcePath, "r")
assert(file, "Cannot read " .. sourcePath .. ": " .. tostring(openError))

local source = file:read("*a")
file:close()

local required = {
    {"release header", "-- v4.0.1"},
    {"Solara mouse input", "mousemoveabs"},
    {"Solara mouse press", "mouse1press"},
    {"Solara mouse release", "mouse1release"},
    {"Solara keyboard input", "keyclick"},
    {"ranked game UI matching", "local function findGameButton"},
    {"click dispatcher", "local function sendMouseClick"},
    {"cancellable Story runner", "local function startStory"},
    {"quest claim action", "local function claimAllQuests"},
    {"native Smart Macro", "local function startNativeMacro"},
    {"Unit Hunt capture flow", "local function processUnitHunt"},
    {"runtime UI report", "local function copyUiReport"},
    {"runtime self test", "local function selfTest"},
    {"Stop All", "local function stopAll"},
    {"Unload", "local function unload"},
    {"requested wallpaper asset", "assets/yno-background.jpg"},
    {"compact two-column Game layout", "beginColumnPage(\"GAME\", \"WAVE ACTIONS\""},
    {"right-column button support", "callback, column)"},
    {"cancellable Macro sequence", "runAsync(\"macroStarting\", function(generation)"},
    {"safe login track reopening", "findGameButton({\"Login Rewards\", \"Rewards\"}"},
}

for _, check in ipairs(required) do
    assert(source:find(check[2], 1, true), "Missing required source feature: " .. check[1])
end

local declared = {}
for name in source:gmatch("local function%s+([%w_]+)%s*%(") do
    assert(not declared[name], "Duplicate local function: " .. name)
    declared[name] = true
end

assert(not source:find("setNativeToggle", 1, true), "Unsafe Set-ON helper was reintroduced")
assert(not source:find(":FireServer(", 1, true), "Private RemoteEvent invocation was introduced")
assert(not source:find(":InvokeServer(", 1, true), "Private RemoteFunction invocation was introduced")
assert(not source:find("statusLabel", 1, true), "Stale undefined statusLabel reference was introduced")
assert(not source:find("Farm Planner", 1, true), "The old generic Farm Planner UI was reintroduced")

print(string.format("yno hub static checks passed: %d required features, %d local functions.", #required, (function()
    local count = 0
    for _ in pairs(declared) do count = count + 1 end
    return count
end)()))
