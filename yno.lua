--[[
================================================================================
 ynoez - Anime Adventures Auto Farm Framework  v0.2.0
================================================================================
 Single file. No HTTP calls, no external UI library, no guessed remote names.

 Install : save as  <executor workspace>/ynoez.lua
 Run     : loadstring(readfile("ynoez.lua"))()
           (autoexec works too; selfFile below is what queue_on_teleport re-runs)

 What it does
   * Results screen : clicks Replay / Next Level (Back to Lobby once a job hits its run limit)
   * In match       : clicks skip / vote-start, optional game speed, claim buttons
   * Event votes    : picks the best-ranked visible option (Summer Hunt weather: Low Tide first)
   * Macros        : you record lobby navigation and unit placement/upgrades ONCE
                      (hotbar keys, HELD keys such as hold-E, clicks, UI buttons, waypoints);
                      the script replays them
   * AFK job        : a lobby macro that walks to an AFK spot and holds a key is played once,
                      then the script idles there with anti-AFK (job.afk = true)
   * Safety nets    : anti-AFK, rejoin after disconnect, re-run after teleport, and a pause
                      while a human-verification prompt is on screen (it never solves one)

 Everything build-specific (button texts, wave label) lives in CONFIG.patterns.
 Retargeted to Anime Adventures from public guides only. It was written without access to the
 live game and has never run inside Roblox: "Dump UI" is how you check the wording.
================================================================================
]]

local ENV = (getgenv and getgenv()) or _G
if type(ENV.__YNOEZ) == "table" and type(ENV.__YNOEZ.Unload) == "function" then
    pcall(ENV.__YNOEZ.Unload) -- previous instance cleans itself up
end

local App = { alive = true, version = "0.2.0", conns = {}, cleanups = {} }
ENV.__YNOEZ = App

local unpack = table.unpack or unpack

-- ================================ CONFIG =====================================
local CONFIG = {
    folder = "ynoez",     -- created inside the executor workspace
    selfFile = "ynoez.lua",

    -- feature switches (persisted to config.json when changed from the UI)
    enabled = true,
    antiAfk = true,
    autoRejoin = true,
    autoResults = true,
    autoSkip = true,
    autoClaim = true,
    autoVote = true,                   -- event votes (Summer Hunt weather / cards), see patterns.vote
    autoSpeed = false,                 -- off: a locked speed button may open a Robux prompt
    targetSpeed = 2,                   -- 1..3, only used when autoSpeed = true
    autoLobbyMacro = true,
    autoMatchMacro = true,

    -- timing, seconds
    tick = 1.0,                        -- controller loop period (one UI scan per tick)
    stateDebounce = 1.5,               -- a new phase must persist this long
    resultClickInterval = 2.0,
    leavePatience = 12,                -- results: wait this long before falling back to Leave
    skipInterval = 3.0,
    claimInterval = 5.0,
    claimCooldown = 45,                -- same button is not re-clicked for this long
    voteInterval = 3.0,
    voteCooldown = 20,                 -- after ONE vote click no other vote option is clicked for this long
    voteSettle = 1.2,                  -- a vote screen must be visible this long before the pick
    speedInterval = 2.0,
    speedMaxTries = 3,                 -- per match
    lobbyDelay = 10,                   -- lobby must be stable this long before the lobby macro
    lobbyRetry = 90,                   -- re-run the lobby macro if still in lobby after this
    stuckMinutes = 0,                  -- 0 = never rejoin because of a stuck phase

    -- behaviour
    leaveIfNoReplay = true,
    maxStartWave = 1,                  -- joined later than this wave -> macro skipped for that match
    jitterTime = 0.15,                 -- random extra delay on UI clicks (seconds, max)
    jitterPx = 2,                      -- random offset on UI click position (pixels, max)
    clickMethod = "auto",              -- heuristic clicks: "auto" | "signal" | "vim"
    macroClickMethod = "vim",          -- macro UI clicks: "auto" | "signal" | "vim"
    macroTimeScale = 1.0,              -- >1 slows a macro down, <1 speeds it up
    waveGate = true,                   -- do not run an event before the wave it was recorded in
    waveGateTimeout = 90,
    macroGuiFallbackToCoords = true,   -- recorded UI button missing -> click recorded position
    moveTimeout = 12,                  -- waypoint walk timeout
    rejoinLobbyPlaceId = nil,          -- set from the UI ("Set lobby place") or here
    uiToggleKey = "RightShift",
    printLog = false,

    -- human-verification prompts (captcha style): while one is visible nothing is clicked
    pauseOnCheck = true,
    checkClearDelay = 4,               -- seconds the prompt must be gone before resuming
    -- recorder: a key held at least this long is stored WITH its duration (hold-E prompts)
    holdMin = 0.35,
    maxHold = 20,                      -- seconds, upper bound for a replayed key hold
}

-- Jobs run in order. runs = 0 means "replay forever". After `runs` finished matches
-- the script leaves, advances to the next job and plays that job's lobby macro.
--   afk = true : the job has no match. Its lobby macro is played once (walk to the AFK spot,
--                hold the key) and the script then idles with anti-AFK. Make it the LAST job.
-- Macro names are files under <folder>/macros/ that YOU record ("Rec lobby" / "Rec match").
CONFIG.jobs = {
    { name = "story", lobby = "story_lobby", match = "story_match", runs = 0 },
    -- rotation example (remove the dashes): 5 story runs, then park in the AFK spot
    --   { name = "story", lobby = "story_lobby", match = "story_match", runs = 5 },
    --   { name = "afk",   lobby = "afk_machine", afk = true },
}

-- Phrases are matched as whole words against normalised text (lowercase, punctuation
-- stripped). The results / replay / next / leave wordings come from public guides and generic
-- tower-defense UIs: none of them could be checked against the live Anime Adventures UI.
-- Use the "Dump UI" button and edit them if something is not detected.
CONFIG.patterns = {
    results   = { "victory", "defeat", "game over", "mission complete", "mission failed",
                  "stage complete", "stage cleared", "you win", "you won", "you lose", "you lost" },
    replay    = { "replay", "retry", "play again", "restart" },
    nextStage = { "next stage", "next act", "next level", "next map", "next chapter" },
    leave     = { "leave", "return to lobby", "back to lobby", "return lobby", "exit" },
    skip      = { "vote skip", "skip wave", "skip", "vote start", "start wave" },
    claim     = { "claim", "claim all", "collect" },
    -- Event votes, in ORDER OF PREFERENCE (first = picked when visible). Summer Hunt (Update 21)
    -- is reported to ask for a weather vote between Low Tide, Rising Tide and Tsunami; Tsunami is
    -- described as doubling SummerPearls but making enemies much tougher, so it is listed last.
    -- Card names can be added here too (e.g. "enemy health"). One click per voteCooldown.
    vote      = { "low tide", "rising tide", "tsunami" },
    -- human-verification prompts: the script only PAUSES on these, it never tries to solve one.
    -- No such prompt was found in the Anime Adventures guides; this is a generic safety net.
    check     = { "captcha", "verify you are human", "verify that you are human",
                  "human verification", "are you a robot", "are you human", "not a robot" },
}

-- Never auto-clicked: matched (plain substring) against the button text and its path.
CONFIG.blacklist = {
    "shop", "store", "buy", "purchase", "robux", "gamepass", "game pass", "premium", "vip",
    "summon", "gift", "trade", "delete", "reset", "rebirth", "setting", "report", "invite",
    "friend", "donate", "bundle", "banner", "unequip", "sell",
}

-- Source: community code lists for Update 21 (samlover "verified 2026-11-01", beatcopgame,
-- animeadventuresgame.wiki), read 2026-11. NONE is confirmed by the developers.
--   SUMMERCOMEBACK level 20+ | AACOMEBACK level 10+ | APRILFOOLS level 20+ |
--   CELESTIALCOMPASSU21 one per account (one list says: join the group first).
-- 2MILLIONFAVES is from an older list and probably expired. Codes are case-sensitive; a wrong,
-- expired or level-gated code just fails. One guide says the lobby has a "Codes circle": stand in
-- it to open the Codes window, then press "Redeem codes".
CONFIG.codes = { "CELESTIALCOMPASSU21", "SUMMERCOMEBACK", "AACOMEBACK", "APRILFOOLS", "2MILLIONFAVES" }

-- Keys never captured by the macro recorder (movement, chat, menu).
CONFIG.recordIgnoreKeys = {
    W = true, A = true, S = true, D = true, Space = true, LeftShift = true, RightShift = true,
    LeftControl = true, RightControl = true, LeftAlt = true, RightAlt = true, Tab = true,
    Escape = true, Slash = true, Return = true, Backspace = true, Unknown = true,
    Up = true, Down = true, Left = true, Right = true,
}

-- ================================= UTIL ======================================
local Util = {}

function Util.clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

-- "<b>Vote Skip</b> (3/4)" -> "vote skip 3 4"
function Util.normalize(s)
    s = string.lower(tostring(s or ""))
    s = string.gsub(s, "<[^>]*>", " ")
    s = string.gsub(s, "[^%w%s]", " ")
    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "^ ", "")
    s = string.gsub(s, " $", "")
    return s
end

function Util.hasPhrase(norm, phrase)
    return string.find(" " .. norm .. " ", " " .. phrase .. " ", 1, true) ~= nil
end

function Util.findPhrase(norm, list)
    for i = 1, #list do
        if Util.hasPhrase(norm, list[i]) then return list[i] end
    end
    return nil
end

-- "wave 5", "wave 5 15" -> 5. Anchored so "best wave 120" does not count.
function Util.parseWave(norm)
    local n = string.match(norm, "^wave (%d+)")
    return n and tonumber(n) or nil
end

-- "2x", "x2", "speed 2x" -> 2
function Util.parseSpeed(norm)
    local n = string.match(norm, "^(%d)x$") or string.match(norm, "^x(%d)$")
        or string.match(norm, "^speed (%d)x?$")
    return n and tonumber(n) or nil
end

-- Macro names become file names: letters, digits, _ and - only.
function Util.sanitizeName(s)
    s = string.gsub(tostring(s or ""), "[^%w_%-]", "_")
    s = string.sub(s, 1, 40)
    if s == "" then return nil end
    return s
end

function Util.shallowCopy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

-- ================================== LOG ======================================
local Log = { buf = {}, max = 300, last = {}, hook = nil }

-- key + every: drop repeats of the same message inside `every` seconds.
function Log.add(msg, key, every)
    local t = os.clock()
    if key then
        local prev = Log.last[key]
        if prev and (t - prev) < (every or 30) then return end
        Log.last[key] = t
    end
    local line = os.date("%H:%M:%S") .. "  " .. tostring(msg)
    Log.buf[#Log.buf + 1] = line
    if #Log.buf > Log.max then table.remove(Log.buf, 1) end
    if CONFIG.printLog then print("[ynoez] " .. line) end
    if Log.hook then pcall(Log.hook, line) end
end

-- ============================ PHASE / JOBS (pure) ============================
-- snap = { hits = { results = {..}, replay = {..}, nextStage = {..}, skip = {..} },
--          wave = number|nil, speedObj = table|nil }
local Phase = {}

function Phase.compute(snap)
    local h = snap.hits
    if #h.results > 0 or #h.replay > 0 or #h.nextStage > 0 then return "results" end
    -- skip/start buttons alone prove nothing: lobby room screens have "Start" buttons too
    if snap.wave or snap.speedObj then return "match" end
    return "lobby"
end

function Phase.new(initial, now)
    return { cur = initial, since = now, cand = initial, candSince = now }
end

-- Debounce: commits `observed` only after it stayed unchanged for `debounce` seconds.
-- Returns changed:boolean, previous phase.
function Phase.step(st, observed, now, debounce)
    if observed ~= st.cand then
        st.cand, st.candSince = observed, now
    end
    if st.cand ~= st.cur and (now - st.candSince) >= debounce then
        local prev = st.cur
        st.cur, st.since = st.cand, now
        return true, prev
    end
    return false, st.cur
end

local Jobs = {}

function Jobs.get(idx)
    local n = #CONFIG.jobs
    if n == 0 then return nil end
    return CONFIG.jobs[((idx - 1) % n) + 1]
end

function Jobs.nextIndex(idx)
    local n = #CONFIG.jobs
    if n == 0 then return 1 end
    return (idx % n) + 1
end

function Jobs.limitReached(job, runsDone)
    return job ~= nil and job.runs > 0 and runsDone >= job.runs
end

-- ============================ CONFIG VALIDATION ==============================
local LIMITS = {
    tick = { 0.2, 5 }, stateDebounce = { 0.3, 10 }, resultClickInterval = { 0.5, 30 },
    leavePatience = { 2, 300 }, skipInterval = { 0.5, 60 }, claimInterval = { 1, 120 },
    claimCooldown = { 5, 600 }, speedInterval = { 0.5, 30 }, speedMaxTries = { 0, 10 },
    lobbyDelay = { 1, 300 }, lobbyRetry = { 15, 1800 },
    stuckMinutes = { 0, 240 }, maxStartWave = { 0, 100 }, jitterTime = { 0, 2 },
    jitterPx = { 0, 8 }, macroTimeScale = { 0.25, 4 }, waveGateTimeout = { 5, 600 },
    moveTimeout = { 2, 60 }, targetSpeed = { 1, 3 },
    checkClearDelay = { 1, 60 }, holdMin = { 0.15, 5 }, maxHold = { 1, 60 },
    voteInterval = { 0.5, 60 }, voteCooldown = { 5, 600 }, voteSettle = { 0, 10 },
}

local CLICK_METHODS = { auto = true, signal = true, vim = true }

-- Called after loading overrides and after UI edits: keeps every value inside a safe range
-- so a bad config file cannot cause division by zero, runaway loops or zero-delay spam.
function Phase.sanitizeConfig()
    for key, range in pairs(LIMITS) do
        local v = tonumber(CONFIG[key])
        if v == nil then v = range[1] end
        CONFIG[key] = Util.clamp(v, range[1], range[2])
    end
    CONFIG.targetSpeed = math.floor(CONFIG.targetSpeed)
    if not CLICK_METHODS[CONFIG.clickMethod] then CONFIG.clickMethod = "auto" end
    if not CLICK_METHODS[CONFIG.macroClickMethod] then CONFIG.macroClickMethod = "vim" end

    local clean = {}
    for _, j in ipairs(type(CONFIG.jobs) == "table" and CONFIG.jobs or {}) do
        if type(j) == "table" then
            clean[#clean + 1] = {
                name = tostring(j.name or ("job" .. (#clean + 1))),
                lobby = Util.sanitizeName(j.lobby),
                match = Util.sanitizeName(j.match),
                runs = math.max(0, math.floor(tonumber(j.runs) or 0)),
                afk = j.afk == true,
            }
        end
    end
    if #clean == 0 then
        clean[1] = { name = "story", lobby = "story_lobby", match = "story_match", runs = 0, afk = false }
    end
    CONFIG.jobs = clean
end

Phase.sanitizeConfig()

-- ========================== SERVICES / CAPABILITIES ==========================
local function svc(name)
    local ok, s = pcall(function() return game:GetService(name) end)
    if not ok or not s then return nil end
    if type(cloneref) == "function" then
        local ok2, c = pcall(cloneref, s)
        if ok2 and c then return c end
    end
    return s
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = svc("Players")
local UIS = svc("UserInputService")
local GuiService = svc("GuiService")
local HttpService = svc("HttpService")
local TeleportService = svc("TeleportService")
local CoreGui = svc("CoreGui")
local VIM = svc("VirtualInputManager")
local VirtualUser = svc("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.2)
    LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Executor functions are feature-detected; every missing one degrades a feature, never crashes.
local Cap = {
    writefile = type(writefile) == "function",
    readfile = type(readfile) == "function",
    isfile = type(isfile) == "function",
    isfolder = type(isfolder) == "function",
    makefolder = type(makefolder) == "function",
    firesignal = type(firesignal) == "function",
    getconnections = type(getconnections) == "function",
    hook = type(hookmetamethod) == "function" and type(getnamecallmethod) == "function",
    gethui = type(gethui) == "function",
    setclipboard = type(setclipboard) == "function",
    queue = (type(queue_on_teleport) == "function" and queue_on_teleport)
        or (syn and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport)
        or (fluxus and type(fluxus.queue_on_teleport) == "function" and fluxus.queue_on_teleport)
        or nil,
}

-- ================================ FILES / JSON ===============================
local FS = {}

function FS.ensure(path)
    if not Cap.makefolder then return false end
    if Cap.isfolder then
        local ok, exists = pcall(isfolder, path)
        if ok and exists then return true end
    end
    return (pcall(makefolder, path))
end

function FS.write(path, data)
    if not Cap.writefile then return false, "writefile unavailable in this executor" end
    return pcall(writefile, path, data)
end

function FS.exists(path)
    if not Cap.isfile then return false end
    local ok, r = pcall(isfile, path)
    return ok and r == true
end

function FS.read(path)
    if not Cap.readfile or not FS.exists(path) then return nil end
    local ok, data = pcall(readfile, path)
    if ok then return data end
    return nil
end

FS.ensure(CONFIG.folder)
FS.ensure(CONFIG.folder .. "/macros")

local Json = {}

function Json.encode(v)
    local ok, r = pcall(function() return HttpService:JSONEncode(v) end)
    if ok then return r end
    return nil, r
end

function Json.decode(s)
    local ok, r = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return r end
    return nil, r
end

-- ============================ CONFIG PERSISTENCE =============================
local PERSIST = {
    "enabled", "antiAfk", "autoRejoin", "autoResults", "autoSkip", "autoClaim", "autoSpeed",
    "targetSpeed", "autoLobbyMacro", "autoMatchMacro", "macroTimeScale", "rejoinLobbyPlaceId",
    "pauseOnCheck", "autoVote",
}

local Cfg = {
    path = CONFIG.folder .. "/config.json",
    state = { jobIndex = 1, runsDone = 0, jobsEdited = false },
}

function Cfg.save()
    local out = {
        jobIndex = Cfg.state.jobIndex, runsDone = Cfg.state.runsDone,
        jobsEdited = Cfg.state.jobsEdited,
    }
    if Cfg.state.jobsEdited then out.jobs = CONFIG.jobs end
    for _, k in ipairs(PERSIST) do out[k] = CONFIG[k] end
    local json, err = Json.encode(out)
    if not json then
        Log.add("config encode failed: " .. tostring(err), "cfgenc", 60)
        return false
    end
    local ok, werr = FS.write(Cfg.path, json)
    if not ok then Log.add("config save failed: " .. tostring(werr), "cfgsave", 60) end
    return ok
end

function Cfg.load()
    local raw = FS.read(Cfg.path)
    if not raw then return false end
    local data, err = Json.decode(raw)
    if type(data) ~= "table" then
        Log.add("config.json unreadable, defaults kept (" .. tostring(err) .. ")")
        return false
    end
    for _, k in ipairs(PERSIST) do
        local want = type(CONFIG[k])
        if data[k] ~= nil and (want == "nil" or type(data[k]) == want) then CONFIG[k] = data[k] end
    end
    if data.jobsEdited == true and type(data.jobs) == "table" then
        CONFIG.jobs = data.jobs
        Cfg.state.jobsEdited = true
    end
    Phase.sanitizeConfig()
    Cfg.state.jobIndex = Util.clamp(math.floor(tonumber(data.jobIndex) or 1), 1, #CONFIG.jobs)
    Cfg.state.runsDone = math.max(0, math.floor(tonumber(data.runsDone) or 0))
    return true
end

-- ================================ GUI HELPERS ================================
local Gui = { ownFrame = nil }

function Gui.viewport()
    local cam = workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1920, 1080)
end

-- AbsolutePosition is relative to the ScreenGui origin; ScreenGuis that respect the
-- inset start below the top bar, so mouse/VIM coordinates need the inset added.
function Gui.insetValue()
    local ok, v = pcall(function() return GuiService:GetGuiInset() end)
    if ok and v then return v end
    return Vector2.new(0, 36)
end

function Gui.insetFor(obj)
    local sg = obj and obj:FindFirstAncestorWhichIsA("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.new(0, 0) end
    return Gui.insetValue()
end

function Gui.visible(obj)
    if not obj or not obj.Parent then return false end
    local cur = obj
    while cur and cur ~= PlayerGui do
        if cur:IsA("GuiObject") then
            if not cur.Visible then return false end
            if cur:IsA("CanvasGroup") and cur.GroupTransparency >= 0.99 then return false end
        elseif cur:IsA("ScreenGui") then
            if not cur.Enabled then return false end
        end
        cur = cur.Parent
    end
    if obj:IsA("GuiObject") then
        local s = obj.AbsoluteSize
        if s.X <= 0 or s.Y <= 0 then return false end
        if (obj:IsA("TextLabel") or obj:IsA("TextButton"))
            and obj.TextTransparency >= 0.99 and obj.BackgroundTransparency >= 0.99 then
            return false
        end
        local c = obj.AbsolutePosition + s * 0.5
        local vp = Gui.viewport()
        if c.X < 0 or c.Y < 0 or c.X > vp.X or c.Y > vp.Y then return false end
    end
    return true
end

function Gui.center(obj)
    local inset = Gui.insetFor(obj)
    local p = obj.AbsolutePosition + obj.AbsoluteSize * 0.5
    return Vector2.new(p.X + inset.X, p.Y + inset.Y)
end

function Gui.pathOf(obj)
    local p, cur = {}, obj
    while cur and cur ~= PlayerGui and cur.Parent do
        table.insert(p, 1, cur.Name)
        cur = cur.Parent
    end
    return p
end

function Gui.resolve(path)
    local cur = PlayerGui
    for _, name in ipairs(path or {}) do
        cur = cur:FindFirstChild(name)
        if not cur then return nil end
    end
    return cur
end

-- Own text plus the text of up to 6 descendants, normalised. Used to label buttons.
function Gui.textOf(obj)
    local parts = {}
    if obj:IsA("TextButton") or obj:IsA("TextLabel") then parts[1] = obj.Text end
    local n = 0
    for _, d in ipairs(obj:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" then
            parts[#parts + 1] = d.Text
            n = n + 1
            if n >= 6 then break end
        end
    end
    return Util.normalize(table.concat(parts, " "))
end

function Gui.clickable(obj)
    if obj:IsA("GuiButton") then return obj end
    return obj:FindFirstAncestorWhichIsA("GuiButton")
end

function Gui.blocked(obj, norm)
    local path = string.lower(table.concat(Gui.pathOf(obj), "/"))
    for _, w in ipairs(CONFIG.blacklist) do
        if string.find(path, w, 1, true) or (norm and string.find(norm, w, 1, true)) then
            return true, w
        end
    end
    return false
end

-- Smallest visible GuiButton containing a screen position (screen coords, inset included).
function Gui.buttonAt(pos)
    local best, bestArea
    local insetDefault = Gui.insetValue()
    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg ~= Gui.ownGui and sg:IsA("ScreenGui") and sg.Enabled then
            local inset = sg.IgnoreGuiInset and Vector2.new(0, 0) or insetDefault
            for _, d in ipairs(sg:GetDescendants()) do
                if d:IsA("GuiButton") then
                    local p, s = d.AbsolutePosition + inset, d.AbsoluteSize
                    if pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
                        and Gui.visible(d) then
                        local area = s.X * s.Y
                        if not best or area < bestArea then best, bestArea = d, area end
                    end
                end
            end
        end
    end
    return best
end

function Gui.findButtonByText(norm)
    if not norm or norm == "" then return nil end
    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg ~= Gui.ownGui and sg:IsA("ScreenGui") and sg.Enabled then
            for _, d in ipairs(sg:GetDescendants()) do
                if d:IsA("GuiButton") and Gui.visible(d) and Gui.textOf(d) == norm then return d end
            end
        end
    end
    return nil
end

-- Clicks on our own panel must never be recorded as game clicks.
function Gui.overOwnUi(pos)
    local f = Gui.ownFrame
    if not f or not f.Parent or not f.Visible then return false end
    local p, s = f.AbsolutePosition, f.AbsoluteSize -- our ScreenGui ignores the inset
    return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

function Gui.character()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

-- ================================ INPUT LAYER ================================
local Input = { warned = {} }

local function jitter(max)
    if not max or max <= 0 then return 0 end
    return (math.random() * 2 - 1) * max
end

local function warnOnce(key, msg)
    if not Input.warned[key] then
        Input.warned[key] = true
        Log.add(msg)
    end
end

function Input.pause()
    if CONFIG.jitterTime > 0 then task.wait(math.random() * CONFIG.jitterTime) end
end

-- x, y in screen coordinates (same space as UserInputService:GetMouseLocation()).
function Input.mouse(x, y)
    if not VIM then
        warnOnce("vim", "VirtualInputManager unavailable: real mouse input cannot be sent")
        return false
    end
    local ok, err = pcall(function()
        VIM:SendMouseMoveEvent(x, y, game)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    if not ok then warnOnce("vimerr", "VirtualInputManager call failed: " .. tostring(err)) end
    return ok
end

function Input.clickNorm(nx, ny)
    local vp = Gui.viewport()
    return Input.mouse(nx * vp.X, ny * vp.Y)
end

-- hold (seconds, optional): keeps the key down that long (hold-E style prompts). `cancelled`
-- is polled while holding so a stop request releases the key at once; the key-up is ALWAYS sent.
function Input.key(name, hold, cancelled)
    if not VIM then
        warnOnce("vim", "VirtualInputManager unavailable: key presses cannot be sent")
        return false
    end
    local okK, kc = pcall(function() return Enum.KeyCode[name] end)
    if not okK or not kc then return false end
    hold = tonumber(hold)
    if hold and hold > 0 then hold = Util.clamp(hold, 0.05, CONFIG.maxHold) else hold = nil end
    if not pcall(function() VIM:SendKeyEvent(true, kc, false, game) end) then return false end
    local ok = pcall(function()
        if hold then
            local untilT = os.clock() + hold
            while os.clock() < untilT do
                if cancelled and cancelled() then break end
                task.wait(math.min(0.1, math.max(0.01, untilT - os.clock())))
            end
        else
            task.wait(0.05)
        end
    end)
    pcall(function() VIM:SendKeyEvent(false, kc, false, game) end)
    return ok
end

local BUTTON_SIGNALS = { "MouseButton1Down", "MouseButton1Up", "MouseButton1Click", "Activated" }

function Input.signal(btn)
    if not btn:IsA("GuiButton") then return false end
    local fired = false
    for _, name in ipairs(BUTTON_SIGNALS) do
        local okS, sig = pcall(function() return btn[name] end)
        if okS and sig then
            if Cap.firesignal then
                if pcall(firesignal, sig) then fired = true end
            elseif Cap.getconnections then
                local okC, conns = pcall(getconnections, sig)
                if okC and conns then
                    for _, c in ipairs(conns) do
                        if pcall(function() c:Fire() end) then fired = true end
                    end
                end
            end
        end
    end
    return fired
end

-- attempt rotates the method in "auto" mode so a click that did nothing is retried differently.
function Input.clickGui(obj, attempt, method)
    local target = Gui.clickable(obj) or obj
    method = method or CONFIG.clickMethod
    local seq = { "signal", "vim" }
    if method == "signal" then seq = { "signal" } elseif method == "vim" then seq = { "vim" } end
    local m = seq[((attempt or 1) - 1) % #seq + 1]
    if m == "signal" and not (target:IsA("GuiButton") and (Cap.firesignal or Cap.getconnections)) then
        m = "vim"
    end
    if m == "signal" then return Input.signal(target), "signal" end
    local c = Gui.center(target)
    return Input.mouse(c.X + jitter(CONFIG.jitterPx), c.Y + jitter(CONFIG.jitterPx)), "vim"
end

-- ================================== SCANNER ==================================
-- One pass over the enabled ScreenGuis per call. Text is matched first (cheap), visibility
-- is verified only for objects that matched.
local Scan = { groups = {}, last = nil }

function Scan.rebuildGroups()
    local groups = {}
    for _, n in ipairs({ "results", "replay", "nextStage", "leave", "skip", "claim", "vote", "check" }) do
        groups[n] = {}
    end
    for name, list in pairs(CONFIG.patterns) do
        local norm = {}
        if type(list) == "table" then
            for _, p in ipairs(list) do
                local q = Util.normalize(p)
                if q ~= "" then norm[#norm + 1] = q end
            end
        end
        groups[name] = norm
    end
    Scan.groups = groups
end

Scan.rebuildGroups()

function Scan.pass()
    local hits = {}
    for g in pairs(Scan.groups) do hits[g] = {} end
    local waves, speeds = {}, {}

    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg ~= Gui.ownGui and sg:IsA("ScreenGui") and sg.Enabled then
            for _, d in ipairs(sg:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    local raw = d.Text
                    if raw ~= "" and #raw <= 120 then -- long strings are descriptions, not labels
                        local norm = Util.normalize(raw)
                        if norm ~= "" then
                            for g, phrases in pairs(Scan.groups) do
                                local ph = Util.findPhrase(norm, phrases)
                                if ph then
                                    local list = hits[g]
                                    list[#list + 1] = { obj = d, text = norm, phrase = ph }
                                end
                            end
                            local w = Util.parseWave(norm)
                            if w then waves[#waves + 1] = { obj = d, value = w } end
                            local sp = Util.parseSpeed(norm)
                            if sp then speeds[#speeds + 1] = { obj = d, value = sp } end
                        end
                    end
                end
            end
        end
    end

    for g, list in pairs(hits) do
        local keep = {}
        for _, h in ipairs(list) do
            if Gui.visible(h.obj) then keep[#keep + 1] = h end
        end
        hits[g] = keep
    end

    local wave
    for _, w in ipairs(waves) do
        if Gui.visible(w.obj) and (not wave or w.value > wave) then wave = w.value end
    end
    local speedObj
    for _, s in ipairs(speeds) do
        if Gui.visible(s.obj) then
            speedObj = s
            break
        end
    end

    local snap = { hits = hits, wave = wave, speedObj = speedObj, t = os.clock() }
    Scan.last = snap
    return snap
end

-- First hit that is not blacklisted. Visibility was already verified by pass().
function Scan.pick(list)
    for _, h in ipairs(list or {}) do
        local blocked, word = Gui.blocked(h.obj, h.text)
        if not blocked then return h end
        Log.add("ignored '" .. h.text .. "' (blacklist: " .. word .. ")", "bl_" .. h.text, 120)
    end
    return nil
end

function Scan.click(hit, attempt, why)
    Input.pause()
    local ok, how = Input.clickGui(hit.obj, attempt, CONFIG.clickMethod)
    Log.add(string.format("%s: '%s' via %s%s", why, hit.text, tostring(how), ok and "" or " (failed)"))
    return ok
end

-- ================================== MACROS ===================================
-- A macro is a timed list of the things YOU did: key presses, clicks on the 3D world
-- (stored as fractions of the viewport), clicks on UI buttons (stored by path + text) and
-- walk waypoints. Replay re-sends them as input, so no server remote is ever touched.
local Macro = { rec = nil, playing = nil }

local function macroPath(name)
    return CONFIG.folder .. "/macros/" .. name .. ".json"
end

function Macro.exists(name)
    return name ~= nil and FS.exists(macroPath(name))
end

function Macro.load(name)
    local raw = FS.read(macroPath(name))
    if not raw then return nil, "file not found: " .. macroPath(name) end
    local data, err = Json.decode(raw)
    if type(data) ~= "table" or type(data.events) ~= "table" then
        return nil, "malformed macro file (" .. tostring(err) .. ")"
    end
    return data
end

-- ------------------------------- recording ----------------------------------
function Macro.isRecording()
    return Macro.rec ~= nil
end

function Macro.onInput(rec, input)
    if Macro.rec ~= rec then return end
    local t = os.clock() - rec.t0
    local ut = input.UserInputType
    local wave = Scan.last and Scan.last.wave or nil

    if ut == Enum.UserInputType.Keyboard then
        if UIS:GetFocusedTextBox() then return end
        local name = input.KeyCode.Name
        if CONFIG.recordIgnoreKeys[name] then return end
        local ev = { t = t, k = "key", key = name, w = wave }
        rec.events[#rec.events + 1] = ev
        rec.downEv[name], rec.downAt[name] = ev, os.clock() -- duration is added on key release
    elseif ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
        local pos
        if ut == Enum.UserInputType.Touch then
            -- best effort: touch positions are reported without the top-bar inset
            local inset = Gui.insetValue()
            pos = Vector2.new(input.Position.X + inset.X, input.Position.Y + inset.Y)
        else
            pos = UIS:GetMouseLocation()
        end
        if Gui.overOwnUi(pos) then return end
        local vp = Gui.viewport()
        if vp.X <= 0 or vp.Y <= 0 then return end
        local ev = { t = t, k = "click", nx = pos.X / vp.X, ny = pos.Y / vp.Y, w = wave }
        local btn = Gui.buttonAt(pos)
        if btn then
            ev.k = "gui"
            ev.path = Gui.pathOf(btn)
            ev.text = Gui.textOf(btn)
        end
        rec.events[#rec.events + 1] = ev
    end
end

-- A key that stayed down for at least CONFIG.holdMin keeps its duration (ev.d, seconds), so a
-- "walk to the machine, hold E" lobby macro replays as a real hold and not as a tap.
function Macro.onInputEnded(rec, input)
    if Macro.rec ~= rec or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local name = input.KeyCode.Name
    local ev, at = rec.downEv[name], rec.downAt[name]
    if not ev then return end
    rec.downEv[name], rec.downAt[name] = nil, nil
    local dur = os.clock() - at
    if dur >= CONFIG.holdMin then
        ev.d = math.floor(math.min(dur, CONFIG.maxHold) * 100 + 0.5) / 100
    end
end

function Macro.stopRecord(save)
    local rec = Macro.rec
    if not rec then return false end
    Macro.rec = nil
    if rec.conn then rec.conn:Disconnect() end
    if rec.connEnd then rec.connEnd:Disconnect() end
    if save == false then return false end
    if #rec.events == 0 then
        Log.add("recording '" .. rec.name .. "' was empty, nothing saved")
        return false
    end
    local data = {
        version = 1, name = rec.name, viewport = rec.viewport, placeId = rec.placeId,
        events = rec.events, length = rec.events[#rec.events].t,
    }
    local json, err = Json.encode(data)
    if not json then
        Log.add("macro encode failed: " .. tostring(err))
        return false
    end
    local ok, werr = FS.write(macroPath(rec.name), json)
    if not ok then
        Log.add("macro save failed: " .. tostring(werr))
        return false
    end
    Log.add(string.format("saved macro '%s': %d events, %.1fs", rec.name, #rec.events, data.length))
    return true
end

function Macro.startRecord(name)
    name = Util.sanitizeName(name)
    if not name then return false, "invalid macro name" end
    if not UIS then return false, "UserInputService unavailable" end
    if Macro.rec then Macro.stopRecord(true) end
    local vp = Gui.viewport()
    local rec = {
        name = name, t0 = os.clock(), events = {}, viewport = { vp.X, vp.Y }, placeId = game.PlaceId,
        downEv = {}, downAt = {},
    }
    rec.conn = UIS.InputBegan:Connect(function(input)
        local ok, err = pcall(Macro.onInput, rec, input)
        if not ok then Log.add("recorder error: " .. tostring(err), "recerr", 10) end
    end)
    rec.connEnd = UIS.InputEnded:Connect(function(input)
        local ok, err = pcall(Macro.onInputEnded, rec, input)
        if not ok then Log.add("recorder error: " .. tostring(err), "recerr", 10) end
    end)
    Macro.rec = rec
    Log.add("recording '" .. name .. "': perform the sequence, then press Stop")
    return true
end

function Macro.addWaypoint()
    local rec = Macro.rec
    if not rec then return false, "not recording" end
    local hrp = Gui.character()
    if not hrp then return false, "no character" end
    local p = hrp.Position
    rec.events[#rec.events + 1] = {
        t = os.clock() - rec.t0, k = "move", x = p.X, y = p.Y, z = p.Z,
        w = Scan.last and Scan.last.wave or nil,
    }
    Log.add(string.format("waypoint added (%.0f, %.0f, %.0f)", p.X, p.Y, p.Z))
    return true
end

-- -------------------------------- playback ----------------------------------
local function sleepUntil(deadline, cancelled)
    while true do
        local left = deadline - os.clock()
        if left <= 0 then return true end
        if cancelled() then return false end
        task.wait(math.min(0.1, left))
    end
end

function Macro.walkTo(pos)
    local hrp, hum = Gui.character()
    if not (hrp and hum) then
        Log.add("macro: waypoint skipped, no character", "nochar", 20)
        return
    end
    local done = false
    local conn = hum.MoveToFinished:Connect(function() done = true end)
    hum:MoveTo(pos)
    local t0 = os.clock()
    while not done and App.alive and (os.clock() - t0) < CONFIG.moveTimeout do
        task.wait(0.1)
        if (hrp.Position - pos).Magnitude < 4 then break end
    end
    conn:Disconnect()
end

function Macro.execute(ev, cancelled)
    local k = ev.k
    if k == "key" then
        Input.key(tostring(ev.key), tonumber(ev.d), cancelled)
    elseif k == "click" then
        Input.clickNorm(tonumber(ev.nx) or 0.5, tonumber(ev.ny) or 0.5)
    elseif k == "gui" then
        local obj
        if type(ev.path) == "table" and #ev.path > 0 then obj = Gui.resolve(ev.path) end
        if not (obj and Gui.visible(obj)) then obj = Gui.findButtonByText(ev.text) end
        if obj then
            Input.clickGui(obj, 1, CONFIG.macroClickMethod)
        elseif CONFIG.macroGuiFallbackToCoords then
            Log.add("macro: button '" .. tostring(ev.text) .. "' not found, using recorded position",
                "mg_" .. tostring(ev.text), 20)
            Input.clickNorm(tonumber(ev.nx) or 0.5, tonumber(ev.ny) or 0.5)
        else
            Log.add("macro: button '" .. tostring(ev.text) .. "' not found, event skipped",
                "mg_" .. tostring(ev.text), 20)
        end
    elseif k == "move" then
        Macro.walkTo(Vector3.new(tonumber(ev.x) or 0, tonumber(ev.y) or 0, tonumber(ev.z) or 0))
    end
end

-- Runs a saved macro. isCancelled() is polled between events; returns true when it finished.
function Macro.play(name, isCancelled)
    local data, err = Macro.load(name)
    if not data then
        Log.add("macro '" .. tostring(name) .. "': " .. tostring(err), "mload_" .. tostring(name), 30)
        return false
    end
    local function cancelled() return not App.alive or isCancelled() end
    Macro.playing = name
    Log.add(string.format("playing macro '%s' (%d events)", name, #data.events))

    local start, shift, finished = os.clock(), 0, true
    for i, ev in ipairs(data.events) do
        local due = start + shift + (tonumber(ev.t) or 0) * CONFIG.macroTimeScale
        if not sleepUntil(due, cancelled) then
            finished = false
            break
        end
        local gate = tonumber(ev.w)
        if CONFIG.waveGate and gate then
            local gateStart = os.clock()
            while not cancelled() and (os.clock() - gateStart) < CONFIG.waveGateTimeout do
                local cur = Scan.last and Scan.last.wave
                if not cur or cur >= gate then break end
                task.wait(0.25)
            end
            shift = shift + (os.clock() - gateStart) -- later events keep their spacing
        end
        if cancelled() then
            finished = false
            break
        end
        local ok, e = pcall(Macro.execute, ev, cancelled)
        if not ok then Log.add("macro event " .. i .. " failed: " .. tostring(e), "mev", 5) end
    end
    Macro.playing = nil
    Log.add(string.format("macro '%s' %s", name, finished and "finished" or "cancelled"))
    return finished
end

-- ================================ CONTROLLER =================================
local Ctl = {
    phase = nil,                -- Phase state (debounced)
    token = 0,                  -- bumped whenever running macros must stop
    session = 0,                -- bumped when a match starts
    manualId = 0,               -- bumped to stop a macro started from the UI
    jobIndex = 1, runsDone = 0, pendingAdvance = false,
    lastResultClick = 0, resultAttempts = 0,
    lastSkip = 0, lastClaim = 0, lastSpeed = 0, speedTries = 0,
    lastVote = -1e9, voteSeenSince = nil,
    lobbyBusy = false, lastLobbyRun = -1e9, lastRejoin = -1e9,
    afkDone = false,            -- afk job: its lobby macro finished, the script is parked
    checkActive = false, checkLast = 0, -- a human-verification prompt is on screen
    claimed = setmetatable({}, { __mode = "k" }),
}

function Ctl.job()
    return Jobs.get(Ctl.jobIndex)
end

function Ctl.cancelMacros()
    Ctl.token = Ctl.token + 1
end

function Ctl.statusText()
    local job = Ctl.job()
    local limit = (job and job.runs > 0) and ("/" .. job.runs) or ""
    local snap = Scan.last
    local macro = Macro.rec and ("REC " .. Macro.rec.name) or Macro.playing or "-"
    local extra = ""
    if not CONFIG.enabled then
        extra = " | PAUSED"
    elseif Ctl.checkActive then
        extra = " | HUMAN CHECK: paused"
    elseif job and job.afk and Ctl.afkDone then
        extra = " | AFK parked"
    end
    return string.format("%s | wave %s | run %d%s | job %s | macro %s%s",
        Ctl.phase and Ctl.phase.cur or "?", snap and snap.wave and tostring(snap.wave) or "-",
        Ctl.runsDone, limit, job and job.name or "?", macro, extra)
end

function Ctl.rejoin()
    Ctl.lastRejoin = os.clock()
    local placeId = tonumber(CONFIG.rejoinLobbyPlaceId) or game.PlaceId
    Log.add("teleporting to place " .. tostring(placeId))
    local ok, err = pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
    if not ok then Log.add("teleport failed: " .. tostring(err)) end
end

function Ctl.advanceJob()
    Ctl.jobIndex = Jobs.nextIndex(Ctl.jobIndex)
    Ctl.runsDone = 0
    Ctl.pendingAdvance = false
    Ctl.afkDone = false
    Cfg.state.jobIndex, Cfg.state.runsDone = Ctl.jobIndex, 0
    Cfg.save()
    local j = Ctl.job()
    Log.add("next job: " .. (j and j.name or "?"))
end

-- ------------------------------ phase entries -------------------------------
function Ctl.startMatchMacro(snap)
    if not (CONFIG.enabled and CONFIG.autoMatchMacro) or Ctl.checkActive then return end
    local job = Ctl.job()
    if job and job.afk then return end -- an AFK job has no match macro
    local name = job and job.match
    if not name then
        Log.add("job '" .. tostring(job and job.name) .. "' has no match macro set", "nomm", 120)
        return
    end
    if not Macro.exists(name) then
        Log.add("match macro '" .. name .. "' not found: record it first", "nomm_" .. name, 120)
        return
    end
    if snap.wave and snap.wave > CONFIG.maxStartWave then
        Log.add(string.format("joined at wave %d: macro skipped for this match", snap.wave))
        return
    end
    local token, session = Ctl.token, Ctl.session
    task.spawn(function()
        Macro.play(name, function() return token ~= Ctl.token or session ~= Ctl.session end)
    end)
end

function Ctl.onEnter(cur, prev, snap)
    Log.add(string.format("phase %s -> %s%s", prev, cur, snap.wave and (" (wave " .. snap.wave .. ")") or ""))
    Ctl.cancelMacros() -- a running macro belongs to the previous phase
    if cur == "match" then
        Ctl.session = Ctl.session + 1
        Ctl.speedTries, Ctl.lastSkip, Ctl.lastSpeed = 0, 0, 0
        Ctl.lastVote, Ctl.voteSeenSince = -1e9, nil
        Ctl.startMatchMacro(snap)
    elseif cur == "results" then
        Ctl.runsDone = Ctl.runsDone + 1
        Ctl.resultAttempts, Ctl.lastResultClick = 0, 0
        Cfg.state.runsDone, Cfg.state.jobIndex = Ctl.runsDone, Ctl.jobIndex
        Cfg.save()
        local job = Ctl.job()
        Log.add(string.format("match finished: run %d%s", Ctl.runsDone,
            (job and job.runs > 0) and ("/" .. job.runs) or ""))
    elseif cur == "lobby" then
        Ctl.lastLobbyRun = -1e9
        Ctl.afkDone = false -- a fresh lobby: the AFK spot has to be entered again
        if Ctl.pendingAdvance then Ctl.advanceJob() end
    end
end

-- ------------------------------ phase handlers ------------------------------
function Ctl.handleResults(snap, now)
    if not CONFIG.autoResults then return end
    if now - Ctl.lastResultClick < CONFIG.resultClickInterval then return end
    local wantLeave = Jobs.limitReached(Ctl.job(), Ctl.runsDone)
    local order
    if wantLeave then
        order = { "leave" }
    else
        order = { "replay", "nextStage" }
        if CONFIG.leaveIfNoReplay and (now - Ctl.phase.since) >= CONFIG.leavePatience then
            order[#order + 1] = "leave"
        end
    end
    for _, g in ipairs(order) do
        local hit = Scan.pick(snap.hits[g])
        if hit then
            Ctl.resultAttempts = Ctl.resultAttempts + 1
            Ctl.lastResultClick = now
            if g == "leave" and wantLeave then Ctl.pendingAdvance = true end
            Scan.click(hit, Ctl.resultAttempts, "results/" .. g)
            return
        end
    end
    Log.add("results screen detected but no usable replay/next/leave button", "res_none", 20)
end

function Ctl.handleSpeed(snap, now)
    local s = snap.speedObj
    if not s or s.value == CONFIG.targetSpeed then return end
    if Ctl.speedTries >= CONFIG.speedMaxTries or (now - Ctl.lastSpeed) < CONFIG.speedInterval then return end
    local hit = { obj = s.obj, text = Util.normalize(s.obj.Text) }
    if Gui.blocked(s.obj, hit.text) then return end
    Ctl.speedTries = Ctl.speedTries + 1
    Ctl.lastSpeed = now
    Scan.click(hit, Ctl.speedTries, string.format("speed %dx -> %dx", s.value, CONFIG.targetSpeed))
end

-- Event votes (Summer Hunt weather / cards). CONFIG.patterns.vote is an ordered preference list:
-- the visible option that ranks highest is clicked. Safeguards: the vote screen must have been
-- visible for voteSettle seconds (options may fade in one by one), and after ONE click nothing in
-- this group is clicked for voteCooldown seconds, so a screen that stays open never flips the pick.
function Ctl.handleVote(snap, now)
    local options = {} -- only text that is a button or sits inside one counts as an option
    for _, h in ipairs(snap.hits.vote or {}) do
        if Gui.clickable(h.obj) then options[#options + 1] = h end
    end
    if #options == 0 then
        Ctl.voteSeenSince = nil
        return
    end
    Ctl.voteSeenSince = Ctl.voteSeenSince or now
    if (now - Ctl.voteSeenSince) < CONFIG.voteSettle then return end
    if (now - Ctl.lastVote) < CONFIG.voteCooldown then return end
    for _, phrase in ipairs(Scan.groups.vote or {}) do
        for _, h in ipairs(options) do
            if h.phrase == phrase and not Gui.blocked(h.obj, h.text) then
                Ctl.lastVote = now
                Scan.click(h, 1, "vote")
                return
            end
        end
    end
end

function Ctl.handleMatch(snap, now)
    if CONFIG.autoSkip and (now - Ctl.lastSkip) >= CONFIG.skipInterval then
        local hit = Scan.pick(snap.hits.skip)
        if hit then
            Ctl.lastSkip = now
            Scan.click(hit, 1, "skip")
        end
    end
    if CONFIG.autoVote then Ctl.handleVote(snap, now) end
    if CONFIG.autoSpeed then Ctl.handleSpeed(snap, now) end
end

function Ctl.handleLobby(_, now)
    if not CONFIG.autoLobbyMacro or Ctl.lobbyBusy then return end
    local job = Ctl.job()
    if job and job.afk and Ctl.afkDone then return end -- parked: anti-AFK keeps the session alive
    if (now - Ctl.phase.since) < CONFIG.lobbyDelay or (now - Ctl.lastLobbyRun) < CONFIG.lobbyRetry then return end
    local name = job and job.lobby
    if not name then
        Log.add("job '" .. tostring(job and job.name) .. "' has no lobby macro set", "nolm", 120)
        return
    end
    if not Macro.exists(name) then
        Log.add("lobby macro '" .. name .. "' not found: record it first", "nolm_" .. name, 120)
        return
    end
    Ctl.lobbyBusy = true
    Ctl.lastLobbyRun = now
    local token = Ctl.token
    task.spawn(function()
        local ok, finished = pcall(Macro.play, name, function() return token ~= Ctl.token end)
        Ctl.lobbyBusy = false
        if ok and finished == true and job and job.afk and token == Ctl.token then
            Ctl.afkDone = true
            Log.add("AFK macro finished: parked here, anti-AFK stays on")
        end
    end)
end

function Ctl.handleClaim(snap, now)
    if (now - Ctl.lastClaim) < CONFIG.claimInterval then return end
    for _, h in ipairs(snap.hits.claim or {}) do
        local target = Gui.clickable(h.obj) or h.obj
        local last = Ctl.claimed[target]
        if not (last and (now - last) < CONFIG.claimCooldown) and not Gui.blocked(h.obj, h.text) then
            Ctl.claimed[target] = now
            Ctl.lastClaim = now
            Scan.click(h, 1, "claim")
            return
        end
    end
end

function Ctl.watchdog(now)
    local limit = CONFIG.stuckMinutes * 60
    if limit <= 0 then return end
    if (now - Ctl.phase.since) > limit and (now - Ctl.lastRejoin) > limit then
        Log.add(string.format("phase '%s' unchanged for %d min: rejoining", Ctl.phase.cur, CONFIG.stuckMinutes))
        Ctl.rejoin()
    end
end

-- A human-verification prompt needs a person. While one is visible every automatic click and
-- macro stops; automation resumes `checkClearDelay` seconds after it is gone. Never solves it.
function Ctl.humanCheck(snap, now)
    if not CONFIG.pauseOnCheck then
        Ctl.checkActive = false
        return false
    end
    local hit = snap.hits.check and snap.hits.check[1]
    if hit then
        Ctl.checkLast = now
        if not Ctl.checkActive then
            Ctl.checkActive = true
            Ctl.cancelMacros()
            Log.add("human-check prompt visible ('" .. hit.text .. "'): automation paused, answer it yourself")
        end
    elseif Ctl.checkActive and (now - Ctl.checkLast) >= CONFIG.checkClearDelay then
        Ctl.checkActive = false
        Log.add("human-check prompt gone: automation resumed")
    end
    return Ctl.checkActive
end

function Ctl.step()
    local now = os.clock()
    local snap = Scan.pass()
    Ctl.humanCheck(snap, now)
    local changed, prev = Phase.step(Ctl.phase, Phase.compute(snap), now, CONFIG.stateDebounce)
    if changed then Ctl.onEnter(Ctl.phase.cur, prev, snap) end
    if not CONFIG.enabled or Ctl.checkActive then return end
    local cur = Ctl.phase.cur
    if cur == "results" then
        Ctl.handleResults(snap, now)
    elseif cur == "match" then
        Ctl.handleMatch(snap, now)
    else
        Ctl.handleLobby(snap, now)
    end
    if CONFIG.autoClaim then Ctl.handleClaim(snap, now) end
    Ctl.watchdog(now)
end

function Ctl.start()
    Ctl.jobIndex = Util.clamp(Cfg.state.jobIndex, 1, #CONFIG.jobs)
    Ctl.runsDone = Cfg.state.runsDone
    Ctl.phase = Phase.new("lobby", os.clock())
    task.spawn(function()
        while App.alive do
            local ok, err = pcall(Ctl.step)
            if not ok then Log.add("controller error: " .. tostring(err), "ctlerr", 10) end
            task.wait(CONFIG.tick)
        end
    end)
end

function Ctl.playManual(name)
    name = Util.sanitizeName(name)
    if not name then
        Log.add("invalid macro name")
        return
    end
    Ctl.manualId = Ctl.manualId + 1
    local id = Ctl.manualId
    task.spawn(function()
        Macro.play(name, function() return id ~= Ctl.manualId end)
    end)
end

function Ctl.stopManual()
    Ctl.manualId = Ctl.manualId + 1
    Ctl.cancelMacros()
end

-- ================================== FEATURES =================================
local Features = { redeeming = false }

function Features.antiAfk()
    local conn = LocalPlayer.Idled:Connect(function()
        if not CONFIG.antiAfk then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
    App.conns[#App.conns + 1] = conn
end

-- Reconnects through the lobby place when Roblox shows the disconnect prompt.
function Features.autoRejoin()
    task.spawn(function()
        local ok, overlay = pcall(function()
            return CoreGui:WaitForChild("RobloxPromptGui", 15):WaitForChild("promptOverlay", 15)
        end)
        if not ok or not overlay then
            Log.add("auto-rejoin: Roblox prompt overlay not reachable, feature inactive")
            return
        end
        local conn = overlay.ChildAdded:Connect(function(child)
            if CONFIG.autoRejoin and child.Name == "ErrorPrompt" then
                Log.add("disconnect prompt detected")
                task.wait(2)
                Ctl.rejoin()
            end
        end)
        App.conns[#App.conns + 1] = conn
    end)
end

function Features.persistAcrossTeleports()
    if not Cap.queue then
        Log.add("queue_on_teleport unavailable: put the script in autoexec to survive teleports")
        return
    end
    if not FS.exists(CONFIG.selfFile) then
        Log.add("save this script as workspace/" .. CONFIG.selfFile .. " to re-run after teleports")
        return
    end
    pcall(Cap.queue, string.format("loadstring(readfile(%q))()", CONFIG.selfFile))
end

local REDEEM_WORDS = { "redeem", "claim", "submit", "enter", "apply", "confirm" }

local function findCodeBox()
    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg ~= Gui.ownGui and sg:IsA("ScreenGui") and sg.Enabled then
            for _, d in ipairs(sg:GetDescendants()) do
                if d:IsA("TextBox") and Gui.visible(d) then
                    local label = string.lower(d.PlaceholderText .. " " .. d.Name)
                    if string.find(label, "code", 1, true) then return d end
                end
            end
        end
    end
    return nil
end

local function findRedeemButton(box)
    local scope = box.Parent
    for _ = 1, 2 do
        if scope and scope.Parent and scope.Parent ~= PlayerGui then scope = scope.Parent end
    end
    for _, d in ipairs(scope and scope:GetDescendants() or {}) do
        if d:IsA("GuiButton") and Gui.visible(d) then
            local norm = Gui.textOf(d)
            if Util.findPhrase(norm, REDEEM_WORDS) and not Gui.blocked(d, norm) then return d end
        end
    end
    return nil
end

-- No redeem button next to the box: submit like a player would. Focus the box, set the text,
-- press Enter. Game code that listens to FocusLost(enterPressed) never fires from setting .Text
-- alone, and focusing a box with ClearTextOnFocus wipes it, so the text goes in AFTER focusing.
-- Returns how the code was sent, for the log.
local function submitWithEnter(box, code)
    local entered = false
    local conn = box.FocusLost:Connect(function(enterPressed)
        if enterPressed then entered = true end
    end)
    pcall(function() box:CaptureFocus() end)
    task.wait(0.15)
    box.Text = code
    task.wait(0.2)
    Input.key("Return")
    task.wait(0.3)
    pcall(function() box:ReleaseFocus() end)
    conn:Disconnect()
    if entered then return "Enter key" end
    if Cap.firesignal and pcall(firesignal, box.FocusLost, true) then return "FocusLost signal (Enter not seen)" end
    return "Enter key (not confirmed)"
end

-- The Codes window must already be open (it is a UI step the game does not expose by name).
function Features.redeemCodes()
    if Features.redeeming then return end
    Features.redeeming = true
    task.spawn(function()
        local box = findCodeBox()
        if not box then
            Log.add("codes: open the in-game Codes window first (no visible code box found)")
        else
            for _, code in ipairs(CONFIG.codes) do
                if not App.alive or not box.Parent then break end
                box.Text = code
                task.wait(0.4)
                local btn = findRedeemButton(box)
                local how
                if btn then
                    Input.clickGui(btn, 1, CONFIG.clickMethod)
                    how = "redeem button"
                else
                    how = submitWithEnter(box, code)
                end
                Log.add("codes: tried " .. code .. " via " .. how)
                task.wait(2)
            end
        end
        Features.redeeming = false
    end)
end

-- =============================== DIAGNOSTICS =================================
-- These exist so build-specific wording / remotes can be captured and pasted back.
local Diag = {}

function Diag.dumpUi()
    local lines = {}
    local function add(s) lines[#lines + 1] = s end
    local snap = Scan.pass()
    add(string.format("# UI dump %s  place %s  observed phase %s  wave %s",
        os.date("%Y-%m-%d %H:%M:%S"), tostring(game.PlaceId), Phase.compute(snap), tostring(snap.wave)))
    add("speed label: " .. (snap.speedObj and (snap.speedObj.value .. "x") or "none"))
    for g, list in pairs(snap.hits) do
        add(string.format("pattern group '%s': %d visible hit(s)", g, #list))
        for _, h in ipairs(list) do
            add(string.format("    %s [%s] '%s'", table.concat(Gui.pathOf(h.obj), "/"), h.obj.ClassName, h.text))
        end
    end
    add("")
    add("## visible buttons")
    local nb, nl = 0, 0
    local labels = {}
    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg ~= Gui.ownGui and sg:IsA("ScreenGui") and sg.Enabled then
            for _, d in ipairs(sg:GetDescendants()) do
                if d:IsA("GuiButton") and Gui.visible(d) then
                    nb = nb + 1
                    if nb <= 400 then
                        add(string.format("%s [%s] '%s' %.0fx%.0f", table.concat(Gui.pathOf(d), "/"),
                            d.ClassName, Gui.textOf(d), d.AbsoluteSize.X, d.AbsoluteSize.Y))
                    end
                elseif d:IsA("TextLabel") and d.Text ~= "" and #d.Text <= 80 and Gui.visible(d) then
                    nl = nl + 1
                    if nl <= 300 then
                        labels[#labels + 1] = string.format("%s '%s'", table.concat(Gui.pathOf(d), "/"), Util.normalize(d.Text))
                    end
                end
            end
        end
    end
    add("")
    add("## visible text labels")
    for _, l in ipairs(labels) do add(l) end
    local text = table.concat(lines, "\n")
    local ok, err = FS.write(CONFIG.folder .. "/ui_dump.txt", text)
    if Cap.setclipboard then pcall(setclipboard, text) end
    Log.add(string.format("UI dump: %d buttons, %d labels -> %s%s", nb, nl, CONFIG.folder .. "/ui_dump.txt",
        ok and (Cap.setclipboard and " (also copied)" or "") or (" (file write failed: " .. tostring(err) .. ")")))
end

local Remotes = { enabled = false, installed = false, entries = {}, rate = {} }

local function fmtValue(v, depth)
    local t = typeof(v)
    if t == "string" then return string.format("%q", string.sub(v, 1, 80)) end
    if t == "number" or t == "boolean" or t == "nil" then return tostring(v) end
    if t == "Instance" then return "Instance<" .. v:GetFullName() .. ">" end
    if t == "table" then
        if depth >= 3 then return "{...}" end
        local parts, n = {}, 0
        for k, x in pairs(v) do
            n = n + 1
            if n > 12 then
                parts[#parts + 1] = "..."
                break
            end
            parts[#parts + 1] = "[" .. fmtValue(k, depth + 1) .. "]=" .. fmtValue(x, depth + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return t .. "(" .. tostring(v) .. ")"
end

function Remotes.record(remote, method, args)
    local now = os.clock()
    local r = Remotes.rate[remote]
    if not r or now - r.t > 1 then
        r = { t = now, n = 0 }
        Remotes.rate[remote] = r
    end
    r.n = r.n + 1
    if r.n > 6 then return end -- per-remote flood guard (position/heartbeat style remotes)
    local parts = {}
    for i = 1, args.n do parts[i] = fmtValue(args[i], 0) end
    Remotes.entries[#Remotes.entries + 1] = string.format("%s  %s:%s(%s)", os.date("%H:%M:%S"),
        remote:GetFullName(), method, table.concat(parts, ", "))
    if #Remotes.entries > 2000 then table.remove(Remotes.entries, 1) end
end

function Remotes.install()
    if Remotes.installed then return true end
    if not Cap.hook then return false, "executor lacks hookmetamethod/getnamecallmethod" end
    local old
    local function hook(self, ...)
        local method = getnamecallmethod() -- must be read before any other method call
        if Remotes.enabled and (method == "FireServer" or method == "InvokeServer")
            and typeof(self) == "Instance" and not (checkcaller and checkcaller()) then
            local args = table.pack(...)
            task.defer(function() pcall(Remotes.record, self, method, args) end)
        end
        if setnamecallmethod then setnamecallmethod(method) end
        return old(self, ...)
    end
    local ok, res = pcall(hookmetamethod, game, "__namecall", newcclosure and newcclosure(hook) or hook)
    if not ok then return false, tostring(res) end
    old = res
    Remotes.installed = true
    return true
end

function Remotes.toggle()
    if Remotes.enabled then
        Remotes.enabled = false
        local text = table.concat(Remotes.entries, "\n")
        local ok = FS.write(CONFIG.folder .. "/remotes.txt", text)
        if Cap.setclipboard and #text > 0 then pcall(setclipboard, text) end
        Log.add(string.format("remote log stopped: %d calls%s", #Remotes.entries,
            ok and (" -> " .. CONFIG.folder .. "/remotes.txt") or " (file write failed)"))
        return false
    end
    local ok, err = Remotes.install()
    if not ok then
        Log.add("remote log unavailable: " .. tostring(err))
        return false
    end
    Remotes.entries, Remotes.rate = {}, {}
    Remotes.enabled = true
    Log.add("remote log started: play one loop, then press the button again to save it")
    return true
end

-- ===================================== UI ====================================
local UI = { gui = nil, root = nil, status = nil, logLabel = nil, refreshers = {} }

local THEME = {
    bg = Color3.fromRGB(24, 24, 30), panel = Color3.fromRGB(38, 38, 50),
    on = Color3.fromRGB(58, 140, 92), off = Color3.fromRGB(110, 58, 58),
    accent = Color3.fromRGB(88, 76, 170), text = Color3.fromRGB(235, 235, 240),
    dim = Color3.fromRGB(160, 160, 176),
}

local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function currentJob()
    return Jobs.get(Ctl.jobIndex)
end

local function markJobsEdited()
    Cfg.state.jobsEdited = true
    Cfg.save()
end

function UI.build()
    local gui = make("ScreenGui", {
        Name = "ynoez" .. tostring(math.random(1000, 9999)), ResetOnSpawn = false,
        IgnoreGuiInset = true, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, nil)
    local parented = false
    if Cap.gethui then parented = pcall(function() gui.Parent = gethui() end) end
    if not parented then parented = pcall(function() gui.Parent = CoreGui end) end
    if not parented then gui.Parent = PlayerGui end
    UI.gui = gui
    Gui.ownGui = gui -- excluded from every scan and from the recorder

    local root = make("Frame", {
        Name = "Root", Size = UDim2.new(0, 300, 0, 0), Position = UDim2.new(0, 24, 0, 90),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Active = true,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, gui)
    UI.root, Gui.ownFrame = root, root
    make("UICorner", { CornerRadius = UDim.new(0, 8) }, root)
    make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, root)
    make("UIPadding", { PaddingBottom = UDim.new(0, 6) }, root)

    -- title bar (drag handle + collapse)
    local title = make("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
        LayoutOrder = 1, Active = true,
    }, root)
    make("UICorner", { CornerRadius = UDim.new(0, 8) }, title)
    make("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1,
        Text = "ynoez  v" .. App.version, TextColor3 = THEME.text, Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, title)
    local collapse = make("TextButton", {
        Size = UDim2.new(0, 24, 0, 20), Position = UDim2.new(1, -28, 0, 4), Text = "-",
        BackgroundColor3 = THEME.panel, TextColor3 = THEME.text, Font = Enum.Font.GothamBold,
        TextSize = 14, BorderSizePixel = 0,
    }, title)

    local body = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 2,
    }, root)
    make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, body)
    make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, body)
    collapse.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
        collapse.Text = body.Visible and "-" or "+"
    end)

    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    UI.status = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "starting...",
        TextColor3 = THEME.text, Font = Enum.Font.Code, TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, body)

    local function grid(items)
        local rows = math.ceil(#items / 2)
        local frame = make("Frame", {
            Size = UDim2.new(1, 0, 0, rows * 28 - 4), BackgroundTransparency = 1, LayoutOrder = nextOrder(),
        }, body)
        make("UIGridLayout", {
            CellSize = UDim2.new(0.5, -2, 0, 24), CellPadding = UDim2.new(0, 4, 0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, frame)
        return frame
    end

    local function addToggle(frame, label, key, onChange)
        local btn = make("TextButton", {
            BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.text,
            LayoutOrder = nextOrder(), Text = "",
        }, frame)
        make("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)
        local function refresh()
            btn.Text = (CONFIG[key] and "ON   " or "OFF  ") .. label
            btn.BackgroundColor3 = CONFIG[key] and THEME.on or THEME.off
        end
        UI.refreshers[#UI.refreshers + 1] = refresh
        btn.MouseButton1Click:Connect(function()
            CONFIG[key] = not CONFIG[key]
            Cfg.save()
            refresh()
            if onChange then onChange(CONFIG[key]) end
        end)
        refresh()
    end

    local function addButton(frame, label, fn)
        local btn = make("TextButton", {
            BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.text,
            BackgroundColor3 = THEME.panel, Text = label, LayoutOrder = nextOrder(),
        }, frame)
        make("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(fn)
            if not ok then Log.add("button '" .. label .. "' failed: " .. tostring(err)) end
        end)
    end

    -- feature toggles
    local tg = grid({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 })
    addToggle(tg, "Farm loop", "enabled")
    addToggle(tg, "Results", "autoResults")
    addToggle(tg, "Skip waves", "autoSkip")
    addToggle(tg, "Event votes", "autoVote")
    addToggle(tg, "Claim", "autoClaim")
    addToggle(tg, "Game speed", "autoSpeed")
    addToggle(tg, "Lobby macro", "autoLobbyMacro")
    addToggle(tg, "Match macro", "autoMatchMacro")
    addToggle(tg, "Anti-AFK", "antiAfk")
    addToggle(tg, "Auto rejoin", "autoRejoin")
    addToggle(tg, "Pause on check", "pauseOnCheck")

    -- macro names of the current job
    local function nameRow(label, field)
        local row = make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = nextOrder() }, body)
        make("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Text = label, TextColor3 = THEME.dim,
            Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local box = make("TextBox", {
            Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = THEME.panel,
            TextColor3 = THEME.text, Font = Enum.Font.Code, TextSize = 12, ClearTextOnFocus = false,
            PlaceholderText = "macro name", Text = "", BorderSizePixel = 0,
        }, row)
        UI.refreshers[#UI.refreshers + 1] = function()
            local j = currentJob()
            box.Text = (j and j[field]) or ""
        end
        box.FocusLost:Connect(function()
            local j = currentJob()
            if not j then return end
            j[field] = Util.sanitizeName(box.Text)
            box.Text = j[field] or ""
            markJobsEdited()
        end)
    end
    nameRow("lobby macro", "lobby")
    nameRow("match macro", "match")

    local mg = grid({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    addButton(mg, "Rec lobby", function()
        local j = currentJob()
        local ok, err = Macro.startRecord((j and j.lobby) or "lobby")
        if not ok then Log.add(tostring(err)) end
    end)
    addButton(mg, "Rec match", function()
        local j = currentJob()
        local ok, err = Macro.startRecord((j and j.match) or "match")
        if not ok then Log.add(tostring(err)) end
    end)
    addButton(mg, "Stop + save", function()
        if not Macro.stopRecord(true) then Log.add("no recording to save") end
    end)
    addButton(mg, "Add waypoint", function()
        local ok, err = Macro.addWaypoint()
        if not ok then Log.add("waypoint: " .. tostring(err)) end
    end)
    addButton(mg, "Play lobby", function()
        local j = currentJob()
        Ctl.playManual(j and j.lobby)
    end)
    addButton(mg, "Play match", function()
        local j = currentJob()
        Ctl.playManual(j and j.match)
    end)
    addButton(mg, "Stop playback", function() Ctl.stopManual() end)
    addButton(mg, "Reset run count", function()
        Ctl.runsDone = 0
        Cfg.state.runsDone = 0
        Cfg.save()
        Log.add("run counter reset")
    end)
    -- AFK job: no match, the lobby macro is played once and the script parks there
    local afkBtn = make("TextButton", {
        BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.text,
        LayoutOrder = nextOrder(), Text = "",
    }, mg)
    make("UICorner", { CornerRadius = UDim.new(0, 5) }, afkBtn)
    local function refreshAfk()
        local j = currentJob()
        local on = j and j.afk == true
        afkBtn.Text = (on and "ON   " or "OFF  ") .. "AFK job"
        afkBtn.BackgroundColor3 = on and THEME.on or THEME.off
    end
    UI.refreshers[#UI.refreshers + 1] = refreshAfk
    afkBtn.MouseButton1Click:Connect(function()
        local j = currentJob()
        if not j then return end
        j.afk = not (j.afk == true)
        Ctl.afkDone = false
        markJobsEdited()
        refreshAfk()
    end)
    addButton(mg, "Re-arm AFK", function()
        Ctl.afkDone = false
        Ctl.lastLobbyRun = -1e9
        Log.add("AFK job re-armed: the lobby macro runs again")
    end)

    local tools = grid({ 1, 2, 3, 4, 5, 6 })
    addButton(tools, "Dump UI", Diag.dumpUi)
    addButton(tools, "Log remotes", Remotes.toggle)
    addButton(tools, "Redeem codes", Features.redeemCodes)
    addButton(tools, "Set lobby place", function()
        CONFIG.rejoinLobbyPlaceId = game.PlaceId
        Cfg.save()
        Log.add("rejoin target set to place " .. tostring(game.PlaceId))
    end)
    addButton(tools, "Save log", function()
        local ok = FS.write(CONFIG.folder .. "/log.txt", table.concat(Log.buf, "\n"))
        Log.add(ok and ("log saved to " .. CONFIG.folder .. "/log.txt") or "log save failed")
    end)
    addButton(tools, "Unload", function() App.Unload() end)

    UI.logLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = THEME.panel, BorderSizePixel = 0,
        Text = "", TextColor3 = THEME.dim, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom,
        LayoutOrder = nextOrder(),
    }, body)

    Log.hook = function()
        local n = #Log.buf
        UI.logLabel.Text = table.concat(Log.buf, "\n", math.max(1, n - 7), n)
    end

    -- drag by the title bar
    local dragging, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(input)
        local ut = input.UserInputType
        if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, root.Position
        end
    end)
    App.conns[#App.conns + 1] = UIS.InputChanged:Connect(function(input)
        local ut = input.UserInputType
        if dragging and (ut == Enum.UserInputType.MouseMovement or ut == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    App.conns[#App.conns + 1] = UIS.InputEnded:Connect(function(input)
        local ut = input.UserInputType
        if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then dragging = false end
    end)

    -- show / hide with a key
    App.conns[#App.conns + 1] = UIS.InputBegan:Connect(function(input, processed)
        local okK, kc = pcall(function() return Enum.KeyCode[CONFIG.uiToggleKey] end)
        if okK and kc and not processed and input.KeyCode == kc then root.Visible = not root.Visible end
    end)

    for _, fn in ipairs(UI.refreshers) do fn() end
    task.spawn(function()
        while App.alive do
            if UI.status and UI.status.Parent then UI.status.Text = Ctl.statusText() end
            task.wait(0.5)
        end
    end)
end

-- ================================= LIFECYCLE =================================
function App.Unload()
    if not App.alive then return end
    App.alive = false
    Ctl.cancelMacros()
    Ctl.stopManual()
    pcall(Macro.stopRecord, false)
    Remotes.enabled = false -- an installed namecall hook stays in place but does nothing
    for _, c in ipairs(App.conns) do pcall(function() c:Disconnect() end) end
    App.conns = {}
    for _, fn in ipairs(App.cleanups) do pcall(fn) end
    Log.hook = nil
    if UI.gui then pcall(function() UI.gui:Destroy() end) end
    if ENV.__YNOEZ == App then ENV.__YNOEZ = nil end
end

local function executorName()
    if type(identifyexecutor) ~= "function" then return "unknown" end
    local ok, name, ver = pcall(identifyexecutor)
    if not ok then return "unknown" end
    return tostring(name) .. (ver and (" " .. tostring(ver)) or "")
end

Cfg.load()
Scan.rebuildGroups() -- CONFIG.patterns may have been edited above

local uiOk, uiErr = pcall(UI.build)
if not uiOk then Log.add("UI failed to build, running headless: " .. tostring(uiErr)) end

Features.antiAfk()
Features.autoRejoin()
Features.persistAcrossTeleports()
Ctl.start()

Log.add(string.format("v%s loaded | executor %s | place %s", App.version, executorName(), tostring(game.PlaceId)))
Log.add(string.format("caps: signal=%s vim=%s files=%s hook=%s queue=%s",
    tostring(Cap.firesignal or Cap.getconnections), tostring(VIM ~= nil),
    tostring(Cap.writefile and Cap.readfile), tostring(Cap.hook), tostring(Cap.queue ~= nil)))
for _, jobMacro in ipairs({ "lobby", "match" }) do
    local j = Jobs.get(Ctl.jobIndex)
    local name = j and j[jobMacro]
    if name and not Macro.exists(name) then
        Log.add(string.format("no %s macro '%s' yet: use Rec %s", jobMacro, name, jobMacro))
    end
end