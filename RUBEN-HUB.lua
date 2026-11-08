-- =========================================================================
-- [RUBEN HUB v3] — Kukirin Life (Fixed 200 variable limit)
-- =========================================================================
if _G.RubenHubLoaded then return end

local Hub = {
    Settings = {},
    Connections = {},
    UIElements = {},
    Tabs = {},
    Binds = {}
}
_G.RubenHubLoaded = Hub

-- =========================================================================
-- SERVICES & UTILS
-- =========================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local guiParent = gethui and gethui() or game:GetService("CoreGui")

if not (workspace:FindFirstChild("Rides") and RS:FindFirstChild("Scooters") and RS:FindFirstChild("Remotes")) then
    warn("[Ruben Hub] This script only works in Kukirin Life!")
    return
end

local function new(class, props)
    local inst = Instance.new(class)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do inst[k] = v end
    inst.Parent = parent
    return inst
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p }) end
local function tween(inst, props, dur)
    TweenService:Create(inst, TweenInfo.new(dur or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end
local function bind(c) table.insert(Hub.Connections, c) return c end
local function getHum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end

-- =========================================================================
-- SETTINGS
-- =========================================================================
local defaults = {
    AutoQuests = false, AutoAchievements = false, AutoDaily = false, AutoDelivery = false,
    AutoBuyRide = false, MoneyRain = false, AutoWheelie = false, AutoTricks = false,
    TrickMode = "Spin", TrickSpeed = 1, QuestHelpers = true, WheelieAngle = 35,
    RideSpeedBoost = 0, SpeedLimit = 140, QuickRide = "", AntiPolice = false, SeatLock = true,
    PlayerESP = false, RideESP = false, PoliceESP = false, CustomerESP = false, DropESP = false,
    ESPNames = true, ESPDistance = true, ESPBoxes = true, ESPMaxDistance = 0,
    ESPPlayerColor = 350, ESPRideColor = 160, Fullbright = false,
    WalkSpeed = 16, JumpHeight = 50, HipHeight = 2, InfJump = false, Noclip = false,
    Fly = false, FlySpeed = 60, FOV = 70, Anchor = false,
    AntiAFK = true, QuickInteract = false, HidePlayers = false, BlackScreen = false,
    FPSCap = 60, AntiLag = false, Desync = false,
    UITransparency = 0, ShowProfile = true, ShowFPS = true, ShowPing = true, ToggleKey = "RightShift",
}
for k, v in pairs(defaults) do Hub.Settings[k] = v end

-- =========================================================================
-- REMOTES & STATE
-- =========================================================================
local Remotes = RS.Remotes
local function getRemote(name)
    for _, r in ipairs(Remotes:GetDescendants()) do
        if r.Name == name and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    end
end
local GetQuests, ClaimQuest = getRemote("GetQuests"), getRemote("ClaimQuest")
local ClaimAchievement, ClaimAchievementReward = getRemote("ClaimAchievement"), getRemote("ClaimAchievementReward")
local GetDailyRewards, ClaimDailyReward = getRemote("GetDailyRewards"), getRemote("ClaimDailyReward")
local SpawnRide, GoToDealership = getRemote("SpawnRide"), getRemote("GoToDealership")
local GetRides, BuyRide = getRemote("GetRides"), getRemote("BuyRide")
local RiderArmEvent, PoliceMode = getRemote("RiderArmEvent"), getRemote("PoliceMode")
local FoodDelivery = Remotes:FindFirstChild("FoodDelivery")
local RainFolder = Remotes:FindFirstChild("MoneyRain")

local Session = {
    startedAt = os.clock(), startCash = tonumber(lp:GetAttribute("Cash")) or 0,
    quests = 0, achievements = 0, daily = 0, deliveries = 0, deliveryCash = 0
}

-- =========================================================================
-- RIDE & TELEPORT UTILS
-- =========================================================================
local function myRide() return workspace.Rides:FindFirstChild("Ride_" .. lp.Name) end
local function myDriveSeat() local r = myRide() return r and r:FindFirstChild("DriveSeat", true) end

local function streamAround(pos)
    local done = false
    task.spawn(function()
        pcall(function() lp:RequestStreamAroundAsync(pos, 5) end)
        done = true
    end)
    local t = os.clock()
    while not done and os.clock() - t < 3 do task.wait(0.1) end
end

local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Exclude
local function groundBelow(pos, depth)
    groundParams.FilterDescendantsInstances = { workspace.Rides, lp.Character, workspace:FindFirstChild("POIs") }
    return workspace:Raycast(pos, Vector3.new(0, -(depth or 12), 0), groundParams)
end

local function seatHeight(seat)
    local g = groundBelow(seat.Position, 20)
    return g and seat.Position.Y - g.Position.Y or 3
end

local function placeRide(seatPos)
    local ride, seat = myRide(), myDriveSeat()
    if not (ride and seat) then return end
    local look = seat.CFrame.LookVector
    local target = CFrame.new(seatPos) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
    ride:PivotTo(target * (seat.CFrame:Inverse() * ride:GetPivot()))
    for _, d in ipairs(ride:GetDescendants()) do
        if d:IsA("BasePart") then
            d.AssemblyLinearVelocity = Vector3.zero
            d.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function teleport(pos)
    streamAround(pos)
    local ground = groundBelow(pos + Vector3.new(0, 40, 0), 200)
    if ground then pos = ground.Position end
    local seat = myDriveSeat()
    local hum = getHum()
    if seat and hum and hum.SeatPart == seat then
        placeRide(pos + Vector3.new(0, seatHeight(seat), 0))
        return
    end
    local root = getRoot()
    if not root then return end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

-- =========================================================================
-- SPEED LIMITER
-- =========================================================================
bind(RunService.Heartbeat:Connect(function()
    local limit = Hub.Settings.SpeedLimit
    if not limit or limit <= 0 then return end
    local seat = myDriveSeat()
    local hum = getHum()
    if not (seat and hum and hum.SeatPart == seat) then return end
    
    local body = seat.AssemblyRootPart or seat
    if not body then return end
    local vel = body.AssemblyLinearVelocity
    local speed = vel.Magnitude
    
    if speed > limit then
        local flatVel = Vector3.new(vel.X, 0, vel.Z)
        if flatVel.Magnitude > limit then
            local scaled = flatVel.Unit * limit
            body.AssemblyLinearVelocity = Vector3.new(scaled.X, vel.Y * 0.9, scaled.Z)
        end
    end
end))

-- =========================================================================
-- AUTOMATION (FARM & WHEELIE)
-- =========================================================================
local function startFarmLoops()
    local quests = {}
    local function questNeeds(id)
        for _, q in ipairs(quests) do
            if q.Id == id and (q.NextAt or 0) <= os.time() and (q.Progress or 0) < (q.Target or 0) then return true end
        end
        return false
    end

    -- Auto Quests & Achievements
    task.spawn(function()
        while _G.RubenHubLoaded do
            if GetQuests and (Hub.Settings.AutoQuests or (Hub.Settings.AutoWheelie and Hub.Settings.QuestHelpers)) then
                local ok, list = pcall(function() return GetQuests:InvokeServer() end)
                if ok and type(list) == "table" then
                    quests = list
                    for i, q in ipairs(Hub.Settings.AutoQuests and ClaimQuest and list or {}) do
                        local ready = (q.NextAt or 0) <= os.time() and (q.Progress or 0) >= (q.Target or math.huge)
                        if ready then
                            local okc, claimed = pcall(function() return ClaimQuest:InvokeServer(i) end)
                            if okc and claimed then Session.quests += 1 task.wait(0.4) end
                        end
                    end
                end
            end
            task.wait(5)
        end
    end)

    -- Auto Delivery
    local DELIVERY_NPC = Vector3.new(1424.7, 58.6, -607.8)
    task.spawn(function()
        while _G.RubenHubLoaded do
            if Hub.Settings.AutoDelivery and FoodDelivery then
                local target = lp:GetAttribute("DeliveryTarget")
                if typeof(target) ~= "Vector3" then
                    teleport(DELIVERY_NPC)
                    task.wait(0.6)
                    pcall(function() FoodDelivery.Start:InvokeServer() end)
                    task.wait(3)
                else
                    teleport(target + Vector3.new(0, 0, 4))
                    local giveUp = os.clock() + 75
                    while Hub.Settings.AutoDelivery and lp:GetAttribute("DeliveryTarget") == target and os.clock() < giveUp do
                        local ok, done, pay, _, tip = pcall(function() return FoodDelivery.Deliver:InvokeServer() end)
                        if ok and done then
                            Session.deliveries += 1
                            Session.deliveryCash += (tonumber(pay) or 0) + (tonumber(tip) or 0)
                            break
                        end
                        task.wait(1.5)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

startFarmLoops()

-- =========================================================================
-- ESP
-- =========================================================================
local function startESP()
    local folder = Instance.new("Folder")
    folder.Name = "RubenESP"
    local tags = {}
    
    local function getTag(target, adornee)
        local tag = tags[target]
        if not tag then
            local gui = new("BillboardGui", { Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(200, 34), StudsOffset = Vector3.new(0, 3, 0), Parent = folder })
            local label = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = 0.4, Parent = gui })
            local highlight = new("Highlight", { Adornee = target, FillTransparency = 0.75, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = folder })
            tag = { gui = gui, label = label, highlight = highlight }
            tags[target] = tag
        end
        tag.seen = true
        return tag
    end
    
    local function clear(keep)
        for target, tag in pairs(tags) do
            if not (keep and tag.seen and target.Parent) then
                tag.gui:Destroy() tag.highlight:Destroy() tags[target] = nil
            end
            tag.seen = false
        end
    end
    
    local function paint(tag, color, name, dist)
        local text = Hub.Settings.ESPNames and name or ""
        if Hub.Settings.ESPDistance then text = text .. string.format(" [%dm]", dist // 1) end
        tag.label.Text = text
        tag.label.TextColor3 = color
        tag.highlight.FillColor = color
        tag.highlight.OutlineColor = color
        tag.highlight.Enabled = Hub.Settings.ESPBoxes
    end

    task.spawn(function()
        while _G.RubenHubLoaded do
            local root = getRoot()
            if root and (Hub.Settings.PlayerESP or Hub.Settings.RideESP or Hub.Settings.PoliceESP) then
                folder.Parent = guiParent
                local maxD = Hub.Settings.ESPMaxDistance
                local pColor = Color3.fromHSV(Hub.Settings.ESPPlayerColor / 360, 0.85, 1)
                local rColor = Color3.fromHSV(Hub.Settings.ESPRideColor / 360, 0.85, 1)
                
                if Hub.Settings.PlayerESP then
                    for _, p in ipairs(Players:GetPlayers()) do
                        local head = p ~= lp and p.Character and p.Character:FindFirstChild("Head")
                        local dist = head and (head.Position - root.Position).Magnitude
                        if head and (maxD == 0 or dist <= maxD) then paint(getTag(p.Character, head), pColor, p.DisplayName, dist) end
                    end
                end
                if Hub.Settings.RideESP then
                    for _, r in ipairs(workspace.Rides:GetChildren()) do
                        local oid = r:GetAttribute("OwnerUserId")
                        local body = oid and oid ~= lp.UserId and r:FindFirstChild("DriveSeat", true)
                        local dist = body and (body.Position - root.Position).Magnitude
                        if body and (maxD == 0 or dist <= maxD) then
                            paint(getTag(r, body), rColor, string.format("%s's %s", r.Name:gsub("^Ride_", ""), tostring(r:GetAttribute("TemplateName") or "ride")), dist)
                        end
                    end
                end
                clear(true)
            else
                clear(false)
            end
            task.wait(0.3)
        end
    end)
end

startESP()

-- =========================================================================
-- PLAYER MOVEMENT (Noclip, Fly, Anchor)
-- =========================================================================
local noclipSaved = {}
bind(RunService.Stepped:Connect(function()
    if not Hub.Settings.Noclip then return end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            noclipSaved[p] = true
            p.CanCollide = false
        end
    end
end))

bind(RunService.Heartbeat:Connect(function()
    local h, root = getHum(), getRoot()
    if not (h and root) then return end
    
    local S = Hub.Settings
    h.WalkSpeed = S.WalkSpeed
    h.UseJumpPower = false
    h.JumpHeight = S.JumpHeight
    h.HipHeight = S.HipHeight
    workspace.CurrentCamera.FieldOfView = S.FOV

    if S.Anchor then root.Anchored = true else root.Anchored = false end

    if S.Fly then
        h.PlatformStand = true
        local cf = workspace.CurrentCamera.CFrame
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end
        root.AssemblyLinearVelocity = dir * S.FlySpeed
    elseif h.PlatformStand then
        h.PlatformStand = false
    end
end))

-- =========================================================================
-- UI CREATION (Wrapped in function to avoid local variable limit)
-- =========================================================================
local function buildUI()
    local Theme = {
        Bg = Color3.fromRGB(10, 14, 24),
        Surface = Color3.fromRGB(18, 24, 38),
        Surface2 = Color3.fromRGB(26, 34, 52),
        Border = Color3.fromRGB(36, 48, 72),
        Accent = Color3.fromRGB(59, 130, 246),
        AccentHover = Color3.fromRGB(96, 165, 250),
        Text = Color3.fromRGB(249, 250, 251),
        TextSub = Color3.fromRGB(156, 163, 175),
    }

    local ui = new("ScreenGui", { Name = "RubenHubUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent })
    local win = new("Frame", {
        Size = UDim2.fromOffset(620, 500), Position = UDim2.new(0.5, -310, 0.5, -250),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = ui
    })
    corner(win, 12)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = win })

    -- Header
    local header = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, Parent = win })
    local logo = new("Frame", { Position = UDim2.fromOffset(20, 16), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Accent, Parent = header })
    corner(logo, 6)
    new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "R", Font = Enum.Font.GothamBlack, TextColor3 = Theme.Text, Parent = logo })
    
    new("TextLabel", { Position = UDim2.fromOffset(56, 12), Size = UDim2.new(0, 200, 0, 20), BackgroundTransparency = 1, Text = "RUBEN HUB", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    new("TextLabel", { Position = UDim2.fromOffset(56, 32), Size = UDim2.new(0, 200, 0, 14), BackgroundTransparency = 1, Text = "KUKIRIN LIFE", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.TextSub, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

    local closeBtn = new("TextButton", { Position = UDim2.new(1, -40, 0, 16), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Surface2, Text = "×", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, Parent = header })
    corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() _G.RubenHubUnload() end)

    -- Body
    local body = new("Frame", { Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), BackgroundTransparency = 1, Parent = win })
    local sidebar = new("Frame", { Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0, 140, 1, -16), BackgroundColor3 = Theme.Surface, Parent = body })
    corner(sidebar, 10)
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar })
    new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = sidebar })

    local pages = new("Frame", { Position = UDim2.fromOffset(168, 0), Size = UDim2.new(1, -184, 1, -16), BackgroundTransparency = 1, Parent = body })
    local currentTab = nil

    local function switchTab(tab)
        currentTab = tab
        for _, t in ipairs(Hub.Tabs) do
            local active = t == tab
            t.page.Visible = active
            tween(t.btn, { BackgroundColor3 = active and Theme.Accent or Theme.Surface, TextColor3 = active and Theme.Text or Theme.TextSub })
        end
    end

    local function addTab(name)
        local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Surface, Text = "   " .. name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.TextSub, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar })
        corner(btn, 6)
        local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = pages })
        new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
        new("UIPadding", { PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = page })
        local t = { btn = btn, page = page, order = 0 }
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        table.insert(Hub.Tabs, t)
        return t
    end

    local function addSection(tab, text)
        tab.order += 1
        new("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = tab.order, Parent = tab.page })
    end

    local function addRow(tab, h)
        tab.order += 1
        local r = new("Frame", { Size = UDim2.new(1, 0, 0, h or 38), BackgroundColor3 = Theme.Surface2, LayoutOrder = tab.order, Parent = tab.page })
        corner(r, 8)
        return r
    end

    local function addToggle(tab, text, key)
        local r = addRow(tab)
        new("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = r })
        local sw = new("Frame", { Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.Border, Parent = r })
        corner(sw, 10)
        local knob = new("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Theme.Text, Parent = sw })
        corner(knob, 8)
        local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = r })
        
        local function render()
            local on = Hub.Settings[key]
            tween(sw, { BackgroundColor3 = on and Theme.Accent or Theme.Border })
            tween(knob, { Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) })
        end
        hit.MouseButton1Click:Connect(function() Hub.Settings[key] = not Hub.Settings[key]; render() end)
        render()
    end

    local function addSlider(tab, text, key, min, max, step)
        local r = addRow(tab, 52)
        new("TextLabel", { Size = UDim2.new(1, -60, 0, 24), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = r })
        local valLbl = new("TextLabel", { Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -62, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = r })
        local bar = new("Frame", { Size = UDim2.new(1, -24, 0, 4), Position = UDim2.fromOffset(12, 34), BackgroundColor3 = Theme.Border, Parent = r })
        corner(bar, 2)
        local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, Parent = bar })
        corner(fill, 2)
        local hit = new("TextButton", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundTransparency = 1, Parent = bar })
        
        local function render()
            local v = Hub.Settings[key]
            local pct = (v - min) / (max - min)
            fill.Size = UDim2.fromScale(pct, 1)
            valLbl.Text = tostring(math.floor(v))
        end
        local function update(x)
            local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            Hub.Settings[key] = math.clamp(math.floor((min + a * (max - min)) / step + 0.5) * step, min, max)
            render()
        end
        hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then update(i.Position.X) end end)
        bind(UIS.InputChanged:Connect(function(i) if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and i.UserInputType == Enum.UserInputType.MouseMovement and bar:IsHovered() then update(i.Position.X) end end))
        render()
    end

    -- Build Tabs
    local tabFarm = addTab("Farm")
    addSection(tabFarm, "Automation")
    addToggle(tabFarm, "Auto Quests", "AutoQuests")
    addToggle(tabFarm, "Auto Delivery", "AutoDelivery")
    
    local tabRide = addTab("Ride")
    addSection(tabRide, "Speed Settings")
    addSlider(tabRide, "Speed Limit", "SpeedLimit", 0, 400, 5)
    addSlider(tabRide, "Boost", "RideSpeedBoost", 0, 300, 10)
    
    local tabVisuals = addTab("Visuals")
    addSection(tabVisuals, "ESP")
    addToggle(tabVisuals, "Player ESP", "PlayerESP")
    addToggle(tabVisuals, "Ride ESP", "RideESP")
    
    local tabPlayer = addTab("Player")
    addSection(tabPlayer, "Movement")
    addSlider(tabPlayer, "WalkSpeed", "WalkSpeed", 16, 200, 1)
    addToggle(tabPlayer, "Noclip", "Noclip")
    addToggle(tabPlayer, "Fly", "Fly")

    switchTab(tabFarm)
    
    -- Drag functionality
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, i.Position, win.Position
        end
    end)
    bind(UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    bind(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    
    -- Toggle Keybind
    bind(UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode[Hub.Settings.ToggleKey] then
            ui.Enabled = not ui.Enabled
        end
    end))
end

-- Start UI
buildUI()

-- =========================================================================
-- UNLOAD
-- =========================================================================
_G.RubenHubUnload = function()
    if not _G.RubenHubLoaded then return end
    _G.RubenHubLoaded = false
    for _, c in ipairs(Hub.Connections) do pcall(function() c:Disconnect() end) end
    local h = getHum()
    if h then h.WalkSpeed = 16; h.JumpHeight = 50; h.PlatformStand = false end
    local ui = guiParent:FindFirstChild("RubenHubUI")
    if ui then ui:Destroy() end
    print("[Ruben Hub] Unloaded.")
end

print("[Ruben Hub] Kukirin Life loaded successfully.")