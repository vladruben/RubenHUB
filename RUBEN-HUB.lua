-- =========================================================================
-- [RUBEN-HUB] — Pulsar Base + Cookies Farm + Fixes
-- =========================================================================
if _G.RubenHubLoaded then return end

local RS = game:GetService("ReplicatedStorage")
if not (workspace:FindFirstChild("Rides") and RS:FindFirstChild("Scooters") and RS:FindFirstChild("Remotes")) then
    warn("[Ruben-Hub] This script only works in Kukirin Life!")
    return
end

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local VirtualUser  = game:GetService("VirtualUser")
local lp           = Players.LocalPlayer
local guiParent    = game:GetService("CoreGui")

if gethui then
    local ok, hui = pcall(gethui)
    if ok and typeof(hui) == "Instance" then guiParent = hui end
end

-- =========================================================================
-- KEY SYSTEM
-- =========================================================================
local VALID_KEYS = {
    ["RUBEN-7K2M-9QX4"] = true, ["RUBEN-3F8N-1LPW"] = true,
    ["RUBEN-6T4R-2VZC"] = true, ["RUBEN-8H5J-7BKD"] = true,
    ["RUBEN-1D9S-4MWG"] = true, ["RUBEN-5G3P-8XTF"] = true,
    ["RUBEN-2C7V-6NQH"] = true, ["RUBEN-9M1L-3ZRB"] = true,
    ["RUBEN-4W8K-5JDP"] = true, ["RUBEN-7Q2F-9TXN"] = true,
    ["RUBEN-6B5H-1KMC"] = true, ["RUBEN-3V9R-7LZS"] = true,
    ["RUBEN-8N4T-2FWG"] = true, ["RUBEN-1X6P-5JQK"] = true,
    ["RUBEN-5K3D-8MZH"] = true, ["RUBEN-2R7L-4CVB"] = true,
    ["RUBEN-9H1N-6TWX"] = true, ["RUBEN-4F8J-3PDQ"] = true,
    ["RUBEN-7M2K-9SRL"] = true, ["RUBEN-6Q5V-1BNH"] = true,
    ["RUBEN-3T9W-7FZC"] = true, ["RUBEN-8J4D-2KMX"] = true,
    ["RUBEN-1N6H-5QPL"] = true, ["RUBEN-5C3R-8VZB"] = true,
    ["RUBEN-2W7F-4JTD"] = true, ["RUBEN-9P1K-6MXN"] = true,
    ["RUBEN-4H8Q-3LRS"] = true, ["RUBEN-7D2V-9FWG"] = true,
    ["RUBEN-6N5J-1PZK"] = true, ["RUBEN-3B9M-7CQT"] = true
}
local KEY_FILE = "RubenHub_Key.json"

local function promptKey(callback)
    local gui = Instance.new("ScreenGui", guiParent)
    gui.Name = "RubenKeyUI"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(400, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(16, 18, 27)
    frame.BorderSizePixel = 0
    local cr = Instance.new("UICorner", frame)
    cr.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 44)
    title.Position = UDim2.fromOffset(0, 10)
    title.BackgroundTransparency = 1
    title.Text = "RUBEN-HUB · KEY"
    title.TextColor3 = Color3.fromRGB(238, 242, 252)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -40, 0, 38)
    input.Position = UDim2.fromOffset(20, 62)
    input.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
    input.TextColor3 = Color3.fromRGB(238, 242, 252)
    input.PlaceholderText = "RUBEN-XXXX-XXXX"
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.ClearTextOnFocus = false
    local cr2 = Instance.new("UICorner", input)
    cr2.CornerRadius = UDim.new(0, 8)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -40, 0, 36)
    btn.Position = UDim2.fromOffset(20, 110)
    btn.BackgroundColor3 = Color3.fromRGB(91, 140, 255)
    btn.Text = "ACTIVATE"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    local cr3 = Instance.new("UICorner", btn)
    cr3.CornerRadius = UDim.new(0, 8)
    
    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.fromOffset(20, 152)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(255, 100, 120)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    
    btn.MouseButton1Click:Connect(function()
        local text = input.Text:upper():gsub("%s+", "")
        if VALID_KEYS[text] then
            gui:Destroy()
            _G.RubenHubLoaded = true
            callback()
        else
            status.Text = "Invalid Key"
        end
    end)
end

-- =========================================================================
-- MAIN SCRIPT
-- =========================================================================
local function StartMainScript()
    task.spawn(function()
        local sg = game:GetService("StarterGui")
        for _ = 1, 30 do
            local ok = pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
            if ok then break end
            task.wait(0.1)
        end
        pcall(function() sg:SetCore("TopbarEnabled", false) end)
    end)

    local MB1 = Enum.UserInputType.MouseButton1
    local MOVE = Enum.UserInputType.MouseMovement
    local Hub = { conns = {}, unloaded = false }
    local function bind(c) table.insert(Hub.conns, c) return c end
    local function getHum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
    local function getRoot() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end

    local function new(class, parent)
        local inst = Instance.new(class)
        inst.Parent = parent
        return inst
    end

    -- Remotes
    local Remotes = RS.Remotes
    local function remote(name)
        for _, r in ipairs(Remotes:GetDescendants()) do
            if r.Name == name and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
        end
    end
    local GetQuests = remote("GetQuests")
    local ClaimQuest = remote("ClaimQuest")
    local ClaimAchievement = remote("ClaimAchievement")
    local ClaimAchievementReward = remote("ClaimAchievementReward")
    local GetDailyRewards = remote("GetDailyRewards")
    local ClaimDailyReward = remote("ClaimDailyReward")
    local SpawnRide = remote("SpawnRide")
    local RiderArmEvent = remote("RiderArmEvent")
    local PoliceMode = remote("PoliceMode")
    local PoliceHit = remote("PoliceHit")
    local FoodDelivery = Remotes:FindFirstChild("FoodDelivery")

    local function data(name)
        local ok, mod = pcall(function() return require(RS.Datas[name]) end)
        return ok and type(mod) == "table" and mod or nil
    end
    local AchievementConfig = data("AchievementConfig")

    -- Settings
    local h0 = getHum()
    local Settings = {
        AutoQuests = false, AutoAchievements = false, AutoDaily = false, AutoDelivery = false,
        QuestHelpers = true, AutoWheelie = false, WheelieAngle = 35,
        AngleWheelie = false, AngleWheelieAngle = 35, AutoTricks = false, TrickSpeed = 1,
        RideSpeedBoost = 0, SpeedUncap = false, SpeedLimit = 140, AntiPolice = false,
        PlayerESP = false, RideESP = false, PoliceESP = false, CustomerESP = false, DropESP = false,
        Fullbright = false, WalkSpeed = h0 and h0.WalkSpeed or 16, JumpHeight = h0 and h0.JumpHeight or 50,
        InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, FOV = 70, Desync = false,
        ToggleKey = "RightShift"
    }
    local refreshers = {}

    -- Rides
    local function myRide() return workspace.Rides:FindFirstChild("Ride_" .. lp.Name) end
    local function myDriveSeat() local r = myRide() return r and r:FindFirstChild("DriveSeat", true) end
    local function teleport(pos)
        local root = getRoot()
        if root then 
            root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            root.AssemblyLinearVelocity = Vector3.zero 
        end
    end

    -- =====================================================================
    -- MODULES
    -- =====================================================================
    local function setupModules()
        local S = Settings
        local Session = { quests = 0 }

        -- FARM
        task.spawn(function()
            while not Hub.unloaded do
                if GetQuests and (S.AutoQuests or (S.AutoWheelie and S.QuestHelpers)) then
                    local ok, list = pcall(function() return GetQuests:InvokeServer() end)
                    if ok and type(list) == "table" then
                        for i, q in ipairs(S.AutoQuests and ClaimQuest and list or {}) do
                            if (q.NextAt or 0) <= os.time() and (q.Progress or 0) >= (q.Target or math.huge) then
                                local okc = pcall(function() return ClaimQuest:InvokeServer(i) end)
                                if okc then 
                                    Session.quests = Session.quests + 1 
                                    task.wait(0.4) 
                                end
                            end
                        end
                    end
                end
                if S.AutoAchievements and ClaimAchievement and AchievementConfig then
                    for _, a in ipairs(AchievementConfig.Achievements or {}) do
                        for _ = 1, 20 do
                            local okc = pcall(function() return ClaimAchievement:InvokeServer(a.Id) end)
                            if not okc then break end
                            task.wait(0.3)
                        end
                    end
                    if ClaimAchievementReward then 
                        pcall(function() ClaimAchievementReward:InvokeServer() end) 
                    end
                end
                if S.AutoDaily and GetDailyRewards and ClaimDailyReward then
                    local ok, d = pcall(function() return GetDailyRewards:InvokeServer() end)
                    if ok and type(d) == "table" and (d.NextAt or 0) <= os.time() then
                        pcall(function() return ClaimDailyReward:InvokeServer() end)
                    end
                end
                task.wait(5)
            end
        end)

        -- DELIVERY
        task.spawn(function()
            while not Hub.unloaded do
                if S.AutoDelivery and FoodDelivery then
                    local target = lp:GetAttribute("DeliveryTarget")
                    if typeof(target) ~= "Vector3" then
                        teleport(Vector3.new(1424.7, 58.6, -607.8))
                        task.wait(0.6)
                        pcall(function() return FoodDelivery.Start:InvokeServer() end)
                    else
                        teleport(target + Vector3.new(0, 0, 4))
                        for _ = 1, 5 do
                            local ok, done = pcall(function() return FoodDelivery.Deliver:InvokeServer() end)
                            if ok and done then break end
                            task.wait(1.5)
                        end
                    end
                end
                task.wait(1)
            end
        end)

        -- ESP
        local espFolder = Instance.new("Folder")
        espFolder.Name = "RubenESP"
        local espTags = {}
        task.spawn(function()
            while not Hub.unloaded do
                local root = getRoot()
                if root and (S.PlayerESP or S.RideESP or S.PoliceESP) then
                    espFolder.Parent = guiParent
                    if S.PlayerESP then
                        for _, p in ipairs(Players:GetPlayers()) do
                            local head = p ~= lp and p.Character and p.Character:FindFirstChild("Head")
                            if head then
                                local tag = espTags[p]
                                if not tag then
                                    local gui = new("BillboardGui", espFolder)
                                    gui.Adornee = head
                                    gui.AlwaysOnTop = true
                                    gui.Size = UDim2.fromOffset(200, 34)
                                    local lbl = new("TextLabel", gui)
                                    lbl.Size = UDim2.fromScale(1, 1)
                                    lbl.BackgroundTransparency = 1
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 13
                                    lbl.TextStrokeTransparency = 0
                                    local hl = new("Highlight", espFolder)
                                    hl.Adornee = p.Character
                                    hl.FillTransparency = 0.5
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    tag = { gui = gui, label = lbl, hl = hl }
                                    espTags[p] = tag
                                end
                                local dist = (head.Position - root.Position).Magnitude
                                tag.label.Text = p.DisplayName .. " [" .. math.floor(dist) .. "m]"
                                tag.label.TextColor3 = Color3.fromHSV(0, 1, 1)
                                tag.hl.FillColor = tag.label.TextColor3
                                tag.gui.Enabled = true
                                tag.hl.Enabled = true
                            end
                        end
                    end
                else
                    for p, tag in pairs(espTags) do
                        tag.gui:Destroy() 
                        tag.hl:Destroy() 
                        espTags[p] = nil
                    end
                end
                task.wait(0.3)
            end
        end)

        -- SPEED & LIMIT
        bind(RunService.Heartbeat:Connect(function(dt)
            local seat = myDriveSeat()
            local hum = getHum()
            if not (seat and hum and hum.SeatPart == seat) then return end
            local body = seat.AssemblyRootPart or seat
            local W = UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up)
            local vel = body.AssemblyLinearVelocity
            local look = seat.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude < 0.1 then return end
            flat = flat.Unit

            if S.RideSpeedBoost > 0 and W then
                body.AssemblyLinearVelocity = body.AssemblyLinearVelocity + flat * S.RideSpeedBoost * dt
            end
            if S.SpeedUncap and W then
                body.AssemblyLinearVelocity = flat * 300 + Vector3.new(0, vel.Y * 0.9, 0)
            end
            if S.SpeedLimit > 0 then
                local v2 = body.AssemblyLinearVelocity
                local flatV = Vector3.new(v2.X, 0, v2.Z)
                if flatV.Magnitude > S.SpeedLimit then
                    local scaled = flatV.Unit * S.SpeedLimit
                    body.AssemblyLinearVelocity = Vector3.new(scaled.X, v2.Y * 0.9, scaled.Z)
                end
            end
        end))

        -- WHEELIES & TRICKS
        local angleWheelie = { active = false, seat = nil, align = nil, attach = nil, yaw = 0 }
        local spin = { phase = "Idle", phaseAt = 0, idleAt = 0, totalAngle = 0, align = nil, attach = nil }
        
        bind(RunService.Heartbeat:Connect(function(dt)
            local seat = myDriveSeat()
            local hum = getHum()
            local s = hum and hum.SeatPart

            -- Classic Wheelie
            if S.AutoWheelie and seat then
                local aci = lp.PlayerGui:FindFirstChild("A-Chassis Interface")
                local values = aci and aci:FindFirstChild("Values")
                local drive = aci and aci:FindFirstChild("Drive")
                local input = drive and drive:FindFirstChild("VirtualInput")
                if values and input then
                    if not values.Wheelie.Value then values.Wheelie.Value = true end
                    input:Fire({ KeyCode = Enum.KeyCode.ButtonR2, UserInputType = Enum.UserInputType.Gamepad1, UserInputState = Enum.UserInputState.Change, Position = Vector3.new(0.4, 0, 0) })
                    input:Fire({ KeyCode = Enum.KeyCode.Thumbstick1, UserInputType = Enum.UserInputType.Gamepad1, UserInputState = Enum.UserInputState.Change, Position = Vector3.new(0.25, 0, 0) })
                end
            end

            -- Angle Wheelie
            local w = angleWheelie
            if S.AngleWheelie and s then
                if not w.active or w.seat ~= s then
                    w.active = true
                    w.seat = s
                    w.yaw = select(2, s.CFrame:ToOrientation())
                    w.attach = Instance.new("Attachment", s)
                    w.align = Instance.new("AlignOrientation", s)
                    w.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
                    w.align.Attachment0 = w.attach
                    w.align.MaxTorque = 10000000
                end
                local steer = s.SteerFloat or 0
                w.yaw = w.yaw - steer * 3.0 * dt
                w.align.CFrame = CFrame.new(s.Position) * CFrame.Angles(0, w.yaw, 0) * CFrame.Angles(math.rad(S.AngleWheelieAngle), 0, 0)
            elseif w.active then
                if w.align then w.align:Destroy() end
                if w.attach then w.attach:Destroy() end
                w.active = false
            end

            -- Tricks
            if S.AutoTricks and s then
                local body = s.AssemblyRootPart or s
                local now = os.clock()
                if spin.phase == "Idle" then
                    if now - spin.idleAt >= 0.35 then
                        spin.phase = "Spin"
                        spin.phaseAt = now
                        spin.totalAngle = 0
                        spin.attach = Instance.new("Attachment", body)
                        spin.align = Instance.new("AlignOrientation", body)
                        spin.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        spin.align.Attachment0 = spin.attach
                        spin.align.MaxTorque = 1e9
                        spin.align.MaxAngularVelocity = 1e6
                        body.AssemblyLinearVelocity = Vector3.new(0, 15, 0)
                    end
                elseif spin.phase == "Spin" then
                    local rate = math.rad(720) * (S.TrickSpeed or 1)
                    spin.totalAngle = spin.totalAngle + rate * dt
                    spin.align.CFrame = CFrame.Angles(0, spin.totalAngle, 0)
                    if math.abs(spin.totalAngle) >= math.rad(1440) then spin.phase = "Descend" end
                elseif spin.phase == "Descend" then
                    body.AssemblyLinearVelocity = Vector3.new(0, -90, 0)
                    if now - spin.phaseAt > 1.6 then
                        if spin.align then spin.align:Destroy() end
                        if spin.attach then spin.attach:Destroy() end
                        spin.phase = "Idle"
                        spin.idleAt = now
                    end
                end
            elseif spin.phase ~= "Idle" then
                if spin.align then spin.align:Destroy() end
                if spin.attach then spin.attach:Destroy() end
                spin.phase = "Idle"
            end
        end))

        -- PLAYER
        local noclipSaved = {}
        bind(RunService.Stepped:Connect(function()
            if not S.Noclip then return end
            local c = lp.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then 
                    noclipSaved[p] = true
                    p.CanCollide = false 
                end
            end
        end))

        bind(UIS.JumpRequest:Connect(function()
            if S.InfJump then local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end))

        bind(RunService.Heartbeat:Connect(function()
            local h, root = getHum(), getRoot()
            if not (h and root) then return end
            h.WalkSpeed = S.WalkSpeed
            h.JumpHeight = S.JumpHeight
            workspace.CurrentCamera.FieldOfView = S.FOV
            if S.Fly then
                h.PlatformStand = true
                local cf = workspace.CurrentCamera.CFrame
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
                if dir.Magnitude == 0 then dir = h.MoveDirection end
                root.AssemblyLinearVelocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * S.FlySpeed
            elseif h.PlatformStand and not S.Fly then h.PlatformStand = false end
            if S.Fullbright then 
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1e9 
            end
        end))

        -- POLICE
        local oldHook = nil
        bind(RunService.Heartbeat:Connect(function()
            if S.AntiPolice then
                if not oldHook and getrawmetatable and PoliceHit then
                    pcall(function()
                        local mt = getrawmetatable(game)
                        oldHook = mt.__namecall
                        setreadonly(mt, false)
                        mt.__namecall = newcclosure(function(self, ...)
                            if self == PoliceHit then return end
                            return oldHook(self, ...)
                        end)
                        setreadonly(mt, true)
                    end)
                end
                local root = getRoot()
                local police = workspace:FindFirstChild("PoliceNPCs")
                if root and police then
                    for _, m in ipairs(police:GetChildren()) do
                        local p = m.PrimaryPart
                        if p and (p.Position - root.Position).Magnitude < 200 then
                            m:PivotTo(CFrame.new(p.Position + Vector3.new(0, 100, 0)))
                        end
                    end
                end
            end
        end))
    end
    setupModules()

    -- =====================================================================
    -- UI
    -- =====================================================================
    local function buildUI()
        local Theme = {
            Bg = Color3.fromRGB(16, 18, 27), Panel = Color3.fromRGB(24, 27, 38),
            Panel2 = Color3.fromRGB(34, 38, 52), Border = Color3.fromRGB(42, 48, 66),
            Accent = Color3.fromRGB(91, 140, 255), AccentHi = Color3.fromRGB(130, 170, 255),
            Text = Color3.fromRGB(238, 242, 252), TextSub = Color3.fromRGB(150, 158, 180)
        }
        local FB = Enum.Font.GothamBold
        local FM = Enum.Font.GothamMedium
        local ui = new("ScreenGui", guiParent)
        ui.Name = "RubenHubUI"
        ui.ResetOnSpawn = false
        local WIN_W = 640
        local WIN_H = 520

        local win = new("Frame", ui)
        win.Size = UDim2.fromOffset(WIN_W, WIN_H)
        win.Position = UDim2.new(0.5, -320, 0.5, -260)
        win.BackgroundColor3 = Theme.Bg
        win.BorderSizePixel = 0
        win.ClipsDescendants = true
        win.Active = true
        local c1 = new("UICorner", win)
        c1.CornerRadius = UDim.new(0, 16)
        local st1 = new("UIStroke", win)
        st1.Color = Theme.Border

        local header = new("Frame", win)
        header.Size = UDim2.new(1, 0, 0, 56)
        header.BackgroundTransparency = 1
        header.Active = true

        local title = new("TextLabel", header)
        title.Position = UDim2.fromOffset(20, 12)
        title.Size = UDim2.new(0, 300, 0, 32)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 18
        title.TextColor3 = Theme.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = "RUBEN-HUB"

        local minBtn = new("TextButton", header)
        minBtn.Text = "-"
        minBtn.Font = FB
        minBtn.TextSize = 20
        minBtn.Size = UDim2.fromOffset(28, 28)
        minBtn.Position = UDim2.new(1, -70, 0, 14)
        minBtn.BackgroundColor3 = Theme.Panel2
        minBtn.TextColor3 = Theme.Text
        local c2 = new("UICorner", minBtn)
        c2.CornerRadius = UDim.new(0, 8)

        local closeBtn = new("TextButton", header)
        closeBtn.Text = "x"
        closeBtn.Font = FB
        closeBtn.TextSize = 15
        closeBtn.Size = UDim2.fromOffset(28, 28)
        closeBtn.Position = UDim2.new(1, -36, 0, 14)
        closeBtn.BackgroundColor3 = Theme.Accent
        closeBtn.TextColor3 = Theme.Text
        local c3 = new("UICorner", closeBtn)
        c3.CornerRadius = UDim.new(0, 8)

        local body = new("Frame", win)
        body.Position = UDim2.fromOffset(0, 56)
        body.Size = UDim2.new(1, 0, 1, -56)
        body.BackgroundTransparency = 1

        local sidebar = new("Frame", body)
        sidebar.Position = UDim2.fromOffset(14, 10)
        sidebar.Size = UDim2.new(0, 150, 1, -24)
        sidebar.BackgroundColor3 = Theme.Panel
        local c4 = new("UICorner", sidebar)
        c4.CornerRadius = UDim.new(0, 12)
        
        local layout = new("UIListLayout", sidebar)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        local pages = new("Frame", body)
        pages.Position = UDim2.fromOffset(178, 10)
        pages.Size = UDim2.new(1, -192, 1, -24)
        pages.BackgroundTransparency = 1

        local tabs = {}
        local currentTab = nil
        local function selectTab(sel)
            currentTab = sel
            for _, t in ipairs(tabs) do
                local on = t == sel
                t.page.Visible = on
                if on then
                    t.btn.BackgroundColor3 = Theme.Accent
                    t.btn.TextColor3 = Theme.Text
                else
                    t.btn.BackgroundColor3 = Theme.Panel2
                    t.btn.TextColor3 = Theme.TextSub
                end
            end
        end

        local function Tab(name)
            local btn = new("TextButton", sidebar)
            btn.Text = "   " .. name
            btn.Font = FB
            btn.TextSize = 12
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Theme.Panel2
            btn.TextColor3 = Theme.TextSub
            btn.TextXAlignment = Enum.TextXAlignment.Left
            local c = new("UICorner", btn)
            c.CornerRadius = UDim.new(0, 8)

            local page = new("ScrollingFrame", pages)
            page.Size = UDim2.fromScale(1, 1)
            page.BackgroundTransparency = 1
            page.ScrollBarThickness = 3
            page.Visible = false
            
            local pLayout = new("UIListLayout", page)
            pLayout.Padding = UDim.new(0, 6)

            local t = { btn = btn, page = page }
            btn.MouseButton1Click:Connect(function() selectTab(t) end)
            table.insert(tabs, t)
            return t
        end

        local function Toggle(t, text, key)
            local r = new("Frame", t.page)
            r.Size = UDim2.new(1, 0, 0, 38)
            r.BackgroundColor3 = Theme.Panel2
            local cr = new("UICorner", r)
            cr.CornerRadius = UDim.new(0, 8)
            
            local l = new("TextLabel", r)
            l.Text = text
            l.Font = FM
            l.TextSize = 12
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(14, 0)
            l.Size = UDim2.new(1, -24, 0, 38)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = Theme.Text

            local sw = new("Frame", r)
            sw.Size = UDim2.fromOffset(42, 22)
            sw.Position = UDim2.new(1, -56, 0.5, -11)
            sw.BackgroundColor3 = Theme.Border
            local cr2 = new("UICorner", sw)
            cr2.CornerRadius = UDim.new(0, 11)

            local knob = new("Frame", sw)
            knob.Size = UDim2.fromOffset(16, 16)
            knob.Position = UDim2.fromOffset(3, 3)
            knob.BackgroundColor3 = Theme.TextSub
            local cr3 = new("UICorner", knob)
            cr3.CornerRadius = UDim.new(0, 8)

            local hit = new("TextButton", r)
            hit.Text = ""
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.fromScale(1, 1)

            local function render()
                local on = Settings[key]
                if on then
                    TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(23, 3), BackgroundColor3 = Theme.Text}):Play()
                else
                    TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Border}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Theme.TextSub}):Play()
                end
            end
            hit.MouseButton1Click:Connect(function() Settings[key] = not Settings[key]; render() end)
            render()
            table.insert(refreshers, render)
        end

        local function Slider(t, text, key, mn, mx, step, fmt)
            local r = new("Frame", t.page)
            r.Size = UDim2.new(1, 0, 0, 56)
            r.BackgroundColor3 = Theme.Panel2
            local cr = new("UICorner", r)
            cr.CornerRadius = UDim.new(0, 8)
            
            local l = new("TextLabel", r)
            l.Text = text
            l.Font = FM
            l.TextSize = 12
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(14, 0)
            l.Size = UDim2.new(1, -24, 0, 38)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = Theme.Text

            local value = new("TextLabel", r)
            value.Font = FB
            value.TextSize = 11
            value.BackgroundTransparency = 1
            value.Position = UDim2.new(1, -112, 0, 0)
            value.Size = UDim2.fromOffset(100, 38)
            value.TextXAlignment = Enum.TextXAlignment.Right
            value.TextColor3 = Theme.AccentHi

            local bar = new("Frame", r)
            bar.Size = UDim2.new(1, -28, 0, 4)
            bar.Position = UDim2.fromOffset(14, 40)
            bar.BackgroundColor3 = Theme.Border
            local cr2 = new("UICorner", bar)
            cr2.CornerRadius = UDim.new(0, 2)

            local fill = new("Frame", bar)
            fill.Size = UDim2.fromScale(0, 1)
            fill.BackgroundColor3 = Theme.Accent
            local cr3 = new("UICorner", fill)
            cr3.CornerRadius = UDim.new(0, 2)

            local knob = new("Frame", bar)
            knob.Size = UDim2.fromOffset(14, 14)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.BackgroundColor3 = Theme.Text
            local cr4 = new("UICorner", knob)
            cr4.CornerRadius = UDim.new(0, 7)

            local hit = new("TextButton", bar)
            hit.Text = ""
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.new(1, 0, 0, 24)
            hit.Position = UDim2.new(0, 0, 0.5, -12)

            local function render()
                local v = Settings[key]
                local rel = math.clamp((v - mn) / (mx - mn), 0, 1)
                fill.Size = UDim2.fromScale(rel, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                value.Text = fmt(v)
            end
            local dragging = false
            local function update(x)
                local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                Settings[key] = math.clamp(math.floor((mn + a * (mx - mn)) / step + 0.5) * step, mn, mx)
                render()
            end
            hit.InputBegan:Connect(function(i) if i.UserInputType == MB1 then dragging = true; update(i.Position.X) end end)
            UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == MOVE then update(i.Position.X) end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == MB1 then dragging = false end end)
            render()
            table.insert(refreshers, render)
        end

        local bindsList = {}
        local function addBind(t, text, key)
            local r = new("Frame", t.page)
            r.Size = UDim2.new(1, 0, 0, 38)
            r.BackgroundColor3 = Theme.Panel2
            local cr = new("UICorner", r)
            cr.CornerRadius = UDim.new(0, 8)

            local l = new("TextLabel", r)
            l.Text = text
            l.Font = FM
            l.TextSize = 12
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(14, 0)
            l.Size = UDim2.new(1, -24, 0, 38)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = Theme.Text

            local b = new("TextButton", r)
            b.Size = UDim2.fromOffset(100, 26)
            b.Position = UDim2.new(1, -114, 0.5, -13)
            b.BackgroundColor3 = Theme.Panel
            b.TextColor3 = Theme.Text
            b.Font = FB
            b.TextSize = 11
            local cr2 = new("UICorner", b)
            cr2.CornerRadius = UDim.new(0, 7)
            
            local listening = false
            local function render()
                local bindKey = nil
                for k, v in pairs(bindsList) do if v == key then bindKey = k break end end
                if listening then
                    b.Text = "Press..."
                elseif bindKey then
                    b.Text = "["..bindKey.."]"
                else
                    b.Text = "Bind"
                end
            end
            b.MouseButton1Click:Connect(function() listening = not listening; render() end)
            UIS.InputBegan:Connect(function(i)
                if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                listening = false
                for k, v in pairs(bindsList) do if v == key then bindsList[k] = nil end end
                bindsList[i.KeyCode.Name] = key
                render()
            end)
            render()
        end

        -- TABS
        local farmTab = Tab("Farm")
        Toggle(farmTab, "Auto claim quests", "AutoQuests")
        Toggle(farmTab, "Auto claim achievements", "AutoAchievements")
        Toggle(farmTab, "Auto daily reward", "AutoDaily")
        Toggle(farmTab, "Auto delivery", "AutoDelivery")
        Toggle(farmTab, "Auto wheelie (Classic)", "AutoWheelie")

        local rideTab = Tab("Ride")
        local spawnBtn = new("TextButton", rideTab.page)
        spawnBtn.Size = UDim2.new(1, 0, 0, 34)
        spawnBtn.BackgroundColor3 = Theme.Panel2
        spawnBtn.Text = "Spawn Ride (G2)"
        spawnBtn.Font = FB
        spawnBtn.TextColor3 = Theme.Text
        local c = new("UICorner", spawnBtn)
        c.CornerRadius = UDim.new(0, 8)
        spawnBtn.MouseButton1Click:Connect(function() 
            if SpawnRide then pcall(function() SpawnRide:InvokeServer("ScooterG2") end) end 
        end)

        local sitBtn = new("TextButton", rideTab.page)
        sitBtn.Size = UDim2.new(1, 0, 0, 34)
        sitBtn.BackgroundColor3 = Theme.Panel2
        sitBtn.Text = "Sit on Ride"
        sitBtn.Font = FB
        sitBtn.TextColor3 = Theme.Text
        local c2 = new("UICorner", sitBtn)
        c2.CornerRadius = UDim.new(0, 8)
        sitBtn.MouseButton1Click:Connect(function()
            local seat = myDriveSeat()
            local hum = getHum()
            if seat and hum then
                local root = getRoot()
                if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end
                task.wait(0.3)
                pcall(function() seat:Sit(hum) end)
            end
        end)

        Toggle(rideTab, "Auto Wheelie (Angle)", "AngleWheelie")
        Slider(rideTab, "Angle Deg", "AngleWheelieAngle", -80, 80, 1, function(v) return math.floor(v) .. "°" end)
        Toggle(rideTab, "Auto Tricks", "AutoTricks")
        Slider(rideTab, "Trick Speed", "TrickSpeed", 0.3, 1.5, 0.1, function(v) return string.format("x%.1f", v) end)
        Slider(rideTab, "Speed Boost", "RideSpeedBoost", 0, 300, 10, function(v) return v == 0 and "Off" or (math.floor(v).." st/s²") end)
        Toggle(rideTab, "Speed Uncap (300)", "SpeedUncap")
        Slider(rideTab, "Speed Limit", "SpeedLimit", 0, 400, 5, function(v) return v == 0 and "Off" or (math.floor(v).." st/s") end)
        Toggle(rideTab, "Anti Police", "AntiPolice")

        local visualsTab = Tab("Visuals")
        Toggle(visualsTab, "Player ESP", "PlayerESP")
        Toggle(visualsTab, "Fullbright", "Fullbright")

        local playerTab = Tab("Player")
        Slider(playerTab, "WalkSpeed", "WalkSpeed", 0, 200, 1, function(v) return tostring(math.floor(v)) end)
        Slider(playerTab, "Jump height", "JumpHeight", 0, 100, 1, function(v) return tostring(math.floor(v)) end)
        Toggle(playerTab, "Infinite jump", "InfJump")
        Toggle(playerTab, "Noclip", "Noclip")
        Toggle(playerTab, "Fly", "Fly")
        Slider(playerTab, "Fly speed", "FlySpeed", 10, 300, 5, function(v) return tostring(math.floor(v)) end)
        Slider(playerTab, "FOV", "FOV", 30, 120, 1, function(v) return math.floor(v) .. "°" end)

        local bindsTab = Tab("Binds")
        addBind(bindsTab, "Auto Quests", "AutoQuests")
        addBind(bindsTab, "Auto Wheelie (Classic)", "AutoWheelie")
        addBind(bindsTab, "Auto Wheelie (Angle)", "AngleWheelie")
        addBind(bindsTab, "Auto Tricks", "AutoTricks")
        addBind(bindsTab, "Player ESP", "PlayerESP")
        addBind(bindsTab, "Fly", "Fly")
        addBind(bindsTab, "Anti Police", "AntiPolice")

        selectTab(farmTab)
        
        closeBtn.MouseButton1Click:Connect(function() 
            Hub.unloaded = true
            ui:Destroy() 
        end)
        
        local isMinimized = false
        minBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            body.Visible = not isMinimized
            win.Size = UDim2.fromOffset(WIN_W, isMinimized and 56 or WIN_H)
        end)

        header.InputBegan:Connect(function(i)
            if i.UserInputType == MB1 then
                local dragging = true
                local dragStart = i.Position
                local startPos = win.Position
                local conn1 = UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == MOVE then
                        local d = input.Position - dragStart
                        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                    end
                end)
                local conn2 = UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == MB1 then
                        dragging = false
                        conn1:Disconnect()
                        conn2:Disconnect()
                    end
                end)
            end
        end)

        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode.Name == Settings.ToggleKey then
                win.Visible = not win.Visible
            end
            for keyName, settingKey in pairs(bindsList) do
                if i.KeyCode.Name == keyName then
                    if type(Settings[settingKey]) == "boolean" then
                        Settings[settingKey] = not Settings[settingKey]
                        for _, r in ipairs(refreshers) do r() end
                    end
                end
            end
        end)
    end
    buildUI()
end

promptKey(function()
    StartMainScript()
end)