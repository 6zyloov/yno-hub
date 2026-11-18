-- yno hub | anime crusaders x
-- v4.0.1 | 2026-11-17
-- Rebuilt around explicit game workflows, documented Solara input APIs,
-- ranked visible-UI matching, cancellable tasks, and a compact LixHub-inspired UI.
-- Uses visible UI, ordinary key input, ProximityPrompts and the game's native Macro.
-- No private RemoteEvent calls, inventory editing, currency editing or anti-cheat bypass.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ENV = (type(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "yno_hub_runtime"

if ENV[RUNTIME_KEY] and type(ENV[RUNTIME_KEY].Unload) == "function" then
    pcall(ENV[RUNTIME_KEY].Unload)
end

local THEME = {
    bg = Color3.fromRGB(5, 8, 13),
    sidebar = Color3.fromRGB(7, 12, 19),
    surface = Color3.fromRGB(13, 20, 29),
    surface2 = Color3.fromRGB(18, 27, 38),
    surface3 = Color3.fromRGB(27, 39, 53),
    line = Color3.fromRGB(48, 64, 82),
    text = Color3.fromRGB(233, 238, 244),
    muted = Color3.fromRGB(144, 159, 176),
    accent = Color3.fromRGB(111, 151, 181),
    accentDark = Color3.fromRGB(36, 60, 82),
    green = Color3.fromRGB(135, 184, 153),
    amber = Color3.fromRGB(196, 160, 105),
    red = Color3.fromRGB(190, 108, 108),
}

local WORLDS = {
    "Planet Namak",
    "Marine's Ford",
    "Karakura Town",
    "Shibuya",
    "Demon District",
    "Devil City",
    "Soul Society",
    "West City (Ruined)",
    "Culling Games",
    "Doldrey",
    "Sword Arena",
}

local state = {
    running = true,
    page = "Overview",
    minimized = false,
    generation = 0,
    storyRunning = false,
    tasks = {},
    connections = {},
    toggles = {
        autoVoteStart = false,
        autoSkip = false,
        autoNext = false,
        autoReplay = false,
        autoClaim = false,
        autoHunt = false,
        autoPerfect = false,
        lowEffects = false,
        hideAttackEffects = false,
    },
    values = {
        questCategory = "Daily",
        storyWorld = "Planet Namak",
        storyAct = "Act 1",
        storyDifficulty = "Normal",
        storyRoute = "Individual Act",
        storyEntry = "Matchmaking",
        macroMode = "Loop",
        blankUnit = "Shadow (Atomic)",
        youtubeChannel = "",
        fpsCap = "60",
        uiScale = "1.00",
    },
    cooldowns = {},
    gameButtons = {},
    gameButtonsAt = 0,
    lastGameScan = 0,
    lastScreenText = "",
    lastScreenTextAt = 0,
    lastQuestClaim = 0,
    lastAutoStart = 0,
    lastAutoSkip = 0,
    lastAutoNext = 0,
    lastAutoReplay = 0,
    lastHuntScan = 0,
    lastHuntPromptScan = 0,
    lastHuntMove = 0,
    lastHuntInteract = 0,
    activeHuntPrompt = nil,
    cachedHuntPrompt = nil,
    logs = {},
    lastLog = "",
    lastLogAt = 0,
    originalLighting = {},
    originalShadows = nil,
    originalAttackEffects = {},
    originalFpsCap = nil,
}

local function norm(value)
    local s = string.lower(tostring(value or ""))
    s = string.gsub(s, "[%p%c]", " ")
    s = string.gsub(s, "%s+", " ")
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function safeFullName(object)
    local ok, result = pcall(function() return object:GetFullName() end)
    return ok and result or tostring(object)
end

local function make(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function round(object, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 4)}, object)
end

local function stroke(object, color, transparency, thickness)
    make("UIStroke", {
        Color = color or THEME.line,
        Transparency = transparency or 0.5,
        Thickness = thickness or 1,
    }, object)
end

local function textLabel(parent, text, size, color, bold, height)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 20),
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextColor3 = color or THEME.text,
        TextSize = size or 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = parent:IsA("GuiObject") and (parent.ZIndex + 1) or 2,
    }, parent)
end

local function trackConnection(connection)
    table.insert(state.connections, connection)
    return connection
end

local function spawnTracked(callback)
    local thread = task.spawn(function()
        local ok, err = pcall(callback)
        if not ok and state.running then
            warn("[yno hub] " .. tostring(err))
        end
    end)
    table.insert(state.tasks, thread)
    return thread
end

local function isVisible(object)
    local current = object
    while current and current ~= game do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        if current:IsA("ScreenGui") and not current.Enabled then
            return false
        end
        current = current.Parent
    end
    return true
end

local function getUiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then
            return result
        end
    end
    local ok, result = pcall(function() return CoreGui end)
    if ok and result then return result end
    return playerGui
end

local uiParent = getUiParent()
local oldGui = uiParent:FindFirstChild("yno_hub")
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

local gui = make("ScreenGui", {
    Name = "yno_hub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, uiParent)

local camera = workspace.CurrentCamera
local view = camera and camera.ViewportSize or Vector2.new(1366, 768)
local uiScale = make("UIScale", {
    Scale = math.clamp(math.min(view.X / 1180, view.Y / 760), 0.64, 1),
}, gui)
state.values.uiScale = string.format("%.2f", uiScale.Scale)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1120, 680),
    BackgroundColor3 = THEME.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1,
}, gui)
round(main, 5)
stroke(main, THEME.line, 0.12, 1)

local bgImage = nil
local bgTint = make("Frame", {
    Name = "BackgroundTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = THEME.bg,
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    ZIndex = 2,
}, main)

local function loadWallpaper()
    if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
        return nil
    end
    local folder = "yno_hub"
    local filePath = folder .. "/yno-background.jpg"
    local url = "https://raw.githubusercontent.com/6zyloov/yno-hub/main/assets/yno-background.jpg"
    local ok = pcall(function()
        if type(isfolder) == "function" and not isfolder(folder) then
            makefolder(folder)
        end
        if type(isfile) ~= "function" or not isfile(filePath) then
            local bytes = game:HttpGet(url)
            if type(bytes) ~= "string" or #bytes < 1000 then
                error("wallpaper download was empty")
            end
            writefile(filePath, bytes)
        end
    end)
    if not ok then return nil end
    local assetOk, asset = pcall(getcustomasset, filePath)
    return assetOk and asset or nil
end

spawnTracked(function()
    local asset = loadWallpaper()
    if asset and state.running and main.Parent then
        bgImage = make("ImageLabel", {
            Name = "BackgroundImage",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = asset,
            ImageColor3 = Color3.fromRGB(228, 236, 244),
            ImageTransparency = 0.32,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 1,
        }, main)
        bgTint.BackgroundTransparency = 0.43
    end
end)

local sidebar = make("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = THEME.sidebar,
    BackgroundTransparency = 0.06,
    Size = UDim2.new(0, 188, 1, 0),
    BorderSizePixel = 0,
    ZIndex = 5,
}, main)
make("Frame", {
    BackgroundColor3 = THEME.line,
    BackgroundTransparency = 0.45,
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BorderSizePixel = 0,
    ZIndex = 6,
}, sidebar)

local brand = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 16),
    Size = UDim2.new(1, -30, 0, 48),
    ZIndex = 7,
}, sidebar)
local logo = make("Frame", {
    BackgroundColor3 = THEME.accentDark,
    Size = UDim2.fromOffset(38, 38),
    BorderSizePixel = 0,
    ZIndex = 8,
}, brand)
round(logo, 6)
local logoLetter = textLabel(logo, "y", 23, THEME.text, true, 36)
logoLetter.TextXAlignment = Enum.TextXAlignment.Center
local brandName = textLabel(brand, "yno hub", 17, THEME.text, true, 22)
brandName.Position = UDim2.new(0, 47, 0, 0)
local brandSubtitle = textLabel(brand, "ANIME CRUSADERS X", 8, THEME.muted, true, 16)
brandSubtitle.Position = UDim2.new(0, 48, 0, 24)

textLabel(sidebar, "MAIN MENU", 8, THEME.muted, true, 17).Position = UDim2.new(0, 15, 0, 78)

local navHolder = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 103),
    Size = UDim2.new(1, -16, 0, 440),
    ZIndex = 7,
}, sidebar)
local navLayout = make("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, navHolder)

local content = make("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 204, 0, 0),
    Size = UDim2.new(1, -220, 1, 0),
    ZIndex = 5,
}, main)

local topbar = make("Frame", {
    Name = "Topbar",
    BackgroundColor3 = THEME.bg,
    BackgroundTransparency = 0.15,
    Size = UDim2.new(1, 0, 0, 55),
    BorderSizePixel = 0,
    ZIndex = 7,
}, content)
textLabel(topbar, "COMMAND CENTER", 8, THEME.muted, true, 13).Position = UDim2.new(0, 0, 0, 4)
local pageTitle = textLabel(topbar, "Overview", 18, THEME.text, true, 25)
pageTitle.Position = UDim2.new(0, 0, 0, 21)

local searchBox = make("TextBox", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -165, 0, 14),
    Size = UDim2.fromOffset(182, 28),
    BackgroundColor3 = THEME.surface2,
    Text = "",
    PlaceholderText = "Search controls...",
    PlaceholderColor3 = THEME.muted,
    TextColor3 = THEME.text,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    BorderSizePixel = 0,
    ZIndex = 9,
}, topbar)
round(searchBox, 3)
stroke(searchBox, THEME.line, 0.55, 1)

local readyPill = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -76, 0, 16),
    Size = UDim2.fromOffset(68, 23),
    BackgroundColor3 = Color3.fromRGB(22, 45, 40),
    Text = "● READY",
    TextColor3 = THEME.green,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 9,
}, topbar)
round(readyPill, 3)

local minimizeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -40, 0, 16),
    Size = UDim2.fromOffset(27, 23),
    BackgroundColor3 = THEME.surface3,
    Text = "—",
    TextColor3 = THEME.text,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 9,
}, topbar)
round(minimizeButton, 3)

local closeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -5, 0, 16),
    Size = UDim2.fromOffset(27, 23),
    BackgroundColor3 = Color3.fromRGB(55, 32, 35),
    Text = "×",
    TextColor3 = THEME.red,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 9,
}, topbar)
round(closeButton, 3)

local pageScroll = make("ScrollingFrame", {
    Name = "PageScroll",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 63),
    Size = UDim2.new(1, 0, 1, -93),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.accent,
    BorderSizePixel = 0,
    ZIndex = 7,
}, content)
local pageList = make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, pageScroll)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 14),
    PaddingLeft = UDim.new(0, 1),
    PaddingRight = UDim.new(0, 8),
}, pageScroll)

local footer = make("Frame", {
    BackgroundColor3 = THEME.sidebar,
    BackgroundTransparency = 0.1,
    Position = UDim2.new(0, 8, 1, -62),
    Size = UDim2.new(1, -16, 0, 46),
    BorderSizePixel = 0,
    ZIndex = 7,
}, sidebar)
round(footer, 4)
local footerDot = make("Frame", {
    BackgroundColor3 = THEME.green,
    Position = UDim2.new(0, 10, 0, 18),
    Size = UDim2.fromOffset(7, 7),
    BorderSizePixel = 0,
    ZIndex = 9,
}, footer)
round(footerDot, 5)
textLabel(footer, "CLIENT READY", 8, THEME.green, true, 13).Position = UDim2.new(0, 24, 0, 6)
local footerStatus = textLabel(footer, "yno hub 4.0.0", 8, THEME.muted, false, 13)
footerStatus.Position = UDim2.new(0, 24, 0, 22)

local toast = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -22),
    Size = UDim2.fromOffset(340, 35),
    BackgroundColor3 = THEME.surface3,
    BackgroundTransparency = 0.08,
    Text = "",
    TextColor3 = THEME.text,
    TextSize = 9,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 50,
}, gui)
round(toast, 4)
stroke(toast, THEME.line, 0.2, 1)
make("UIPadding", {PaddingLeft = UDim.new(0, 11)}, toast)

local function log(message, level)
    local value = tostring(message)
    local now = os.clock()
    if state.lastLog == value and now - state.lastLogAt < 1.25 then return end
    state.lastLog = value
    state.lastLogAt = now
    table.insert(state.logs, 1, {time = os.date("%H:%M:%S"), message = value, level = level or "info"})
    while #state.logs > 12 do table.remove(state.logs) end

    footerStatus.Text = string.sub(value, 1, 36)
    footerStatus.TextColor3 = level == "error" and THEME.red or (level == "success" and THEME.green or THEME.muted)

    toast.Text = value
    toast.TextColor3 = level == "error" and THEME.red or (level == "success" and THEME.green or THEME.text)
    toast.Visible = true
    task.delay(2.8, function()
        if toast and toast.Parent and toast.Text == value then
            toast.Visible = false
        end
    end)
end

pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageList.AbsoluteContentSize.Y + 26)
end)

local function getButtonText(button)
    local parts = {}
    if button:IsA("TextButton") and button.Text ~= "" then
        table.insert(parts, norm(button.Text))
    end
    table.insert(parts, norm(button.Name))
    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Text and child.Text ~= "" then
                table.insert(parts, norm(child.Text))
            end
        end
    end
    return table.concat(parts, " ")
end

local function getContextText(object)
    local parts = {}
    local node = object
    for _ = 1, 7 do
        if not node or node == playerGui then break end
        table.insert(parts, norm(node.Name))
        if node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox") then
            table.insert(parts, norm(node.Text))
        end
        local parent = node.Parent
        if parent then
            for _, sibling in ipairs(parent:GetChildren()) do
                if sibling ~= node and (sibling:IsA("TextLabel") or sibling:IsA("TextButton")) then
                    local siblingText = norm(sibling.Text)
                    if siblingText ~= "" and #siblingText < 90 then
                        table.insert(parts, siblingText)
                    end
                end
            end
        end
        node = parent
    end
    return table.concat(parts, " ")
end

local function getGameButtons(forceRefresh)
    local now = os.clock()
    if not forceRefresh and now - state.gameButtonsAt < 0.5 then
        return state.gameButtons
    end

    local found = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if item:IsA("GuiButton") and item.Parent and isVisible(item) then
                local active = true
                pcall(function()
                    active = item.Active and item.Interactable
                end)
                if active and not item:IsDescendantOf(gui) then
                    table.insert(found, item)
                end
            end
        end
    end

    state.gameButtons = found
    state.gameButtonsAt = now
    return found
end

local function scoreButton(button, labels, contextHint, partial)
    local ownText = button:IsA("TextButton") and norm(button.Text) or ""
    local ownName = norm(button.Name)
    local allText = getButtonText(button)
    local context = getContextText(button)
    local contextScore = contextHint and string.find(context, norm(contextHint), 1, true) and 24 or 0
    local score = -1

    for _, phrase in ipairs(labels) do
        local target = norm(phrase)
        if target ~= "" then
            local localScore = -1
            if ownText == target then
                localScore = 120
            elseif ownName == target then
                localScore = 108
            else
                for _, child in ipairs(button:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        local childText = norm(child.Text)
                        if childText == target then
                            localScore = math.max(localScore, 112)
                        elseif partial and string.find(childText, target, 1, true) then
                            localScore = math.max(localScore, 78)
                        end
                    end
                end
                if partial and localScore < 0 then
                    if string.find(ownText, target, 1, true) then
                        localScore = 88
                    elseif string.find(ownName, target, 1, true) then
                        localScore = 82
                    elseif string.find(allText, target, 1, true) then
                        localScore = 68
                    end
                end
            end
            score = math.max(score, localScore)
        end
    end

    if score < 0 then return -1 end
    score = score + contextScore
    local area = button.AbsoluteSize.X * button.AbsoluteSize.Y
    score = score + math.min(area / 25000, 5)
    score = score + math.min(button.ZIndex * 0.02, 1)
    return score
end

local function findGameButton(labels, contextHint, partial, forceRefresh)
    local best, bestScore = nil, -math.huge
    for _, button in ipairs(getGameButtons(forceRefresh)) do
        local size = button.AbsoluteSize
        if size.X > 2 and size.Y > 2 then
            local score = scoreButton(button, labels, contextHint, partial == true)
            if score > bestScore then
                best = button
                bestScore = score
            end
        end
    end
    if best then return best, bestScore end
    return nil, "Não encontrei: " .. table.concat(labels, " / ") .. (contextHint and (" (" .. contextHint .. ")") or "")
end

local function isRobloxFocused()
    if type(isrbxactive) == "function" then
        local ok, active = pcall(isrbxactive)
        if ok then return active == true end
    end
    return true
end

local function sendMouseClick(button)
    if not button or not button.Parent or not isVisible(button) then
        return false, "O botão deixou de estar visível."
    end
    local active = true
    pcall(function() active = button.Active and button.Interactable end)
    if not active then return false, "O botão está desativado." end
    if not isRobloxFocused() then return false, "Traga o Roblox para primeiro plano." end

    local center = button.AbsolutePosition + (button.AbsoluteSize / 2)
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
    if viewport and (center.X < 1 or center.Y < 1 or center.X > viewport.X or center.Y > viewport.Y) then
        return false, "O botão está fora da área visível."
    end

    local moved = false
    if type(mousemoveabs) == "function" then
        moved = pcall(mousemoveabs, math.floor(center.X), math.floor(center.Y))
    end

    if moved and type(mouse1press) == "function" and type(mouse1release) == "function" then
        local pressed = pcall(mouse1press)
        task.wait(0.05)
        local released = pcall(mouse1release)
        if pressed and released then return true end
    end

    if moved and type(mouse1click) == "function" then
        local ok = pcall(mouse1click)
        if ok then return true end
    end

    local activated = pcall(function() button:Activate() end)
    if activated then return true end
    return false, "O Solara não conseguiu enviar input para o botão."
end

local function clickGameButton(labels, contextHint, partial, actionKey, cooldown)
    local button, reason = findGameButton(labels, contextHint, partial, true)
    if not button then return false, reason end

    local key = actionKey or safeFullName(button)
    local now = os.clock()
    if state.cooldowns[key] and now - state.cooldowns[key] < (cooldown or 1) then
        return false, "Ação em cooldown."
    end

    local ok, err = sendMouseClick(button)
    if ok then
        state.cooldowns[key] = now
        return true, "Input enviado: " .. table.concat(labels, " / ")
    end
    return false, err
end

local function waitForGameButton(labels, contextHint, timeout, partial, generation)
    local deadline = os.clock() + (timeout or 7)
    while state.running and os.clock() < deadline do
        if generation and generation ~= state.generation then
            return nil, "Ação cancelada."
        end
        local button = findGameButton(labels, contextHint, partial, true)
        if button then return button end
        task.wait(0.2)
    end
    return nil, "Tempo esgotado procurando " .. table.concat(labels, " / ")
end

local function clickGameAndWait(labels, contextHint, timeout, partial, generation)
    local button, reason = waitForGameButton(labels, contextHint, timeout, partial, generation)
    if not button then error(reason) end
    local ok, err = sendMouseClick(button)
    if not ok then error(err) end
    task.wait(0.35)
    if generation and generation ~= state.generation then error("Ação cancelada.") end
    return true
end

local function sendKey(keyCode)
    if not isRobloxFocused() then return false, "Roblox precisa estar em primeiro plano." end
    if type(keyclick) == "function" then
        local ok, err = pcall(keyclick, keyCode)
        return ok, err
    end
    return false, "keyclick não está disponível no Solara."
end

local function screenText(forceRefresh)
    local now = os.clock()
    if not forceRefresh and now - state.lastScreenTextAt < 0.35 then
        return state.lastScreenText
    end
    local parts = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if not item:IsDescendantOf(gui)
                and (item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox"))
                and item.Text and item.Text ~= "" and isVisible(item) then
                table.insert(parts, norm(item.Text))
            end
        end
    end
    state.lastScreenText = table.concat(parts, " | ")
    state.lastScreenTextAt = now
    return state.lastScreenText
end

local function hasScreenText(phrases)
    local haystack = screenText()
    for _, phrase in ipairs(phrases) do
        if string.find(haystack, norm(phrase), 1, true) then return true end
    end
    return false
end

local function clickVisible(labelSet, context, actionKey, cooldown, partial)
    return clickGameButton(labelSet, context, partial, actionKey, cooldown)
end

local function openMacroPanel()
    local alreadyOpen = findGameButton({"Run"}, "macro", false, true)
        or findGameButton({"Units"}, "macro", false, true)
        or findGameButton({"Placement"}, "macro", false, true)
        or (hasScreenText({"Auto upgrade", "Auto abilities", "Show the circles while playing"}) and findGameButton({"Macro"}, nil, false, true))
    if alreadyOpen then return true, "Macro já está aberto." end

    local button = findGameButton({"Macro"}, nil, false, true)
    if not button then
        return false, "Entre em uma partida; o botão Macro fica no lado direito da tela."
    end
    return clickVisible({"Macro"}, nil, "open-macro-panel", 1.3, false)
end

local function openMacroUnits()
    local opened = openMacroPanel()
    if not opened and not hasScreenText({"Units", "Placement", "Run"}) then
        return false, "Não consegui abrir Macro. Entre primeiro em uma partida."
    end
    task.wait(0.3)
    local units = findGameButton({"Units"}, "macro", false, true)
    if units then
        return clickVisible({"Units"}, "macro", "macro-open-units", 1.1, false)
    end
    if hasScreenText({"Slot", "Auto upgrade", "Auto abilities"}) then
        return true, "Macro → Units já está visível."
    end
    return false, "Abra Macro → Units manualmente e tente novamente."
end

local function toggleNativeOption(labelText)
    local target = norm(labelText)
    local bestButton, bestDistance = nil, math.huge

    for _, root in ipairs(playerGui:GetChildren()) do
        for _, labelObject in ipairs(root:GetDescendants()) do
            if not labelObject:IsDescendantOf(gui) and labelObject:IsA("TextLabel")
                and isVisible(labelObject) and norm(labelObject.Text) == target then
                local center = labelObject.AbsolutePosition + (labelObject.AbsoluteSize / 2)
                local parent = labelObject.Parent

                for depth = 1, 4 do
                    if not parent then break end
                    for _, candidate in ipairs(parent:GetDescendants()) do
                        if not candidate:IsDescendantOf(gui) and candidate:IsA("GuiButton")
                            and candidate.Parent and isVisible(candidate) then
                            local candidateCenter = candidate.AbsolutePosition + (candidate.AbsoluteSize / 2)
                            local distance = (candidateCenter - center).Magnitude
                            local width = candidate.AbsoluteSize.X
                            local height = candidate.AbsoluteSize.Y
                            if distance < 145 and width <= 150 and height <= 80 and distance < bestDistance then
                                bestButton = candidate
                                bestDistance = distance
                            end
                        end
                    end
                    parent = parent.Parent
                end
            end
        end
    end

    if not bestButton then
        return false, "Não encontrei o toggle ao lado de " .. labelText .. ". Abra Macro → Units e deixe a opção visível."
    end
    local ok, err = sendMouseClick(bestButton)
    if not ok then return false, err end
    return true, "Toggle enviado para " .. labelText .. ". Confira o estado no jogo."
end

local function runAsync(name, callback)
    if state[name] then return false, "Essa sequência já está em execução." end
    state[name] = true
    local generation = state.generation
    spawnTracked(function()
        local ok, err = pcall(callback, generation)
        state[name] = false
        if ok then
            log(name .. " concluído.", "success")
        elseif state.running then
            log(name .. ": " .. tostring(err), "error")
        end
    end)
    return true, name .. " iniciado."
end

local function storyStep(labels, context, generation, timeout, partial)
    return clickGameAndWait(labels, context, timeout or 8, partial == true, generation)
end

local function startStory()
    local world = state.values.storyWorld
    local act = state.values.storyAct
    local difficulty = state.values.storyDifficulty
    local route = state.values.storyRoute
    local entry = state.values.storyEntry

    if route == "World Skip" and world == "Sword Arena" then
        return false, "Sword Arena não tem World Skip. Escolha Individual Act."
    end

    return runAsync("storyRunning", function(generation)
        storyStep({"Play"}, nil, generation, 8, false)
        storyStep({"Story"}, "play", generation, 8, false)
        storyStep({world}, "story", generation, 8, true)

        if route == "World Skip" then
            storyStep({"World Skip"}, "story", generation, 6, false)
        else
            storyStep({act}, "story", generation, 6, true)
        end

        storyStep({difficulty}, "story", generation, 6, false)
        storyStep({entry}, "story", generation, 6, false)

        if entry == "Matchmaking" then
            log(world .. " / " .. route .. " / " .. difficulty .. " enviado para Matchmaking.", "success")
            return
        end

        storyStep({"Start"}, "select stage", generation, 10, false)
    end)
end

local function openQuests(category)
    local tab = findGameButton({category}, "quest", false, true)
        or findGameButton({category}, nil, false, true)
    if not tab then
        local opened, reason = clickVisible({"Quests"}, nil, "open-quests", 1.2, true)
        if not opened then return false, reason end
        task.wait(0.35)
        tab = findGameButton({category}, "quest", false, true)
            or findGameButton({category}, nil, false, true)
    end
    if not tab then return false, "Não encontrei a aba " .. category .. " na janela Quests." end
    return sendMouseClick(tab)
end

local function claimAllQuests()
    local button = findGameButton({"Claim All"}, "quest", false, true)
    if not button then button = findGameButton({"Claim All"}, nil, false, true) end
    if not button then return false, "Abra Quests, Guide, Event Quests ou Bounties primeiro." end
    return sendMouseClick(button)
end

local function openGuidebook()
    return openQuests("Guide")
end

local function openBounties()
    local button = findGameButton({"Bounties"}, nil, false, true)
    if button then return sendMouseClick(button) end
    if hasScreenText({"Request Board", "Navi"}) then
        return false, "Fale com Navi no Request Board e selecione Bounties."
    end
    return false, "Vá ao Request Board no lobby, fale com Navi e abra Bounties."
end

local function startNativeMacro()
    return runAsync("macroStarting", function(generation)
        local opened, openReason = openMacroPanel()
        if not opened then
            error(openReason or "Entre em uma partida antes de iniciar o Smart Macro.")
        end
        task.wait(0.35)
        if generation ~= state.generation then error("Ação cancelada.") end

        local runButton, reason = waitForGameButton({"Run"}, "macro", 6, false, generation)
        if not runButton then error(reason) end
        local runOk, runErr = sendMouseClick(runButton)
        if not runOk then error(runErr) end
        task.wait(0.25)
        if generation ~= state.generation then error("Ação cancelada.") end

        local mode = state.values.macroMode
        local modeButton, modeReason = waitForGameButton({mode}, "run", 6, false, generation)
        if not modeButton then error("Não achei o modo " .. mode .. ": " .. tostring(modeReason)) end
        local modeOk, modeErr = sendMouseClick(modeButton)
        if not modeOk then error(modeErr) end
        task.wait(0.25)
        if generation ~= state.generation then error("Ação cancelada.") end

        local startButton, startReason = waitForGameButton({"Start"}, "run", 6, false, generation)
        if not startButton then error("Não achei Start no menu Run: " .. tostring(startReason)) end
        local startOk, startErr = sendMouseClick(startButton)
        if not startOk then error(startErr) end
    end)
end

local function stopNativeMacro()
    local pause = findGameButton({"Pause"}, "macro", false, true)
    if pause then return sendMouseClick(pause) end
    local stop = findGameButton({"Stop"}, "macro", false, true)
    if stop then return sendMouseClick(stop) end
    return false, "Painel flutuante do Macro não está visível; use Open no painel nativo."
end

local function findPromptPart(prompt)
    local parent = prompt.Parent
    if parent and parent:IsA("BasePart") then return parent end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) end
    return nil
end

local function findCapturePrompt()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local now = os.clock()
    local cached = state.cachedHuntPrompt
    if cached and cached.prompt and cached.prompt.Parent and cached.prompt.Enabled
        and cached.part and cached.part.Parent and now - state.lastHuntPromptScan < 1.6 then
        cached.distance = (root.Position - cached.part.Position).Magnitude
        return cached
    end
    if now - state.lastHuntPromptScan < 1.6 then return nil end
    state.lastHuntPromptScan = now

    local nearest, nearestDistance = nil, math.huge
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local promptText = norm(object.ActionText .. " " .. object.ObjectText .. " " .. object.Name)
            if string.find(promptText, "capture", 1, true) then
                local part = findPromptPart(object)
                if part then
                    local distance = (root.Position - part.Position).Magnitude
                    if distance < nearestDistance then
                        nearest = {prompt = object, part = part, distance = distance}
                        nearestDistance = distance
                    end
                end
            end
        end
    end
    state.cachedHuntPrompt = nearest
    return nearest
end

local function colorLooksGold(color)
    return color and color.R > 0.58 and color.G > 0.34 and color.B < 0.48 and color.R > color.G * 0.92
end

local function isSameTrack(marker, zone)
    local parents = {}
    local current = marker
    for _ = 1, 5 do
        if not current then break end
        parents[current] = true
        current = current.Parent
    end
    current = zone
    for _ = 1, 5 do
        if not current then break end
        if parents[current] and current:IsA("GuiObject") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function capturePerfectReady()
    local now = os.clock()
    if state.lastCaptureUiScan and now - state.lastCaptureUiScan < 0.25 then
        return state.captureUiReady == true
    end
    state.lastCaptureUiScan = now

    local markers, zones = {}, {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, object in ipairs(root:GetDescendants()) do
            if object:IsA("GuiObject") and object.Visible then
                local name = norm(object.Name)
                if string.find(name, "marker", 1, true)
                    or string.find(name, "needle", 1, true)
                    or string.find(name, "pointer", 1, true) then
                    table.insert(markers, object)
                end

                local isZone = string.find(name, "perfect", 1, true)
                    or string.find(name, "gold", 1, true)
                    or colorLooksGold(object.BackgroundColor3)
                if isZone then table.insert(zones, object) end
            end
        end
    end

    for _, marker in ipairs(markers) do
        for _, zone in ipairs(zones) do
            if marker ~= zone and isSameTrack(marker, zone) then
                local markerX = marker.AbsolutePosition.X + marker.AbsoluteSize.X / 2
                local left = zone.AbsolutePosition.X
                local right = left + zone.AbsoluteSize.X
                local sameBand = math.abs(marker.AbsolutePosition.Y - zone.AbsolutePosition.Y) < 42
                if sameBand and markerX >= left and markerX <= right then
                    state.captureUiReady = true
                    return true
                end
            end
        end
    end
    state.captureUiReady = false
    return false
end

local function startUnitHunt()
    return runAsync("huntStarting", function(generation)
        storyStep({"Events"}, nil, generation, 8, false)
        storyStep({"Unit Hunt"}, "events", generation, 8, false)
        storyStep({"Start Hunt"}, "unit hunt", generation, 8, false)
    end)
end

local function openUnitHuntBook()
    local book = findGameButton({"Book", "Collection Book"}, "unit hunt", false, true)
        or findGameButton({"Book", "Collection Book"}, nil, false, true)
    if not book then
        local unit = findGameButton({"Unit Hunt"}, "events", false, true)
        if not unit then
            local events = clickVisible({"Events"}, nil, "open-events-book", 1.2, false)
            if not events then return false, "Abra Events no menu do jogo." end
            task.wait(0.3)
            unit = findGameButton({"Unit Hunt"}, "events", false, true)
        end
        if not unit then return false, "Não encontrei Unit Hunt na lista de eventos." end
        local ok, err = sendMouseClick(unit)
        if not ok then return false, err end
        task.wait(0.3)
        book = findGameButton({"Book", "Collection Book"}, "unit hunt", false, true)
            or findGameButton({"Book", "Collection Book"}, nil, false, true)
    end
    if not book then return false, "Unit Hunt abriu, mas não apareceu o botão Book." end
    return sendMouseClick(book)
end

local function openEventQuests()
    local quest = findGameButton({"Event Quests"}, "unit hunt", false, true)
    if quest then return sendMouseClick(quest) end

    local hunt = findGameButton({"Unit Hunt"}, "events", false, true)
    if not hunt then
        local events = clickVisible({"Events"}, nil, "open-events-quests", 1.2, false)
        if not events then return false, "Abra Events no menu do jogo." end
        task.wait(0.25)
        hunt = findGameButton({"Unit Hunt"}, "events", false, true)
    end
    if not hunt then return false, "Selecione Unit Hunt em Events." end
    local ok, err = sendMouseClick(hunt)
    if not ok then return false, err end
    task.wait(0.3)
    quest = findGameButton({"Event Quests"}, "unit hunt", false, true)
    if not quest then return false, "Não encontrei Event Quests na página Unit Hunt." end
    return sendMouseClick(quest)
end

local function processUnitHunt()
    if not state.toggles.autoHunt then return end
    local now = os.clock()
    if not hasScreenText({"Hunting Isles", "Hunt Wave"}) then return end

    if state.toggles.autoPerfect and capturePerfectReady() and now - state.lastHuntInteract > 0.16 then
        state.lastHuntInteract = now
        sendKey(0x20)
        return
    end

    local target = findCapturePrompt()
    if target then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local prompt = target.prompt
        local maxDistance = math.max(3, prompt.MaxActivationDistance - 1)

        if state.activeHuntPrompt ~= prompt then
            state.activeHuntPrompt = prompt
            state.lastHuntInteract = 0
        end

        if target.distance > maxDistance then
            if humanoid and now - state.lastHuntMove > 2.0 then
                state.lastHuntMove = now
                local delta = target.part.Position - root.Position
                if delta.Magnitude > 0.1 then
                    local direction = delta.Unit
                    humanoid:MoveTo(target.part.Position - direction * math.min(3, maxDistance * 0.35))
                end
            end
        elseif now - state.lastHuntInteract > 12 then
            state.lastHuntInteract = now
            sendKey(0x45)
        end
    else
        state.activeHuntPrompt = nil
        if now - state.lastHuntScan > 8 then
            state.lastHuntScan = now
            sendKey(0x51)
        end
    end
end

local function claimLoginRewards()
    local claimed = 0
    for _, tabName in ipairs({"Daily", "Anniversary"}) do
        local tab = findGameButton({tabName}, "login", false, true)

        -- Login Rewards closes after a successful claim. Reopen it before
        -- attempting the second track rather than assuming both remain visible.
        if not tab then
            local open = findGameButton({"Login Rewards", "Rewards"}, nil, true, true)
            if open then
                local opened, openError = sendMouseClick(open)
                if not opened then return false, openError end
                task.wait(0.35)
                tab = findGameButton({tabName}, "login", false, true)
            end
        end

        if tab then
            local tabOk, tabError = sendMouseClick(tab)
            if not tabOk then return false, tabError end
            task.wait(0.25)

            local claim = findGameButton({"Claim"}, "login", false, true)
            if claim then
                local claimOk = sendMouseClick(claim)
                if claimOk then
                    claimed = claimed + 1
                    task.wait(0.45)
                end
            end
        end
    end

    if claimed > 0 then return true, "Claims de Login Rewards enviados: " .. tostring(claimed) end
    return false, "Não encontrei Claim disponível nas abas Daily ou Anniversary."
end

local function openHesiaRewards()
    local button = findGameButton({"Free Rewards"}, "hesia", false, true)
    if not button then return false, "Vá até Hesia no lobby, fale com ela e abra Free Rewards." end
    return sendMouseClick(button)
end

local function claimHesiaRewards()
    local button = findGameButton({"Claim Rewards"}, "free rewards", false, true)
    if not button then return false, "Conclua as quatro tarefas sociais de Hesia antes do Claim Rewards." end
    return sendMouseClick(button)
end

local function openYoutubeReward()
    local button = findGameButton({"YouTube Reward"}, nil, false, true)
    if not button then return false, "Abra YouTube Reward no lobby primeiro." end
    return sendMouseClick(button)
end

local function redeemYoutubeReward()
    local channel = tostring(state.values.youtubeChannel or "")
    if channel == "" then return false, "Digite seu nome de canal no campo YouTube channel name." end

    local box
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if not item:IsDescendantOf(gui) and item:IsA("TextBox") and isVisible(item) then
                local context = norm(item.Name .. " " .. item.PlaceholderText .. " " .. getContextText(item))
                if string.find(context, "channel", 1, true) then
                    box = item
                    break
                end
            end
        end
        if box then break end
    end
    if not box then return false, "Campo de canal não encontrado. Abra YouTube Reward e preencha manualmente." end
    box.Text = channel
    local redeem = findGameButton({"Redeem"}, "youtube", false, true)
    if not redeem then return false, "Não encontrei Redeem na tela YouTube Reward." end
    return sendMouseClick(redeem)
end

local function claimKingsIndex()
    local open = findGameButton({"Open Index"}, "king", false, true)
    if open then
        local ok, err = sendMouseClick(open)
        if not ok then return false, err end
        task.wait(0.3)
    end
    local claim = findGameButton({"Claim All"}, "index", false, true)
    if not claim then return false, "Fale com King, abra Open Index e verifique se há recompensas." end
    return sendMouseClick(claim)
end

local function claimBlankUnit()
    local blank = findGameButton({"Blank Tokens"}, nil, false, true)
    if not blank then
        local board = findGameButton({"Bounties"}, nil, false, true)
        if board then
            local ok, err = sendMouseClick(board)
            if not ok then return false, err end
            task.wait(0.25)
        end
        blank = findGameButton({"Blank Tokens"}, nil, false, true)
    end
    if not blank then return false, "Abra Bounty Board → Blank Tokens." end
    local ok, err = sendMouseClick(blank)
    if not ok then return false, err end
    task.wait(0.25)
    local unit = findGameButton({state.values.blankUnit}, nil, false, true)
    if not unit then return false, "Não encontrei " .. state.values.blankUnit .. " na loja. Cada uma custa 30 Blank Tokens." end
    local unitOk, unitErr = sendMouseClick(unit)
    if not unitOk then return false, unitErr end
    task.wait(0.25)
    local claim = findGameButton({"Claim"}, "blank", false, true)
    if not claim then return false, "Confira seu saldo de 30 Blank Tokens e a janela de confirmação." end
    return sendMouseClick(claim)
end

local function setLowEffects(enabled)
    if enabled then
        if state.originalShadows == nil then
            state.originalShadows = Lighting.GlobalShadows
        end
        Lighting.GlobalShadows = false
        for _, effect in ipairs(Lighting:GetDescendants()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect")
                or effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect")
                or effect:IsA("SunRaysEffect") then
                if state.originalLighting[effect] == nil then
                    state.originalLighting[effect] = effect.Enabled
                end
                effect.Enabled = false
            end
        end
        return true, "Low Effects ligado localmente."
    end

    if state.originalShadows ~= nil then
        Lighting.GlobalShadows = state.originalShadows
        state.originalShadows = nil
    end
    for effect, oldValue in pairs(state.originalLighting) do
        if effect and effect.Parent then pcall(function() effect.Enabled = oldValue end) end
    end
    state.originalLighting = {}
    return true, "Efeitos visuais restaurados."
end

local function setHideAttackEffects(enabled)
    if enabled then
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Highlight") then
                if state.originalAttackEffects[object] == nil then
                    state.originalAttackEffects[object] = object.Enabled
                end
                object.Enabled = false
            end
        end
    else
        for object, oldValue in pairs(state.originalAttackEffects) do
            if object and object.Parent then pcall(function() object.Enabled = oldValue end) end
        end
        state.originalAttackEffects = {}
    end
    return true, enabled and "Attack Effects ocultos localmente." or "Attack Effects restaurados."
end

local function applyFpsCap()
    if type(setfpscap) ~= "function" then return false, "setfpscap não está disponível no Solara." end
    local cap = math.clamp(math.floor(tonumber(state.values.fpsCap) or 60), 30, 360)
    if state.originalFpsCap == nil and type(getfpscap) == "function" then
        local ok, previous = pcall(getfpscap)
        if ok then state.originalFpsCap = previous end
    end
    local ok, err = pcall(setfpscap, cap)
    return ok, ok and ("FPS cap definido para " .. tostring(cap) .. ".") or tostring(err)
end

local function restorePerformance()
    setLowEffects(false)
    setHideAttackEffects(false)
    if state.originalFpsCap ~= nil and type(setfpscap) == "function" then
        pcall(setfpscap, state.originalFpsCap)
        state.originalFpsCap = nil
    end
    return true, "Configurações visuais restauradas."
end

local function saveConfig()
    if type(writefile) ~= "function" then return false, "Filesystem indisponível." end
    local payload = {values = state.values}
    local ok, err = pcall(function()
        if type(isfolder) == "function" and not isfolder("yno_hub") then
            makefolder("yno_hub")
        end
        writefile("yno_hub/config.json", HttpService:JSONEncode(payload))
    end)
    return ok, ok and "Preferências salvas em yno_hub/config.json." or tostring(err)
end

local function loadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
    local exists = false
    pcall(function() exists = isfile("yno_hub/config.json") end)
    if not exists then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("yno_hub/config.json"))
    end)
    if not ok or type(data) ~= "table" or type(data.values) ~= "table" then return false end
    for key, value in pairs(data.values) do
        if state.values[key] ~= nil then state.values[key] = value end
    end
    return true
end

local currentSection = nil
local currentColumn = nil
local toggleControls = {}

local function clearPage()
    for _, child in ipairs(pageScroll:GetChildren()) do
        if child ~= pageList and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    table.clear(toggleControls)
    currentSection = nil
    currentColumn = nil
    pageScroll.CanvasPosition = Vector2.new(0, 0)
end

local function addPageHeader(title, description)
    local holder = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 8,
    }, pageScroll)
    textLabel(holder, title, 19, THEME.text, true, 24)
    local sub = textLabel(holder, description, 9, THEME.muted, false, 18)
    sub.Position = UDim2.new(0, 0, 0, 26)
end

local function createColumn(parent, title)
    local column = make("Frame", {
        BackgroundColor3 = THEME.surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0.5, -5, 0, 40),
        BorderSizePixel = 0,
        ZIndex = 8,
    }, parent)
    round(column, 3)
    stroke(column, THEME.line, 0.7, 1)
    local heading = textLabel(column, title, 10, THEME.text, true, 24)
    heading.Position = UDim2.new(0, 10, 0, 3)
    local body = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 7, 0, 31),
        Size = UDim2.new(1, -14, 0, 0),
        ZIndex = 9,
    }, column)
    local layout = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, body)

    local function resize()
        if not column.Parent then return end
        local height = layout.AbsoluteContentSize.Y
        body.Size = UDim2.new(1, -14, 0, height)
        column.Size = UDim2.new(0.5, -5, 0, 37 + height)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    return body, column, resize
end

local function addColumns(leftTitle, rightTitle)
    local group = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 8,
    }, pageScroll)
    local leftBody, leftColumn, resizeLeft = createColumn(group, leftTitle)
    local rightBody, rightColumn, resizeRight = createColumn(group, rightTitle)
    rightColumn.Position = UDim2.new(0.5, 5, 0, 0)
    local function resizeGroup()
        resizeLeft()
        resizeRight()
        group.Size = UDim2.new(1, 0, 0, math.max(leftColumn.AbsoluteSize.Y, rightColumn.AbsoluteSize.Y))
    end
    task.defer(resizeGroup)
    currentColumn = {left = leftBody, right = rightBody, resize = resizeGroup}
    return leftBody, rightBody
end

local function setToggleUi(key, value)
    state.toggles[key] = value == true
    local control = toggleControls[key]
    if control and control.Parent then
        control.Text = state.toggles[key] and "ON" or "OFF"
        control.BackgroundColor3 = state.toggles[key] and THEME.accentDark or THEME.surface3
    end
end

local function addControlRow(parent, title, description, controlText, callback, kind, key, choices)
    local row = make("Frame", {
        BackgroundColor3 = THEME.surface2,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 51),
        BorderSizePixel = 0,
        ZIndex = 9,
    }, parent)
    round(row, 3)
    stroke(row, THEME.line, 0.84, 1)

    local heading = textLabel(row, title, 9, THEME.text, true, 16)
    heading.Position = UDim2.new(0, 9, 0, 5)
    heading.Size = UDim2.new(1, -118, 0, 16)
    local sub = textLabel(row, description, 7, THEME.muted, false, 16)
    sub.Position = UDim2.new(0, 9, 0, 24)
    sub.Size = UDim2.new(1, -16, 0, 16)

    local control
    if kind == "toggle" then
        local active = state.toggles[key] == true
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(40, 20),
            BackgroundColor3 = active and THEME.accentDark or THEME.surface3,
            Text = active and "ON" or "OFF",
            TextColor3 = THEME.text,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, row)
        round(control, 3)
        toggleControls[key] = control
        control.Activated:Connect(function()
            local nextValue = not state.toggles[key]
            if callback then
                local ok, result, message = pcall(callback, nextValue)
                if not ok then
                    log(title .. ": " .. tostring(result), "error")
                    return
                end
                if result == false then
                    log(message or (title .. " não foi alterado."), "warn")
                    return
                end
            end
            setToggleUi(key, nextValue)
            if callback == nil then
                log(title .. (nextValue and " ON." or " OFF."), "success")
            elseif nextValue then
                log(message or (title .. " ativado."), "success")
            else
                log(message or (title .. " desativado."), "info")
            end
        end)
    elseif kind == "select" then
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(112, 22),
            BackgroundColor3 = THEME.surface3,
            Text = tostring(state.values[key]),
            TextColor3 = THEME.text,
            TextSize = 8,
            Font = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, row)
        round(control, 3)
        control.Activated:Connect(function()
            local index = 1
            for i, choice in ipairs(choices) do
                if choice == state.values[key] then index = i break end
            end
            index = index + 1
            if index > #choices then index = 1 end
            state.values[key] = choices[index]
            control.Text = tostring(choices[index])
            log(title .. ": " .. tostring(choices[index]), "info")
        end)
    elseif kind == "input" then
        control = make("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(112, 22),
            BackgroundColor3 = THEME.surface3,
            Text = tostring(state.values[key] or ""),
            PlaceholderText = "Digite aqui",
            PlaceholderColor3 = THEME.muted,
            TextColor3 = THEME.text,
            TextSize = 8,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, row)
        round(control, 3)
        control.FocusLost:Connect(function()
            state.values[key] = control.Text
        end)
    else
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(94, 22),
            BackgroundColor3 = THEME.accentDark,
            Text = controlText or "OPEN",
            TextColor3 = THEME.text,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, row)
        round(control, 3)
        control.Activated:Connect(function()
            if not callback then
                log(title .. ": ação não configurada.", "warn")
                return
            end
            local ok, result, message = pcall(callback)
            if not ok then
                log(title .. ": " .. tostring(result), "error")
            elseif result == false then
                log(message or (title .. " não encontrou o controle esperado."), "warn")
            else
                log(message or (title .. ": comando enviado; confira o jogo."), "success")
            end
        end)
    end

    row:SetAttribute("yno_search", norm(title .. " " .. description))
    return row
end

local function addButton(title, description, caption, callback, column)
    local parent = column or (currentColumn and currentColumn.left or currentSection)
    return addControlRow(parent, title, description, caption, callback, "button")
end

local function addToggle(title, description, key, callback, column)
    local parent = column or (currentColumn and currentColumn.left or currentSection)
    return addControlRow(parent, title, description, nil, callback, "toggle", key)
end

local function addSelect(title, description, key, choices, column)
    local parent = column or (currentColumn and currentColumn.left or currentSection)
    return addControlRow(parent, title, description, nil, nil, "select", key, choices)
end

local function addInput(title, description, key, column)
    local parent = column or (currentColumn and currentColumn.left or currentSection)
    return addControlRow(parent, title, description, nil, nil, "input", key)
end

local function addNotice(title, description, tag)
    local card = make("Frame", {
        BackgroundColor3 = THEME.surface,
        BackgroundTransparency = 0.12,
        Size = UDim2.new(1, 0, 0, 65),
        BorderSizePixel = 0,
        ZIndex = 8,
    }, pageScroll)
    round(card, 3)
    stroke(card, THEME.line, 0.8, 1)
    textLabel(card, title, 9, THEME.text, true, 17).Position = UDim2.new(0, 10, 0, 6)
    local body = textLabel(card, description, 8, THEME.muted, false, 35)
    body.Position = UDim2.new(0, 10, 0, 25)
    body.Size = UDim2.new(1, -20, 0, 35)
    if tag then
        local pill = make("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 6),
            Size = UDim2.fromOffset(76, 18),
            BackgroundColor3 = THEME.accentDark,
            Text = tag,
            TextColor3 = THEME.text,
            TextSize = 7,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, card)
        round(pill, 3)
    end
    card:SetAttribute("yno_search", norm(title .. " " .. description))
end

local function beginColumnPage(leftTitle, rightTitle, description)
    addPageHeader(pageTitle.Text, description)
    local left, right = addColumns(leftTitle, rightTitle)
    currentSection = left
    return left, right
end

local function finishColumns()
    if currentColumn and currentColumn.resize then
        currentColumn.resize()
    end
    currentColumn = nil
    currentSection = nil
end

local function addSingleSection(title, description)
    addPageHeader(title, description)
    local panel = make("Frame", {
        BackgroundColor3 = THEME.surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        ZIndex = 8,
    }, pageScroll)
    round(panel, 3)
    stroke(panel, THEME.line, 0.75, 1)
    textLabel(panel, title, 10, THEME.text, true, 19).Position = UDim2.new(0, 10, 0, 5)
    local body = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 29),
        Size = UDim2.new(1, -16, 0, 0),
        ZIndex = 9,
    }, panel)
    local layout = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, body)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        body.Size = UDim2.new(1, -16, 0, layout.AbsoluteContentSize.Y)
        panel.Size = UDim2.new(1, 0, 0, 36 + layout.AbsoluteContentSize.Y)
    end)
    currentSection = body
    return body
end

local function copyUiReport()
    local buttons = getGameButtons(true)
    table.sort(buttons, function(a, b)
        return safeFullName(a) < safeFullName(b)
    end)
    local lines = {
        "yno hub 4.0.0 - visible Anime Crusaders X controls",
        "Player: " .. player.Name,
        "Visible buttons: " .. tostring(#buttons),
        "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"),
    }
    for index, button in ipairs(buttons) do
        if index > 160 then break end
        table.insert(lines, string.format(
            "%03d | %s | text=%s | context=%s",
            index,
            safeFullName(button),
            getButtonText(button),
            getContextText(button)
        ))
    end
    local report = table.concat(lines, "\n")
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, report)
        if ok then return true, "Relatório da UI copiado (" .. tostring(math.min(#buttons, 160)) .. " botões)." end
    end
    print(report)
    return false, "Clipboard não disponível; relatório enviado ao console."
end

local function selfTest()
    local apis = {
        "getgenv", "gethui", "getcustomasset", "writefile", "readfile",
        "isfile", "isfolder", "makefolder", "mousemoveabs", "mouse1press",
        "mouse1release", "mouse1click", "keyclick", "isrbxactive", "setfpscap",
    }
    local found, missing = {}, {}
    for _, name in ipairs(apis) do
        if type(ENV[name]) == "function" or type(_G[name]) == "function" then
            table.insert(found, name)
        elseif type(getfenv) == "function" and type(getfenv()[name]) == "function" then
            table.insert(found, name)
        else
            table.insert(missing, name)
        end
    end
    local lines = {
        "yno hub 4.0.0 runtime self-check",
        "Visible game buttons: " .. tostring(#getGameButtons(true)),
        "Solara APIs found: " .. tostring(#found),
        "Solara APIs missing: " .. tostring(#missing),
        "Found: " .. table.concat(found, ", "),
        "Missing: " .. table.concat(missing, ", "),
    }
    local report = table.concat(lines, "\n")
    if type(setclipboard) == "function" then pcall(setclipboard, report) end
    print(report)
    if #missing == 0 then return true, "Self-check concluído; relatório copiado/impresso." end
    return true, "Self-check: " .. tostring(#missing) .. " APIs não detectadas. Veja o relatório."
end

local function buildOverview()
    beginColumnPage("QUICK ACTIONS", "SESSION STATUS", "Farm, progress and rewards at a glance.")
    addButton("Start Story", "Abre Play → Story e usa as escolhas configuradas.", "START", startStory, currentColumn.left)
    addButton("Claim Quest Rewards", "Reivindica Claim All na janela de Quests que estiver aberta.", "CLAIM", claimAllQuests, currentColumn.left)
    addButton("Enter Unit Hunt", "Events → Unit Hunt → Start Hunt.", "ENTER", startUnitHunt, currentColumn.left)
    addButton("Start Smart Macro", "Inicia o Macro nativo com o modo selecionado.", "RUN", startNativeMacro, currentColumn.left)
    addNotice("NATIVE FARM ENGINE", "O Smart Macro do jogo faz posicionamento, upgrades e venda. Configure Units e Placement uma vez; depois use This Stage, Loop ou Routine.", "MACRO")
    addNotice("QUESTS", "All, Daily, Infinite, Story, Event e Guide. O hub abre a categoria e reivindica objetivos que o próprio jogo já marcou como concluídos.", "CLAIM")
    addNotice("UNIT HUNT", "Q procura raros; E inicia o encontro; clique, Space ou E durante a barra de captura. PERFECT no centro dourado causa dano dobrado.", "EVENT")
    finishColumns()
    currentSection = nil
end

local function buildGame()
    local left, right = beginColumnPage("GAME", "WAVE ACTIONS", "Compact controls for the active match and Smart Macro.")
    addToggle("Auto Vote Start", "Envia Vote Start / Start Match quando visível.", "autoVoteStart", nil, left)
    addToggle("Auto Skip Waves", "Envia Vote Skip / Skip Wave quando visível.", "autoSkip", nil, left)
    addToggle("Auto Next", "Clica Next depois de detectar uma tela de vitória.", "autoNext", nil, left)
    addToggle("Auto Replay", "Clica Replay / Retry depois de detectar derrota.", "autoReplay", nil, left)
    addButton("Open Macro → Units", "Abre a configuração nativa de slots, Auto upgrade e Auto abilities.", "OPEN", openMacroUnits, left)

    addButton("Toggle Auto Upgrade", "Alterna a opção nativa quando Macro → Units estiver aberto.", "TOGGLE", function()
        return toggleNativeOption("Auto upgrade")
    end, right)
    addButton("Toggle Auto Abilities", "Alterna a opção nativa quando Macro → Units estiver aberto.", "TOGGLE", function()
        return toggleNativeOption("Auto abilities")
    end, right)
    addButton("Toggle Auto Skip Waves", "Alterna a opção nativa do Smart Macro.", "TOGGLE", function()
        return toggleNativeOption("Auto skip waves")
    end, right)
    addButton("Toggle Smart Placement", "Alterna o posicionamento inteligente em mapas novos.", "TOGGLE", function()
        return toggleNativeOption("Smart placement on new maps")
    end, right)
    addButton("Stop / Pause Macro", "Usa o controle Pause ou Stop do painel flutuante nativo.", "STOP", stopNativeMacro, right)

    finishColumns()
    addNotice("HOW IT WORKS", "Auto Vote Start/Skip/Next/Replay observam botões normais do jogo. Auto upgrade, habilidades e colocação são opções internas do Smart Macro, não comandos inventados pelo yno hub.", "GAME UI")
end

local function buildStory()
    addPageHeader("Story", "Selecione a rota. O runner navega apenas por botões visíveis.")
    local left, right = addColumns("STAGE SELECTOR", "AUTOMATION")
    addSelect("World", "11 mundos em ordem de progressão.", "storyWorld", WORLDS, left)
    addSelect("Act", "Selecione o ato individual.", "storyAct", {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"}, left)
    addSelect("Difficulty", "Hard exige completar o ato em Normal.", "storyDifficulty", {"Normal", "Hard"}, left)
    addSelect("Route", "World Skip existe nos mundos 1–10; Sword Arena não tem.", "storyRoute", {"Individual Act", "World Skip"}, left)
    addSelect("Entry", "Matchmaking procura jogadores; Select Stage abre a seleção de fase.", "storyEntry", {"Matchmaking", "Select Stage"}, left)
    addButton("Start selected Story", "Play → Story → World → Act/World Skip → Difficulty → Matchmaking/Select Stage.", "START", startStory, right)
    addToggle("Auto Vote Start", "Liga/desliga a votação de início na sala.", "autoVoteStart", nil, right)
    addToggle("Auto Skip Waves", "Liga/desliga a votação de skip durante partidas.", "autoSkip", nil, right)
    addToggle("Auto Next", "Avança somente após vitória/conclusão detectada.", "autoNext", nil, right)
    addToggle("Auto Replay", "Repete somente após derrota detectada.", "autoReplay", nil, right)
    finishColumns()
    addNotice("WORLD ORDER", "Planet Namak → Marine's Ford → Karakura Town → Shibuya → Demon District → Devil City → Soul Society → West City (Ruined) → Culling Games → Doldrey → Sword Arena.", "11 WORLDS")
    addNotice("WORLD SKIP", "Normal only, +900% enemy HP, worlds 1–10. Sword Arena uses the six individual acts.", "LIMITS")
end

local function buildQuests()
    local left, right = beginColumnPage("QUESTS", "GUIDE / BOUNTIES", "Open a game quest category, then claim completed objectives.")
    addSelect("Quest category", "All / Daily / Infinite / Story / Event / Guide.", "questCategory", {"All", "Daily", "Infinite", "Story", "Event", "Guide"}, left)
    addButton("Open selected category", "Abre Quests e escolhe a categoria atual.", "OPEN", function()
        return openQuests(state.values.questCategory)
    end, left)
    addButton("Claim All", "Coleta apenas quando Claim All aparece na UI do jogo.", "CLAIM", claimAllQuests, left)
    addToggle("Auto Claim", "Verifica a cada intervalo se Claim All está visível em Quests.", "autoClaim", nil, left)
    addButton("Open Guidebook", "Quests → Guide; acompanhe as dez tarefas que liberam Phoenix.", "GUIDE", openGuidebook, right)
    addButton("Open Bounties", "Abra Bounties no Request Board com Navi.", "BOUNTIES", openBounties, right)
    addButton("Claim Bounties", "Coleta Claim All se a janela de Bounties estiver aberta.", "CLAIM", claimAllQuests, right)
    addButton("Start Story quest grind", "Liga Auto Start, Auto Skip e Auto Next e inicia o Story selecionado.", "GRIND", function()
        setToggleUi("autoVoteStart", true)
        setToggleUi("autoSkip", true)
        setToggleUi("autoNext", true)
        return startStory()
    end, right)
    finishColumns()
    addNotice("DAILY QUEST COMPLETE", "Cinco tarefas diárias liberam o bônus de 750 Gems + 10 Trait Remnants. O hub recolhe a recompensa depois que o jogo marca as tarefas como concluídas.", "DAILY")
    addNotice("GUIDEBOOK → PHOENIX", "Complete as dez Guide Quests e reivindique Guide Quests Complete! para receber Phoenix. Algumas tarefas gastam XP Food, unidades ou Stat Cubes.", "FREE UNIT")
    addNotice("BOUNTIES", "Cada cartão tem três objetivos. Complete os três e reivindique 5 Event Tokens + 1 Blank Token. Reroll custa 10.000 Gold e apaga o progresso do cartão.", "TOKENS")
end

local function buildMacro()
    local left, right = beginColumnPage("RUN MODE", "NATIVE SETTINGS", "The game's built-in Smart Macro is the actual farming engine.")
    addSelect("Run mode", "This Stage, Loop ou Routine.", "macroMode", {"This Stage", "Loop", "Routine"}, left)
    addButton("Open Macro", "Macro fica no lado direito durante uma partida.", "OPEN", openMacroPanel, left)
    addButton("Open Units", "Abre slots, targeting, Auto upgrade e Auto abilities.", "UNITS", openMacroUnits, left)
    addButton("Start Smart Macro", "Macro → Run → modo selecionado → Start.", "START", startNativeMacro, left)
    addButton("Pause / Stop", "Usa Pause ou Stop no floating panel do jogo.", "PAUSE", stopNativeMacro, left)
    addButton("Toggle Auto Upgrade", "Requer Macro → Units aberto.", "TOGGLE", function()
        return toggleNativeOption("Auto upgrade")
    end, right)
    addButton("Toggle Auto Abilities", "Requer Macro → Units aberto.", "TOGGLE", function()
        return toggleNativeOption("Auto abilities")
    end, right)
    addButton("Toggle Auto Skip Waves", "Requer o painel Macro nativo visível.", "TOGGLE", function()
        return toggleNativeOption("Auto skip waves")
    end, right)
    addButton("Toggle Smart Placement", "Smart placement on new maps.", "TOGGLE", function()
        return toggleNativeOption("Smart placement on new maps")
    end, right)
    addButton("Open Macro Routine", "Configure uma fila de tarefas antes de iniciar Routine.", "ROUTINE", function()
        local ok, reason = openMacroPanel()
        if not ok then return false, reason end
        task.wait(0.25)
        return clickVisible({"Routine"}, "macro", "open-macro-routine", 1.1, false)
    end, right)
    finishColumns()
    addNotice("CONFIGURE ONCE", "Macro → Units → Slots: configure seus seis slots e Hero. Macro → Units → Placement: escolha Zones, Recording ou Shared area.", "SETUP")
    addNotice("RUN MODES", "This Stage executa uma partida; Loop repete a fase atual; Routine percorre a fila de tarefas que você configurou.", "MODES")
    addNotice("FLOATING PANEL", "Pause pausa a execução, Stop encerra a rotina e Open volta ao painel de configuração.", "CONTROLS")
end

local function buildUnitHunt()
    local left, right = beginColumnPage("HUNTING ISLES", "COLLECTION / EVENT", "Creature capture event. Requires Player Level 5.")
    addButton("Enter Unit Hunt", "Events → Unit Hunt → Start Hunt.", "ENTER", startUnitHunt, left)
    addToggle("Auto Hunt", "Q scan; aproxima-se de prompts Capture e usa E quando estiver perto.", "autoHunt", nil, left)
    addToggle("Auto PERFECT Assist", "Tenta Space quando o marcador é detectado dentro da zona dourada.", "autoPerfect", nil, left)
    addButton("Open Collection Book", "Abre Book na página do Unit Hunt.", "BOOK", openUnitHuntBook, left)
    addButton("Open Event Quests", "Events → Unit Hunt → Event Quests.", "QUESTS", openEventQuests, right)
    addButton("Claim Event Rewards", "Coleta Claim All na janela de Event Quests.", "CLAIM", claimAllQuests, right)
    addButton("Scan now (Q)", "Envia uma tecla Q para procurar criaturas raras.", "SCAN", function()
        return sendKey(0x51)
    end, right)
    addButton("Capture key (E)", "Envia E para iniciar a captura quando o prompt aparecer.", "CAPTURE", function()
        return sendKey(0x45)
    end, right)
    finishColumns()
    addNotice("CAPTURE INPUT", "Pressione Q para scan. Aproxime até E Capture aparecer. Durante a barra, clique, Space ou E quando o marcador entrar na zona; o centro dourado dá PERFECT com dano dobrado.", "Q / E / SPACE")
    addNotice("COLLECTION", "Book principal: 39 entradas. Shinies: 35 entradas em aba separada. Capturas repetidas aumentam o contador Caught, sem contar como nova entrada distinta.", "39 + 35")
    addNotice("REGIONS", "Whisperwood Isles é a inicial; Bridgeway Hollow abre na Hunt Wave 3; Crown Ward na Wave 6; Frostfang Peak na Wave 9. No.039 exige 38 entradas e Hunt Wave 10.", "4 REGIONS")
    addNotice("EVENT QUESTS", "Rookie Hunter: 25 captures; Seasoned Hunter: 150; Shiny Spotter: 1 Shiny; Valkyrie Slayer: 3 assists; Shrine Keeper: 2 Guardian awakenings.", "5 QUESTS")
end

local function buildRewards()
    local left, right = beginColumnPage("LOGIN / FREE REWARDS", "INDEX / BLANK TOKENS", "Claim rewards only after the game's own requirements are complete.")
    addButton("Claim Login Rewards", "Tenta Daily e Anniversary separadamente.", "CLAIM", claimLoginRewards, left)
    addButton("Open Hesia Free Rewards", "Fale com Hesia no lobby e use Free Rewards.", "OPEN", openHesiaRewards, left)
    addButton("Claim Hesia Rewards", "Requer as quatro tarefas sociais concluídas.", "CLAIM", claimHesiaRewards, left)
    addInput("YouTube channel name", "Digite seu próprio nome de canal antes do Redeem.", "youtubeChannel", left)
    addButton("Open YouTube Reward", "Abre a tela para inscrição e verificação.", "OPEN", openYoutubeReward, left)
    addButton("Redeem YouTube Reward", "Preenche seu canal e envia Redeem. O jogo valida a inscrição.", "REDEEM", redeemYoutubeReward, left)
    addButton("Claim King's Index", "Requer King → Open Index.", "CLAIM", claimKingsIndex, right)
    addSelect("Blank Unit", "Shadow (Atomic) ou Lao (Heart).", "blankUnit", {"Shadow (Atomic)", "Lao (Heart)"}, right)
    addButton("Claim Blank Unit", "Cada unidade custa 30 Blank Tokens. Claim manual, sem gastar automaticamente.", "CLAIM", claimBlankUnit, right)
    finishColumns()
    addNotice("TWENTY ONE", "Anniversary Login Day 1 entrega Twenty One e um Anniversary Ticket. Daily e Anniversary são abas diferentes.", "DAY 1")
    addNotice("PHOENIX", "Complete as dez Guide Quests e reivindique Guide Quests Complete! para receber Phoenix.", "10 QUESTS")
    addNotice("HESIA / YOUTUBE", "Hesia exige Join Group, Like + Favorite, Notifications e Follow Event. YouTube Reward exige inscrição em @32xGames e notificações ativadas.", "SOCIAL")
    addNotice("BLANK UNITS", "Shadow (Atomic) custa 30 Blank Tokens. Lao (Heart) custa 30 Blank Tokens. Nenhuma das duas é gratuita.", "30 TOKENS")
end

local function buildPerformance()
    local left, right = beginColumnPage("LOCAL RENDER", "FPS / RESTORE", "Client-only presentation settings. Server state is untouched.")
    addToggle("Low Effects", "Desliga sombras globais e pós-processamento local.", "lowEffects", function(enabled)
        return setLowEffects(enabled)
    end, left)
    addToggle("Hide Attack Effects", "Desliga ParticleEmitter, Trail, Beam e Highlight locais.", "hideAttackEffects", function(enabled)
        return setHideAttackEffects(enabled)
    end, left)
    addInput("FPS cap", "30–360 FPS.", "fpsCap", right)
    addButton("Apply FPS cap", "Aplica o limite escolhido com setfpscap.", "APPLY", applyFpsCap, right)
    addButton("Restore performance", "Restaura efeitos e FPS cap anteriores.", "RESTORE", restorePerformance, right)
    finishColumns()
    addNotice("LOCAL ONLY", "Low Effects e Hide Attack Effects alteram a renderização deste cliente. Não aumentam dano, drops ou velocidade do servidor.", "CLIENT")
end

local function stopAll()
    state.generation = state.generation + 1
    for key in pairs(state.toggles) do
        state.toggles[key] = false
    end
    for _, button in pairs(toggleControls) do
        if button and button.Parent then
            button.Text = "OFF"
            button.BackgroundColor3 = THEME.surface3
        end
    end
    restorePerformance()
    local macroStopped = stopNativeMacro()
    log(macroStopped and "Automações do yno hub desligadas; Smart Macro pausado e efeitos restaurados." or "Automações do yno hub desligadas; efeitos restaurados. Pause o Smart Macro se ainda estiver rodando.", "warn")
    return true, "Stop All executado."
end

local function unload()
    if not state.running then return end
    state.running = false
    state.generation = state.generation + 1
    setLowEffects(false)
    setHideAttackEffects(false)
    if state.originalFpsCap ~= nil and type(setfpscap) == "function" then
        pcall(setfpscap, state.originalFpsCap)
        state.originalFpsCap = nil
    end
    for _, connection in ipairs(state.connections) do
        pcall(function() connection:Disconnect() end)
    end
    for _, thread in ipairs(state.tasks) do
        pcall(task.cancel, thread)
    end
    if gui and gui.Parent then pcall(function() gui:Destroy() end) end
    ENV[RUNTIME_KEY] = nil
end

local function buildSettings()
    local left, right = beginColumnPage("DIAGNOSTICS", "PREFERENCES / CONTROL", "Runtime inspection and safe shutdown.")
    addButton("Copy Game UI report", "Copia até 160 botões visíveis com texto e hierarquia.", "COPY UI", copyUiReport, left)
    addButton("Run Solara self-check", "Verifica input, filesystem, GUI e APIs do executor.", "SELF TEST", selfTest, left)
    addButton("Save preferences", "Salva seleções; toggles de automação sempre iniciam OFF.", "SAVE", saveConfig, left)
    addSelect("UI scale", "0.80–1.10.", "uiScale", {"0.80", "0.90", "1.00", "1.10"}, right)
    addButton("Apply UI scale", "Aplica a escala selecionada.", "APPLY", function()
        uiScale.Scale = math.clamp(tonumber(state.values.uiScale) or 1, 0.64, 1.1)
        return true, "Escala atualizada."
    end, right)
    addButton("STOP ALL", "Cancela sequências e desliga os toggles do hub.", "STOP", stopAll, right)
    addButton("UNLOAD", "Fecha o painel, desconecta eventos e restaura efeitos.", "CLOSE", unload, right)
    finishColumns()
    addNotice("HOTKEY", "RightShift mostra/oculta. — minimiza para o botão flutuante y. × descarrega o yno hub.", "UI")
    addNotice("SAFE CONFIG", "Save preferences guarda escolhas de mundo, categoria e modo, mas não liga automações ao iniciar novamente.", "CONFIG")
end

local pages = {
    Overview = buildOverview,
    Game = buildGame,
    Story = buildStory,
    Quests = buildQuests,
    Macro = buildMacro,
    ["Unit Hunt"] = buildUnitHunt,
    Rewards = buildRewards,
    Performance = buildPerformance,
    Settings = buildSettings,
}

local navData = {
    {"Overview", "◈"},
    {"Game", "⚔"},
    {"Story", "▣"},
    {"Quests", "◎"},
    {"Macro", "▤"},
    {"Unit Hunt", "✧"},
    {"Rewards", "◇"},
    {"Performance", "◌"},
    {"Settings", "⚙"},
}

local navButtons = {}

local function showPage(name)
    if not pages[name] then return end
    state.page = name
    pageTitle.Text = name
    clearPage()
    local ok, err = pcall(pages[name])
    if not ok then
        currentColumn = nil
        currentSection = nil
        log("Erro na página " .. name .. ": " .. tostring(err), "error")
    end
    if currentColumn and currentColumn.resize then currentColumn.resize() end
    for pageName, button in pairs(navButtons) do
        local active = pageName == name
        button.BackgroundColor3 = active and THEME.accentDark or THEME.sidebar
        button.TextColor3 = active and THEME.text or THEME.muted
        local marker = button:FindFirstChild("ActiveMarker")
        if marker then marker.Visible = active end
    end
    searchBox.Text = ""
end

for index, item in ipairs(navData) do
    local name, glyph = item[1], item[2]
    local button = make("TextButton", {
        Name = "Nav_" .. string.gsub(name, "%s+", ""),
        AutoButtonColor = false,
        BackgroundColor3 = THEME.sidebar,
        Size = UDim2.new(1, 0, 0, 34),
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. glyph .. "    " .. name,
        TextColor3 = THEME.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        LayoutOrder = index,
        ZIndex = 9,
    }, navHolder)
    round(button, 3)
    local marker = make("Frame", {
        Name = "ActiveMarker",
        BackgroundColor3 = THEME.accent,
        Position = UDim2.new(0, 0, 0.5, -10),
        Size = UDim2.fromOffset(3, 20),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, button)
    round(marker, 2)
    button.Activated:Connect(function() showPage(name) end)
    navButtons[name] = button
end

local floatingButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -22, 1, -86),
    Size = UDim2.fromOffset(46, 46),
    BackgroundColor3 = THEME.accentDark,
    Text = "y",
    TextColor3 = THEME.text,
    TextSize = 23,
    Font = Enum.Font.GothamBold,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 60,
}, gui)
round(floatingButton, 7)
stroke(floatingButton, THEME.accent, 0.2, 1)
floatingButton.Activated:Connect(function()
    main.Visible = true
    floatingButton.Visible = false
    state.minimized = false
end)

minimizeButton.Activated:Connect(function()
    main.Visible = false
    floatingButton.Visible = true
    state.minimized = true
end)

closeButton.Activated:Connect(unload)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = norm(searchBox.Text)
    for _, child in ipairs(pageScroll:GetChildren()) do
        if child:IsA("Frame") then
            if query == "" then
                child.Visible = true
            else
                local searchText = norm(child:GetAttribute("yno_search") or "")
                if searchText == "" then
                    for _, descendant in ipairs(child:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            searchText = searchText .. " " .. norm(descendant.Text)
                        end
                    end
                end
                child.Visible = string.find(searchText, query, 1, true) ~= nil
            end
        end
    end
end)

local dragging = false
local dragStart = nil
local dragOrigin = nil
trackConnection(topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragOrigin = main.Position
    end
end))
trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            dragOrigin.X.Scale, dragOrigin.X.Offset + delta.X,
            dragOrigin.Y.Scale, dragOrigin.Y.Offset + delta.Y
        )
    end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))
trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
        floatingButton.Visible = not main.Visible
        state.minimized = not main.Visible
    end
end))

local function automationLoop()
    while state.running do
        local now = os.clock()

        if state.toggles.autoVoteStart and now - state.lastAutoStart > 2.5 then
            state.lastAutoStart = now
            clickVisible({"Vote Start", "Start Match"}, nil, "auto-vote-start", 2.2, false)
        end

        if state.toggles.autoSkip and now - state.lastAutoSkip > 2.5 then
            state.lastAutoSkip = now
            clickVisible({"Vote Skip", "Skip Wave"}, nil, "auto-skip-wave", 2.2, false)
        end

        local won, lost = false, false
        if state.toggles.autoNext or state.toggles.autoReplay then
            local content = screenText()
            won = string.find(content, "victory", 1, true)
                or string.find(content, "stage cleared", 1, true)
                or string.find(content, "wave completed", 1, true)
                or string.find(content, "completed the stage", 1, true)
            lost = string.find(content, "defeat", 1, true)
                or string.find(content, "you lost", 1, true)
                or string.find(content, "you were defeated", 1, true)
                or string.find(content, "match lost", 1, true)
        end

        if state.toggles.autoNext and won and now - state.lastAutoNext > 3 then
            state.lastAutoNext = now
            clickVisible({"Next Stage", "Next"}, nil, "auto-next", 2.5, false)
        end

        if state.toggles.autoReplay and lost and now - state.lastAutoReplay > 3 then
            state.lastAutoReplay = now
            clickVisible({"Replay", "Retry"}, nil, "auto-replay", 2.5, false)
        end

        if state.toggles.autoClaim and now - state.lastQuestClaim > 3 then
            local claim = findGameButton({"Claim All"}, "quest", false, true)
                or findGameButton({"Claim All"}, "guide", false, true)
                or findGameButton({"Claim All"}, "event", false, true)
                or findGameButton({"Claim All"}, "bounty", false, true)
            if claim then
                state.lastQuestClaim = now
                sendMouseClick(claim)
            end
        end

        if state.toggles.autoHunt then
            local ok, err = pcall(processUnitHunt)
            if not ok then log("Auto Hunt: " .. tostring(err), "error") end
        end

        task.wait(0.28)
    end
end

loadConfig()
uiScale.Scale = math.clamp(tonumber(state.values.uiScale) or uiScale.Scale, 0.64, 1.1)
showPage("Overview")
ENV[RUNTIME_KEY] = {Unload = unload, Version = "4.0.1", Open = function() main.Visible = true end}

spawnTracked(automationLoop)
log("yno hub 4.0.1 carregado. RightShift mostra/oculta.", "success")
