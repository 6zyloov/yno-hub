-- yno hub | anime crusaders x companion
-- Version: 1.0.0 | 2026-11-17
-- Informational companion for the game's built-in Smart Macro.
-- This script does not automate gameplay, call undocumented remotes, or modify game data.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui
pcall(function()
    local holder = (type(gethui) == "function" and gethui()) or CoreGui
    oldGui = holder:FindFirstChild("yno_hub")
end)
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

local theme = {
    bg = Color3.fromRGB(8, 10, 18),
    panel = Color3.fromRGB(13, 16, 28),
    panel2 = Color3.fromRGB(18, 22, 37),
    panel3 = Color3.fromRGB(24, 29, 48),
    line = Color3.fromRGB(42, 49, 73),
    text = Color3.fromRGB(239, 242, 255),
    muted = Color3.fromRGB(145, 155, 184),
    purple = Color3.fromRGB(143, 105, 255),
    purple2 = Color3.fromRGB(91, 66, 190),
    cyan = Color3.fromRGB(82, 211, 232),
    green = Color3.fromRGB(90, 220, 165),
    yellow = Color3.fromRGB(255, 194, 92),
    red = Color3.fromRGB(255, 105, 124),
}
local currentPage = "Overview"
local compact = false
local gui, main, pageScroll, pageLayout, navHolder, toast
local uiScale

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 12)}, parent)
end

local function stroke(parent, color, transparency, thickness)
    make("UIStroke", {
        Color = color or theme.line,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    }, parent)
end

local function label(parent, text, size, color, bold, height)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 24),
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        Text = text,
        TextColor3 = color or theme.text,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local function button(parent, text, callback, width)
    local b = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.panel3,
        Size = UDim2.new(0, width or 104, 0, 34),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = theme.text,
        TextSize = 12,
        BorderSizePixel = 0,
    }, parent)
    corner(b, 9)
    stroke(b, theme.line, 0.25, 1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.14), {BackgroundColor3 = theme.purple2}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.14), {BackgroundColor3 = theme.panel3}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

local function notify(message, accent)
    if not toast or not toast.Parent then return end
    toast.Text = message
    toast.TextColor3 = accent or theme.text
    toast.Visible = true
    toast.BackgroundTransparency = 0.08
    TweenService:Create(toast, TweenInfo.new(0.18), {Position = UDim2.new(1, -22, 1, -62)}):Play()
    task.delay(2.6, function()
        if toast and toast.Parent then
            TweenService:Create(toast, TweenInfo.new(0.2), {
                Position = UDim2.new(1, 340, 1, -62),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.22, function()
                if toast and toast.Parent then toast.Visible = false end
            end)
        end
    end)
end

local function copyText(value)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, value)
        if ok then
            notify("Copiado para a área de transferência", theme.green)
            return
        end
    end
    notify("Clipboard indisponível neste executor", theme.yellow)
end

local function makeCard(parent, titleText, bodyText, tagText, tagColor, height)
    local card = make("Frame", {
        BackgroundColor3 = theme.panel2,
        Size = UDim2.new(1, 0, 0, height or 112),
        BorderSizePixel = 0,
    }, parent)
    corner(card, 13)
    stroke(card, theme.line, 0.28, 1)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 13),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
    }, card)
    local title = label(card, titleText, 14, theme.text, true, 22)
    title.Size = UDim2.new(1, tagText and -108 or 0, 0, 22)
    local body = label(card, bodyText, 12, theme.muted, false, 48)
    body.Position = UDim2.new(0, 0, 0, 30)
    body.Size = UDim2.new(1, 0, 0, height and height - 66 or 48)
    if tagText then
        local tag = make("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 94, 0, 22),
            BackgroundColor3 = tagColor or theme.purple2,
            Font = Enum.Font.GothamBold,
            Text = tagText,
            TextColor3 = theme.text,
            TextSize = 10,
            BorderSizePixel = 0,
        }, card)
        corner(tag, 7)
    end
    return card
end

local function addSection(titleText, subtitle)
    local wrap = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 62),
    }, pageScroll)
    label(wrap, titleText, 22, theme.text, true, 30)
    local sub = label(wrap, subtitle or "", 12, theme.muted, false, 24)
    sub.Position = UDim2.new(0, 0, 0, 32)
end

local function addActionCard(titleText, bodyText, actionText, action)
    local card = makeCard(pageScroll, titleText, bodyText, nil, nil, 112)
    local b = button(card, actionText, action, 112)
    b.AnchorPoint = Vector2.new(1, 1)
    b.Position = UDim2.new(1, 0, 1, -2)
end

local function clearPage()
    for _, child in ipairs(pageScroll:GetChildren()) do
        child:Destroy()
    end
    pageScroll.CanvasPosition = Vector2.new(0, 0)
    pageLayout = make("UIListLayout", {
        Padding = UDim.new(0, 11),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, pageScroll)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 10),
    }, pageScroll)
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 22)
    end)
end

local function buildOverview()
    addSection("Bem-vindo ao yno hub", "Seu centro de planejamento para Anime Crusaders X.")
    local hero = make("Frame", {
        BackgroundColor3 = theme.panel2,
        Size = UDim2.new(1, 0, 0, 142),
        BorderSizePixel = 0,
    }, pageScroll)
    corner(hero, 15)
    stroke(hero, theme.purple, 0.34, 1)
    make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 28, 67)),
            ColorSequenceKeypoint.new(1, theme.panel2),
        }),
        Rotation = 0,
    }, hero)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
    }, hero)
    label(hero, "FARM SMARTER. PLAN BETTER.", 10, theme.cyan, true, 18)
    label(hero, "Seu progresso, sob seu controle.", 20, theme.text, true, 30).Position = UDim2.new(0, 0, 0, 24)
    local desc = label(hero, "O yno hub organiza rotas, equipes, códigos e o Smart Macro nativo. A execução das partidas continua no próprio jogo.", 12, theme.muted, false, 42)
    desc.Position = UDim2.new(0, 0, 0, 60)
    local chips = make("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -27), Size = UDim2.new(1, 0, 0, 22)}, hero)
    local chipLayout = make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, chips)
    local function chip(text, color)
        local c = make("TextLabel", {
            BackgroundColor3 = theme.panel3, Size = UDim2.new(0, 120, 0, 22),
            Font = Enum.Font.GothamBold, Text = text, TextColor3 = color,
            TextSize = 9, BorderSizePixel = 0,
        }, chips)
        corner(c, 7)
    end
    chip("SMART MACRO GUIDE", theme.cyan)
    chip("PATCH · 16 NOV", theme.green)
    chip("BUILD 1.0.0", theme.purple)

    addSection("Atalhos", "Abra uma área sem perder tempo.")
    addActionCard("Farm Planner", "Rotas para Gems, Gold, Event Tokens e materiais de evolução.", "ABRIR ROTAS", function() showPage("Farm Planner") end)
    addActionCard("Smart Macro", "Configure Loop, Routine, seis slots, Hero, upgrades e habilidades no painel nativo.", "CONFIGURAR", function() showPage("Smart Macro") end)
    addActionCard("Códigos recentes", "Novos códigos foram adicionados em 16 de novembro. Confirmados separados dos não verificados.", "VER CÓDIGOS", function() showPage("Codes") end)
    local note = makeCard(pageScroll, "Como funciona", "Este hub não injeta RemoteEvents, não altera moedas e não tenta contornar o anti-cheat. Ele organiza informação e presets para você configurar o sistema oficial do jogo.", "COMPANION", theme.green, 100)
end

local function buildFarm()
    addSection("Farm Planner", "Escolha o recurso e siga a rota adequada ao seu objetivo.")
    makeCard(pageScroll, "Gems · rota diária", "Resgate o login diário, finalize as cinco missões diárias e recolha recompensas do Guidebook. O track semanal completo informa 22.500 Gems + 225 Trait Remnants.", "DAILY", theme.green, 118)
    makeCard(pageScroll, "Gold · rota de minigames", "Crusader Dash paga 10 Gold por moeda, até 100.000 Gold por dia. Chess paga 1.000 Gold por vitória contra outro jogador. Reel Rush tem duas tentativas diárias com recompensas.", "GOLD", theme.yellow, 118)
    makeCard(pageScroll, "Event Tokens + Blank Tokens", "Complete os três objetivos de um Bounty Card: a recompensa indicada é 5 Event Tokens e 1 Blank Token.", "BOUNTY", theme.cyan, 104)
    makeCard(pageScroll, "Trait Remnants / Trait Tokens", "Use Daily Login e Guidebook para Trait Remnants. Algumas unidades têm custo de reroll diferente; confira o custo da unidade antes de gastar.", "TRAITS", theme.purple, 104)
    makeCard(pageScroll, "Stat Cube / Perfect Stat Cube", "Stat Cube altera Damage, SPA e Range juntos. Perfect Stat Cube altera apenas um atributo escolhido. Multi gasta 1 Stat Cube por unidade selecionada.", "STATS", theme.purple, 104)
    makeCard(pageScroll, "Relic Cubes / Curse Tokens", "Relic Cube rerrola atributos de relíquia. Curse Token é usado para aplicar curse em Twenty One; trocar entre curse ativa e salva é gratuito.", "RELICS", theme.cyan, 104)
    makeCard(pageScroll, "Boss Rush shops", "Control usa Token of Chains; Perfection usa Token of Resonance. Compare o saldo e o estoque de cada loja antes de planejar compras.", "SHOP", theme.yellow, 104)
    addActionCard("Abrir guia completo de recursos", "Confira os valores e condições de cada recompensa na referência comunitária.", "COPIAR URL", function()
        copyText("https://anime-crusaders-x.wiki/resource-farming/")
    end)
end

local function buildMacro()
    addSection("Smart Macro", "Guia de configuração do sistema integrado do Anime Crusaders X.")
    makeCard(pageScroll, "1 · Escolha o modo", "This Stage executa uma partida. Loop repete a fase atual. Routine percorre uma fila de tarefas com modo, mundo, ato, dificuldade e meta de runs. Para farm repetível, configure Retry nas opções da partida.", "CORE", theme.cyan, 110)
    makeCard(pageScroll, "2 · Configure seu time", "Macro → Units → Slots oferece seis slots e um Hero slot. Use Fill My Team para preencher a formação equipada. Você pode seguir a posição do time ou vincular um slot a uma unidade específica e até cinco substitutas.", "6 + HERO", theme.purple, 110)
    makeCard(pageScroll, "3 · Upgrade e habilidade", "Ative Slot enabled, Targeting, Auto upgrade e Auto abilities. Na aba Advanced configure Place from wave, Place through wave, Upgrade priority, Maximum upgrade e Abilities from wave.", "TIMING", theme.green, 110)
    makeCard(pageScroll, "4 · Prioridades", "O botão Auto de upgrade alterna entre prioridades P1–P6 e depois Off. No painel de upgrades, passar o cursor sobre um pip mostra o alcance daquele upgrade. Ajuste a prioridade para o seu plano.", "P1 — P6", theme.yellow, 110)
    makeCard(pageScroll, "5 · Posicionamento", "Placement permite Zones ou Recording. Use Add Zone na aba do slot para definir áreas próprias. Shared area define uma área global. Recording permite gravar e gerenciar posições por mapa.", "MAP", theme.cyan, 110)
    makeCard(pageScroll, "6 · Auto Challenge", "Em Dailies → Auto Challenge, selecione categorias de desafios para agendar junto à automação. Confira a fila e os limites antes de iniciar.", "DAILIES", theme.purple, 100)
    makeCard(pageScroll, "7 · Desempenho", "O menu oferece None, Low, Medium, High e Extreme. Comece em High se quiser priorizar FPS durante o macro; teste Extreme apenas se ainda houver queda forte de desempenho. Use None/Low quando preferir os efeitos visuais.", "FPS", theme.green, 110)
    addActionCard("Copiar checklist de preparação", "Use esta lista antes de iniciar uma rotina longa.", "COPIAR", function()
        copyText("YNO HUB — CHECKLIST\n1. Entrar na fase correta.\n2. Macro > Units > Fill My Team.\n3. Conferir slots, Hero, targeting e Auto abilities.\n4. Ajustar Zones/Recording.\n5. Configurar This Stage, Loop ou Routine.\n6. Escolher otimização.\n7. Start e conferir Activity, Runs, Wins e Losses.\n8. Pausar ou Stop se a estratégia falhar.")
    end)
    addActionCard("Abrir guia completo do Macro", "Consulte capturas e explicações do painel nativo.", "COPIAR URL", function()
        copyText("https://anime-crusaders-x.wiki/macro/")
    end)
end

local function buildTeam()
    addSection("Team Builder", "Formação comunitária de referência. Use somente as unidades que você possui.")
    makeCard(pageScroll, "Twenty One", "Dano principal · desenvolva esta unidade para sustentar as ondas iniciais.", "DAMAGE", theme.purple, 92)
    makeCard(pageScroll, "Loid", "Farm · ajuda a construir economia para upgrades posteriores.", "FARM", theme.green, 92)
    makeCard(pageScroll, "AI (Idol)", "Buff / suporte · posicione para cobrir o núcleo de dano.", "SUPPORT", theme.cyan, 92)
    makeCard(pageScroll, "Speedcart", "Farm · custo de implantação baixo (550 Yen), bom para abrir economia.", "FARM", theme.green, 92)
    makeCard(pageScroll, "Useless Goddess", "Suporte para atacantes Magic · mantenha os atacantes dentro do alcance.", "MAGIC BUFF", theme.purple, 92)
    makeCard(pageScroll, "Phoenix (Rebirth)", "Dano Magic e summons com cobertura de Flying. Não confunda com a forma Phoenix base.", "FLYING", theme.yellow, 92)
    makeCard(pageScroll, "Alternativa", "Se não tiver Phoenix (Rebirth), use outra unidade de dano disponível. Goju VS Sukuno é uma alternativa citada pelo guia, mas reavalie sua cobertura contra Flying.", "SWAP", theme.yellow, 108)
    addActionCard("Copiar formação", "Use como checklist de equipe, não como promessa de equipe universal.", "COPIAR", function()
        copyText("Twenty One | Loid | AI (Idol) | Speedcart | Useless Goddess | Phoenix (Rebirth)\nAjuste por mapa, orçamento, raridade e inimigos Flying.")
    end)
    addActionCard("Abrir guia de equipes", "Veja sinergias e alternativas de acordo com o tipo de dano.", "COPIAR URL", function()
        copyText("https://anime-crusaders-x.wiki/team-building/")
    end)
end

local codes = {
    {code="ACBESTTD2026", reward="50 Curse Tokens · 50 Relic Cubes · 50 Stat Cubes · 5.000 Gems", verified=true},
    {code="ACCOMEBACK", reward="200 Trait Remnants · requisito: nível 20+", verified=true},
    {code="ANNIVERSARY", reward="100 Trait Remnants · requisito: nível 10+", verified=true},
    {code="SORRYFORSHUTDOWNEA2026", reward="50 Trait Remnants", verified=true},
    {code="WELCOMETOACX", reward="200 Trait Remnants · 5.000 Gems", verified=true},
    {code="THANKYOUFOR30KMAJORFIXES", reward="50 Trait Remnants · 1.000 Gems · ainda não verificado", verified=false},
}
local function buildCodes()
    addSection("Codes", "Códigos publicados ou atualizados em 16 de novembro de 2026. Resgate no jogo; disponibilidade pode mudar.")
    for _, item in ipairs(codes) do
        local status = item.verified and "CONFIRMADO" or "NÃO VERIFICADO"
        local color = item.verified and theme.green or theme.yellow
        local card = makeCard(pageScroll, item.code, item.reward, status, color, 92)
        local b = button(card, "COPIAR", function() copyText(item.code) end, 94)
        b.AnchorPoint = Vector2.new(1, 1)
        b.Position = UDim2.new(1, 0, 1, -1)
    end
    makeCard(pageScroll, "Como resgatar", "Abra o menu de Codes no jogo, digite o código exatamente como aparece e pressione Redeem. Códigos expirados ou já usados podem falhar.", "TIP", theme.cyan, 88)
    addActionCard("Conferir lista atualizada", "Fonte comunitária de códigos. Verifique novamente antes de iniciar uma sessão longa.", "ABRIR URL", function()
        copyText("https://rblxstat.com/pt/games/7660436108/codes")
    end)
end

local function buildUpdates()
    addSection("Patch Notes", "Resumo das mudanças recentes listadas para 16 de novembro de 2026.")
    makeCard(pageScroll, "Novos servidores · Raids e Play window", "Todas as raids ficam abertas por padrão; mundos e atos bloqueados podem ser visualizados. Controles de upgrade de unidade receberam melhorias.", "16 NOV", theme.green, 104)
    makeCard(pageScroll, "Auto Upgrade P1–P6", "O botão Auto alterna pelas prioridades P1 até P6 e depois desliga. Passar o cursor sobre um pip de upgrade mostra o alcance.", "GAMEPLAY", theme.cyan, 94)
    makeCard(pageScroll, "Patch 1 · Ayzen, Shadow e Falcon", "Ayzen's Boss Rush retorna com partidas ilimitadas. Shadow retorna e Falcon recebe uma área de evolução. Einz's Boons lembra a última carta e os slots Small Army.", "CONTENT", theme.purple, 110)
    makeCard(pageScroll, "Melhorias do Macro", "Foram listadas correções de execução automática de Einz, seleção de portal, interface de Macro e vários problemas de jogo e menus.", "FIXES", theme.green, 100)
    makeCard(pageScroll, "Code Redemption Patch", "A página de updates lista uma melhoria planejada para reduzir a espera na hora de resgatar códigos. Ainda estava marcada como em desenvolvimento na consulta.", "PLANNED", theme.yellow, 100)
    addActionCard("Abrir histórico de updates", "Veja os detalhes completos e confirme se houve outra atualização após esta consulta.", "COPIAR URL", function()
        copyText("https://anime-crusaders-x.wiki/updates/")
    end)
end

local function buildSettings()
    addSection("Settings", "Preferências visuais e informações do projeto.")
    local scaleCard = makeCard(pageScroll, "Escala da interface", "Altere o tamanho visual do painel para caber melhor na tela.", "UI", theme.cyan, 104)
    local compactBtn = button(scaleCard, "COMPACT", function()
        compact = true
        if uiScale then uiScale.Scale = 0.86 end
        notify("Escala compacta ativada", theme.cyan)
    end, 98)
    compactBtn.AnchorPoint = Vector2.new(1, 1)
    compactBtn.Position = UDim2.new(1, -106, 1, -2)
    local normalBtn = button(scaleCard, "NORMAL", function()
        compact = false
        if uiScale then uiScale.Scale = 1 end
        notify("Escala normal ativada", theme.green)
    end, 98)
    normalBtn.AnchorPoint = Vector2.new(1, 1)
    normalBtn.Position = UDim2.new(1, 0, 1, -2)
    addActionCard("GitHub do projeto", "O repositório yno-hub está privado. Um executor sem autenticação não consegue buscar arquivos raw de um repositório privado.", "COPIAR URL", function()
        copyText("https://github.com/6zyloov/yno-hub")
    end)
    addActionCard("Loader remoto (quando público)", "Este loader só funcionará remotamente depois que o repositório for tornado público. A fonte continua no seu GitHub.", "COPIAR", function()
        copyText('loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()')
    end)
    makeCard(pageScroll, "Controles", "RightShift: mostrar/ocultar o painel. Arraste pela barra superior. O botão X fecha a interface atual.", "HOTKEY", theme.purple, 82)
    makeCard(pageScroll, "Privacidade e limites", "O yno hub não pede senha, cookie, token, chave de conta ou webhook. Não injeta chamadas de rede no jogo nem promete recompensas automáticas.", "SAFETY", theme.green, 94)
    makeCard(pageScroll, "Build", "yno hub · Anime Crusaders X companion · 1.0.0 · 17 nov 2026.", "ABOUT", theme.cyan, 76)
end

local pages = {
    ["Overview"] = buildOverview,
    ["Farm Planner"] = buildFarm,
    ["Smart Macro"] = buildMacro,
    ["Team Builder"] = buildTeam,
    ["Codes"] = buildCodes,
    ["Patch Notes"] = buildUpdates,
    ["Settings"] = buildSettings,
}

function showPage(name)
    if not pages[name] then return end
    currentPage = name
    clearPage()
    pages[name]()
    for pageName, navButton in pairs(_G.__yno_nav_buttons or {}) do
        local active = pageName == name
        navButton.BackgroundColor3 = active and Color3.fromRGB(43, 35, 76) or theme.panel
        navButton.TextColor3 = active and theme.text or theme.muted
        local bar = navButton:FindFirstChild("active_bar")
        if bar then bar.Visible = active end
    end
end

local function createNavButton(name, iconText)
    local b = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.panel,
        Size = UDim2.new(1, 0, 0, 42),
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. iconText .. "    " .. name,
        TextColor3 = theme.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
    }, navHolder)
    corner(b, 9)
    local bar = make("Frame", {
        Name = "active_bar",
        BackgroundColor3 = theme.purple,
        Position = UDim2.new(0, 0, 0.18, 0),
        Size = UDim2.new(0, 3, 0.64, 0),
        Visible = false,
        BorderSizePixel = 0,
    }, b)
    corner(bar, 3)
    b.MouseButton1Click:Connect(function() showPage(name) end)
    return b
end

gui = make("ScreenGui", {
    Name = "yno_hub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, (function()
    local ok, holder = pcall(function()
        if type(gethui) == "function" then return gethui() end
        return CoreGui
    end)
    if ok and holder then return holder end
    return playerGui
end)())

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
uiScale = make("UIScale", {Scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 820), 0.72, 1)}, gui)

main = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1000, 660),
    BackgroundColor3 = theme.bg,
    BorderSizePixel = 0,
}, gui)
corner(main, 18)
stroke(main, theme.line, 0.05, 1)
make("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(14, 17, 31), Color3.fromRGB(8, 10, 18)),
    Rotation = 90,
}, main)

local sidebar = make("Frame", {
    BackgroundColor3 = theme.panel,
    Size = UDim2.new(0, 204, 1, 0),
    BorderSizePixel = 0,
}, main)
corner(sidebar, 18)
make("Frame", {
    BackgroundColor3 = theme.panel,
    Position = UDim2.new(1, -18, 0, 0),
    Size = UDim2.new(0, 18, 1, 0),
    BorderSizePixel = 0,
}, sidebar)

local brand = make("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 18, 0, 20), Size = UDim2.new(1, -36, 0, 56)}, sidebar)
local logo = make("Frame", {BackgroundColor3 = theme.purple, Size = UDim2.new(0, 42, 0, 42), BorderSizePixel = 0}, brand)
corner(logo, 12)
make("UIGradient", {Color = ColorSequence.new(theme.purple, theme.cyan), Rotation = 35}, logo)
local logoText = label(logo, "y", 27, Color3.new(1, 1, 1), true, 40)
logoText.TextXAlignment = Enum.TextXAlignment.Center
local brandName = label(brand, "yno hub", 19, theme.text, true, 25)
brandName.Position = UDim2.new(0, 53, 0, 1)
local brandSub = label(brand, "ACX COMPANION", 9, theme.muted, true, 17)
brandSub.Position = UDim2.new(0, 54, 0, 27)

label(sidebar, "WORKSPACE", 9, theme.muted, true, 18).Position = UDim2.new(0, 20, 0, 96)
navHolder = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 120),
    Size = UDim2.new(1, -28, 0, 350),
}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, navHolder)
_G.__yno_nav_buttons = {}
local navData = {
    {"Overview", "◈"},
    {"Farm Planner", "⌁"},
    {"Smart Macro", "▦"},
    {"Team Builder", "♧"},
    {"Codes", "✳"},
    {"Patch Notes", "↻"},
    {"Settings", "⚙"},
}
for _, entry in ipairs(navData) do
    _G.__yno_nav_buttons[entry[1]] = createNavButton(entry[1], entry[2])
end

local sidebarFoot = make("Frame", {
    BackgroundColor3 = theme.panel2,
    Position = UDim2.new(0, 14, 1, -66),
    Size = UDim2.new(1, -28, 0, 48),
    BorderSizePixel = 0,
}, sidebar)
corner(sidebarFoot, 10)
local statusDot = make("Frame", {BackgroundColor3 = theme.green, Position = UDim2.new(0, 12, 0, 18), Size = UDim2.new(0, 8, 0, 8), BorderSizePixel = 0}, sidebarFoot)
corner(statusDot, 8)
label(sidebarFoot, "CLIENT READY", 10, theme.green, true, 18).Position = UDim2.new(0, 28, 0, 8)
label(sidebarFoot, "No external libraries", 9, theme.muted, false, 16).Position = UDim2.new(0, 28, 0, 24)

local content = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 224, 0, 0),
    Size = UDim2.new(1, -242, 1, 0),
}, main)

local topbar = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 62),
}, content)
label(topbar, "COMMAND CENTER", 10, theme.muted, true, 18).Position = UDim2.new(0, 0, 0, 8)
local topTitle = label(topbar, "Overview", 20, theme.text, true, 28)
topTitle.Position = UDim2.new(0, 0, 0, 27)
local ready = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -82, 0, 18),
    Size = UDim2.new(0, 105, 0, 26),
    BackgroundColor3 = Color3.fromRGB(20, 48, 44),
    Font = Enum.Font.GothamBold,
    Text = "●  READY",
    TextColor3 = theme.green,
    TextSize = 10,
    BorderSizePixel = 0,
}, topbar)
corner(ready, 8)
local version = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -122, 0, 18),
    Size = UDim2.new(0, 62, 0, 26),
    BackgroundColor3 = theme.panel3,
    Font = Enum.Font.GothamBold,
    Text = "v1.0.0",
    TextColor3 = theme.muted,
    TextSize = 10,
    BorderSizePixel = 0,
}, topbar)
corner(version, 8)

local closeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 18),
    Size = UDim2.new(0, 30, 0, 26),
    BackgroundColor3 = Color3.fromRGB(62, 30, 43),
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextColor3 = theme.red,
    TextSize = 18,
    BorderSizePixel = 0,
}, topbar)
corner(closeButton, 8)
closeButton.MouseButton1Click:Connect(function() gui:Destroy() end)

pageScroll = make("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 70),
    Size = UDim2.new(1, 0, 1, -84),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.purple,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, content)

toast = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 340, 1, -62),
    Size = UDim2.new(0, 300, 0, 40),
    BackgroundColor3 = theme.panel3,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamSemibold,
    Text = "",
    TextColor3 = theme.text,
    TextSize = 12,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 20,
}, gui)
corner(toast, 10)
stroke(toast, theme.line, 0.15, 1)

-- Drag the window from the top area.
local dragging = false
local dragStart
local startPosition
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
topbar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift and gui and gui.Parent then
        main.Visible = not main.Visible
    end
end)

local function updateTitle()
    if topTitle then topTitle.Text = currentPage end
end

local originalShowPage = showPage
showPage = function(name)
    originalShowPage(name)
    updateTitle()
end

showPage("Overview")
notify("yno hub carregado · pressione RightShift para ocultar", theme.green)
