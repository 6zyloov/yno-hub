-- yno hub | anime crusaders x
-- v2.2.1 | 2026-11-17
-- Original client-side hub. Uses visible game UI and Roblox's built-in Smart Macro.
-- No hidden remote calls, currency modification, server bypass or anti-cheat evasion.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ENV = (type(getgenv) == "function" and getgenv()) or _G
local HUB_KEY = "yno_hub_runtime"

if ENV[HUB_KEY] and ENV[HUB_KEY].Unload then
    pcall(ENV[HUB_KEY].Unload)
end

local THEME = {
    bg = Color3.fromRGB(9, 10, 18),
    sidebar = Color3.fromRGB(12, 14, 24),
    panel = Color3.fromRGB(17, 20, 33),
    panel2 = Color3.fromRGB(22, 26, 42),
    panel3 = Color3.fromRGB(29, 34, 54),
    line = Color3.fromRGB(47, 54, 78),
    text = Color3.fromRGB(241, 243, 255),
    muted = Color3.fromRGB(142, 151, 177),
    purple = Color3.fromRGB(145, 104, 255),
    purpleDark = Color3.fromRGB(79, 55, 150),
    cyan = Color3.fromRGB(82, 211, 232),
    green = Color3.fromRGB(91, 219, 162),
    yellow = Color3.fromRGB(255, 194, 92),
    red = Color3.fromRGB(255, 103, 125),
}

local state = {
    running = true,
    page = "Overview",
    minimized = false,
    toggles = {},
    values = {
        joinMode = "Story",
        joinDelay = "8",
        summonLimit = "10",
        summonTarget = "",
        summonAmount = "10",
        rerollKind = "Trait",
        rerollLimit = "10",
        rerollTarget = "",
        shopItem = "",
        shopLimit = "1",
        macroName = "farm_route",
        macroMode = "Once",
        macroImport = "",
        redeemCode = "",
        webhook = "",
        fpsCap = "60",
        uiScale = "1.00",
        autoJoinDelay = "8",
    },
    macro = {},
    macroRecording = false,
    macroPlaying = false,
    stopMacro = false,
    macroGeneration = 0,
    playingKeys = {},
    renderConnection = nil,
    effectConnection = nil,
    originalFpsCap = nil,
    savedCoreGui = nil,
    summonCount = 0,
    rerollCount = 0,
    shopCount = 0,
    summonBaseline = {},
    rerollBaseline = {},
    heldKeys = {},
    lastAction = {},
    connections = {},
    savedVisuals = {},
    savedRender = nil,
    log = {},
}

local function gethuiSafe()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return CoreGui
end

local uiParent = gethuiSafe()
local oldGui = uiParent:FindFirstChild("yno_hub")
if oldGui then pcall(function() oldGui:Destroy() end) end

local gui, main, page, pageLayout, nav, titleLabel, statusLabel, toast, uiScale, floatingButton
local inputName, importBox, debugBox
local navButtons = {}
local toggleButtons = {}
local featureCallbacks = {}
local originalShowPage

local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, amount)
    create("UICorner", {CornerRadius = UDim.new(0, amount or 10)}, obj)
end

local function outline(obj, color, transparency, thickness)
    create("UIStroke", {
        Color = color or THEME.line,
        Transparency = transparency or 0.15,
        Thickness = thickness or 1,
    }, obj)
end

local function gradient(obj, c1, c2, rotation)
    create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 0,
    }, obj)
end

local function textLabel(parent, text, size, color, bold, height)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 22),
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextColor3 = color or THEME.text,
        TextSize = size or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local function normalize(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "[%p%c]", " ")
    value = string.gsub(value, "%s+", " ")
    return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

local function log(message, color)
    local item = {
        time = os.date("%H:%M:%S"),
        message = tostring(message),
        color = color or THEME.muted,
    }
    table.insert(state.log, 1, item)
    while #state.log > 8 do table.remove(state.log) end
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = item.message
        statusLabel.TextColor3 = item.color
    end
    if toast and toast.Parent then
        toast.Text = item.message
        toast.TextColor3 = item.color
        toast.Visible = true
        toast.BackgroundTransparency = 0.08
        toast.Position = UDim2.new(1, -18, 1, -58)
        task.delay(2.2, function()
            if toast and toast.Parent then
                toast.Visible = false
                toast.BackgroundTransparency = 1
            end
        end)
    end
end

local function safeClipboard(value)
    if type(setclipboard) ~= "function" then
        log("Clipboard não está disponível neste executor.", THEME.yellow)
        return false
    end
    local ok = pcall(setclipboard, tostring(value))
    log(ok and "Copiado." or "Não foi possível copiar.", ok and THEME.green or THEME.yellow)
    return ok
end

local function safeNumber(value, fallback, minimum, maximum)
    local n = tonumber(value)
    if not n then return fallback end
    return math.clamp(math.floor(n), minimum or 1, maximum or 9999)
end

local function visible(obj)
    local current = obj
    while current and current ~= game do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") and not current.Enabled then return false end
        current = current.Parent
    end
    return true
end

local function getTextForButton(button)
    local parts = {button.Name}
    if button:IsA("TextButton") then table.insert(parts, button.Text) end
    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child.Text and child.Text ~= "" then table.insert(parts, child.Text) end
        end
    end
    return normalize(table.concat(parts, " "))
end

local function exactButtonText(button, target)
    target = normalize(target)
    if normalize(button.Name) == target then return true end
    if button:IsA("TextButton") and normalize(button.Text) == target then return true end
    for _, child in ipairs(button:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and normalize(child.Text) == target then
            return true
        end
    end
    return false
end

local function gameButtons()
    local now = os.clock()
    if state.buttonCache and now - (state.buttonCacheAt or 0) < 0.35 then
        return state.buttonCache
    end
    local found = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        if root ~= gui then
            for _, item in ipairs(root:GetDescendants()) do
                if item:IsA("GuiButton") and visible(item) and item.Active then
                    table.insert(found, item)
                end
            end
        end
    end
    state.buttonCache = found
    state.buttonCacheAt = now
    return found
end

local function findButton(needles, exact, requiredContext)
    local buttons = gameButtons()
    local context = requiredContext and normalize(requiredContext) or nil
    for _, button in ipairs(buttons) do
        if not (gui and button:IsDescendantOf(gui)) then
            local haystack = getTextForButton(button)
            local contextOkay = true
            if context then
                local contextParts = {haystack}
                local ancestor = button.Parent
                local depth = 0
                while ancestor and depth < 5 do
                    table.insert(contextParts, normalize(ancestor.Name))
                    for _, child in ipairs(ancestor:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text ~= "" then
                            table.insert(contextParts, normalize(child.Text))
                        end
                    end
                    ancestor = ancestor.Parent
                    depth = depth + 1
                end
                local contextText = table.concat(contextParts, " ")
                contextOkay = string.find(contextText, normalize(context), 1, true) ~= nil
            end
            if contextOkay then
                for _, needle in ipairs(needles) do
                    local target = normalize(needle)
                    if target ~= "" then
                        local matched = exact and exactButtonText(button, target)
                            or (not exact and string.find(haystack, target, 1, true) ~= nil)
                        if matched then return button, haystack end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function activate(button, actionKey, cooldown)
    if not button or not button.Parent then return false end
    if not visible(button) or not button.Active then return false end
    if type(isrbxactive) == "function" then
        local focusOk, focused = pcall(isrbxactive)
        if focusOk and not focused then
            log("Roblox não está em primeiro plano; clique cancelado.", THEME.yellow)
            return false
        end
    end
    local now = os.clock()
    local key = actionKey or tostring(button)
    if state.lastAction[key] and now - state.lastAction[key] < (cooldown or 1.2) then
        return false
    end
    state.lastAction[key] = now

    -- Prefer documented Solara mouse input; fall back to Roblox GuiButton:Activate().
    local center = button.AbsolutePosition + (button.AbsoluteSize / 2)
    local ok = false
    if type(mousemoveabs) == "function" and type(mouse1click) == "function" then
        ok = pcall(function()
            mousemoveabs(math.floor(center.X), math.floor(center.Y))
            task.wait(0.04)
            mouse1click()
        end)
    end
    if not ok then
        ok = pcall(function() button:Activate() end)
    end
    if ok then
        log("Ação executada: " .. tostring(actionKey or button.Name), THEME.green)
        return true
    end
    log("O executor não conseguiu clicar no botão visível.", THEME.red)
    return false
end

local function clickWhenVisible(actionKey, phrases, interval, exact, context)
    local button = findButton(phrases, exact, context)
    if not button then return false end
    return activate(button, actionKey, interval or 1.4)
end

local function clickAllWhenVisible(actionKey, phrases, interval)
    local clicked = 0
    for _, button in ipairs(gameButtons()) do
        local haystack = getTextForButton(button)
        for _, phrase in ipairs(phrases) do
            if string.find(haystack, normalize(phrase), 1, true) then
                if activate(button, actionKey .. ":" .. tostring(button), interval or 1.1) then
                    clicked = clicked + 1
                end
                break
            end
        end
    end
    return clicked
end

local function allGuiText()
    local parts = {}
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
                if visible(item) and item.Text and item.Text ~= "" then
                    table.insert(parts, normalize(item.Text))
                end
            end
        end
    end
    return table.concat(parts, " | ")
end

local function findTextBox(needle)
    local target = normalize(needle)
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if item:IsA("TextBox") and visible(item) then
                local hint = normalize(item.Name .. " " .. item.PlaceholderText)
                if target == "" or string.find(hint, target, 1, true) then
                    return item
                end
            end
        end
    end
    return nil
end

local function toggleFromLabel(needle)
    local target = normalize(needle)
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, label in ipairs(root:GetDescendants()) do
            if label:IsA("TextLabel") and visible(label) and normalize(label.Text) == target then
                local parent = label.Parent
                for depth = 1, 2 do
                    if not parent then break end
                    for _, item in ipairs(parent:GetChildren()) do
                        if item:IsA("GuiButton") and visible(item) and item.Active then
                            local buttonName = normalize(item.Name)
                            local buttonText = item:IsA("TextButton") and normalize(item.Text) or ""
                            local toggleLabel = false
                            if buttonText == "on" or buttonText == "off" or buttonText == "enabled"
                                or buttonText == "disabled" or buttonText == "yes" or buttonText == "no" then
                                toggleLabel = true
                            end
                            if string.find(buttonName, "toggle", 1, true)
                                or string.find(buttonName, "switch", 1, true)
                                or string.find(buttonName, "checkbox", 1, true) then
                                toggleLabel = true
                            end
                            if not toggleLabel then
                                for _, child in ipairs(item:GetDescendants()) do
                                    if child:IsA("TextLabel") then
                                        local childText = normalize(child.Text)
                                        if childText == "on" or childText == "off"
                                            or childText == "enabled" or childText == "disabled" then
                                            toggleLabel = true
                                            break
                                        end
                                    end
                                end
                            end
                            if toggleLabel then
                                return activate(item, "settings:" .. target, 1.5)
                            end
                        end
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    log("Não achei o controle de alternância ao lado de '" .. needle .. "'. Abra essa opção manualmente.", THEME.yellow)
    return false
end

local function makeButton(parent, caption, callback, width, accent)
    local b = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = accent and THEME.purpleDark or THEME.panel3,
        Size = UDim2.new(0, width or 112, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = caption,
        TextColor3 = THEME.text,
        TextSize = 11,
        BorderSizePixel = 0,
    }, parent)
    round(b, 9)
    outline(b, accent and THEME.purple or THEME.line, 0.3, 1)
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = accent and THEME.purple or Color3.fromRGB(42, 48, 72)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = accent and THEME.purpleDark or THEME.panel3
    end)
    b.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then log("Erro: " .. tostring(err), THEME.red) end
        end
    end)
    return b
end

local function section(parent, heading, subtitle)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 58),
    }, parent)
    textLabel(holder, heading, 21, THEME.text, true, 27)
    local sub = textLabel(holder, subtitle or "", 11, THEME.muted, false, 22)
    sub.Position = UDim2.new(0, 0, 0, 29)
    return holder
end

local function row(parent, height)
    local holder = create("Frame", {
        BackgroundColor3 = THEME.panel,
        Size = UDim2.new(1, 0, 0, height or 64),
        BorderSizePixel = 0,
    }, parent)
    round(holder, 11)
    outline(holder, THEME.line, 0.5, 1)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 9),
        PaddingBottom = UDim.new(0, 8),
    }, holder)
    return holder
end

local function addInfo(parent, heading, description, tag, color, height)
    local holder = row(parent, height or 77)
    local title = textLabel(holder, heading, 13, THEME.text, true, 20)
    title.Size = UDim2.new(1, tag and -112 or 0, 0, 20)
    local body = textLabel(holder, description, 11, THEME.muted, false, (height or 77) - 34)
    body.Position = UDim2.new(0, 0, 0, 25)
    body.Size = UDim2.new(1, 0, 0, (height or 77) - 34)
    if tag then
        local badge = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 98, 0, 20),
            BackgroundColor3 = color or THEME.purpleDark,
            Font = Enum.Font.GothamBold,
            Text = tag,
            TextColor3 = THEME.text,
            TextSize = 9,
            BorderSizePixel = 0,
        }, holder)
        round(badge, 6)
    end
    return holder, title, body
end

local function addAction(parent, heading, description, caption, callback)
    local holder, title, body = addInfo(parent, heading, description, nil, nil, 91)
    body.Size = UDim2.new(1, -124, 0, 57)
    local b = makeButton(holder, caption, callback, 112, true)
    b.AnchorPoint = Vector2.new(1, 1)
    b.Position = UDim2.new(1, 0, 1, -1)
    return holder
end

local function setToggleValue(key, enabled)
    state.toggles[key] = enabled == true
    local button = toggleButtons[key]
    if button and button.Parent then
        button.Text = state.toggles[key] and "ON" or "OFF"
        button.BackgroundColor3 = state.toggles[key] and THEME.purple or THEME.panel3
    end
end

local function addToggle(parent, key, heading, description, defaultValue, callback)
    if state.toggles[key] == nil then state.toggles[key] = defaultValue or false end
    local holder = row(parent, 65)
    textLabel(holder, heading, 12, THEME.text, true, 19)
    local sub = textLabel(holder, description or "", 10, THEME.muted, false, 24)
    sub.Position = UDim2.new(0, 0, 0, 23)
    local btn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 48, 0, 26),
        BackgroundColor3 = state.toggles[key] and THEME.purple or THEME.panel3,
        Text = state.toggles[key] and "ON" or "OFF",
        TextColor3 = THEME.text,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    }, holder)
    round(btn, 8)
    toggleButtons[key] = btn
    btn.MouseButton1Click:Connect(function()
        local nextValue = not state.toggles[key]
        state.toggles[key] = nextValue
        if callback then
            local ok, accepted = pcall(callback, nextValue)
            if not ok then
                state.toggles[key] = not nextValue
                log("Erro: " .. tostring(accepted), THEME.red)
            elseif accepted == false then
                state.toggles[key] = false
            end
        end
        setToggleValue(key, state.toggles[key])
        log(heading .. (state.toggles[key] and " ativado." or " desativado."), state.toggles[key] and THEME.green or THEME.muted)
    end)
    return holder
end

local function addInput(parent, key, heading, placeholder, defaultValue, callback, width)
    local multiline = key == "macroImport"
    local holder = row(parent, multiline and 122 or 74)
    textLabel(holder, heading, 12, THEME.text, true, 20)
    local box = create("TextBox", {
        Position = UDim2.new(0, 0, 0, 27),
        Size = UDim2.new(1, width and -width or 0, 0, multiline and 78 or 31),
        BackgroundColor3 = THEME.panel3,
        Text = state.values[key] or defaultValue or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = THEME.muted,
        TextColor3 = THEME.text,
        TextSize = 11,
        Font = multiline and Enum.Font.Code or Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        TextWrapped = multiline,
        MultiLine = multiline,
        BorderSizePixel = 0,
    }, holder)
    round(box, 7)
    box.FocusLost:Connect(function()
        state.values[key] = box.Text
        if callback then callback(box.Text) end
    end)
    return box, holder
end

local function addSelect(parent, key, heading, choices, description)
    local holder = row(parent, 68)
    textLabel(holder, heading, 12, THEME.text, true, 20)
    local sub = textLabel(holder, description or "Clique para alternar as opções.", 9, THEME.muted, false, 16)
    sub.Position = UDim2.new(0, 0, 0, 25)
    local button
    button = makeButton(holder, tostring(state.values[key] or choices[1]), function()
        local current = state.values[key] or choices[1]
        local index = 1
        for i, choice in ipairs(choices) do
            if choice == current then index = i break end
        end
        index = index + 1
        if index > #choices then index = 1 end
        state.values[key] = choices[index]
        button.Text = choices[index]
        log(heading .. ": " .. choices[index], THEME.cyan)
    end, 130)
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, 0, 0.5, 0)
    return holder, button
end

local function addSpacer(parent, height)
    create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 3)}, parent)
end

local function clearPage()
    for _, item in ipairs(page:GetChildren()) do item:Destroy() end
    page.CanvasPosition = Vector2.new(0, 0)
    pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 9),
    }, page)
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 25)
    end)
end

local function saveConfig()
    if type(writefile) ~= "function" then return false end
    local safeValues = {}
    for key, value in pairs(state.values) do
        if key ~= "webhook" and key ~= "webhookId" and key ~= "macroImport" then
            safeValues[key] = value
        end
    end
    local payload = {
        visual = {
            lowQuality = state.toggles.lowQuality == true,
            hideEffects = state.toggles.hideEffects == true,
        },
        values = safeValues,
    }
    local ok = pcall(function()
        if type(makefolder) == "function" then
            pcall(makefolder, "yno_hub")
        end
        writefile("yno_hub/config.json", HttpService:JSONEncode(payload))
    end)
    return ok
end

local function loadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    local ok, data = pcall(function()
        if not isfile("yno_hub/config.json") then return nil end
        return HttpService:JSONDecode(readfile("yno_hub/config.json"))
    end)
    if ok and type(data) == "table" then
        if type(data.visual) == "table" then
            state.toggles.lowQuality = data.visual.lowQuality == true
            state.toggles.hideEffects = data.visual.hideEffects == true
        end
        if type(data.values) == "table" then
            for k, v in pairs(data.values) do
                if k ~= "webhook" and k ~= "webhookId" and k ~= "macroImport" then
                    state.values[k] = v
                end
            end
        end
    end
end

local function filePath(name)
    name = tostring(name or "macro")
    name = string.gsub(name, "[^%w_%-]", "_")
    if name == "" then name = "macro" end
    return "yno_hub/macros/" .. name .. ".json"
end

local function ensureMacroFolder()
    if type(makefolder) == "function" then
        pcall(makefolder, "yno_hub")
        pcall(makefolder, "yno_hub/macros")
    end
end

local function validateMacroActions(actions)
    if type(actions) ~= "table" then return nil, "A lista de ações não é válida." end
    if #actions > 10000 then return nil, "A macro ultrapassa o limite de 10.000 ações." end
    local sanitized = {}
    for _, action in ipairs(actions) do
        if type(action) ~= "table" then return nil, "A macro contém uma ação inválida." end
        local t = tonumber(action.t)
        if not t or t ~= t or t < 0 or t > 86400 then
            return nil, "A macro contém um horário inválido."
        end
        local kind = action.kind
        if kind == "click" then
            local x, y = tonumber(action.x), tonumber(action.y)
            if not x or not y or x ~= x or y ~= y or x < 0 or x > 1 or y < 0 or y > 1 then
                return nil, "A macro contém coordenadas inválidas."
            end
            table.insert(sanitized, {t=t, kind="click", x=x, y=y})
        elseif kind == "key" or kind == "key_down" or kind == "key_up" then
            if type(action.key) ~= "string" or not VK[action.key] then
                return nil, "A macro contém uma tecla não suportada."
            end
            table.insert(sanitized, {t=t, kind=kind, key=action.key})
        else
            return nil, "A macro contém um tipo de ação desconhecido."
        end
    end
    table.sort(sanitized, function(a, b) return a.t < b.t end)
    return sanitized
end

local function saveMacro(name)
    if type(writefile) ~= "function" then
        log("Este executor não oferece writefile.", THEME.yellow)
        return false
    end
    local sanitized, validationError = validateMacroActions(state.macro)
    if not sanitized then
        log("Macro inválida: " .. tostring(validationError), THEME.red)
        return false
    end
    ensureMacroFolder()
    local payload = {
        version = 1,
        game = "anime crusaders x",
        placeId = game.PlaceId,
        map = state.values.macroMap or "current",
        actions = sanitized,
    }
    local ok, err = pcall(function()
        writefile(filePath(name), HttpService:JSONEncode(payload))
    end)
    log(ok and ("Macro salva: " .. tostring(name)) or ("Falha ao salvar macro: " .. tostring(err)), ok and THEME.green or THEME.red)
    return ok
end

local function loadMacro(name)
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        log("Este executor não oferece leitura de arquivos.", THEME.yellow)
        return false
    end
    local path = filePath(name)
    local ok, result = pcall(function()
        if not isfile(path) then error("Arquivo não encontrado: " .. path) end
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok then
        log("Falha ao carregar macro: " .. tostring(result), THEME.red)
        return false
    end
    if type(result) ~= "table" or type(result.actions) ~= "table" then
        log("Arquivo de macro inválido.", THEME.red)
        return false
    end
    local sanitized, validationError = validateMacroActions(result.actions)
    if not sanitized then
        log("Macro inválida: " .. tostring(validationError), THEME.red)
        return false
    end
    state.macro = sanitized
    log("Macro carregada: " .. tostring(name) .. " (" .. tostring(#state.macro) .. " ações)", THEME.green)
    return true
end

local function listMacros()
    local result = {}
    if type(listfiles) ~= "function" then return result end
    ensureMacroFolder()
    local ok, files = pcall(listfiles, "yno_hub/macros")
    if ok and type(files) == "table" then
        for _, path in ipairs(files) do
            if string.sub(string.lower(path), -5) == ".json" then
                local name = string.match(path, "([^/\\]+)%.json$")
                if name then table.insert(result, name) end
            end
        end
    end
    table.sort(result)
    return result
end

local VK = {
    Backspace=0x08, Tab=0x09, Return=0x0D, Enter=0x0D, Escape=0x1B, Space=0x20,
    PageUp=0x21, PageDown=0x22, End=0x23, Home=0x24, Left=0x25, Up=0x26,
    Right=0x27, Down=0x28, Insert=0x2D, Delete=0x2E, LeftShift=0xA0,
    RightShift=0xA1, LeftControl=0xA2, RightControl=0xA3, LeftAlt=0xA4,
    RightAlt=0xA5, CapsLock=0x14, NumLock=0x90, ScrollLock=0x91,
    Zero=0x30, One=0x31, Two=0x32, Three=0x33, Four=0x34,
    Five=0x35, Six=0x36, Seven=0x37, Eight=0x38, Nine=0x39,
    Semicolon=0xBA, Equals=0xBB, Comma=0xBC, Minus=0xBD, Period=0xBE,
    Slash=0xBF, Backquote=0xC0, LeftBracket=0xDB, BackSlash=0xDC,
    RightBracket=0xDD, Quote=0xDE,
}
for i = 1, 26 do VK[string.char(64 + i)] = 0x40 + i end
for i = 1, 12 do VK["F" .. i] = 0x6F + i end

local function sendKeyState(keyName, isDown)
    local code = VK[keyName]
    if not code then
        log("Tecla não mapeada para replay: " .. tostring(keyName), THEME.yellow)
        return false
    end
    if isDown and type(isrbxactive) == "function" then
        local focusOk, focused = pcall(isrbxactive)
        if focusOk and not focused then return false end
    end
    local fn = isDown and keypress or keyrelease
    if type(fn) ~= "function" then return false end
    local ok = pcall(fn, code)
    if ok then
        if isDown then state.playingKeys[keyName] = true
        else state.playingKeys[keyName] = nil end
    end
    return ok
end

local function releasePlaybackKeys()
    for keyName in pairs(state.playingKeys) do
        pcall(function() sendKeyState(keyName, false) end)
    end
    state.playingKeys = {}
end

local function sendKeyTap(keyName)
    local code = VK[keyName]
    if not code then
        log("Tecla não mapeada para replay: " .. tostring(keyName), THEME.yellow)
        return false
    end
    if type(isrbxactive) == "function" then
        local focusOk, focused = pcall(isrbxactive)
        if focusOk and not focused then
            log("Roblox precisa estar em primeiro plano para receber a tecla.", THEME.yellow)
            return false
        end
    end
    if type(keyclick) == "function" then
        return pcall(keyclick, code)
    end
    if type(keypress) == "function" and type(keyrelease) == "function" then
        local ok = pcall(keypress, code)
        task.wait(0.05)
        local released = pcall(keyrelease, code)
        return ok and released
    end
    return false
end

local function getViewportInset()
    local ok, inset = pcall(function()
        return game:GetService("GuiService"):GetGuiInset()
    end)
    if ok then return inset end
    return Vector2.new(0, 0)
end

local function sendClick(x, y)
    if type(mousemoveabs) ~= "function" or type(mouse1click) ~= "function" then
        log("O executor não oferece mousemoveabs/mouse1click para replay.", THEME.red)
        return false
    end
    local inset = getViewportInset()
    if type(isrbxactive) == "function" then
        local focusOk, focused = pcall(isrbxactive)
        if focusOk and not focused then return false end
    end
    local ok = pcall(function()
        mousemoveabs(math.floor(x + inset.X), math.floor(y + inset.Y))
        task.wait(0.04)
        mouse1click()
    end)
    return ok
end

local function stopPlayback()
    state.macroGeneration = (state.macroGeneration or 0) + 1
    state.stopMacro = true
    state.macroPlaying = false
    releasePlaybackKeys()
end

local appendKeyUps

local function playMacro()
    if state.macroPlaying then
        log("Macro já está em execução.", THEME.yellow)
        return
    end
    if state.macroRecording then
        appendKeyUps()
        state.macroRecording = false
        state.recordStart = nil
        log("Gravação finalizada antes da reprodução.", THEME.cyan)
    end
    if #state.macro == 0 then
        log("Nenhuma ação gravada ou carregada.", THEME.yellow)
        return
    end
    state.macroGeneration = (state.macroGeneration or 0) + 1
    local generation = state.macroGeneration
    state.stopMacro = false
    state.macroPlaying = true
    local repetitions = state.values.macroMode == "Loop" and 999999 or 1
    log("Reprodução iniciada: " .. tostring(#state.macro) .. " ações.", THEME.green)
    task.spawn(function()
        for loopIndex = 1, repetitions do
            local previous = 0
            for _, action in ipairs(state.macro) do
                if generation ~= state.macroGeneration or state.stopMacro or not state.running then break end
                local waitFor = math.max(0, (tonumber(action.t) or 0) - previous)
                previous = tonumber(action.t) or previous
                local deadline = os.clock() + waitFor
                while waitFor > 0 and os.clock() < deadline do
                    if generation ~= state.macroGeneration or state.stopMacro or not state.running then break end
                    task.wait(math.min(deadline - os.clock(), 0.2))
                end
                if generation ~= state.macroGeneration or state.stopMacro or not state.running then break end
                if action.kind == "click" then
                    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
                    local x = math.clamp((tonumber(action.x) or 0.5) * viewport.X, 1, viewport.X - 1)
                    local y = math.clamp((tonumber(action.y) or 0.5) * viewport.Y, 1, viewport.Y - 1)
                    if not sendClick(x, y) then
                        log("Falha no clique da macro. Reprodução interrompida.", THEME.red)
                        state.stopMacro = true
                        break
                    end
                elseif action.kind == "key" then
                    local okKey = sendKeyTap(action.key)
                    if not okKey then
                        log("Falha ao reproduzir tecla: " .. tostring(action.key), THEME.red)
                    end
                elseif action.kind == "key_down" then
                    if not sendKeyState(action.key, true) then
                        log("Falha ao pressionar tecla: " .. tostring(action.key), THEME.red)
                    end
                elseif action.kind == "key_up" then
                    if not sendKeyState(action.key, false) then
                        log("Falha ao soltar tecla: " .. tostring(action.key), THEME.red)
                    end
                end
            end
            if generation ~= state.macroGeneration or state.stopMacro then break end
            if loopIndex < repetitions then task.wait(1) end
        end
        if generation == state.macroGeneration then
            releasePlaybackKeys()
            state.macroPlaying = false
            state.stopMacro = false
            log("Reprodução finalizada.", THEME.cyan)
        end
    end)
end

appendKeyUps = function()
    local t = os.clock() - (state.recordStart or os.clock())
    for keyName in pairs(state.heldKeys) do
        table.insert(state.macro, {t = t, kind = "key_up", key = keyName})
    end
    state.heldKeys = {}
end

local function stopRecording()
    if not state.macroRecording then return end
    appendKeyUps()
    state.macroRecording = false
    state.recordStart = nil
    log("Gravação parada: " .. tostring(#state.macro) .. " ações.", THEME.green)
end

local function startRecording()
    if state.macroPlaying then stopPlayback() end
    state.macro = {}
    state.heldKeys = {}
    state.macroRecording = true
    state.recordStart = os.clock()
    log("Gravando cliques e duração das teclas. F7 para parar.", THEME.yellow)
end

local function isOverHub(position)
    if not gui then return false end
    local ok, objects = pcall(function()
        return game:GetService("GuiService"):GetGuiObjectsAtPosition(position.X, position.Y)
    end)
    if not ok then return false end
    for _, obj in ipairs(objects) do
        if obj:IsDescendantOf(gui) then return true end
    end
    return false
end

local function recordInput(input, isDown)
    if not state.macroRecording or state.macroPlaying then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F6
        or input.KeyCode == Enum.KeyCode.F7 or input.KeyCode == Enum.KeyCode.F8
        or input.KeyCode == Enum.KeyCode.F9 then return end
    local focusedBox = UIS:GetFocusedTextBox()
    if focusedBox then return end
    local now = os.clock() - (state.recordStart or os.clock())
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isDown then
        if isOverHub(input.Position) then return end
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local inset = getViewportInset()
        local x = input.Position.X - inset.X
        local y = input.Position.Y - inset.Y
        table.insert(state.macro, {
            t = now,
            kind = "click",
            x = math.clamp(x / math.max(viewport.X, 1), 0, 1),
            y = math.clamp(y / math.max(viewport.Y, 1), 0, 1),
        })
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        local keyName = input.KeyCode.Name
        if not VK[keyName] then return end
        if isDown then
            if not state.heldKeys[keyName] then
                state.heldKeys[keyName] = true
                table.insert(state.macro, {t = now, kind = "key_down", key = keyName})
            end
        elseif state.heldKeys[keyName] then
            state.heldKeys[keyName] = nil
            table.insert(state.macro, {t = now, kind = "key_up", key = keyName})
        end
    end
end

local function countTargetLabels(targets)
    local counts = {}
    local tokens = {}
    for token in string.gmatch(string.gsub(tostring(targets or ""), "\n", ","), "[^,]+") do
        local normalized = normalize(token)
        if normalized ~= "" then table.insert(tokens, {original = token, normalized = normalized}) end
    end
    for _, root in ipairs(playerGui:GetChildren()) do
        for _, item in ipairs(root:GetDescendants()) do
            if (item:IsA("TextLabel") or item:IsA("TextButton")) and visible(item) and item.Text and item.Text ~= "" then
                local value = normalize(item.Text)
                for _, token in ipairs(tokens) do
                    if string.find(value, token.normalized, 1, true) then
                        counts[token.normalized] = (counts[token.normalized] or 0) + 1
                    end
                end
            end
        end
    end
    return counts, tokens
end

local function captureTargetBaseline(targets)
    local counts = countTargetLabels(targets)
    return counts
end

local function targetFoundAfterBaseline(targets, baseline)
    local current, tokens = countTargetLabels(targets)
    baseline = baseline or {}
    for _, token in ipairs(tokens) do
        if (current[token.normalized] or 0) > (baseline[token.normalized] or 0) then
            return true, token.original
        end
    end
    return false, nil
end

local function findTargetButtonForItem(needle)
    local target = normalize(needle)
    for _, button in ipairs(gameButtons()) do
        local current = button
        local context = getTextForButton(button)
        local depth = 0
        while current and depth < 4 do
            context = context .. " " .. normalize(current.Name)
            for _, child in ipairs(current:GetChildren()) do
                if child:IsA("TextLabel") then context = context .. " " .. normalize(child.Text) end
            end
            current = current.Parent
            depth = depth + 1
        end
        if string.find(context, "buy", 1, true) and (target == "" or string.find(context, target, 1, true)) then
            return button
        end
    end
    return nil
end

local function redeemCode(code)
    local box = findTextBox("code")
    if not box then
        log("Abra a janela de códigos do jogo para resgatar.", THEME.yellow)
        return false
    end
    box.Text = tostring(code)
    local redeem = findButton({"redeem", "resgatar"}, false)
    if not redeem then
        log("Campo preenchido; botão Redeem não encontrado.", THEME.yellow)
        return false
    end
    return activate(redeem, "redeem:" .. tostring(code), 0.7)
end

local function makeTab(parent, name, icon)
    local b = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = THEME.sidebar,
        Size = UDim2.new(1, 0, 0, 37),
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. icon .. "   " .. name,
        TextColor3 = THEME.muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
    }, parent)
    round(b, 8)
    local bar = create("Frame", {
        Name = "active_bar",
        BackgroundColor3 = THEME.purple,
        Position = UDim2.new(0, 0, 0.18, 0),
        Size = UDim2.new(0, 3, 0.64, 0),
        Visible = false,
        BorderSizePixel = 0,
    }, b)
    round(bar, 2)
    b.MouseButton1Click:Connect(function()
        if originalShowPage then originalShowPage(name) end
    end)
    navButtons[name] = b
    return b
end

local function buildOverview()
    section(page, "Overview", "Painel de controle do yno hub para Anime Crusaders X.")
    local hero = row(page, 132)
    gradient(hero, Color3.fromRGB(40, 29, 76), THEME.panel, 0)
    textLabel(hero, "yno hub // acx", 9, THEME.cyan, true, 17)
    local headline = textLabel(hero, "Farm. Optimize. Repeat.", 22, THEME.text, true, 31)
    headline.Position = UDim2.new(0, 0, 0, 22)
    local desc = textLabel(hero, "Automação de interface, macro gravável, presets e atalhos para os sistemas do próprio jogo.", 11, THEME.muted, false, 35)
    desc.Position = UDim2.new(0, 0, 0, 56)
    local quick = row(page, 67)
    textLabel(quick, "QUICK ACTIONS", 10, THEME.muted, true, 16)
    local b1 = makeButton(quick, "START", function()
        clickWhenVisible("quick-start", {"vote start", "start match"}, 1.5, false)
    end, 82, true)
    b1.Position = UDim2.new(0, 0, 0, 23)
    local b2 = makeButton(quick, "SKIP WAVE", function()
        clickWhenVisible("quick-skip", {"skip wave", "vote skip"}, 1.5, false)
    end, 95)
    b2.Position = UDim2.new(0, 91, 0, 23)
    local b3 = makeButton(quick, "REPLAY", function()
        clickWhenVisible("quick-replay", {"replay", "retry"}, 1.5, false)
    end, 82)
    b3.Position = UDim2.new(0, 195, 0, 23)
    addInfo(page, "Smart Macro nativo", "O jogo já possui This Stage, Loop, Routine, zonas, gravações, slots, upgrades e habilidades automáticas. Use Game → Start Auto Farm para iniciar o modo que você configurou.", "GAME SYSTEM", THEME.green, 87)
    addInfo(page, "Compatibilidade", "Creator do jogo esperado: 35139043. O hub usa botões visíveis da interface do jogo; se uma atualização mudar os nomes dos botões, use o UI Scanner para verificar a nova interface.", "UI-BASED", THEME.cyan, 83)
    local overviewBar = row(page, 72)
    textLabel(overviewBar, "MACRO HOTKEYS", 10, THEME.muted, true, 16)
    textLabel(overviewBar, "F6  Gravar     F7  Parar     F8  Reproduzir     F9  Interromper", 11, THEME.text, true, 28).Position = UDim2.new(0, 0, 0, 26)
end

local function buildFarmPlanner()
    section(page, "Farm Planner", "Rotas de recursos documentadas para decidir o que farmar e qual atividade repetir.")
    addInfo(page, "Gems · Daily + Quests", "Complete Login Rewards, Daily Quests e Guidebook. O track semanal completo soma 22.500 Gems e 225 Trait Remnants. Resgate prêmios acumulados antes de repetir estágios.", "DAILY", THEME.green, 82)
    addInfo(page, "Gold · Crusader Dash", "Colete moedas no minigame Crusader Dash: 10 Gold por moeda, com limite diário de 100.000 Gold nessa atividade.", "100K / DAY", THEME.yellow, 76)
    addInfo(page, "Gold · Chess / Reel Rush", "Chess paga 1.000 Gold por vitória contra outro jogador. Reel Rush tem duas tentativas diárias com recompensa; o pool listado inclui 10.000 Gold e 1 Event Token.", "MINIGAMES", THEME.cyan, 82)
    addInfo(page, "Event Tokens + Blank Tokens", "Complete os três objetivos de um Bounty Card para receber 5 Event Tokens e 1 Blank Token. Primeira vitória diária no Chess e Reel Rush também podem dar Event Token.", "BOUNTY", THEME.purple, 82)
    addInfo(page, "Trait Remnants / Trait Tokens", "Use Daily Login, Guidebook, Daily Quests e as lojas de Boss Rush. O custo pode variar conforme a unidade; confira antes de repetir rerolls.", "TRAITS", THEME.purple, 76)
    addInfo(page, "Stat Cubes / Perfect Stat Cubes", "Stat Cube rerrola Damage, SPA e Range juntos. Perfect Stat Cube rerrola um atributo escolhido. Multi custa 1 Stat Cube por unidade selecionada.", "STATS", THEME.cyan, 78)
    addInfo(page, "Relic Cubes / Curse Tokens", "Relic Cube rerrola um atributo de relíquia. Curse Token aplica curse em Twenty One. Mely's Shop e lojas de evento/raid podem fornecer materiais conforme o estoque.", "RELICS", THEME.yellow, 78)
    addInfo(page, "Repeatable stage farming", "Use Macro → Run → Loop para repetir a fase atual, ou Routine para enfileirar várias fases e quantidades de runs. Smart Macro posiciona, atualiza e vende farms conforme os slots configurados.", "AUTO FARM", THEME.green, 88)
    addAction(page, "Open resource farming guide", "Veja valores, limites diários e condições mais recentes de cada recompensa.", "COPY URL", function()
        safeClipboard("https://anime-crusaders-x.wiki/resource-farming/")
    end)
    addAction(page, "Open Macro presets", "Pesquise presets por mapa/modo e confira os bindings antes de importar.", "COPY URL", function()
        safeClipboard("https://anime-crusaders-x.wiki/macro-presets/")
    end)
end

local function buildJoiner()
    section(page, "Joiner", "Seleciona o modo e aciona as opções visíveis do lobby.")
    addSelect(page, "joinMode", "Target mode", {
        "Story", "Legend Stages", "Raids", "Challenges", "Daily Challenge", "Weekly Challenge",
        "Infinite", "Weekly Tower", "Boss Rush", "Boss Lair", "Events", "Portal",
        "Infinity Castle", "Tournament", "Infinite Tournament", "Testing Zone",
    }, "Clique para alternar o modo que o Joiner deve localizar.")
    addInput(page, "joinDelay", "Join delay (seconds)", "8", "8")
    addToggle(page, "autoJoin", "Auto Open Selected Mode", "Abre a categoria quando o botão estiver visível no Play menu; mundo, ato, dificuldade e Start são confirmados no próprio jogo.", false, function()
        state.autoJoinDone = false
        return true
    end)
    addAction(page, "Open selected mode", "Abre Play se necessário; depois escolha o modo. Mundo, ato, dificuldade e início da partida são confirmados no menu do jogo.", "OPEN MODE", function()
        local mode = state.values.joinMode or "Story"
        local modeButton = findButton({mode}, false, "Play")
        if modeButton then
            activate(modeButton, "join-manual:" .. mode, 2.5)
            return
        end
        local playButton = findButton({"Play"}, true)
        if playButton then
            activate(playButton, "join-open-play", 2.5)
            log("Play aberto. Pressione Open Mode novamente quando os modos aparecerem.", THEME.cyan)
        else
            log("Abra Play no lobby; depois pressione Open Mode novamente.", THEME.yellow)
        end
    end)
    addInfo(page, "Prioridade de modos", "A ordem configurável do Joiner depende dos botões que o lobby expõe. Mantenha apenas um modo por vez se não quiser que ele selecione outra atividade.", "TIP", THEME.yellow, 74)
end

local function startBuiltInMacro()
    local runTab = findButton({"Run"}, true, "Macro")
    if not runTab then
        local macroButton = findButton({"Macro"}, true)
        if not macroButton then
            log("Entre em uma partida e abra o botão Macro do jogo.", THEME.yellow)
            return false
        end
        if not activate(macroButton, "native-macro-open", 1.5) then return false end
        task.wait(0.4)
        runTab = findButton({"Run"}, true, "Macro")
    end
    if not runTab then
        log("Painel Macro não mostrou a aba Run. Abra Run manualmente.", THEME.yellow)
        return false
    end

    activate(runTab, "native-macro-run-tab", 0.8)
    task.wait(0.25)

    local mode = state.values.smartMacroMode or "Loop"
    local modeButton = findButton({mode}, true, "Run")
    if not modeButton then
        log("Modo " .. mode .. " não está visível na aba Run. Selecione-o manualmente.", THEME.yellow)
        return false
    end
    activate(modeButton, "native-macro-mode:" .. mode, 0.8)
    task.wait(0.25)

    local startButton = findButton({"Start Macro", "Start"}, false, "Run")
    if not startButton then
        log("Não encontrei Start na aba Run. Confira o preset e inicie manualmente.", THEME.yellow)
        return false
    end
    local ok = activate(startButton, "native-macro-start", 2)
    if ok then log("Smart Macro nativo iniciado (" .. mode .. ").", THEME.green) end
    return ok
end

local function stopBuiltInMacro()
    local stopButton = findButton({"Stop"}, true, "Macro")
    if not stopButton then
        local pauseButton = findButton({"Pause"}, true, "Macro")
        if pauseButton then return activate(pauseButton, "native-macro-pause", 1.5) end
        log("Painel flutuante do Macro não está visível.", THEME.yellow)
        return false
    end
    return activate(stopButton, "native-macro-stop", 1.5)
end

local function setStreamerMode(enabled)
    local StarterGui = game:GetService("StarterGui")
    if enabled then
        if not state.savedCoreGui then
            state.savedCoreGui = {}
            for _, coreType in ipairs({Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.EmotesMenu}) do
                local ok, isEnabled = pcall(function()
                    return StarterGui:GetCoreGuiEnabled(coreType)
                end)
                if ok then state.savedCoreGui[coreType] = isEnabled end
            end
        end
        for _, coreType in ipairs({Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.EmotesMenu}) do
            pcall(function() StarterGui:SetCoreGuiEnabled(coreType, false) end)
        end
        log("Streamer Mode: PlayerList, Chat e Emotes ocultos. Overhead names não são ocultados.", THEME.green)
    else
        if state.savedCoreGui then
            for coreType, previous in pairs(state.savedCoreGui) do
                pcall(function() StarterGui:SetCoreGuiEnabled(coreType, previous) end)
            end
            state.savedCoreGui = nil
        end
        log("Streamer Mode desativado; CoreGui restaurado.", THEME.cyan)
    end
end

local function buildGame()
    section(page, "Game", "Ações automáticas em botões reais e controles do Anime Crusaders X.")
    addSelect(page, "smartMacroMode", "Built-in Smart Macro mode", {"Loop", "This Stage", "Routine"}, "O script inicia o modo escolhido na aba Run do Macro nativo.")
    addAction(page, "Start Auto Farm (Smart Macro)", "Inicia o Macro nativo já configurado no jogo. Configure slots, unidades e posicionamento primeiro.", "START FARM", startBuiltInMacro)
    addAction(page, "Stop Auto Farm", "Interrompe o Smart Macro nativo pelo painel flutuante do jogo.", "STOP FARM", stopBuiltInMacro)
    addToggle(page, "autoStart", "Auto Start / Auto Vote Start", "Clica em Start ou Vote Start quando o botão estiver visível.", false)
    addToggle(page, "autoSkip", "Auto Skip Wave", "Envia o voto quando aparecer Skip Wave / Vote Skip.", false)
    addToggle(page, "autoReplay", "Auto Replay / Retry", "Reentra quando o botão Replay ou Retry aparecer no fim da partida.", false)
    addToggle(page, "autoNext", "Auto Next", "Avança quando o botão Next / Next Stage aparecer.", false)
    addToggle(page, "autoAbilities", "Auto Use Abilities", "Aciona botões de habilidade visíveis e ativos. Use com a unidade selecionada.", false)
    addToggle(page, "autoClaim", "Auto Claim Rewards", "Clica em Claim All / Claim quando a recompensa estiver visível.", false)
    addToggle(page, "antiAfk", "Anti AFK", "Quando o evento Idle dispara, move o cursor 1 px e volta; VirtualUser é apenas fallback.", false, function(enabled)
        if enabled then log("Anti AFK local ativado (melhor esforço).", THEME.green) end
    end)
    addToggle(page, "streamerMode", "Streamer Mode", "Oculta PlayerList, Chat e Emotes do CoreGui. Não oculta nomes acima dos personagens.", false, setStreamerMode)
    addAction(page, "Cycle Auto Upgrade priority", "Com uma unidade selecionada, envia Z para alternar P1 → P2 → P3 → P4 → P5 → P6 → Off.", "PRESS Z", function()
        if not sendKeyTap("Z") then log("Selecione uma unidade e deixe Roblox em primeiro plano.", THEME.yellow) end
    end)
    addAction(page, "Instant Auto Upgrade", "Com uma unidade selecionada, envia N para executar a ação Auto instantânea do jogo.", "PRESS N", function()
        if not sendKeyTap("N") then log("Selecione uma unidade e deixe Roblox em primeiro plano.", THEME.yellow) end
    end)
    addAction(page, "Open Macro Units setup", "Abre o Macro nativo e direciona para Units. Use Fill My Team e configure Auto upgrade / Auto abilities em cada slot.", "OPEN UNITS", function()
        local unitsTab = findButton({"Units"}, true)
        if not unitsTab then
            local macroButton = findButton({"Macro"}, true)
            if macroButton then activate(macroButton, "macro-units-open", 1.5) task.wait(0.35) end
            unitsTab = findButton({"Units"}, true)
        end
        if unitsTab then activate(unitsTab, "macro-units-tab", 1)
        else log("Abra Macro → Units manualmente.", THEME.yellow) end
    end)
    addAction(page, "Open native Auto Abilities settings", "O jogo salva habilidades automáticas em Settings → Units por unidade. Abra essa página para configurar o comportamento persistente.", "OPEN SETTINGS", function()
        local settingsButton = findButton({"Settings"}, true)
        if settingsButton then
            activate(settingsButton, "game-settings-open", 1.2)
            task.wait(0.35)
        end
        local unitsButton = findButton({"Units"}, true)
        if unitsButton then activate(unitsButton, "game-settings-units", 1.2)
        else log("Abra Settings → Units manualmente; selecione cada unidade e escolha a habilidade automática.", THEME.yellow) end
    end)
    addAction(page, "Toggle Auto Sell Farms", "Abra Settings → Auto Sell e deixe essa categoria visível no jogo.", "TOGGLE FARM", function()
        toggleFromLabel("Auto Sell Farms")
    end)
    addAction(page, "Toggle Auto Sell Units", "Procura Auto Sell Units na categoria Settings → Auto Sell já aberta.", "TOGGLE UNITS", function()
        toggleFromLabel("Auto Sell Units")
    end)
    addAction(page, "Toggle Auto Retry", "Use Settings → Gameplay → Match. Deixe essa categoria aberta no jogo.", "TOGGLE RETRY", function()
        toggleFromLabel("Auto Retry")
    end)
    addAction(page, "Toggle Auto Next", "Use Settings → Gameplay → Match. Deixe essa categoria aberta no jogo.", "TOGGLE NEXT", function()
        toggleFromLabel("Auto Next")
    end)
    addAction(page, "Toggle Auto Vote Start", "Use Settings → Gameplay → Match. Deixe essa categoria aberta no jogo.", "TOGGLE VOTE", function()
        toggleFromLabel("Auto Vote Start")
    end)
    addAction(page, "Toggle Auto-skip waves", "Abra a janela Skip Wave na partida e procure Auto-skip waves.", "TOGGLE SKIP", function()
        toggleFromLabel("Auto-skip waves")
    end)
    addInfo(page, "Automatic abilities", "O jogo guarda habilidades automáticas por unidade em Settings → Units. Também existe Auto abilities por slot em Macro → Units. Configure uma vez para cada unidade desejada.", "NATIVE SETTING", THEME.green, 82)
    addInfo(page, "Auto Upgrade priority", "A atualização de 16/11 adicionou o ciclo P1, P2, P3, P4, P5, P6 e Off no botão Auto ou na tecla Z. A tecla N é uma ação Auto instantânea separada.", "PATCH 16 NOV", THEME.cyan, 83)
end

local function applyLowQuality(enabled)
    if enabled then
        state.savedRender = state.savedRender or {effects = {}}
        pcall(function()
            if state.savedRender.globalShadows == nil then
                state.savedRender.globalShadows = Lighting.GlobalShadows
            end
            local function disableEffect(obj)
                if obj:IsA("PostEffect") then
                    if state.savedRender.effects[obj] == nil then
                        state.savedRender.effects[obj] = obj.Enabled
                    end
                    obj.Enabled = false
                end
            end
            for _, obj in ipairs(Lighting:GetDescendants()) do disableEffect(obj) end
            Lighting.GlobalShadows = false
            if state.renderConnection then state.renderConnection:Disconnect() end
            state.renderConnection = Lighting.DescendantAdded:Connect(disableEffect)
        end)
    else
        if state.renderConnection then
            pcall(function() state.renderConnection:Disconnect() end)
            state.renderConnection = nil
        end
        if state.savedRender then
            pcall(function()
                if state.savedRender.globalShadows ~= nil then
                    Lighting.GlobalShadows = state.savedRender.globalShadows
                end
                for obj, value in pairs(state.savedRender.effects or {}) do
                    if obj and obj.Parent then obj.Enabled = value end
                end
            end)
            state.savedRender = nil
        end
    end
end

local function applyHideEffects(enabled)
    if enabled then
        local function disableEffect(obj)
            local supported = obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Highlight")
            if supported then
                if state.savedVisuals[obj] == nil then
                    local ok, value = pcall(function() return obj.Enabled end)
                    if ok then state.savedVisuals[obj] = value end
                end
                pcall(function() obj.Enabled = false end)
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do disableEffect(obj) end
        if state.effectConnection then state.effectConnection:Disconnect() end
        state.effectConnection = workspace.DescendantAdded:Connect(disableEffect)
    else
        if state.effectConnection then
            pcall(function() state.effectConnection:Disconnect() end)
            state.effectConnection = nil
        end
        for obj, value in pairs(state.savedVisuals) do
            if obj and obj.Parent then pcall(function() obj.Enabled = value end) end
        end
        state.savedVisuals = {}
    end
end

local function applyFpsCap(value)
    local cap = safeNumber(value, 60, 15, 240)
    if type(setfpscap) == "function" then
        if state.originalFpsCap == nil and type(getfpscap) == "function" then
            local getOk, original = pcall(getfpscap)
            if getOk then state.originalFpsCap = original end
        end
        local ok = pcall(setfpscap, cap)
        log(ok and ("FPS cap: " .. cap) or "Não foi possível alterar o FPS cap.", ok and THEME.green or THEME.yellow)
    else
        log("setfpscap não está disponível neste executor.", THEME.yellow)
    end
end

local function restoreFpsCap()
    if state.originalFpsCap ~= nil and type(setfpscap) == "function" then
        pcall(setfpscap, state.originalFpsCap)
        state.originalFpsCap = nil
    end
end

local function buildPerformance()
    section(page, "Performance", "Reduza efeitos locais e limite o FPS sem alterar dados do servidor.")
    addToggle(page, "lowQuality", "Low Quality Effects", "Desliga sombras globais e efeitos de pós-processamento locais.", false, applyLowQuality)
    addToggle(page, "hideEffects", "Hide Attack Effects", "Desativa partículas, beams, trails e highlights locais do mapa.", false, applyHideEffects)
    addInput(page, "fpsCap", "FPS limit", "60", "60")
    addAction(page, "Apply FPS limit", "Aplica o limite usando setfpscap, se o executor oferecer essa função.", "APPLY", function()
        applyFpsCap(state.values.fpsCap)
    end)
    addAction(page, "Restore FPS limit", "Restaura o limite que estava ativo antes do yno hub alterar o FPS.", "RESTORE", function()
        restoreFpsCap()
        log("FPS cap original restaurado.", THEME.green)
    end)
    addAction(page, "Low Performance Mode", "Desativa sombras, pós-processamento e efeitos de partículas locais. Restaure quando terminar.", "ENABLE", function()
        state.toggles.lowQuality = true
        state.toggles.hideEffects = true
        applyLowQuality(true)
        applyHideEffects(true)
        originalShowPage("Performance")
    end)
    addInfo(page, "Restoration", "Desative os modos visuais antes de sair. O yno hub guarda os valores locais e tenta restaurá-los ao desativar ou descarregar.", "LOCAL ONLY", THEME.green, 76)
end

local function buildSummon()
    section(page, "Summon", "Automação de interface com limite de tentativas e parada por alvo.")
    addSelect(page, "summonAmount", "Pull amount", {"1", "10"}, "Escolha o botão de summon que já está selecionado no jogo.")
    addInput(page, "summonLimit", "Maximum pulls", "10", "10")
    addInput(page, "summonTarget", "Stop when unit appears", "Ex.: Twenty One, Goju", "")
    addToggle(page, "autoSummon", "Auto Summon", "Clica no botão Summon visível até encontrar um alvo novo ou atingir o limite.", false, function(enabled)
        if enabled then state.summonBaseline = captureTargetBaseline(state.values.summonTarget) end
    end)
    addAction(page, "Start summon cycle", "Inicie somente após selecionar o banner correto e conferir o saldo no jogo.", "START", function()
        state.summonCount = 0
        state.summonBaseline = captureTargetBaseline(state.values.summonTarget)
        setToggleValue("autoSummon", true)
        log("Ciclo de summon iniciado com limite " .. tostring(state.values.summonLimit), THEME.yellow)
    end)
    addAction(page, "Stop summon cycle", "Interrompe o ciclo imediatamente.", "STOP", function()
        setToggleValue("autoSummon", false)
        log("Ciclo de summon parado.", THEME.muted)
    end)
    addInfo(page, "Spending safety", "O hub não escolhe banner nem calcula a moeda do servidor. Defina o limite antes de iniciar; o script para no máximo configurado.", "LIMITED", THEME.yellow, 78)
end

local function buildMacro()
    section(page, "Macro", "Grave, salve, importe e reproduza cliques e teclas, incluindo tempo de tecla pressionada.")
    addInfo(page, "Hotkeys", "F6 inicia a gravação · F7 para · F8 reproduz · F9 interrompe. Os cliques no próprio yno hub não são gravados.", "F6–F9", THEME.cyan, 72)
    addInput(page, "macroName", "Macro name", "farm_route", "farm_route")
    addSelect(page, "macroMode", "Playback mode", {"Once", "Loop"}, "Loop repete a sequência até você interromper com F9.")
    addAction(page, "Start recording", "Limpa o buffer e começa a registrar cliques e teclas do jogo.", "RECORD", startRecording)
    addAction(page, "Stop recording", "Finaliza a gravação atual e deixa o buffer pronto para salvar.", "STOP", stopRecording)
    addAction(page, "Save macro", "Grava o buffer em yno_hub/macros/ usando JSON.", "SAVE", function()
        saveMacro(state.values.macroName)
    end)
    addAction(page, "Load macro", "Carrega o JSON local com o nome informado.", "LOAD", function()
        loadMacro(state.values.macroName)
    end)
    addAction(page, "Playback macro", "Reproduz os cliques e teclas registrados. Use F9 para interromper.", "PLAY", playMacro)
    addAction(page, "Stop playback", "Interrompe a reprodução atual.", "STOP", stopPlayback)
    addAction(page, "Export JSON", "Copia a macro atual em formato JSON.", "COPY JSON", function()
        safeClipboard(HttpService:JSONEncode({version=1, game="anime crusaders x", actions=state.macro}))
    end)
    addInput(page, "macroImport", "Import JSON", "Cole JSON aqui; depois clique IMPORT.", "")
    addAction(page, "Import JSON", "Valida e carrega a lista de ações colada no campo acima.", "IMPORT", function()
        local ok, result = pcall(function() return HttpService:JSONDecode(state.values.macroImport or "") end)
        if ok and type(result) == "table" and type(result.actions) == "table" then
            local sanitized, validationError = validateMacroActions(result.actions)
            if sanitized then
                state.macro = sanitized
                log("Macro importada: " .. tostring(#state.macro) .. " ações.", THEME.green)
            else
                log("Macro inválida: " .. tostring(validationError), THEME.red)
            end
        else
            log("JSON inválido ou sem lista actions.", THEME.red)
        end
    end)
    addAction(page, "List local macros", "Mostra os perfis encontrados na pasta yno_hub/macros.", "REFRESH", function()
        local files = listMacros()
        log(#files > 0 and ("Macros: " .. table.concat(files, ", ")) or "Nenhuma macro encontrada.", THEME.cyan)
    end)
    addAction(page, "Delete selected macro", "Apaga somente o arquivo com o nome informado no campo Macro name.", "DELETE", function()
        if type(delfile) ~= "function" or type(isfile) ~= "function" then
            log("Este executor não oferece delfile/isfile.", THEME.yellow)
            return
        end
        local path = filePath(state.values.macroName)
        if isfile(path) then
            local ok = pcall(delfile, path)
            log(ok and "Macro removida." or "Não foi possível apagar a macro.", ok and THEME.green or THEME.red)
        else
            log("Macro não encontrada: " .. path, THEME.yellow)
        end
    end)
    addAction(page, "Scan visible unit labels", "Varre os textos visíveis para ajudar a conferir slots e unidades da configuração atual.", "SCAN UNITS", function()
        local seen, found = {}, {}
        for _, root in ipairs(playerGui:GetChildren()) do
            for _, item in ipairs(root:GetDescendants()) do
                if item:IsA("TextLabel") and visible(item) and item.Text ~= "" then
                    local value = string.gsub(item.Text, "%s+", " ")
                    if #value > 2 and #value < 50 and not seen[value] then
                        seen[value] = true
                        table.insert(found, value)
                    end
                end
            end
        end
        safeClipboard(table.concat(found, "\n"))
        log("Textos visíveis copiados para conferência.", THEME.cyan)
    end)
    addAction(page, "Icy Ainz preset · AP-RSEHDXU", "Preset comunitário Sword Arena - Raid. Requer Beyond Heaven, Sun God VS Dragon, Mr. Champion, Useless Goddess, Loid e Speedcart. Loid/Speedcart P1; Beyond Heaven, Mr. Champion e Useless Goddess P2; Sun God VS Dragon P3.", "COPY CODE", function()
        safeClipboard("AP-RSEHDXU")
    end)
    addInfo(page, "Import preset", "No jogo: Macro → Units → Import, cole AP-RSEHDXU. Alternativamente Macro → Catalog → Presets, pesquise o código e selecione Use. Confira os seis slots e o mapa antes de iniciar.", "PRESET", THEME.cyan, 86)
    addInfo(page, "Auto Challenge", "O Macro nativo tem Dailies → Auto Challenge para agendar Daily, Weekly, Resource e Boost Challenges junto às rotinas. Configure a seleção no próprio jogo antes de iniciar.", "DAILIES", THEME.cyan, 82)
    addInfo(page, "Built-in Smart Macro", "O macro gravado pelo yno hub repete cliques e teclas. Para posicionamento inteligente, upgrades por onda, venda de farms, auto abilities e rotinas, use o Smart Macro nativo do jogo.", "IMPORTANT", THEME.yellow, 86)
end

local function buildReroll()
    section(page, "Auto Reroll", "Repetição limitada de botões visíveis. O hub interrompe por alvo ou limite.")
    addSelect(page, "rerollKind", "Reroll type", {"Trait", "Stat", "Relic", "Curse"}, "Abra primeiro o painel correspondente no jogo.")
    addInput(page, "rerollTarget", "Desired result", "Ex.: Shining, SSS, desired trait", "")
    addInput(page, "rerollLimit", "Maximum rerolls", "10", "10")
    addToggle(page, "autoReroll", "Auto Reroll", "Pressiona o botão Reroll da janela aberta e para por alvo novo/limite.", false, function(enabled)
        if enabled then state.rerollBaseline = captureTargetBaseline(state.values.rerollTarget) end
    end)
    addAction(page, "Start reroll cycle", "Confirme unidade, tipo e saldo antes de iniciar.", "START", function()
        state.rerollCount = 0
        state.rerollBaseline = captureTargetBaseline(state.values.rerollTarget)
        setToggleValue("autoReroll", true)
        log("Reroll iniciado: " .. tostring(state.values.rerollKind) .. ".", THEME.yellow)
    end)
    addAction(page, "Stop reroll cycle", "Interrompe o ciclo de reroll.", "STOP", function()
        setToggleValue("autoReroll", false)
        log("Reroll parado.", THEME.muted)
    end)
    addInfo(page, "Worthiness & costs", "Stat Cube e Perfect Stat Cube gastam Worthiness. Confira o custo por unidade antes de deixar um ciclo rodando.", "LIMITED", THEME.yellow, 77)
end

local function buildShop()
    section(page, "Shop", "Compra limitada pela interface visível e por um nome de item opcional.")
    addInput(page, "shopItem", "Item name filter", "Ex.: Trait Remnant, Stat Cube", "")
    addInput(page, "shopLimit", "Maximum purchases", "1", "1")
    addToggle(page, "autoBuy", "Auto Buy", "Clica em Buy apenas quando o nome do item configurado aparecer na mesma seção da loja.", false, function(enabled)
        if enabled and #normalize(state.values.shopItem) < 2 then
            log("Digite o nome do item antes de ativar Auto Buy.", THEME.yellow)
            return false
        end
        if enabled then state.shopCount = 0 end
        return true
    end)
    addAction(page, "Start purchase cycle", "Abra a loja desejada, informe um nome de item e confira moeda/quantidade antes de começar.", "START", function()
        if normalize(state.values.shopItem) == "" then
            log("Informe o nome específico do item antes de iniciar.", THEME.yellow)
            return
        end
        state.shopCount = 0
        setToggleValue("autoBuy", true)
        log("Ciclo de compra iniciado. O contador mede cliques, não compras confirmadas.", THEME.yellow)
    end)
    addAction(page, "Stop purchase cycle", "Para compras imediatamente.", "STOP", function()
        setToggleValue("autoBuy", false)
        log("Compra automática parada.", THEME.muted)
    end)
    addInfo(page, "Supported shop areas", "Gold Shop, Event, Raid, Boss Rush, Control, Perfection, Kitchen Madness e Einz's Shop são categorias listadas pelo LixHub; selecione a loja no próprio jogo.", "SHOP", THEME.cyan, 82)
end

local function sendWebhook(content)
    local url = tostring(state.values.webhook or "")
    if url == "" then
        log("Informe uma URL de webhook antes de testar.", THEME.yellow)
        return false
    end
    if not string.match(url, "^https://discord%.com/api/webhooks/")
        and not string.match(url, "^https://discordapp%.com/api/webhooks/") then
        log("Informe uma URL oficial de webhook do Discord.", THEME.yellow)
        return false
    end
    if type(request) ~= "function" then
        log("A API request() não está disponível neste executor.", THEME.yellow)
        return false
    end
    local ok, result = pcall(function()
        local response = request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({content = content}),
        })
        if type(response) == "table" and response.Success == false then
            error("HTTP " .. tostring(response.StatusCode or "erro"))
        end
        return response
    end)
    log(ok and "Webhook enviado." or ("Falha no webhook: " .. tostring(result)), ok and THEME.green or THEME.red)
    return ok
end

local function buildWebhook()
    section(page, "Webhook", "Notificações opcionais para um endpoint seu. A URL fica somente nesta sessão.")
    addInput(page, "webhook", "Discord webhook URL", "https://discord.com/api/webhooks/...", "")
    addAction(page, "Send test notification", "Envia uma mensagem de teste para o endpoint informado.", "TEST", function()
        sendWebhook("yno hub: teste de conexão.")
    end)
    addToggle(page, "webhookStage", "Notify on stage end", "Detecta texto de vitória/derrota na interface e envia um aviso.", false)
    addToggle(page, "webhookPing", "Mention Discord ID", "Adiciona menção apenas ao ID digitado no próximo campo.", false)
    addInput(page, "webhookId", "Discord user ID", "123456789012345678", "")
    addInfo(page, "Security", "Não cole tokens de bot, cookies Roblox ou senhas. Use somente um webhook criado para este canal e remova-o depois se ficar exposto.", "PRIVATE", THEME.yellow, 82)
end

local function buildMinigames()
    section(page, "Minigames", "Use macros gravadas para repetir sequências de entrada que você mesmo configurou.")
    addToggle(page, "autoMinigame", "Auto Re-enter Minigame", "Só reentra quando Play Again / Start Minigame aparecer; não joga a atividade sozinho.", false)
    addAction(page, "Open macro recorder", "Grave uma sequência para a atividade atual e salve com o nome do minigame.", "OPEN MACRO", function()
        originalShowPage("Macro")
    end)
    addInfo(page, "Available activity guides", "Crusader Dash, Chess e Reel Rush têm regras e controles próprios. Para jogos de reflexo, revise a gravação antes de usar Loop.", "GUIDE", THEME.cyan, 76)
end

local function buildMisc()
    section(page, "Misc", "Recompensas, códigos, treinamento e inspeção da interface.")
    addToggle(page, "autoTrain", "Auto Train Selected Unit", "Tenta acionar Train / Training em um painel de unidade aberto.", false)
    addAction(page, "Redeem code", "Preenche o campo Code visível e clica Redeem.", "REDEEM", function()
        if tostring(state.values.redeemCode or "") == "" then
            log("Digite um código antes de resgatar.", THEME.yellow)
        else
            redeemCode(state.values.redeemCode)
        end
    end)
    addInput(page, "redeemCode", "Code", "ACBESTTD2026", "")
    addAction(page, "Redeem confirmed codes", "Tenta resgatar a lista confirmada na consulta de 17/11/2026; códigos já usados/expirados serão ignorados pelo jogo.", "REDEEM LIST", function()
        local list = {"ACBESTTD2026", "ACCOMEBACK", "ANNIVERSARY", "SORRYFORSHUTDOWNEA2026", "WELCOMETOACX"}
        task.spawn(function()
            for _, code in ipairs(list) do
                if not state.running then break end
                redeemCode(code)
                task.wait(1.8)
            end
        end)
    end)
    addAction(page, "UI Scanner", "Lista botões visíveis do PlayerGui para diagnosticar alterações do jogo.", "SCAN UI", function()
        local found = {}
        for _, button in ipairs(gameButtons()) do
            local name = getTextForButton(button)
            if name ~= "" then table.insert(found, name) end
        end
        local output = table.concat(found, "\n")
        debugBox.Text = output ~= "" and output or "Nenhum botão visível foi encontrado."
        log("UI Scanner: " .. tostring(#found) .. " botões visíveis.", THEME.cyan)
    end)
    addAction(page, "Copy UI scan", "Copia o último resultado do UI Scanner.", "COPY", function()
        safeClipboard(debugBox.Text)
    end)
    local scanHolder = row(page, 176)
    textLabel(scanHolder, "VISIBLE UI CONTROLS", 10, THEME.muted, true, 18)
    debugBox = create("TextBox", {
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 1, -28),
        BackgroundColor3 = THEME.panel3,
        Text = "Clique em SCAN UI para listar controles do jogo.",
        TextColor3 = THEME.text,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        BorderSizePixel = 0,
    }, scanHolder)
    round(debugBox, 7)
end

local function buildSettings()
    section(page, "Settings", "Preferências, salvamento de configuração e diagnóstico.")
    addAction(page, "Save settings", "Salva toggles e campos em yno_hub/config.json, se writefile estiver disponível.", "SAVE CONFIG", function()
        log(saveConfig() and "Configuração salva." or "Salvamento não está disponível.", THEME.cyan)
    end)
    addSelect(page, "uiScale", "Interface scale", {"0.80", "0.90", "1.00", "1.10", "1.20"}, "A escala é aplicada ao painel inteiro.")
    addAction(page, "Apply interface scale", "Aplica o valor selecionado.", "APPLY", function()
        local n = tonumber(state.values.uiScale) or 1
        uiScale.Scale = math.clamp(n, 0.7, 1.25)
    end)
    addAction(page, "Restore visual settings", "Restaura efeitos visuais que o yno hub desativou.", "RESTORE", function()
        applyLowQuality(false)
        applyHideEffects(false)
        state.toggles.lowQuality = false
        state.toggles.hideEffects = false
        log("Configurações visuais restauradas.", THEME.green)
        originalShowPage("Performance")
    end)
    addAction(page, "Stop all automation", "Desativa todos os ciclos automáticos de UI, summon, reroll e shop.", "STOP ALL", function()
        for key, value in pairs(state.toggles) do
            if type(value) == "boolean" then state.toggles[key] = false end
        end
        applyLowQuality(false)
        applyHideEffects(false)
        restoreFpsCap()
        if state.savedCoreGui then setStreamerMode(false) end
        stopPlayback()
        stopRecording()
        stopBuiltInMacro()
        log("Todas as automações foram interrompidas.", THEME.yellow)
        originalShowPage("Settings")
    end)
    addAction(page, "Unload yno hub", "Fecha a interface, para loops e desconecta eventos.", "UNLOAD", function()
        if ENV[HUB_KEY] and ENV[HUB_KEY].Unload then ENV[HUB_KEY].Unload() end
    end)
    addInfo(page, "Build information", "yno hub · Anime Crusaders X · 2.2.1 · baseado nos recursos públicos consultados em 17/11/2026.", "BUILD", THEME.cyan, 76)
    addInfo(page, "Limits", "As ações automáticas dependem de botões visíveis. O jogo pode mudar nomes e layouts; o UI Scanner ajuda a identificar essas alterações. O hub não usa remotes privados ou funções internas adivinhadas.", "HONEST", THEME.green, 86)
end

local builders = {
    ["Overview"] = buildOverview,
    ["Farm Planner"] = buildFarmPlanner,
    ["Joiner"] = buildJoiner,
    ["Game"] = buildGame,
    ["Performance"] = buildPerformance,
    ["Summon"] = buildSummon,
    ["Macro"] = buildMacro,
    ["Auto Reroll"] = buildReroll,
    ["Shop"] = buildShop,
    ["Webhook"] = buildWebhook,
    ["Minigames"] = buildMinigames,
    ["Misc"] = buildMisc,
    ["Settings"] = buildSettings,
}

local function showPage(name)
    if not builders[name] then return end
    state.page = name
    clearPage()
    titleLabel.Text = name
    builders[name]()
    for pageName, button in pairs(navButtons) do
        local active = pageName == name
        button.BackgroundColor3 = active and Color3.fromRGB(42, 33, 73) or THEME.sidebar
        button.TextColor3 = active and THEME.text or THEME.muted
        local bar = button:FindFirstChild("active_bar")
        if bar then bar.Visible = active end
    end
end
originalShowPage = showPage

local function isGameScreen()
    local text = allGuiText()
    return string.find(text, "wave", 1, true) ~= nil
        or string.find(text, "match time", 1, true) ~= nil
        or string.find(text, "stage info", 1, true) ~= nil
end

local function processAutomation()
    while state.running do
        local cycleOk, cycleError = pcall(function()
        if not state.toggles.autoJoin then
            state.autoJoinDone = false
        elseif not state.autoJoinDone and not isGameScreen() then
            local mode = state.values.joinMode or "Story"
            local modeButton = findButton({mode}, false, "Play")
            local delayTime = safeNumber(state.values.joinDelay, 8, 3, 90)
            if modeButton and activate(modeButton, "auto-open-mode:" .. mode, delayTime) then
                state.autoJoinDone = true
                log(mode .. " aberto. Escolha mundo/ato/dificuldade e confirme Start no Play menu.", THEME.cyan)
            end
        end
        if state.toggles.autoStart then
            local startButton = findButton({"Vote Start", "Start Match"}, false)
            if startButton then activate(startButton, "auto-start", 1.8) end
        end
        if state.toggles.autoSkip then
            clickWhenVisible("auto-skip", {"vote skip", "skip wave"}, 1.5, false)
        end
        local nextButton = state.toggles.autoNext and findButton({"Next Stage", "Next"}, true) or nil
        local replayButton = state.toggles.autoReplay and findButton({"Replay", "Retry"}, true) or nil
        if nextButton then
            activate(nextButton, "auto-next", 2.0)
        elseif replayButton then
            activate(replayButton, "auto-replay", 2.0)
        end
        if state.toggles.autoAbilities then
            clickAllWhenVisible("auto-ability", {"use ability", "ability ready"}, 1.1)
        end
        if state.toggles.autoClaim then
            clickWhenVisible("auto-claim", {"claim all", "claim reward"}, 1.8, false)
        end
        if state.toggles.autoSummon then
            local found, name = targetFoundAfterBaseline(state.values.summonTarget, state.summonBaseline)
            local limit = safeNumber(state.values.summonLimit, 10, 1, 500)
            if found then
                setToggleValue("autoSummon", false)
                log("Alvo encontrado: " .. tostring(name) .. ". Summon interrompido.", THEME.green)
            elseif state.summonCount >= limit then
                setToggleValue("autoSummon", false)
                log("Limite de summon atingido: " .. tostring(limit), THEME.yellow)
            else
                local amount = safeNumber(state.values.summonAmount, 10, 1, 10)
                local button = findButton({
                    "summon x" .. amount,
                    "summon " .. amount,
                    "x" .. amount .. " summon",
                }, false)
                if button and state.summonCount + amount <= limit and activate(button, "summon-cycle", 2.1) then
                    state.summonCount = state.summonCount + amount
                    log("Tentativa de summon " .. tostring(state.summonCount) .. "/" .. tostring(limit), THEME.cyan)
                elseif button and state.summonCount + amount > limit then
                    setToggleValue("autoSummon", false)
                    log("Limite próximo menor que o pull selecionado; ciclo parado para não ultrapassar.", THEME.yellow)
                end
            end
        end
        if state.toggles.autoReroll then
            local found, name = targetFoundAfterBaseline(state.values.rerollTarget, state.rerollBaseline)
            local limit = safeNumber(state.values.rerollLimit, 10, 1, 500)
            if found then
                setToggleValue("autoReroll", false)
                log("Resultado encontrado: " .. tostring(name) .. ". Reroll interrompido.", THEME.green)
            elseif state.rerollCount >= limit then
                setToggleValue("autoReroll", false)
                log("Limite de reroll atingido: " .. tostring(limit), THEME.yellow)
            else
                local button = findButton({"reroll"}, false, state.values.rerollKind)
                if button and activate(button, "reroll-cycle", 2.0) then
                    state.rerollCount = state.rerollCount + 1
                    log("Reroll " .. tostring(state.rerollCount) .. "/" .. tostring(limit), THEME.cyan)
                end
            end
        end
        if state.toggles.autoBuy then
            local filter = normalize(state.values.shopItem)
            if filter == "" then
                setToggleValue("autoBuy", false)
                log("Defina o nome do item antes de iniciar Auto Buy.", THEME.yellow)
            else
            local limit = safeNumber(state.values.shopLimit, 1, 1, 100)
            if state.shopCount >= limit then
                setToggleValue("autoBuy", false)
                log("Limite de compras atingido.", THEME.yellow)
            else
                local button = findTargetButtonForItem(state.values.shopItem)
                if button and activate(button, "shop-buy-cycle", 2.0) then
                    state.shopCount = state.shopCount + 1
                    log("Clique de compra " .. tostring(state.shopCount) .. "/" .. tostring(limit), THEME.cyan)
                end
            end
            end
        end
        if state.toggles.autoTrain then
            clickWhenVisible("auto-train", {"start training", "train selected"}, 2.0, false)
        end
        if state.toggles.autoMinigame then
            clickWhenVisible("auto-minigame", {"play again", "start minigame"}, 3.0, false)
        end
        if state.toggles.webhookStage then
            local text = allGuiText()
            local finished = string.find(text, "victory", 1, true) or string.find(text, "defeat", 1, true)
                or string.find(text, "stage cleared", 1, true)
            if finished and not state.stageWebhookSent then
                state.stageWebhookSent = true
                local mention = ""
                if state.toggles.webhookPing and state.values.webhookId
                    and string.match(tostring(state.values.webhookId), "^%d+$") then
                    mention = "<@" .. state.values.webhookId .. "> "
                end
                sendWebhook(mention .. "yno hub: partida finalizada.")
            elseif not finished then
                state.stageWebhookSent = false
            end
        end
        end)
        if not cycleOk then
            log("Automation recovery: " .. tostring(cycleError), THEME.red)
            task.wait(1)
        end
        task.wait(0.45)
    end
end

local function setupAntiAfk()
    local ok, connection = pcall(function()
        return player.Idled:Connect(function()
            if state.toggles.antiAfk then
                local moved = false
                if type(mousemoverel) == "function" then
                    moved = pcall(function()
                        mousemoverel(1, 0)
                        task.wait(0.04)
                        mousemoverel(-1, 0)
                    end)
                end
                if not moved then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                    end)
                end
            end
        end)
    end)
    if ok and connection then table.insert(state.connections, connection) end
end

local function unload()
    if not state.running then return end
    state.running = false
    state.stopMacro = true
    state.macroRecording = false
    state.macroPlaying = false
    releasePlaybackKeys()
    applyLowQuality(false)
    applyHideEffects(false)
    restoreFpsCap()
    if state.savedCoreGui then setStreamerMode(false) end
    for _, connection in ipairs(state.connections) do
        pcall(function() connection:Disconnect() end)
    end
    for _, connection in ipairs({}) do pcall(function() connection:Disconnect() end) end
    if gui and gui.Parent then pcall(function() gui:Destroy() end) end
    if ENV[HUB_KEY] then ENV[HUB_KEY] = nil end
end

loadConfig()

gui = create("ScreenGui", {
    Name = "yno_hub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, uiParent)

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 800)
local initialScale = math.clamp(math.min(viewport.X / 1100, viewport.Y / 700), 0.72, 1)
uiScale = create("UIScale", {Scale = initialScale}, gui)

main = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(940, 620),
    BackgroundColor3 = THEME.bg,
    BorderSizePixel = 0,
}, gui)
round(main, 17)
outline(main, THEME.line, 0.08, 1)
gradient(main, Color3.fromRGB(17, 19, 34), Color3.fromRGB(8, 10, 17), 90)

local sidebar = create("Frame", {
    BackgroundColor3 = THEME.sidebar,
    Size = UDim2.new(0, 188, 1, 0),
    BorderSizePixel = 0,
}, main)
round(sidebar, 17)
create("Frame", {
    BackgroundColor3 = THEME.sidebar,
    Position = UDim2.new(1, -15, 0, 0),
    Size = UDim2.new(0, 15, 1, 0),
    BorderSizePixel = 0,
}, sidebar)

local brand = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 15, 0, 17),
    Size = UDim2.new(1, -30, 0, 54),
}, sidebar)
local icon = create("Frame", {
    BackgroundColor3 = THEME.purple,
    Size = UDim2.new(0, 40, 0, 40),
    BorderSizePixel = 0,
}, brand)
round(icon, 12)
gradient(icon, THEME.purple, THEME.cyan, 35)
local iconText = textLabel(icon, "y", 26, Color3.new(1, 1, 1), true, 40)
iconText.TextXAlignment = Enum.TextXAlignment.Center
local brandTitle = textLabel(brand, "yno hub", 18, THEME.text, true, 23)
brandTitle.Position = UDim2.new(0, 49, 0, 1)
local brandSubtitle = textLabel(brand, "ANIME CRUSADERS X", 8, THEME.muted, true, 18)
brandSubtitle.Position = UDim2.new(0, 50, 0, 25)

textLabel(sidebar, "MAIN MENU", 9, THEME.muted, true, 18).Position = UDim2.new(0, 18, 0, 87)
nav = create("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 11, 0, 110),
    Size = UDim2.new(1, -22, 1, -184),
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = THEME.purple,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, sidebar)
local navLayout = create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, nav)
navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    nav.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 8)
end)

local navData = {
    {"Overview", "◈"},
    {"Farm Planner", "¤"},
    {"Joiner", "⌁"},
    {"Game", "⚔"},
    {"Performance", "◉"},
    {"Summon", "✦"},
    {"Macro", "▣"},
    {"Auto Reroll", "⟳"},
    {"Shop", "◇"},
    {"Webhook", "↗"},
    {"Minigames", "▤"},
    {"Misc", "⋯"},
    {"Settings", "⚙"},
}
for _, entry in ipairs(navData) do makeTab(nav, entry[1], entry[2]) end

local footer = create("Frame", {
    BackgroundColor3 = THEME.panel,
    Position = UDim2.new(0, 11, 1, -62),
    Size = UDim2.new(1, -22, 0, 47),
    BorderSizePixel = 0,
}, sidebar)
round(footer, 9)
local dot = create("Frame", {
    BackgroundColor3 = THEME.green,
    Position = UDim2.new(0, 11, 0, 17),
    Size = UDim2.new(0, 8, 0, 8),
    BorderSizePixel = 0,
}, footer)
round(dot, 5)
textLabel(footer, "CLIENT READY", 9, THEME.green, true, 16).Position = UDim2.new(0, 25, 0, 7)
textLabel(footer, "UI automation", 8, THEME.muted, false, 14).Position = UDim2.new(0, 25, 0, 23)

local content = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 208, 0, 0),
    Size = UDim2.new(1, -226, 1, 0),
}, main)

local topbar = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 64),
}, content)
textLabel(topbar, "COMMAND CENTER", 8, THEME.muted, true, 16).Position = UDim2.new(0, 0, 0, 7)
titleLabel = textLabel(topbar, "Overview", 19, THEME.text, true, 28)
titleLabel.Position = UDim2.new(0, 0, 0, 27)

local statusPill = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -42, 0, 16),
    Size = UDim2.new(0, 92, 0, 25),
    BackgroundColor3 = Color3.fromRGB(19, 48, 42),
    Text = "●  READY",
    TextColor3 = THEME.green,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, topbar)
round(statusPill, 7)
local close = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 16),
    Size = UDim2.new(0, 28, 0, 25),
    BackgroundColor3 = Color3.fromRGB(61, 30, 43),
    Text = "×",
    TextColor3 = THEME.red,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, topbar)
round(close, 7)
close.MouseButton1Click:Connect(unload)

local minimize = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -34, 0, 16),
    Size = UDim2.new(0, 28, 0, 25),
    BackgroundColor3 = THEME.panel3,
    Text = "—",
    TextColor3 = THEME.muted,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, topbar)
round(minimize, 7)

floatingButton = create("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -24, 1, -126),
    Size = UDim2.new(0, 48, 0, 48),
    BackgroundColor3 = THEME.purpleDark,
    Text = "y",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 25,
    Font = Enum.Font.GothamBold,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 50,
}, gui)
round(floatingButton, 15)
outline(floatingButton, THEME.purple, 0.05, 1)
gradient(floatingButton, THEME.purple, THEME.cyan, 35)
floatingButton.MouseButton1Click:Connect(function()
    if main and main.Parent then main.Visible = true end
    if floatingButton and floatingButton.Parent then floatingButton.Visible = false end
end)
minimize.MouseButton1Click:Connect(function()
    if main and main.Parent then main.Visible = false end
    if floatingButton and floatingButton.Parent then floatingButton.Visible = true end
end)

page = create("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 69),
    Size = UDim2.new(1, 0, 1, -116),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.purple,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, content)

local bottomBar = create("Frame", {
    BackgroundColor3 = THEME.panel,
    Position = UDim2.new(0, 0, 1, -39),
    Size = UDim2.new(1, 0, 0, 31),
    BorderSizePixel = 0,
}, content)
round(bottomBar, 8)
statusLabel = textLabel(bottomBar, "Pronto. RightShift mostra/oculta o painel.", 9, THEME.muted, false, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 4)
local versionLabel = textLabel(bottomBar, "2.2.1", 9, THEME.purple, true, 22)
versionLabel.TextXAlignment = Enum.TextXAlignment.Right
versionLabel.Position = UDim2.new(1, -52, 0, 4)
versionLabel.Size = UDim2.new(0, 42, 0, 22)

toast = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 340, 1, -55),
    Size = UDim2.new(0, 310, 0, 38),
    BackgroundColor3 = THEME.panel3,
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = THEME.text,
    TextSize = 11,
    Font = Enum.Font.GothamSemibold,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 30,
}, gui)
round(toast, 9)
outline(toast, THEME.line, 0.1, 1)

-- Drag the window from the top bar.
local dragging = false
local dragStart
local startPosition
table.insert(state.connections, topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
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
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end))

local inputConnection = UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if gui and gui.Parent then
            main.Visible = not main.Visible
            if floatingButton then floatingButton.Visible = not main.Visible end
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.F6 then startRecording() return end
    if input.KeyCode == Enum.KeyCode.F7 then stopRecording() return end
    if input.KeyCode == Enum.KeyCode.F8 then playMacro() return end
    if input.KeyCode == Enum.KeyCode.F9 then stopPlayback() return end
    recordInput(input, true)
end)
table.insert(state.connections, inputConnection)

local inputEndedConnection = UIS.InputEnded:Connect(function(input)
    recordInput(input, false)
end)
table.insert(state.connections, inputEndedConnection)

setupAntiAfk()

ENV[HUB_KEY] = {Unload = unload, Version = "2.2.1"}

if state.toggles.lowQuality then applyLowQuality(true) end
if state.toggles.hideEffects then applyHideEffects(true) end

showPage("Overview")
task.spawn(processAutomation)

if game.CreatorId ~= 35139043 then
    log("Aviso: este não parece ser o CreatorId do Anime Crusaders X.", THEME.yellow)
else
    log("yno hub 2.2.1 carregado. RightShift oculta/mostra.", THEME.green)
end

saveConfig()
