-- yno hub | anime crusaders x
-- v3.0.0 | 2026-11-17
-- LixHub-inspired game hub rebuilt around visible Anime Crusaders X workflows.
-- All game actions use visible UI controls, normal movement, or normal key input.
-- No private RemoteEvents, inventory edits, currency edits, or anti-cheat bypass.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ENV = (type(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "yno_hub_runtime"

if ENV[RUNTIME_KEY] and type(ENV[RUNTIME_KEY].Unload) == "function" then
    pcall(ENV[RUNTIME_KEY].Unload)
end

local THEME = {
    background = Color3.fromRGB(5, 9, 11),
    sidebar = Color3.fromRGB(8, 14, 16),
    panel = Color3.fromRGB(11, 18, 20),
    panel2 = Color3.fromRGB(15, 23, 25),
    panel3 = Color3.fromRGB(24, 34, 36),
    line = Color3.fromRGB(58, 73, 75),
    text = Color3.fromRGB(232, 237, 236),
    muted = Color3.fromRGB(151, 164, 164),
    accent = Color3.fromRGB(111, 151, 143),
    accentDark = Color3.fromRGB(44, 72, 67),
    success = Color3.fromRGB(147, 185, 162),
    warning = Color3.fromRGB(202, 164, 104),
    danger = Color3.fromRGB(190, 113, 105),
}

local WORLD_LIST = {
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
    toggles = {
        autoClaim = false,
        autoStart = false,
        autoSkip = false,
        autoNext = false,
        autoRetry = false,
        autoAbilities = false,
        autoQuestLoop = false,
        autoUnitHunt = false,
        autoHuntClaims = false,
        autoLowEffects = false,
        hideEffects = false,
    },
    values = {
        questCategory = "Daily",
        storyWorld = "Planet Namak",
        storyAct = "Act 1",
        storyDifficulty = "Normal",
        storyMode = "Individual Act",
        storyEntry = "Matchmaking",
        macroMode = "Loop",
        blankUnit = "Shadow (Atomic)",
        fpsCap = "60",
    },
    lastAction = {},
    connections = {},
    threads = {},
    storyFlow = false,
    huntLastScan = 0,
    huntLastPromptScan = 0,
    cachedCapturePrompt = nil,
    huntLastMove = 0,
    huntLastHit = 0,
    lastClaim = 0,
    lastStatus = 0,
    buttonCache = {},
    buttonCacheAt = 0,
    originalLighting = {},
    originalAttackEffects = {},
    originalFpsCap = nil,
    originalShadows = nil,
    captureMissLogged = false,
}

local function norm(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "[%p%c]", " ")
    value = string.gsub(value, "%s+", " ")
    return string.gsub(value, "^%s*(.-)%s*$", "%1")
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

local function outline(object, color, transparency, thickness)
    make("UIStroke", {
        Color = color or THEME.line,
        Transparency = transparency or 0.45,
        Thickness = thickness or 1,
    }, object)
end

local function label(parent, value, size, color, bold, height)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 22),
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        Text = tostring(value or ""),
        TextColor3 = color or THEME.text,
        TextSize = size or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local function getUiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return CoreGui
end

local uiParent = getUiParent()
local existing = uiParent:FindFirstChild("yno_hub")
if existing then
    pcall(function() existing:Destroy() end)
end

local function getBackgroundAsset()
    local assetUrl = "https://raw.githubusercontent.com/6zyloov/yno-hub/main/assets/lixhub-bg.jpg"
    if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
        return nil
    end
    local filePath = "yno_hub/lixhub-bg.jpg"
    local ok = pcall(function()
        if type(isfolder) == "function" and not isfolder("yno_hub") then
            makefolder("yno_hub")
        end
        if type(isfile) ~= "function" or not isfile(filePath) then
            local imageBytes = game:HttpGet(assetUrl)
            if type(imageBytes) ~= "string" or #imageBytes < 1000 then
                error("background download returned empty content")
            end
            writefile(filePath, imageBytes)
        end
    end)
    if not ok then return nil end
    local assetOk, asset = pcall(getcustomasset, filePath)
    if assetOk then return asset end
    return nil
end

local backgroundAsset = getBackgroundAsset()

local gui = make("ScreenGui", {
    Name = "yno_hub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, uiParent)

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local uiScale = make("UIScale", {
    Scale = math.clamp(math.min(viewport.X / 1220, viewport.Y / 790), 0.68, 1),
}, gui)

local main = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1120, 700),
    BackgroundColor3 = THEME.background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
outline(main, THEME.line, 0.1, 1)

if backgroundAsset then
    make("ImageLabel", {
        Name = "yno_background",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Image = backgroundAsset,
        ImageColor3 = Color3.fromRGB(155, 181, 174),
        ImageTransparency = 0.56,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 0,
    }, main)
end

make("Frame", {
    Name = "background_tint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(3, 7, 9),
    BackgroundTransparency = backgroundAsset and 0.28 or 0,
    BorderSizePixel = 0,
    ZIndex = 1,
}, main)

local sidebar = make("Frame", {
    Name = "sidebar",
    BackgroundColor3 = THEME.sidebar,
    BackgroundTransparency = 0.08,
    Size = UDim2.new(0, 190, 1, 0),
    BorderSizePixel = 0,
    ZIndex = 2,
}, main)
make("Frame", {
    BackgroundColor3 = THEME.line,
    BackgroundTransparency = 0.5,
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BorderSizePixel = 0,
    ZIndex = 3,
}, sidebar)

local brand = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 17, 0, 17),
    Size = UDim2.new(1, -32, 0, 54),
    ZIndex = 4,
}, sidebar)
local logo = make("Frame", {
    BackgroundColor3 = THEME.accentDark,
    Size = UDim2.new(0, 39, 0, 39),
    BorderSizePixel = 0,
    ZIndex = 5,
}, brand)
round(logo, 6)
local logoText = label(logo, "y", 25, THEME.text, true, 38)
logoText.TextXAlignment = Enum.TextXAlignment.Center
logoText.ZIndex = 6
local brandTitle = label(brand, "yno hub", 17, THEME.text, true, 22)
brandTitle.Position = UDim2.new(0, 49, 0, 1)
brandTitle.ZIndex = 6
local brandSub = label(brand, "ANIME CRUSADERS X", 8, THEME.muted, true, 16)
brandSub.Position = UDim2.new(0, 50, 0, 25)
brandSub.ZIndex = 6

local menuLabel = label(sidebar, "MAIN MENU", 9, THEME.muted, true, 18)
menuLabel.Position = UDim2.new(0, 16, 0, 83)
menuLabel.ZIndex = 4

local navHolder = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 108),
    Size = UDim2.new(1, -16, 0, 430),
    ZIndex = 4,
}, sidebar)
make("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, navHolder)

local navButtons = {}
local content = make("Frame", {
    Name = "content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 208, 0, 0),
    Size = UDim2.new(1, -224, 1, 0),
    ZIndex = 3,
}, main)

local topbar = make("Frame", {
    BackgroundColor3 = Color3.fromRGB(5, 10, 12),
    BackgroundTransparency = 0.22,
    Size = UDim2.new(1, 0, 0, 55),
    BorderSizePixel = 0,
    ZIndex = 4,
}, content)
label(topbar, "COMMAND CENTER", 8, THEME.muted, true, 14).Position = UDim2.new(0, 0, 0, 5)
local pageTitle = label(topbar, "Overview", 18, THEME.text, true, 28)
pageTitle.Position = UDim2.new(0, 0, 0, 22)

local search = make("TextBox", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -166, 0, 15),
    Size = UDim2.new(0, 180, 0, 28),
    BackgroundColor3 = THEME.panel2,
    Text = "",
    PlaceholderText = "Search...",
    PlaceholderColor3 = THEME.muted,
    TextColor3 = THEME.text,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    BorderSizePixel = 0,
    ZIndex = 5,
}, topbar)
round(search, 3)
outline(search, THEME.line, 0.5, 1)

local ready = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -78, 0, 16),
    Size = UDim2.new(0, 70, 0, 24),
    BackgroundColor3 = Color3.fromRGB(24, 49, 44),
    Font = Enum.Font.GothamBold,
    Text = "● READY",
    TextColor3 = THEME.success,
    TextSize = 9,
    BorderSizePixel = 0,
    ZIndex = 5,
}, topbar)
round(ready, 3)

local minimize = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -42, 0, 16),
    Size = UDim2.new(0, 28, 0, 24),
    BackgroundColor3 = THEME.panel3,
    Text = "—",
    TextColor3 = THEME.text,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 5,
}, topbar)
round(minimize, 3)

local close = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -6, 0, 16),
    Size = UDim2.new(0, 28, 0, 24),
    BackgroundColor3 = Color3.fromRGB(58, 34, 34),
    Text = "×",
    TextColor3 = THEME.danger,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 5,
}, topbar)
round(close, 3)

local pageScroll = make("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 64),
    Size = UDim2.new(1, 0, 1, -94),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 4,
}, content)

local pageLayout = make("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, pageScroll)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 9),
}, pageScroll)

pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 28)
end)

local footer = make("Frame", {
    BackgroundColor3 = THEME.sidebar,
    BackgroundTransparency = 0.12,
    Position = UDim2.new(0, 8, 1, -63),
    Size = UDim2.new(1, -16, 0, 47),
    BorderSizePixel = 0,
    ZIndex = 4,
}, sidebar)
round(footer, 5)
local statusDot = make("Frame", {
    BackgroundColor3 = THEME.success,
    Position = UDim2.new(0, 11, 0, 19),
    Size = UDim2.new(0, 7, 0, 7),
    BorderSizePixel = 0,
    ZIndex = 5,
}, footer)
round(statusDot, 5)
label(footer, "CLIENT READY", 9, THEME.success, true, 15).Position = UDim2.new(0, 25, 0, 7)
label(footer, "UI automation", 8, THEME.muted, false, 13).Position = UDim2.new(0, 25, 0, 23)

local toast = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 360, 1, -26),
    Size = UDim2.new(0, 330, 0, 34),
    BackgroundColor3 = THEME.panel3,
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = THEME.text,
    TextSize = 10,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 20,
}, gui)
round(toast, 4)
outline(toast, THEME.line, 0.25, 1)
make("UIPadding", {PaddingLeft = UDim.new(0, 12)}, toast)

local function notify(message, color)
    if not toast or not toast.Parent then return end
    toast.Text = tostring(message)
    toast.TextColor3 = color or THEME.text
    toast.Visible = true
    toast.BackgroundTransparency = 0.1
    toast.Position = UDim2.new(1, -22, 1, -25)
    task.delay(2.8, function()
        if toast and toast.Parent then
            toast.Visible = false
            toast.BackgroundTransparency = 1
            toast.Position = UDim2.new(1, 360, 1, -25)
        end
    end)
end

local function log(message, color)
    notify(message, color)
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = tostring(message)
        statusLabel.TextColor3 = color or THEME.muted
    end
end

local function visible(object)
    local current = object
    while current and current ~= game do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") and not current.Enabled then return false end
        current = current.Parent
    end
    return true
end

local function buttonText(button)
    local parts = {norm(button.Name)}
    if button:IsA("TextButton") then table.insert(parts, norm(button.Text)) end
    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Text and child.Text ~= "" then
                table.insert(parts, norm(child.Text))
            end
        end
    end
    return table.concat(parts, " ")
end

local function contextText(object)
    local parts = {}
    local current = object
    local depth = 0
    while current and current ~= playerGui and depth < 6 do
        table.insert(parts, norm(current.Name))
        if current:IsA("TextLabel") or current:IsA("TextButton") then
            table.insert(parts, norm(current.Text))
        end
        for _, child in ipairs(current:GetChildren()) do
            if child:IsA("TextLabel") and child.Text ~= "" then
                table.insert(parts, norm(child.Text))
            end
        end
        current = current.Parent
        depth = depth + 1
    end
    return table.concat(parts, " ")
end

local function gameButtons()
    local now = os.clock()
    if now - (state.buttonCacheAt or 0) < 0.25 then
        return state.buttonCache
    end
    local found = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        if root ~= gui then
            for _, item in ipairs(root:GetDescendants()) do
                if item:IsA("GuiButton") and item.Active and visible(item) then
                    table.insert(found, item)
                end
            end
        end
    end
    state.buttonCache = found
    state.buttonCacheAt = now
    return found
end

local function findButton(phrases, exact, requiredContext, requireUnique)
    local matches = {}
    local contextNeedle = requiredContext and norm(requiredContext) or nil
    for _, button in ipairs(gameButtons()) do
        if not button:IsDescendantOf(gui) then
            local haystack = buttonText(button)
            local contextOkay = true
            if contextNeedle then
                contextOkay = string.find(contextText(button), contextNeedle, 1, true) ~= nil
            end
            if contextOkay then
                for _, phrase in ipairs(phrases) do
                    local target = norm(phrase)
                    if target ~= "" then
                        local textOnly = button:IsA("TextButton") and norm(button.Text) or ""
                        local matched
                        if exact then
                            matched = textOnly == target or norm(button.Name) == target
                        else
                            matched = string.find(haystack, target, 1, true) ~= nil
                        end
                        if matched then
                            table.insert(matches, button)
                            break
                        end
                    end
                end
            end
        end
    end
    if #matches == 1 then return matches[1] end
    if #matches > 1 and not requireUnique then return matches[1] end
    return nil
end

local function waitForButton(phrases, exact, timeout, context, unique)
    local deadline = os.clock() + (timeout or 8)
    while state.running and os.clock() < deadline do
        local found = findButton(phrases, exact, context, unique)
        if found then return found end
        task.wait(0.2)
    end
    return nil
end

local function isRobloxFocused()
    if type(isrbxactive) == "function" then
        local ok, focused = pcall(isrbxactive)
        if ok then return focused end
    end
    return true
end

local function clickButton(button, actionKey, cooldown)
    if not button or not button.Parent or not button.Active or not visible(button) then
        return false
    end
    if not isRobloxFocused() then
        log("Roblox precisa estar em primeiro plano para enviar o clique.", THEME.warning)
        return false
    end
    local now = os.clock()
    local key = actionKey or tostring(button)
    if state.lastAction[key] and now - state.lastAction[key] < (cooldown or 0.9) then
        return false
    end
    state.lastAction[key] = now

    local center = button.AbsolutePosition + (button.AbsoluteSize / 2)
    local ok = false
    if type(mousemoveabs) == "function" and type(mouse1click) == "function" then
        ok = pcall(function()
            mousemoveabs(math.floor(center.X), math.floor(center.Y))
            task.wait(0.035)
            mouse1click()
        end)
    end
    if not ok then
        ok = pcall(function() button:Activate() end)
    end
    return ok
end

local VK = {
    Q = 0x51,
    E = 0x45,
    Z = 0x5A,
    N = 0x4E,
    Space = 0x20,
    F6 = 0x75,
    F7 = 0x76,
    F8 = 0x77,
    F9 = 0x78,
}

local function sendKey(keyName)
    local code = VK[keyName]
    if not code or not isRobloxFocused() then return false end
    if type(keyclick) == "function" then
        return pcall(keyclick, code)
    end
    if type(keypress) == "function" and type(keyrelease) == "function" then
        local ok = pcall(keypress, code)
        task.wait(0.045)
        local released = pcall(keyrelease, code)
        return ok and released
    end
    return false
end

local function allGuiText()
    local parts = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
                if item.Text and item.Text ~= "" and visible(item) then
                    table.insert(parts, norm(item.Text))
                end
            end
        end
    end
    return table.concat(parts, " | ")
end

local function safeClipboard(value)
    if type(setclipboard) ~= "function" then
        log("Clipboard indisponível neste executor.", THEME.warning)
        return false
    end
    local ok = pcall(setclipboard, tostring(value))
    if ok then log("Copiado.", THEME.success) end
    return ok
end

local function clearPage()
    for _, child in ipairs(pageScroll:GetChildren()) do
        if child ~= pageLayout then child:Destroy() end
    end
    pageScroll.CanvasPosition = Vector2.new(0, 0)
end

local currentGrid = nil
local function section(titleText, subtitle)
    local holder = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 49),
        ZIndex = 5,
    }, pageScroll)
    label(holder, titleText, 19, THEME.text, true, 25).ZIndex = 6
    local sub = label(holder, subtitle or "", 10, THEME.muted, false, 19)
    sub.Position = UDim2.new(0, 0, 0, 27)
    sub.ZIndex = 6
end

local function newGrid()
    currentGrid = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
    }, pageScroll)
    local gridLayout = make("UIGridLayout", {
        CellSize = UDim2.new(0.5, -7, 0, 74),
        CellPadding = UDim2.new(0, 10, 0, 8),
        FillDirectionMaxCells = 2,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    }, currentGrid)
    gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if currentGrid and currentGrid.Parent then
            currentGrid.Size = UDim2.new(1, 0, 0, gridLayout.AbsoluteContentSize.Y)
        end
    end)
end

local function makeControlCard(titleText, description, controlText, callback, controlKind, initialValue)
    if not currentGrid then newGrid() end
    local card = make("Frame", {
        BackgroundColor3 = THEME.panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, currentGrid)
    round(card, 4)
    outline(card, THEME.line, 0.58, 1)

    local title = label(card, titleText, 11, THEME.text, true, 19)
    title.Position = UDim2.new(0, 11, 0, 7)
    title.Size = UDim2.new(1, -118, 0, 18)
    title.ZIndex = 6
    local desc = label(card, description, 9, THEME.muted, false, 34)
    desc.Position = UDim2.new(0, 11, 0, 29)
    desc.Size = UDim2.new(1, -20, 0, 35)
    desc.ZIndex = 6

    local control
    if controlKind == "toggle" then
        local enabled = state.toggles[controlText]
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 10),
            Size = UDim2.new(0, 45, 0, 23),
            BackgroundColor3 = enabled and THEME.accentDark or THEME.panel3,
            Text = enabled and "ON" or "OFF",
            TextColor3 = THEME.text,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(control, 3)
        control.MouseButton1Click:Connect(function()
            local nextValue = not state.toggles[controlText]
            local accepted = true
            if callback then
                local ok, result = pcall(callback, nextValue)
                if not ok then
                    accepted = false
                    log("Toggle falhou: " .. tostring(result), THEME.danger)
                elseif result == false then
                    accepted = false
                end
            end
            if accepted then state.toggles[controlText] = nextValue end
            local value = state.toggles[controlText] == true
            control.Text = value and "ON" or "OFF"
            control.BackgroundColor3 = value and THEME.accentDark or THEME.panel3
        end)
    elseif controlKind == "select" then
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 9),
            Size = UDim2.new(0, 106, 0, 25),
            BackgroundColor3 = THEME.panel3,
            Text = tostring(state.values[controlText] or initialValue[1]),
            TextColor3 = THEME.text,
            TextSize = 9,
            Font = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(control, 3)
        control.MouseButton1Click:Connect(function()
            local list = initialValue
            local current = state.values[controlText] or list[1]
            local index = 1
            for i, choice in ipairs(list) do
                if choice == current then index = i break end
            end
            index = index + 1
            if index > #list then index = 1 end
            state.values[controlText] = list[index]
            control.Text = list[index]
            if callback then pcall(callback, list[index]) end
        end)
    elseif controlKind == "input" then
        control = make("TextBox", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 9),
            Size = UDim2.new(0, 106, 0, 25),
            BackgroundColor3 = THEME.panel3,
            Text = tostring(state.values[controlText] or initialValue or ""),
            PlaceholderText = "Value",
            PlaceholderColor3 = THEME.muted,
            TextColor3 = THEME.text,
            TextSize = 9,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(control, 3)
        control.FocusLost:Connect(function()
            state.values[controlText] = control.Text
            if callback then pcall(callback, control.Text) end
        end)
    else
        control = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 9),
            Size = UDim2.new(0, 104, 0, 25),
            BackgroundColor3 = THEME.accentDark,
            Text = controlText,
            TextColor3 = THEME.text,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(control, 3)
        control.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then log("Ação falhou: " .. tostring(err), THEME.danger) end
            end
        end)
    end
    card:SetAttribute("yno_search", norm(titleText .. " " .. description))
    return card
end

local function addNotice(titleText, description, tagText)
    local card = make("Frame", {
        BackgroundColor3 = THEME.panel2,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 76),
        BorderSizePixel = 0,
        ZIndex = 5,
    }, pageScroll)
    round(card, 4)
    outline(card, THEME.line, 0.62, 1)
    label(card, titleText, 11, THEME.text, true, 20).Position = UDim2.new(0, 12, 0, 7)
    local desc = label(card, description, 9, THEME.muted, false, 39)
    desc.Position = UDim2.new(0, 12, 0, 30)
    desc.Size = UDim2.new(1, -24, 0, 39)
    if tagText then
        local tag = make("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 8),
            Size = UDim2.new(0, 88, 0, 20),
            BackgroundColor3 = THEME.accentDark,
            Text = tagText,
            TextColor3 = THEME.text,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(tag, 3)
    end
    card:SetAttribute("yno_search", norm(titleText .. " " .. description))
end

local function finishGrid()
    if currentGrid then
        local layout = currentGrid:FindFirstChildOfClass("UIGridLayout")
        if layout then
            currentGrid.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        end
    end
    currentGrid = nil
end

local function addButton(titleText, description, caption, callback)
    return makeControlCard(titleText, description, caption, callback, "button")
end

local function addToggle(titleText, description, key, defaultValue, callback)
    if state.toggles[key] == nil then state.toggles[key] = defaultValue == true end
    return makeControlCard(titleText, description, key, callback, "toggle")
end

local function addSelect(titleText, description, key, choices)
    if state.values[key] == nil then state.values[key] = choices[1] end
    return makeControlCard(titleText, description, key, nil, "select", choices)
end

local function addInput(titleText, description, key, defaultValue, callback)
    if state.values[key] == nil then state.values[key] = defaultValue end
    return makeControlCard(titleText, description, key, callback, "input", defaultValue)
end

local function openMenuButton(name, actionKey)
    local button = findButton({name}, true) or findButton({name}, false)
    if not button then
        log("Não encontrei '" .. name .. "' na interface. Abra esse menu manualmente.", THEME.warning)
        return false
    end
    return clickButton(button, actionKey or ("menu:" .. norm(name)), 1.3)
end

local function clickPhrase(phrases, key, exact, context, unique)
    local button = findButton(phrases, exact, context, unique)
    if not button then return false end
    return clickButton(button, key, 1.1)
end

local function clickFirstPhrase(phrases, key, exact, context, unique)
    for index, phrase in ipairs(phrases) do
        local button = findButton({phrase}, exact, context, unique)
        if button then
            return clickButton(button, key .. ":" .. tostring(index), 1.1)
        end
    end
    return false
end

local function openQuests(category)
    if not clickPhrase({"Quests"}, "open-quests", false, nil, true) then
        log("Abra Quests pelo menu lateral do jogo.", THEME.warning)
        return false
    end
    task.wait(0.35)
    if category and category ~= "All" then
        local categoryButton = waitForButton({category}, true, 3, "quest", true)
        if not categoryButton then
            categoryButton = waitForButton({category}, true, 2, nil, true)
        end
        if categoryButton then
            clickButton(categoryButton, "quest-category:" .. category, 0.7)
        else
            log("A categoria " .. category .. " não apareceu. Selecione-a no jogo.", THEME.warning)
            return false
        end
    end
    return true
end

local function claimVisibleQuests()
    local screenText = allGuiText()
    if not string.find(screenText, "quest", 1, true)
        and not string.find(screenText, "guide", 1, true)
        and not string.find(screenText, "bounty", 1, true)
        and not string.find(screenText, "unit hunt", 1, true) then
        log("Abra a tela de Quests ou Event Quests antes de coletar.", THEME.warning)
        return 0
    end

    local claimed = 0
    local claimAll = findButton({"Claim All"}, true)
    if claimAll and clickButton(claimAll, "claim-all", 2.2) then
        claimed = claimed + 1
        task.wait(0.3)
    end

    if claimed == 0 then
        local buttons = gameButtons()
        for _, button in ipairs(buttons) do
            local txt = button:IsA("TextButton") and norm(button.Text) or ""
            local ctx = contextText(button)
            local safeClaim = txt == "claim rewards" or txt == "claim reward"
            local related = string.find(ctx, "quest", 1, true)
                or string.find(ctx, "guide", 1, true)
                or string.find(ctx, "bounty", 1, true)
                or string.find(ctx, "unit hunt", 1, true)
                or string.find(ctx, "event quest", 1, true)
            if safeClaim and related and clickButton(button, "quest-claim:" .. tostring(button), 0.8) then
                claimed = claimed + 1
                task.wait(0.15)
            end
        end
    end
    log(claimed > 0 and ("Ações de coleta enviadas: " .. tostring(claimed)) or "Não encontrei recompensas concluídas para coletar.", claimed > 0 and THEME.success or THEME.warning)
    return claimed
end

local function openBountyBoard()
    if clickPhrase({"Bounties"}, "open-bounties", false, nil, true) then
        return true
    end
    if clickPhrase({"Missions"}, "open-missions-npc", false, nil, true) then
        task.wait(0.5)
        if clickPhrase({"Bounties"}, "open-bounties-after-missions", false, nil, true) then
            return true
        end
    end
    log("Fale com Navi, marcado como Missions, no Request Board; depois escolha Bounties.", THEME.warning)
    return false
end

local function claimBounties()
    local opened = openBountyBoard()
    if not opened then return false end
    task.wait(0.4)
    local screenText = allGuiText()
    if not string.find(screenText, "bount", 1, true) then
        log("Bounty Board não está visível. Abra a aba Bounties.", THEME.warning)
        return false
    end
    return claimVisibleQuests() > 0
end

local function storyStep(phrases, title, exact, context, timeout, unique)
    log("Story: aguardando " .. title .. "...", THEME.muted)
    local button = waitForButton(phrases, exact, timeout or 8, context, unique)
    if not button then
        error("controle '" .. title .. "' não apareceu. Confira o menu aberto.")
    end
    if not clickButton(button, "story-step:" .. norm(title), 0.7) then
        error("não consegui ativar '" .. title .. "'.")
    end
    task.wait(0.65)
end

local function startStory()
    if state.storyFlow then
        log("Story Runner já está executando.", THEME.warning)
        return false
    end
    local world = state.values.storyWorld
    local act = state.values.storyAct
    local difficulty = state.values.storyDifficulty
    local mode = state.values.storyMode
    local entry = state.values.storyEntry

    if mode == "World Skip" and world == "Sword Arena" then
        log("Sword Arena não oferece World Skip; escolha Individual Act.", THEME.warning)
        return false
    end

    state.storyFlow = true
    task.spawn(function()
        local ok, err = pcall(function()
            storyStep({"Play"}, "Play", true, nil, 5, true)
            storyStep({"Story"}, "Story", true, "play", 6, true)
            storyStep({world}, world, false, "play", 8, true)

            if mode == "World Skip" then
                storyStep({"World Skip"}, "World Skip", true, nil, 6, true)
            else
                storyStep({act}, act, false, nil, 6, true)
            end

            storyStep({difficulty}, difficulty, true, nil, 5, true)
            storyStep({entry}, entry, true, nil, 6, true)

            local startButton = waitForButton({"Start"}, true, 8, nil, true)
            if startButton then
                clickButton(startButton, "story-final-start", 2)
                log(world .. " · " .. mode .. " · " .. difficulty .. " enviado para iniciar.", THEME.success)
            else
                log("Seleção aberta. Se o servidor já iniciou o matchmaking, aguarde; caso contrário clique Start.", THEME.warning)
            end
        end)
        if not ok then
            log("Story Runner pausado: " .. tostring(err), THEME.warning)
        end
        state.storyFlow = false
    end)
    return true
end

local function startNativeMacro()
    local runTab = findButton({"Run"}, true, "macro", true)
    if not runTab then
        local macroButton = findButton({"Macro"}, true, nil, true)
        if not macroButton then
            log("Entre em uma partida e abra Macro no próprio jogo.", THEME.warning)
            return false
        end
        clickButton(macroButton, "native-macro-open", 1.5)
        task.wait(0.4)
        runTab = waitForButton({"Run"}, true, 5, "macro", true)
    end
    if not runTab then
        log("Abra Macro → Run no jogo e tente novamente.", THEME.warning)
        return false
    end
    clickButton(runTab, "native-macro-run", 0.8)
    task.wait(0.25)
    local mode = state.values.macroMode or "Loop"
    local modeButton = findButton({mode}, true, "run", true)
    if not modeButton then
        log("Escolha " .. mode .. " manualmente em Macro → Run.", THEME.warning)
        return false
    end
    clickButton(modeButton, "native-macro-mode:" .. mode, 0.8)
    task.wait(0.25)
    local start = findButton({"Start"}, true, "run", true)
    if not start then
        log("O botão Start do Macro não está visível. Confira a configuração da rotina.", THEME.warning)
        return false
    end
    local ok = clickButton(start, "native-macro-start", 2)
    if ok then log("Smart Macro nativo iniciado: " .. mode .. ".", THEME.success) end
    return ok
end

local function stopNativeMacro()
    local stop = findButton({"Stop"}, true, "macro", true)
    if not stop then stop = findButton({"Pause"}, true, "macro", true) end
    if not stop then
        log("Abra o painel flutuante do Macro nativo para pausar ou parar.", THEME.warning)
        return false
    end
    return clickButton(stop, "native-macro-stop", 1.5)
end

local function startUnitHunt()
    task.spawn(function()
        local ok, err = pcall(function()
            storyStep({"Events"}, "Events", false, nil, 5, true)
            storyStep({"Unit Hunt"}, "Unit Hunt", false, "events", 6, true)
            storyStep({"Start Hunt"}, "Start Hunt", true, nil, 6, true)
        end)
        if ok then
            log("Unit Hunt aberto. Q procura unidades raras; aproxime-se do alvo e use E para capturar.", THEME.success)
        else
            log("Não consegui abrir Unit Hunt: " .. tostring(err), THEME.warning)
        end
    end)
end

local function startHuntBook()
    if not clickFirstPhrase({"Book", "Collection Book"}, "unit-hunt-book", false, nil, true) then
        if not clickPhrase({"Unit Hunt"}, "unit-hunt-book-open", false, "events", true) then
            log("Entre em Events → Unit Hunt e use Book.", THEME.warning)
            return false
        end
    end
    return true
end

local function startHuntEventQuests()
    if not clickPhrase({"Events"}, "event-quests-open-events", false, nil, true) then
        log("Abra Events no menu do jogo.", THEME.warning)
        return false
    end
    task.wait(0.3)
    if not clickFirstPhrase({"Unit Hunt"}, "event-quests-unit-hunt", false, "events", true) then
        log("Selecione Unit Hunt na lista de eventos.", THEME.warning)
        return false
    end
    task.wait(0.3)
    local questButton = findButton({"Event Quests"}, false, "unit hunt", true)
    if questButton then clickButton(questButton, "event-quests-tab", 0.8) end
    return true
end

local function findCapturePrompt()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local now = os.clock()
    local cached = state.cachedCapturePrompt
    if cached and cached.prompt and cached.prompt.Parent and cached.prompt.Enabled
        and cached.part and cached.part.Parent and now - state.huntLastPromptScan < 1.2 then
        cached.distance = (root.Position - cached.part.Position).Magnitude
        return cached
    end
    if now - state.huntLastPromptScan < 1.2 then
        return nil
    end
    state.huntLastPromptScan = now

    local nearest, nearestDistance = nil, math.huge
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local action = norm(object.ActionText .. " " .. object.ObjectText .. " " .. object.Name)
            if string.find(action, "capture", 1, true) then
                local part = object.Parent
                if not part:IsA("BasePart") then
                    local model = object:FindFirstAncestorOfClass("Model")
                    part = model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true))
                end
                if part and part:IsA("BasePart") then
                    local distance = (root.Position - part.Position).Magnitude
                    if distance < nearestDistance then
                        nearest = {prompt = object, part = part, distance = distance}
                        nearestDistance = distance
                    end
                end
            end
        end
    end
    state.cachedCapturePrompt = nearest
    return nearest
end

local function findCaptureTiming()
    local markers, zones = {}, {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if item:IsA("GuiObject") and item.Visible then
                local name = norm(item.Name)
                if string.find(name, "marker", 1, true) or string.find(name, "needle", 1, true)
                    or string.find(name, "cursor", 1, true) then
                    table.insert(markers, item)
                elseif string.find(name, "perfect", 1, true) or string.find(name, "gold", 1, true)
                    or string.find(name, "targetzone", 1, true) or string.find(name, "capturezone", 1, true) then
                    table.insert(zones, item)
                end
            end
        end
    end
    for _, marker in ipairs(markers) do
        for _, zone in ipairs(zones) do
            local markerX = marker.AbsolutePosition.X + marker.AbsoluteSize.X / 2
            local zoneLeft = zone.AbsolutePosition.X
            local zoneRight = zoneLeft + zone.AbsoluteSize.X
            local sameBand = math.abs(marker.AbsolutePosition.Y - zone.AbsolutePosition.Y) < 38
            if sameBand and markerX >= zoneLeft and markerX <= zoneRight then
                return true
            end
        end
    end
    return false
end

local function processUnitHunt()
    if not state.toggles.autoUnitHunt then return end
    local now = os.clock()
    local text = allGuiText()
    local hasCaptureTiming = findCaptureTiming()
    local inEncounter = hasCaptureTiming
        or string.find(text, "perfect", 1, true) ~= nil
        or string.find(text, "hit the center", 1, true) ~= nil

    if inEncounter then
        if now - state.huntLastHit > 0.16 and hasCaptureTiming then
            state.huntLastHit = now
            sendKey("Space")
        elseif not state.captureMissLogged and now - state.huntLastScan > 9 then
            state.captureMissLogged = true
            log("Assist de captura ativo; se a barra não for reconhecida, acerte manualmente o centro dourado com Space/E.", THEME.warning)
        end
        return
    end

    local target = findCapturePrompt()
    if target then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if target.distance > math.max(4, target.prompt.MaxActivationDistance - 1) then
            if humanoid and now - state.huntLastMove > 1.4 then
                state.huntLastMove = now
                local direction = (target.part.Position - character.HumanoidRootPart.Position).Unit
                humanoid:MoveTo(target.part.Position - direction * math.max(2, target.prompt.MaxActivationDistance * 0.45))
            end
        elseif now - state.huntLastHit > 1.1 then
            state.huntLastHit = now
            sendKey("E")
        end
    elseif now - state.huntLastScan > 7 then
        state.huntLastScan = now
        sendKey("Q")
    end
end

local function openGuidebook()
    if not openQuests("Guide") then return false end
    return true
end

local function claimPhoenix()
    if not openGuidebook() then return false end
    task.wait(0.3)
    local claimAll = findButton({"Claim All"}, true, nil, true)
    if claimAll then
        clickButton(claimAll, "guidebook-claim-all", 1.8)
        task.wait(0.3)
    end
    local completion = findButton({"Guide Quests Complete"}, false, "guide", true)
    if completion then
        clickButton(completion, "guidebook-phoenix-completion", 1.5)
        return true
    end
    local claim = findButton({"Claim Rewards", "Claim Reward"}, true, "guide", true)
    if claim then
        clickButton(claim, "guidebook-phoenix-claim", 1.5)
        return true
    end
    log("Conclua as 10 Guide Quests e use Claim All; Phoenix só aparece ao completar a missão final.", THEME.warning)
    return false
end

local function claimBlankUnit()
    if not openBountyBoard() then return false end
    task.wait(0.3)
    if not clickPhrase({"Blank Tokens"}, "blank-token-tab", false, nil, true) then
        log("No Bounty Board, selecione Blank Tokens.", THEME.warning)
        return false
    end
    task.wait(0.25)
    local unit = state.values.blankUnit or "Shadow (Atomic)"
    local unitButton = findButton({unit}, false, nil, true)
    if not unitButton then
        log(unit .. " não está visível. Confira se você tem 30 Blank Tokens.", THEME.warning)
        return false
    end
    clickButton(unitButton, "blank-unit:" .. unit, 1)
    task.wait(0.25)
    local claim = findButton({"Claim"}, true, nil, true)
    if claim then
        clickButton(claim, "blank-unit-claim", 2)
        log("Pedido de claim enviado para " .. unit .. ". Confira o resultado no jogo.", THEME.success)
        return true
    end
    log("A unidade pode estar bloqueada ou já resgatada. Confira o custo de 30 Blank Tokens.", THEME.warning)
    return false
end

local function gameToggleByLabel(labelText)
    local target = norm(labelText)
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, labelObject in ipairs(root:GetDescendants()) do
            if labelObject:IsA("TextLabel") and visible(labelObject) and norm(labelObject.Text) == target then
                local parent = labelObject.Parent
                for depth = 1, 3 do
                    if not parent then break end
                    for _, object in ipairs(parent:GetChildren()) do
                        if object:IsA("GuiButton") and visible(object) and object.Active then
                            local name = norm(object.Name)
                            local buttonLabel = object:IsA("TextButton") and norm(object.Text) or ""
                            local toggleLike = string.find(name, "toggle", 1, true)
                                or string.find(name, "switch", 1, true)
                                or buttonLabel == "on" or buttonLabel == "off"
                            if toggleLike then
                                return clickButton(object, "game-setting:" .. target, 1.4)
                            end
                        end
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    log("Não encontrei o interruptor ao lado de " .. labelText .. ". Abra Settings e deixe essa opção visível.", THEME.warning)
    return false
end

local function openGameSettings()
    if not clickPhrase({"Settings"}, "settings-open", false, nil, true) then
        log("Abra Settings no menu do jogo.", THEME.warning)
        return false
    end
    return true
end

local function setPerformance(enabled)
    if enabled then
        if state.originalShadows == nil then
            state.originalShadows = Lighting.GlobalShadows
        end
        Lighting.GlobalShadows = false
        for _, object in ipairs(Lighting:GetDescendants()) do
            if object:IsA("BloomEffect") or object:IsA("BlurEffect") or object:IsA("ColorCorrectionEffect")
                or object:IsA("DepthOfFieldEffect") or object:IsA("SunRaysEffect") then
                if state.originalLighting[object] == nil then
                    state.originalLighting[object] = object.Enabled
                end
                object.Enabled = false
            end
        end
        log("Low Effects ativado localmente.", THEME.success)
    else
        if state.originalShadows ~= nil then
            Lighting.GlobalShadows = state.originalShadows
            state.originalShadows = nil
        end
        for object, oldValue in pairs(state.originalLighting) do
            if object and object.Parent then pcall(function() object.Enabled = oldValue end) end
        end
        state.originalLighting = {}
        log("Efeitos visuais restaurados.", THEME.success)
    end
end

local function setFpsCap(value)
    if type(setfpscap) ~= "function" then
        log("setfpscap não está disponível neste executor.", THEME.warning)
        return false
    end
    local limit = tonumber(value) or 60
    limit = math.clamp(math.floor(limit), 30, 360)
    if state.originalFpsCap == nil and type(getfpscap) == "function" then
        local ok, old = pcall(getfpscap)
        if ok then state.originalFpsCap = old end
    end
    return pcall(setfpscap, limit)
end

local function setAttackEffects(enabled)
    if enabled then
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
                or object:IsA("Highlight") then
                if state.originalAttackEffects[object] == nil then
                    state.originalAttackEffects[object] = object.Enabled
                end
                object.Enabled = false
            end
        end
    else
        for object, oldValue in pairs(state.originalAttackEffects) do
            if object and object.Parent then
                pcall(function() object.Enabled = oldValue end)
            end
        end
        state.originalAttackEffects = {}
    end
end

local function restorePerformance()
    setPerformance(false)
    setAttackEffects(false)
    if state.originalFpsCap ~= nil and type(setfpscap) == "function" then
        pcall(setfpscap, state.originalFpsCap)
        state.originalFpsCap = nil
    end
end

local function drawOverview()
    section("Overview", "Ações principais do Anime Crusaders X.")
    newGrid()
    addButton("Start Story", "Abre Play → Story e inicia o mundo/ato/dificuldade selecionados.", "START", startStory)
    addButton("Claim Quest Rewards", "Coleta Claim All ou recompensas concluídas nas telas de Quest.", "CLAIM", function()
        if not string.find(allGuiText(), "quest", 1, true) then openQuests(state.values.questCategory) end
        claimVisibleQuests()
    end)
    addButton("Enter Unit Hunt", "Abre Events → Unit Hunt → Start Hunt.", "ENTER", startUnitHunt)
    addButton("Start Smart Macro", "Inicia o Macro nativo já configurado em Macro → Run.", "MACRO", startNativeMacro)
    finishGrid()
    addNotice("Game automation", "O farming de fases usa o Smart Macro nativo: posicionamento, upgrades, habilidades e venda de unidades são decididos pela configuração de slots e zonas que você salvou.", "NATIVE")
    addNotice("Mission automation", "Quests tem categorias All, Daily, Infinite, Story, Event e Guide. O yno hub pode abrir as categorias e coletar recompensas concluídas; os objetivos de batalha são cumpridos jogando as fases.", "QUESTS")
    addNotice("Unit Hunt", "Evento de captura à parte do roster de Tower Defense. São 39 entradas no Book, quatro regiões e cinco Event Quests. O modo exige Level 5.", "EVENT")
    addNotice("Floating panel", "Arraste pela barra superior. — minimiza para o botão y. Clique y para reabrir. RightShift alterna a janela.", "UI")
end

local function drawMissions()
    section("Missions", "Quests, Guidebook, Daily objectives e Bounties.")
    newGrid()
    addSelect("Quest category", "All / Daily / Infinite / Story / Event / Guide.", "questCategory", {"All", "Daily", "Infinite", "Story", "Event", "Guide"})
    addButton("Open selected category", "Abre Quests e seleciona a categoria escolhida.", "OPEN", function()
        openQuests(state.values.questCategory)
    end)
    addButton("Claim All rewards", "Tenta coletar somente recompensas visíveis de Quest/Guide/Event.", "CLAIM ALL", claimVisibleQuests)
    addToggle("Auto claim completed quests", "Coleta Claim All quando uma tela de Quest ou Event Quest já estiver aberta.", "autoClaim", false)
    addButton("Open Guidebook", "Quests → Guide. Use para seguir as 10 tarefas que liberam Phoenix.", "GUIDE", openGuidebook)
    addButton("Open Bounty Board", "Navi, marcado Missions, no Request Board → Bounties.", "BOUNTIES", openBountyBoard)
    addButton("Claim completed bounties", "Coleta recompensas dos cartões de Bounty já concluídos.", "CLAIM", claimBounties)
    addToggle("Auto quest farming", "Mantém Auto Start/Next/Skip ativos para objetivos de kills e clears enquanto você joga Story.", "autoQuestLoop", false, function(enabled)
        if enabled then
            state.toggles.autoStart = true
            state.toggles.autoNext = true
        end
    end)
    finishGrid()
    addNotice("Daily Quests", "Complete cinco tarefas diárias e reivindique o bônus Daily Quests Complete!: 750 Gems + 10 Trait Remnants. As tarefas podem incluir Kills, Challenge, Summoning e Stage Completion; confira a lista atual do seu jogo.", "750 GEMS")
    addNotice("Guidebook → Phoenix", "Complete as 10 Guide Quests e colete Guide Quests Complete! para receber Phoenix. As tarefas incluem Roll Traits, Feed Units, Fuse Units, Clear Stages, Place Units, Sell Units e Roll Stats.", "FREE UNIT")
    addNotice("Bounty cards", "Cada cartão tem três objetivos. Complete os três e receba 5 Event Tokens + 1 Blank Token. A placa diária oferece dez cartões; reroll custa 10.000 Gold e apaga o progresso daquele cartão.", "BOUNTY")
end

local function drawStory()
    section("Story", "Selecione mundo, ato e dificuldade. O runner navega pelos menus visíveis.")
    newGrid()
    addSelect("World", "11 mundos em ordem de progressão.", "storyWorld", WORLD_LIST)
    addSelect("Act", "Sword Arena e mundos com atos individuais usam Act 1–6.", "storyAct", {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"})
    addSelect("Difficulty", "Hard só fica disponível depois de concluir aquele ato em Normal.", "storyDifficulty", {"Normal", "Hard"})
    addSelect("Story route", "World Skip está disponível nos mundos 1–10; Sword Arena exige atos individuais.", "storyMode", {"Individual Act", "World Skip"})
    addSelect("Party entry", "Matchmaking procura jogadores; Select Stage abre a tela de party.", "storyEntry", {"Matchmaking", "Select Stage"})
    addButton("Start selected Story", "Play → Story → World → Act/World Skip → Difficulty → Matchmaking/Select Stage → Start.", "START STORY", startStory)
    addToggle("Auto Start match", "Clica em Vote Start ou Start Match quando esses controles aparecem.", "autoStart", false)
    addToggle("Auto Skip waves", "Vota em Skip Wave quando o botão estiver visível.", "autoSkip", false)
    addToggle("Auto Next stage", "Clica Next/Next Stage após uma conclusão, para avançar na sequência disponível.", "autoNext", false)
    addToggle("Auto Retry after defeat", "Clica Retry/Replay quando derrota e o botão estiver disponível.", "autoRetry", false)
    finishGrid()
    addNotice("World order", "Planet Namak → Marine's Ford → Karakura Town → Shibuya → Demon District → Devil City → Soul Society → West City (Ruined) → Culling Games → Doldrey → Sword Arena.", "11 WORLDS")
    addNotice("World Skip", "Normal only, com +900% de HP dos inimigos. Uma vitória completa todos os atos daquele mundo. Não está disponível em Sword Arena.", "WORLDS 1–10")
    addNotice("Progression tip", "Conclua Culling Games para liberar Doldrey. Concluir um ato em Normal libera Hard para aquele ato. Use Auto Next com cautela: ele segue o próximo estágio que o próprio jogo disponibilizar.", "STORY")
end

local function drawUnitHunt()
    section("Unit Hunt", "O evento de captura de criaturas — não confundir com unidades equipáveis do modo Tower Defense.")
    newGrid()
    addButton("Enter Hunting Isles", "Events → Unit Hunt → Start Hunt. Requer Player Level 5.", "ENTER", startUnitHunt)
    addToggle("Auto Hunt", "Procura ProximityPrompts de Capture, aproxima o personagem e usa E. Pressiona Q para procurar raros.", "autoUnitHunt", false)
    addButton("Open Collection Book", "Abre Book para conferir entradas capturadas, regiões e Shinies.", "BOOK", startHuntBook)
    addButton("Open Event Quests", "Abre a lista das cinco missões do Unit Hunt.", "QUESTS", startHuntEventQuests)
    addToggle("Auto claim Unit Hunt quests", "Coleta recompensas de Event Quests quando a lista está aberta.", "autoHuntClaims", false)
    addButton("Claim Event rewards", "Tenta Claim All / Claim Rewards na página de Event Quests.", "CLAIM", function()
        if not string.find(allGuiText(), "event quest", 1, true) then startHuntEventQuests() end
        task.wait(0.2)
        claimVisibleQuests()
    end)
    finishGrid()
    addNotice("Capture mechanics", "Pressione Q para scan; aproxime-se do alvo até E Capture aparecer; pressione E. No minigame, acerte o marcador no centro dourado com clique, Space ou E para PERFECT (dano dobrado).", "Q · E · SPACE")
    addNotice("Regions & rewards", "Whisperwood Isles: 8 entries / 5 Event Tokens. Bridgeway Hollow: 11 / 10 Tokens (Hunt Wave 3). Crown Ward: 15 Tokens (Wave 6). Frostfang Peak: 20 Tokens (Wave 9).", "4 REGIONS")
    addNotice("Five event quests", "Rookie Hunter: 25 captures / 5 Tokens. Seasoned Hunter: 150 / 15. Shiny Spotter: 1 Shiny / 25. Valkyrie Slayer: 3 assists / 10. Shrine Keeper: awaken 2 Guardians / 10.", "EVENT QUESTS")
    addNotice("Final Page #039", "Capture the other 38 entries and reach Hunt Wave 10. Ride the Wind Geyser to Sky Altar above Frostfang Peak, break the Sky Seal and capture No.039 alone. First capture rewards 25 Event Tokens.", "SECRET")
    addNotice("Important distinction", "As 39 entradas de Unit Hunt são capturas do Collection Book do evento. Elas não são personagens que entram automaticamente no seu time de Tower Defense.", "COLLECTION")
end

local function drawFreeUnits()
    section("Free Units & Rewards", "Unidades resgatáveis por objetivos — custos e requisitos explícitos.")
    newGrid()
    addButton("Claim Phoenix", "Abre Guidebook e tenta coletar Guide Quests Complete! se as 10 tarefas estiverem feitas.", "CLAIM PHOENIX", claimPhoenix)
    addButton("Open Guidebook", "Veja progresso e objetivos individuais que faltam.", "OPEN", openGuidebook)
    addSelect("Blank Unit", "Shadow (Atomic) ou Lao (Heart).", "blankUnit", {"Shadow (Atomic)", "Lao (Heart)"})
    addButton("Open Blank Token shop", "Bounty Board → Blank Tokens. Selecione a unidade desejada.", "OPEN SHOP", function()
        if openBountyBoard() then
            task.wait(0.3)
            clickPhrase({"Blank Tokens"}, "blank-token-shop", false, nil, true)
        end
    end)
    addButton("Claim selected Blank Unit", "Envia o Claim da unidade selecionada. Só clique se você tiver os 30 Blank Tokens.", "CLAIM UNIT", claimBlankUnit)
    finishGrid()
    addNotice("Phoenix", "Phoenix é a recompensa de completar todas as 10 Guide Quests e reivindicar Guide Quests Complete! Phoenix (Rebirth) é outra forma, não a recompensa original.", "10 QUESTS")
    addNotice("Blank Units are not free", "Shadow (Atomic) custa 30 Blank Tokens e Lao (Heart) custa 30. O yno hub não gasta esses tokens automaticamente; o botão de claim acima só age quando você o aciona.", "30 TOKENS")
    addNotice("Other free rewards", "Use Missions → Claim All para recolher Daily, Story, Infinite e Event quest rewards concluídos. Códigos e recompensas podem expirar; verifique a lista atual dentro do jogo.", "CLAIM")
end

local function drawGame()
    section("Game", "Ações automáticas em controles visíveis e opções nativas.")
    newGrid()
    addToggle("Auto Vote Start", "Clica Vote Start / Start Match quando a partida pode começar.", "autoStart", false)
    addToggle("Auto Skip Wave", "Vota em Skip Wave / Vote Skip.", "autoSkip", false)
    addToggle("Auto Next", "Avança quando Next / Next Stage aparece após uma vitória.", "autoNext", false)
    addToggle("Auto Retry", "Repete quando Retry / Replay aparece após derrota.", "autoRetry", false)
    addToggle("Auto Abilities", "Usa botões de habilidade ativos e visíveis.", "autoAbilities", false)
    addButton("Open Macro Units", "Abre Macro → Units para Fill My Team, slots, targeting, Auto upgrade e Auto abilities.", "OPEN UNITS", function()
        local macro = findButton({"Macro"}, true, nil, true)
        if macro then clickButton(macro, "macro-open-units", 1.2) task.wait(0.3) end
        clickPhrase({"Units"}, "macro-units", false, "macro", true)
    end)
    addButton("Toggle Auto Sell Farms", "Procura o interruptor Auto Sell Farms na tela de Settings aberta.", "TOGGLE", function()
        gameToggleByLabel("Auto Sell Farms")
    end)
    addButton("Toggle Auto Sell Units", "Procura Auto Sell Units na tela de Settings aberta.", "TOGGLE", function()
        gameToggleByLabel("Auto Sell Units")
    end)
    addButton("Open Game Settings", "Abre Settings para opções persistentes como Auto Retry, Auto Next e Auto Vote Start.", "SETTINGS", openGameSettings)
    finishGrid()
    addNotice("Native settings", "Auto Retry, Auto Next e Auto Vote Start existem nas configurações do jogo. O script também pode acionar botões visíveis no fim da partida; evite duplicar opções se não precisar.", "SETTINGS")
    addNotice("Ability automation", "Configure Auto abilities por unidade em Settings → Units ou por slot em Macro → Units. O yno hub só aciona habilidades que estejam visíveis na interface.", "UNITS")
end

local function drawMacro()
    section("Smart Macro", "O sistema nativo do jogo faz o farm de verdade.")
    newGrid()
    addSelect("Run mode", "Loop repete a fase atual; This Stage faz uma partida; Routine executa uma fila pré-configurada.", "macroMode", {"Loop", "This Stage", "Routine"})
    addButton("Open Macro", "Abre o painel Smart Macro nativo do jogo.", "OPEN", function()
        openMenuButton("Macro", "native-macro-open-manual")
    end)
    addButton("Start Smart Macro", "Abre Run, seleciona o modo e pressiona Start. Configure o time e o mapa antes.", "START", startNativeMacro)
    addButton("Stop Smart Macro", "Pressiona Stop/Pause no painel Macro nativo.", "STOP", stopNativeMacro)
    addButton("Copy Icy preset code", "Preset comunitário AP-RSEHDXU para Sword Arena - Raid.", "COPY CODE", function()
        safeClipboard("AP-RSEHDXU")
    end)
    finishGrid()
    addNotice("Team setup", "Macro → Units → Fill My Team. Configure os seis slots + Hero, targeting, Auto upgrade, Auto abilities, placement limits e ondas.", "6 SLOTS + HERO")
    addNotice("Placement", "Macro → Units → Placement. Use Zones para definir áreas por unidade ou Recording para gravar o posicionamento por mapa.", "ZONES / RECORDING")
    addNotice("Routine", "Macro → Routine → New → Add Task. Defina Mode, World, Act, Difficulty e Play until Runs. Crie a fila primeiro; depois escolha Routine em Run.", "QUEUE")
    addNotice("Smart Challenge", "Macro → Dailies → Challenges. Selecione Daily/Weekly/Resource/Boost/Elemental/Weekly Tower, configure When e ligue a chave mestra Auto Challenge.", "DAILIES")
end

local function drawPerformance()
    section("Performance", "Ajustes locais de renderização. Os valores originais são restaurados ao descarregar.")
    newGrid()
    addToggle("Low Effects", "Desativa sombras globais e pós-processamento local.", "autoLowEffects", false, function(enabled)
        setPerformance(enabled)
    end)
    addToggle("Hide Attack Effects", "Desliga partículas, trails, beams e highlights locais.", "hideEffects", false, function(enabled)
        setAttackEffects(enabled)
    end)
    addInput("FPS cap", "Valor permitido: 30–360.", "fpsCap", "60")
    addButton("Apply FPS cap", "Aplica o limite selecionado com setfpscap.", "APPLY", function()
        local ok = setFpsCap(state.values.fpsCap)
        log(ok and "FPS cap aplicado." or "Não consegui aplicar o FPS cap.", ok and THEME.success or THEME.warning)
    end)
    addButton("Restore performance", "Restaura FPS, sombras e pós-processamento para os valores anteriores.", "RESTORE", restorePerformance)
    finishGrid()
    addNotice("Performance", "Redução de efeitos muda somente a renderização local. Não altera as regras, os drops nem o processamento do servidor.", "CLIENT SIDE")
end

local function saveConfig()
    if type(writefile) ~= "function" then
        log("Filesystem do executor indisponível.", THEME.warning)
        return false
    end
    local payload = {
        values = state.values,
        toggles = {},
    }
    for key, value in pairs(state.toggles) do
        if key ~= "autoUnitHunt" and key ~= "autoClaim" and key ~= "autoRetry" then
            payload.toggles[key] = value
        end
    end
    local ok = pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("yno_hub") then
            makefolder("yno_hub")
        end
        writefile("yno_hub/config.json", HttpService:JSONEncode(payload))
    end)
    return ok
end

local function loadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile("yno_hub/config.json") then
        return false
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("yno_hub/config.json"))
    end)
    if not ok or type(data) ~= "table" then return false end
    if type(data.values) == "table" then
        for key, value in pairs(data.values) do
            if state.values[key] ~= nil then state.values[key] = value end
        end
    end
    if type(data.toggles) == "table" then
        for key, value in pairs(data.toggles) do
            if state.toggles[key] ~= nil then
                state.toggles[key] = value == true
            end
        end
    end
    return true
end

local function drawSettings()
    section("Settings", "Preferências, diagnóstico e encerramento.")
    newGrid()
    addSelect("UI scale", "Ajuste a escala do painel.", "uiScale", {"0.80", "0.90", "1.00", "1.10"})
    addButton("Apply UI scale", "Aplica a escala escolhida.", "APPLY", function()
        uiScale.Scale = tonumber(state.values.uiScale) or 1
    end)
    addButton("Save configuration", "Salva seleções e toggles que podem ser restaurados com segurança.", "SAVE", function()
        local ok = saveConfig()
        log(ok and "Configuração salva em yno_hub/config.json." or "Falha ao salvar configuração.", ok and THEME.success or THEME.warning)
    end)
    addButton("Stop All automation", "Interrompe ciclos de quests, Story Runner, Unit Hunt e automações de tela.", "STOP ALL", function()
        state.toggles.autoClaim = false
        state.toggles.autoStart = false
        state.toggles.autoSkip = false
        state.toggles.autoNext = false
        state.toggles.autoRetry = false
        state.toggles.autoAbilities = false
        state.toggles.autoQuestLoop = false
        state.toggles.autoUnitHunt = false
        state.toggles.autoHuntClaims = false
        state.storyFlow = false
        log("Todas as automações do yno hub foram interrompidas.", THEME.warning)
    end)
    addButton("Unload yno hub", "Desconecta eventos, restaura efeitos e fecha a interface.", "UNLOAD", function()
        if ENV[RUNTIME_KEY] and ENV[RUNTIME_KEY].Unload then
            ENV[RUNTIME_KEY].Unload()
        end
    end)
    finishGrid()
    addNotice("Hotkey", "RightShift alterna mostrar/ocultar. — minimiza para o botão flutuante y. × descarrega o script.", "CONTROLS")
    addNotice("Privacy", "O script não pede senha, cookie Roblox, token de conta ou webhook. Webhooks e chamadas remotas privadas não fazem parte desta build.", "LOCAL")
end

local pageBuilders = {
    ["Overview"] = drawOverview,
    ["Missions"] = drawMissions,
    ["Story"] = drawStory,
    ["Unit Hunt"] = drawUnitHunt,
    ["Free Units"] = drawFreeUnits,
    ["Game"] = drawGame,
    ["Macro"] = drawMacro,
    ["Performance"] = drawPerformance,
    ["Settings"] = drawSettings,
}

local function showPage(name)
    if not pageBuilders[name] then return end
    state.page = name
    pageTitle.Text = name
    clearPage()
    pageBuilders[name]()
    for pageName, button in pairs(navButtons) do
        local active = pageName == name
        button.BackgroundColor3 = active and Color3.fromRGB(38, 54, 54) or THEME.sidebar
        button.TextColor3 = active and THEME.text or THEME.muted
        local marker = button:FindFirstChild("active_marker")
        if marker then marker.Visible = active end
    end
    search.Text = ""
end

local navData = {
    {"Overview", "◈"},
    {"Missions", "◎"},
    {"Story", "▣"},
    {"Unit Hunt", "✧"},
    {"Free Units", "◇"},
    {"Game", "⚔"},
    {"Macro", "▤"},
    {"Performance", "◌"},
    {"Settings", "⚙"},
}

for _, entry in ipairs(navData) do
    local name, iconText = entry[1], entry[2]
    local button = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = THEME.sidebar,
        Size = UDim2.new(1, 0, 0, 36),
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. iconText .. "   " .. name,
        TextColor3 = THEME.muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, navHolder)
    round(button, 3)
    local marker = make("Frame", {
        Name = "active_marker",
        BackgroundColor3 = THEME.accent,
        Size = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6,
    }, button)
    round(marker, 2)
    button.MouseButton1Click:Connect(function() showPage(name) end)
    navButtons[name] = button
end

local floatingButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -22, 1, -90),
    Size = UDim2.new(0, 47, 0, 47),
    BackgroundColor3 = THEME.accentDark,
    Text = "y",
    TextColor3 = THEME.text,
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 30,
}, gui)
round(floatingButton, 7)
outline(floatingButton, THEME.accent, 0.15, 1)
floatingButton.MouseButton1Click:Connect(function()
    if main and main.Parent then main.Visible = true end
    floatingButton.Visible = false
    state.minimized = false
end)

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    floatingButton.Visible = true
    state.minimized = true
end)

close.MouseButton1Click:Connect(function()
    if ENV[RUNTIME_KEY] and ENV[RUNTIME_KEY].Unload then
        ENV[RUNTIME_KEY].Unload()
    end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
    local query = norm(search.Text)
    for _, child in ipairs(pageScroll:GetChildren()) do
        if child:IsA("Frame") then
            if query == "" then
                child.Visible = true
            else
                local matchText = norm(child:GetAttribute("yno_search") or "")
                if matchText == "" then
                    for _, descendant in ipairs(child:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            matchText = matchText .. " " .. norm(descendant.Text)
                        end
                    end
                end
                child.Visible = string.find(matchText, query, 1, true) ~= nil
            end
        end
    end
end)

-- Window drag handling; all connections are stored for clean unload.
local dragging = false
local dragStart
local startPos
table.insert(state.connections, topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end))
table.insert(state.connections, topbar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))
table.insert(state.connections, UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

local function claimLoop()
    while state.running do
        if state.toggles.autoClaim then
            local text = allGuiText()
            local eligible = string.find(text, "quest", 1, true) or string.find(text, "guide", 1, true)
                or string.find(text, "event quest", 1, true) or string.find(text, "bounty", 1, true)
            if eligible and os.clock() - state.lastClaim > 3.5 then
                state.lastClaim = os.clock()
                claimVisibleQuests()
            end
        end
        if state.toggles.autoHuntClaims then
            local text = allGuiText()
            if string.find(text, "event quest", 1, true) and os.clock() - state.lastClaim > 3.5 then
                state.lastClaim = os.clock()
                claimVisibleQuests()
            end
        end
        task.wait(0.7)
    end
end

local function gameAutomationLoop()
    while state.running do
        local ok, err = pcall(function()
            if state.toggles.autoStart then
                clickFirstPhrase({"Vote Start", "Start Match"}, "auto-start", false, nil, true)
            end
            if state.toggles.autoSkip then
                clickFirstPhrase({"Vote Skip", "Skip Wave"}, "auto-skip", false, nil, true)
            end
            if state.toggles.autoNext then
                clickFirstPhrase({"Next Stage", "Next"}, "auto-next", false, nil, true)
            end
            if state.toggles.autoRetry then
                clickFirstPhrase({"Retry", "Replay"}, "auto-retry", false, nil, true)
            end
            if state.toggles.autoAbilities then
                local buttons = gameButtons()
                for _, button in ipairs(buttons) do
                    local text = buttonText(button)
                    if string.find(text, "use ability", 1, true) or string.find(text, "ability ready", 1, true) then
                        clickButton(button, "auto-ability:" .. tostring(button), 1.3)
                    end
                end
            end
            if state.toggles.autoUnitHunt then
                processUnitHunt()
            end
        end)
        if not ok then
            log("Automation recovery: " .. tostring(err), THEME.warning)
        end
        task.wait(0.35)
    end
end

local function unload()
    if not state.running then return end
    state.running = false
    state.storyFlow = false
    state.toggles.autoUnitHunt = false
    restorePerformance()
    for _, connection in ipairs(state.connections) do
        pcall(function() connection:Disconnect() end)
    end
    for _, thread in ipairs(state.threads) do
        pcall(task.cancel, thread)
    end
    if gui and gui.Parent then
        pcall(function() gui:Destroy() end)
    end
    ENV[RUNTIME_KEY] = nil
end

ENV[RUNTIME_KEY] = {Unload = unload, Version = "3.0.0"}

loadConfig()
showPage("Overview")

table.insert(state.threads, task.spawn(gameAutomationLoop))
table.insert(state.threads, task.spawn(claimLoop))

log("yno hub 3.0.0 carregado. RightShift oculta/mostra.", THEME.success)
