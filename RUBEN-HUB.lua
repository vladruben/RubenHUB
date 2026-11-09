-- =========================================================================
-- [RUBEN-HUB] — Kukirin Life | Full + Key System + Smooth Camera v2
-- =========================================================================
if _G.RubenHubLoaded then return end
_G.RubenHubLoaded = true

-- =========================================================================
-- KEY SYSTEM (HWID-locked, 30 keys)
-- =========================================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local VirtualUser  = game:GetService("VirtualUser")
local Stats        = game:GetService("Stats")
local RS           = game:GetService("ReplicatedStorage")
local lp           = Players.LocalPlayer

local VALID_KEYS = {
    ["RUBEN-7K2M-9QX4"] = true, ["RUBEN-3F8N-1LPW"] = true, ["RUBEN-6T4R-2VZC"] = true,
    ["RUBEN-8H5J-7BKD"] = true, ["RUBEN-1D9S-4MWG"] = true, ["RUBEN-5G3P-8XTF"] = true,
    ["RUBEN-2C7V-6NQH"] = true, ["RUBEN-9M1L-3ZRB"] = true, ["RUBEN-4W8K-5JDP"] = true,
    ["RUBEN-7Q2F-9TXN"] = true, ["RUBEN-6B5H-1KMC"] = true, ["RUBEN-3V9R-7LZS"] = true,
    ["RUBEN-8N4T-2FWG"] = true, ["RUBEN-1X6P-5JQK"] = true, ["RUBEN-5K3D-8MZH"] = true,
    ["RUBEN-2R7L-4CVB"] = true, ["RUBEN-9H1N-6TWX"] = true, ["RUBEN-4F8J-3PDQ"] = true,
    ["RUBEN-7M2K-9SRL"] = true, ["RUBEN-6Q5V-1BNH"] = true, ["RUBEN-3T9W-7FZC"] = true,
    ["RUBEN-8J4D-2KMX"] = true, ["RUBEN-1N6H-5QPL"] = true, ["RUBEN-5C3R-8VZB"] = true,
    ["RUBEN-2W7F-4JTD"] = true, ["RUBEN-9P1K-6MXN"] = true, ["RUBEN-4H8Q-3LRS"] = true,
    ["RUBEN-7D2V-9FWG"] = true, ["RUBEN-6N5J-1PZK"] = true, ["RUBEN-3B9M-7CQT"] = true,
}
local KEY_FILE = "RubenHub_Key.json"

local function getHWID()
    local ok, hwid = pcall(function() return gethwid() end)
    if ok and hwid and hwid ~= "" then return hwid end
    return "USER_" .. tostring(lp.UserId)
end

local function validateKey(key, hwid)
    if not VALID_KEYS[key] then return false, "Invalid key" end
    local data = {}
    if isfile and isfile(KEY_FILE) then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(KEY_FILE)) end)
        if ok and type(decoded) == "table" then data = decoded end
    end
    local bound = data[key]
    if bound and bound ~= hwid then return false, "Key bound to another HWID" end
    if not bound then
        data[key] = hwid
        if writefile then pcall(function() writefile(KEY_FILE, HttpService:JSONEncode(data)) end) end
    end
    return true, "OK"
end

local function promptKey(callback)
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    gui.Name = "RubenKeyUI"; gui.ResetOnSpawn = false
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(400, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(16, 18, 27)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(42, 48, 66); stroke.Thickness = 1
    local grad = Instance.new("Frame", frame)
    grad.Size = UDim2.new(1, 0, 0, 2); grad.BackgroundColor3 = Color3.fromRGB(91, 140, 255); grad.BorderSizePixel = 0
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 44); title.Position = UDim2.fromOffset(0, 10)
    title.BackgroundTransparency = 1
    title.Text = "RUBEN-HUB · KEY ACTIVATION"
    title.TextColor3 = Color3.fromRGB(238, 242, 252)
    title.Font = Enum.Font.GothamBlack; title.TextSize = 15
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -40, 0, 38); input.Position = UDim2.fromOffset(20, 62)
    input.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
    input.TextColor3 = Color3.fromRGB(238, 242, 252); input.PlaceholderText = "RUBEN-XXXX-XXXX"
    input.PlaceholderColor3 = Color3.fromRGB(90, 98, 120)
    input.Font = Enum.Font.GothamBold; input.TextSize = 13; input.ClearTextOnFocus = false
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -40, 0, 36); btn.Position = UDim2.fromOffset(20, 110)
    btn.BackgroundColor3 = Color3.fromRGB(91, 140, 255)
    btn.Text = "ACTIVATE"; btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -40, 0, 20); status.Position = UDim2.fromOffset(20, 152)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(255, 100, 120); status.Font = Enum.Font.Gotham; status.TextSize = 11
    btn.MouseButton1Click:Connect(function()
        local ok, msg = validateKey(input.Text:upper():gsub("%s+", ""), getHWID())
        if ok then
            gui:Destroy()
            callback()
        else
            status.Text = msg
        end
    end)
    input.FocusLost:Connect(function() if input.Text ~= "" then btn:Activate() end end)
end

local function startKeyGate(callback)
    local hwid = getHWID()
    local data = {}
    if isfile and isfile(KEY_FILE) then
        pcall(function() data = HttpService:JSONDecode(readfile(KEY_FILE)) end)
    end
    local hasValid = false
    for k, v in pairs(data) do
        if VALID_KEYS[k] and v == hwid then hasValid = true; break end
    end
    if hasValid then
        callback()
    else
        promptKey(callback)
    end
end

startKeyGate(function()
    -- =====================================================================
    -- GAME CHECK
    -- =====================================================================
    local guiParent
    pcall(function() guiParent = gethui() end)
    if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
    if not guiParent then guiParent = lp:WaitForChild("PlayerGui") end

    if not (workspace:FindFirstChild("Rides") and RS:FindFirstChild("Scooters") and RS:FindFirstChild("Remotes")) then
        warn("[Ruben-Hub] This script only works in Kukirin Life!")
        return
    end

    -- =====================================================================
    -- HIDE TOPBAR
    -- =====================================================================
    task.spawn(function()
        local sg = game:GetService("StarterGui")
        for _ = 1, 30 do
            local ok = pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
            if ok then break end
            task.wait(0.1)
        end
        pcall(function() sg:SetCore("TopbarEnabled", false) end)
    end)

    -- =====================================================================
    -- HUB STATE
    -- =====================================================================
    local Hub = {
        Settings = {},
        State = {
            phase = "idle", phaseAt = 0, padSent = {}, padSentTo = nil,
            pulsarWheelie = { active = false, seat = nil, attach = nil, align = nil, yaw = 0, ownerFixed = false },
            spin = { phase = "Idle", phaseAt = 0, idleAt = 0, totalAngle = 0, targetAngle = 0, rate = 0,
                     mode = "Spin", baseYaw = 0, currentBody = nil, attach = nil, align = nil,
                     savedAutoRotate = true, savedPlatformStand = false, cycleSeated = false, seat = nil,
                     ownerFixed = false },
            session = { startedAt = os.clock(), startCash = tonumber(lp:GetAttribute("Cash")) or 0,
                        quests = 0, achievements = 0, daily = 0, deliveries = 0, deliveryCash = 0, pushed = 0 },
            deliveryStatus = "", collectingRain = false, respawnedAt = 0, respawning = false,
            stuckSince = nil, lastCheckPos = nil, lastWheelieTime = nil,
            oneHandByHelper = false, policeBefore = nil, armToggledAt = 0, lastPush = 0,
        },
        Remotes = {}, Conns = {},
        UI = { refreshers = {}, tabs = {}, bindCapture = false, win = nil, tagGui = nil, glow = nil },
        Binds = {}, SeatLock = nil, DesyncState = nil, NoclipSaved = {}, HiddenParts = {},
        PromptSaved = {}, LagFx = {}, LagShadows = nil, FbSaved = nil,
        Police = { models = {}, scanAt = 0, stuck = {}, hookMt = nil, hookOld = nil, hookOn = false },
        Esp = { folder = nil, tags = {} },
        Camera = { hookActive = false, rideActive = false },
    }

    for k, v in pairs({
        AutoQuests = false, AutoAchievements = false, AutoDaily = false, AutoDelivery = false,
        AutoBuyRide = false, MoneyRain = false, QuestHelpers = true,
        AutoWheelie = false, WheelieAngle = 35,
        WheeliePulsar = false, WheeliePulsarAngle = 35, WheeliePulsarFreeze = false,
        AutoTricks = false, TrickMode = "Spin", TrickSpeed = 1,
        RideSpeedBoost = 0, SpeedUncap = false, SpeedLimit = 140,
        QuickRide = "", SeatLock = true, AntiPolice = false,
        PlayerESP = false, RideESP = false, PoliceESP = false, CustomerESP = false, DropESP = false,
        ESPNames = true, ESPDistance = true, ESPBoxes = true, ESPMaxDistance = 0,
        ESPPlayerColor = 350, ESPRideColor = 160, Fullbright = false,
        WalkSpeed = 16, JumpHeight = 50, HipHeight = 2,
        InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, FOV = 70,
        Anchor = false, Desync = false, AntiAFK = true, QuickInteract = false,
        HidePlayers = false, BlackScreen = false, FPSCap = 60, AntiLag = false,
        UITransparency = 0, ShowProfile = true, ShowFPS = true, ShowPing = true,
        ToggleKey = "RightShift", SmoothCamera = true, SmoothCameraDuration = 0.4,
        CameraWalkMin = 0.5, CameraWalkMax = 20, CameraRideMin = 8, CameraRideMax = 25,
    }) do Hub.Settings[k] = v end

    -- =====================================================================
    -- UTILS
    -- =====================================================================
    local function new(class, props)
        local inst = Instance.new(class); local parent = props.Parent; props.Parent = nil
        for k, v in pairs(props) do inst[k] = v end; inst.Parent = parent; return inst
    end
    local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p }) end
    local function tween(inst, props, dur) TweenService:Create(inst, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play() end
    local function bind(c) table.insert(Hub.Conns, c) return c end
    local function getHum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
    local function getRoot() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
    local function myRide() return workspace.Rides and workspace.Rides:FindFirstChild("Ride_" .. lp.Name) end
    local function myDriveSeat() local r = myRide() return r and r:FindFirstChild("DriveSeat", true) end
    local function seated(seat) local h = getHum() return h and seat and h.SeatPart == seat end

    -- =====================================================================
    -- REMOTES
    -- =====================================================================
    do
        local Remotes = RS.Remotes
        local function r(n) for _, x in ipairs(Remotes:GetDescendants()) do if x.Name == n and (x:IsA("RemoteEvent") or x:IsA("RemoteFunction")) then return x end end end
        Hub.Remotes.GetQuests = r("GetQuests"); Hub.Remotes.ClaimQuest = r("ClaimQuest")
        Hub.Remotes.ClaimAchievement = r("ClaimAchievement"); Hub.Remotes.ClaimAchievementReward = r("ClaimAchievementReward")
        Hub.Remotes.GetDailyRewards = r("GetDailyRewards"); Hub.Remotes.ClaimDailyReward = r("ClaimDailyReward")
        Hub.Remotes.SpawnRide = r("SpawnRide"); Hub.Remotes.GoToDealership = r("GoToDealership")
        Hub.Remotes.GetRides = r("GetRides"); Hub.Remotes.BuyRide = r("BuyRide")
        Hub.Remotes.RiderArmEvent = r("RiderArmEvent"); Hub.Remotes.PoliceMode = r("PoliceMode")
        Hub.Remotes.PoliceHit = r("PoliceHit"); Hub.Remotes.TrickState = r("TrickState")
        Hub.Remotes.FoodDelivery = Remotes:FindFirstChild("FoodDelivery"); Hub.Remotes.RainFolder = Remotes:FindFirstChild("MoneyRain")
    end

    -- =====================================================================
    -- A-CHASSIS / SEAT LOCK
    -- =====================================================================
    local function chassis()
        local aci = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("A-Chassis Interface")
        local values = aci and aci:FindFirstChild("Values"); local drive = aci and aci:FindFirstChild("Drive")
        local input = drive and drive:FindFirstChild("VirtualInput")
        if values and values:FindFirstChild("Wheelie") and input then return values, input end
    end
    local function pad(input, keyCode, value)
        local S = Hub.State
        if S.padSentTo ~= input then S.padSent = {}; S.padSentTo = input end
        value = math.floor(value * 50 + 0.5) / 50
        if S.padSent[keyCode] == value then return end
        S.padSent[keyCode] = value
        input:Fire({ KeyCode = keyCode, UserInputType = Enum.UserInputType.Gamepad1, UserInputState = Enum.UserInputState.Change,
            Position = keyCode == Enum.KeyCode.Thumbstick1 and Vector3.new(value, 0, 0) or Vector3.new(0, 0, value) })
    end
    local function releaseRide()
        local values, input = chassis(); if not values then return end
        pad(input, Enum.KeyCode.ButtonR2, 0); pad(input, Enum.KeyCode.ButtonL2, 0)
        pad(input, Enum.KeyCode.Thumbstick1, 0); values.Wheelie.Value = false
    end
    local function lockSeat()
        local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart"); local seat = hum and hum.SeatPart
        if not (hrp and seat) then if Hub.SeatLock then Hub.SeatLock:Destroy() end; Hub.SeatLock = nil; return end
        if Hub.SeatLock and Hub.SeatLock.Parent and Hub.SeatLock.Part0 == hrp and Hub.SeatLock.Part1 == seat then return end
        if Hub.SeatLock then Hub.SeatLock:Destroy() end
        Hub.SeatLock = Instance.new("WeldConstraint")
        Hub.SeatLock.Name = "RubenSeatLock"; Hub.SeatLock.Part0 = hrp; Hub.SeatLock.Part1 = seat; Hub.SeatLock.Parent = hrp
    end
    local function unlockSeat() if Hub.SeatLock then Hub.SeatLock:Destroy() end; Hub.SeatLock = nil end

    -- =====================================================================
    -- TELEPORT / STREAM
    -- =====================================================================
    local groundParams = RaycastParams.new(); groundParams.FilterType = Enum.RaycastFilterType.Exclude
    local function groundBelow(pos, depth)
        groundParams.FilterDescendantsInstances = { workspace.Rides, lp.Character, workspace:FindFirstChild("POIs") }
        return workspace:Raycast(pos, Vector3.new(0, -(depth or 12), 0), groundParams)
    end
    local function streamAround(pos)
        local done = false; task.spawn(function() pcall(function() lp:RequestStreamAroundAsync(pos, 5) end); done = true end)
        local t = os.clock(); while not done and os.clock() - t < 3 do task.wait(0.1) end
    end
    local function seatHeight(seat) local g = groundBelow(seat.Position, 20); return g and seat.Position.Y - g.Position.Y or 3 end
    local function placeRide(seatPos)
        local ride, seat = myRide(), myDriveSeat(); if not (ride and seat) then return end
        local look = seat.CFrame.LookVector; local target = CFrame.new(seatPos) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
        ride:PivotTo(target * (seat.CFrame:Inverse() * ride:GetPivot()))
        for _, d in ipairs(ride:GetDescendants()) do if d:IsA("BasePart") then d.AssemblyLinearVelocity = Vector3.zero; d.AssemblyAngularVelocity = Vector3.zero end end
    end
    local function teleport(pos)
        streamAround(pos); local ground = groundBelow(pos + Vector3.new(0, 40, 0), 200); if ground then pos = ground.Position end
        local seat = myDriveSeat(); if seat and seated(seat) then placeRide(pos + Vector3.new(0, seatHeight(seat), 0)); return end
        local root = getRoot(); if not root then return end
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)); root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
    end

    -- =====================================================================
    -- FARM MODULE
    -- =====================================================================
    local function setupFarm()
        local R, S, St = Hub.Remotes, Hub.Settings, Hub.State
        local PW, Spin = St.pulsarWheelie, St.spin
        local quests = {}
        local function questNeeds(id) for _, q in ipairs(quests) do if q.Id == id and (q.NextAt or 0) <= os.time() and (q.Progress or 0) < (q.Target or 0) then return true end end return false end

        task.spawn(function()
            while _G.RubenHubLoaded do
                if R.GetQuests and (S.AutoQuests or (S.AutoWheelie and S.QuestHelpers)) then
                    local ok, list = pcall(function() return R.GetQuests:InvokeServer() end)
                    if ok and type(list) == "table" then quests = list
                        for i, q in ipairs(S.AutoQuests and R.ClaimQuest and list or {}) do
                            if (q.NextAt or 0) <= os.time() and (q.Progress or 0) >= (q.Target or math.huge) then
                                local okc, claimed = pcall(function() return R.ClaimQuest:InvokeServer(i) end); if okc and claimed then St.session.quests += 1 task.wait(0.4) end
                            end
                        end
                    end
                end; task.wait(5)
            end
        end)

        local function claimAll(fn) for _ = 1, 20 do local ok, claimed = pcall(fn); if not (ok and claimed) then return end; St.session.achievements += 1; task.wait(0.3) end end
        task.spawn(function()
            local cfgOk, cfg = pcall(function() return require(RS.Datas.AchievementConfig) end)
            while _G.RubenHubLoaded do
                if S.AutoAchievements and R.ClaimAchievement and cfgOk then
                    for _, a in ipairs(cfg.Achievements or {}) do claimAll(function() return R.ClaimAchievement:InvokeServer(a.Id) end) end
                    if R.ClaimAchievementReward then claimAll(function() return R.ClaimAchievementReward:InvokeServer() end) end
                end; task.wait(30)
            end
        end)

        task.spawn(function()
            while _G.RubenHubLoaded do
                if S.AutoDaily and R.GetDailyRewards and R.ClaimDailyReward then
                    local ok, d = pcall(function() return R.GetDailyRewards:InvokeServer() end)
                    if ok and type(d) == "table" and (d.NextAt or 0) <= os.time() then
                        local okc, claimed = pcall(function() return R.ClaimDailyReward:InvokeServer() end); if okc and claimed then St.session.daily += 1 end
                    end
                end; task.wait(60)
            end
        end)

        task.spawn(function()
            local specsOk, specs = pcall(function() return require(RS.Datas.RideSpecs) end)
            local function topSpeed(n) local s = specsOk and specs[n] return s and s.TopSpeed or 0 end
            while _G.RubenHubLoaded do
                if S.AutoBuyRide and R.GetRides and R.BuyRide then
                    local ok, rides = pcall(function() return R.GetRides:InvokeServer() end)
                    if ok and type(rides) == "table" then
                        local best, cash, pick = 0, tonumber(lp:GetAttribute("Cash")) or 0, nil
                        for _, x in ipairs(rides) do if x.Owned then best = math.max(best, topSpeed(x.Name)) end end
                        for _, x in ipairs(rides) do
                            local price = tonumber(x.Price) or 0
                            if not x.Owned and not x.RobuxOnly and not x.Event and price > 0 and price <= cash and topSpeed(x.Name) > best and (not pick or topSpeed(x.Name) > topSpeed(pick.Name)) then pick = x end
                        end
                        if pick then pcall(function() R.BuyRide:InvokeServer(pick.Name) end) end
                    end
                end; task.wait(20)
            end
        end)

        local function raining()
            local RF = R.RainFolder; if not RF or RF:GetAttribute("Id") == nil then return false end
            local started, duration = RF:GetAttribute("StartedAt"), RF:GetAttribute("Duration")
            return started ~= nil and duration ~= nil and workspace:GetServerTimeNow() < started + duration + 8
        end
        task.spawn(function()
            while _G.RubenHubLoaded do
                St.collectingRain = S.MoneyRain and raining()
                if St.collectingRain then
                    local hum, root = getHum(), getRoot(); if hum and hum.SeatPart then hum.Sit = false end
                    local drops = workspace:FindFirstChild("MoneyRain"); local nearest, nearestD
                    for _, d in ipairs(root and drops and drops:GetChildren() or {}) do
                        if d:IsA("BasePart") and d.Transparency < 1 then local dist = (d.Position - root.Position).Magnitude; if not nearestD or dist < nearestD then nearest, nearestD = d, dist end end
                    end
                    if nearest then root.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 2, 0)) end; task.wait(0.12)
                else task.wait(1) end
            end
        end)

        local DELIVERY_NPC = Vector3.new(1424.7, 58.6, -607.8)
        task.spawn(function()
            while _G.RubenHubLoaded do
                if S.AutoDelivery and R.FoodDelivery and not St.collectingRain then
                    local target = lp:GetAttribute("DeliveryTarget")
                    if typeof(target) ~= "Vector3" then
                        teleport(DELIVERY_NPC); task.wait(0.6)
                        local ok, started = pcall(function() return R.FoodDelivery.Start:InvokeServer() end)
                        St.deliveryStatus = (ok and started) and "Order picked up" or "Waiting for order"; task.wait(3)
                    else
                        teleport(target + Vector3.new(0, 0, 4)); St.deliveryStatus = "Delivering..."
                        local giveUp = os.clock() + 75
                        while S.AutoDelivery and lp:GetAttribute("DeliveryTarget") == target and os.clock() < giveUp do
                            local ok, done, pay, _, tip = pcall(function() return R.FoodDelivery.Deliver:InvokeServer() end)
                            if ok and done then local earned = (tonumber(pay) or 0) + (tonumber(tip) or 0); St.session.deliveries += 1; St.session.deliveryCash += earned; St.deliveryStatus = "Delivered +$" .. earned; break end
                            task.wait(1.5)
                        end
                    end
                else St.deliveryStatus = "" end; task.wait(0.5)
            end
        end)

        -- COOKIES WHEELIE
        local FARM_SPOT = Vector3.new(1100, 56.4, -1500); local farmAnchor, farmRadius = FARM_SPOT, 260
        local function clearRadius(ground)
            groundBelow(ground); local nearest = 400
            for a = 0, 71 do local ang = a / 72 * math.pi * 2; local dir = Vector3.new(math.cos(ang), 0, math.sin(ang)) * 400
                for _, h in ipairs({ 1.2, 3, 6 }) do local from = ground + Vector3.new(0, h, 0); local hit = workspace:Raycast(from, dir, groundParams); if hit then nearest = math.min(nearest, (hit.Position - from).Magnitude) end end
            end
            return nearest
        end
        Hub.setWheelieArea = function(ground, clear) farmAnchor, farmRadius = ground, math.min(260, clear - 60); if St.phase ~= "idle" then St.phase, St.phaseAt = "idle", os.clock() end end
        Hub.getWheelieAnchor = function() return farmAnchor end
        Hub.clearRadius = clearRadius

        local function setOneHand(on)
            local seat = myDriveSeat(); if not (seat and R.RiderArmEvent) or os.clock() - St.armToggledAt < 1.5 then return end
            if (seat:GetAttribute("OneHanderActive") == true) ~= on then St.armToggledAt = os.clock(); R.RiderArmEvent:FireServer() end
        end
        local function questHelpers()
            local wheelieing = S.AutoWheelie and St.phase == "wheelie"
            if S.QuestHelpers and wheelieing and questNeeds("OneHandWheelie") then St.oneHandByHelper = true; setOneHand(true)
            elseif St.oneHandByHelper then local seat = myDriveSeat(); if seat and seat:GetAttribute("OneHanderActive") == true then setOneHand(false) else St.oneHandByHelper = false end end
            if not R.PoliceMode then return end
            local mode = lp:GetAttribute("PoliceMode") or "None"
            if S.QuestHelpers and wheelieing and questNeeds("HardPoliceTime") then if St.policeBefore == nil then St.policeBefore = mode end; if mode ~= "Hard" then R.PoliceMode:FireServer("Hard") end; return end
            local want = S.AntiPolice and "None" or St.policeBefore; St.policeBefore = nil
            if want and mode ~= want then R.PoliceMode:FireServer(want) end
        end
        local function respawnRide()
            if not R.SpawnRide or St.respawning or os.clock() - St.respawnedAt < 6 then return end
            St.respawnedAt, St.respawning = os.clock(), true
            local template = myRide() and myRide():GetAttribute("TemplateName") or "ScooterG2"
            task.spawn(function() pcall(function() R.SpawnRide:InvokeServer(template) end); St.respawning = false end)
        end
        local function stuck(seat)
            local wt = tonumber(lp:GetAttribute("WheelieTime")) or 0
            local still = St.lastCheckPos and (seat.Position - St.lastCheckPos).Magnitude < 0.5
            local earning = St.lastWheelieTime and wt > St.lastWheelieTime
            St.lastCheckPos, St.lastWheelieTime = seat.Position, wt
            if still and not earning then St.stuckSince = St.stuckSince or os.clock(); return os.clock() - St.stuckSince > 8 end
            St.stuckSince = nil; return false
        end

        task.spawn(function()
            while _G.RubenHubLoaded do
                local seat, hum = myDriveSeat(), getHum()
                local farming = S.AutoWheelie and not S.AutoDelivery and not St.collectingRain and not S.WheeliePulsar
                if farming and hum and not seat then respawnRide(); St.phase, St.phaseAt = "idle", os.clock()
                elseif farming and seat and hum then
                    if hum.SeatPart ~= seat then St.phase, St.phaseAt = "idle", os.clock(); local root = getRoot(); if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end; task.wait(0.4); pcall(function() seat:Sit(hum) end)
                    elseif St.phase == "idle" then streamAround(farmAnchor); placeRide(farmAnchor + Vector3.new(0, seatHeight(seat), 0)); St.phase, St.phaseAt = "place", os.clock()
                    elseif St.phase ~= "place" and stuck(seat) then St.stuckSince = nil; respawnRide(); St.phase, St.phaseAt = "idle", os.clock() end
                elseif St.phase ~= "idle" then St.phase, St.phaseAt = "idle", os.clock(); releaseRide() end
                questHelpers(); task.wait(0.3)
            end
        end)

        local lastPitch, pitchRate = 0, 0
        bind(RunService.Heartbeat:Connect(function(dt)
            if St.phase == "idle" or S.WheeliePulsar then return end
            local seat = myDriveSeat(); local values, input = chassis(); if not (seat and seated(seat) and values) then return end
            local t = os.clock() - St.phaseAt
            if St.phase == "place" then pad(input, Enum.KeyCode.ButtonR2, 0); if t > 1 then St.phase, St.phaseAt = "launch", os.clock() end; return end
            pad(input, Enum.KeyCode.Thumbstick1, 0.25)
            if St.phase == "launch" then values.Wheelie.Value = false; pad(input, Enum.KeyCode.ButtonR2, 0.7); pad(input, Enum.KeyCode.ButtonL2, 0); if t > 1.5 then lastPitch, pitchRate = 0, 0; St.phase, St.phaseAt = "wheelie", os.clock() end; return end
            if not values.Wheelie.Value then values.Wheelie.Value = true end
            local g = groundBelow(seat.Position); local pitch = math.deg(math.asin(math.clamp(seat.CFrame.LookVector:Dot(g and g.Normal or Vector3.yAxis), -1, 1)))
            pitchRate = pitchRate * 0.7 + (pitch - lastPitch) / math.max(dt, 1 / 120) * 0.3; lastPitch = pitch
            local u = math.clamp(0.45 + 0.04 * (S.WheelieAngle - pitch) - 0.012 * pitchRate, -1, 1)
            pad(input, Enum.KeyCode.ButtonR2, math.max(u, 0)); pad(input, Enum.KeyCode.ButtonL2, math.max(-u, 0))
            local centre = Vector3.new(farmAnchor.X, 0, farmAnchor.Z); local pos = Vector3.new(seat.Position.X, 0, seat.Position.Z)
            local vel = seat.AssemblyLinearVelocity; local flatVel = Vector3.new(vel.X, 0, vel.Z)
            if (pos - centre).Magnitude > farmRadius and flatVel.Magnitude > 5 and (pos - centre):Dot(flatVel) > 0 then local back = centre - flatVel.Unit * (farmRadius - 20); myRide():PivotTo(myRide():GetPivot() + (back - pos)) end
        end))

        -- PULSAR WHEELIE
        local function stopPulsarWheelie()
            if PW.align then pcall(function() PW.align:Destroy() end) end
            if PW.attach then pcall(function() PW.attach:Destroy() end) end
            if PW.seat and PW.seat.Parent then pcall(function() PW.seat.Anchored = false end) end
            PW.active, PW.seat, PW.attach, PW.align, PW.yaw = false, nil, nil, nil, 0
        end
        Hub.stopPulsarWheelie = stopPulsarWheelie

        local function startPulsarWheelie(seat)
            stopPulsarWheelie(); PW.active, PW.seat = true, seat; PW.yaw = select(2, seat.CFrame:ToOrientation())
            if not PW.ownerFixed then
                PW.ownerFixed = true
                pcall(function() local veh = seat:FindFirstAncestorOfClass("Model"); if veh then for _, p in ipairs(veh:GetDescendants()) do if p:IsA("BasePart") and p:CanSetNetworkOwnership() then p:SetNetworkOwner(lp) end end elseif seat:CanSetNetworkOwnership() then seat:SetNetworkOwner(lp) end end)
            end
            PW.attach = Instance.new("Attachment"); PW.attach.Parent = seat
            PW.align = Instance.new("AlignOrientation"); PW.align.Mode = Enum.OrientationAlignmentMode.OneAttachment; PW.align.Attachment0 = PW.attach
            PW.align.MaxTorque = 10000000; PW.align.MaxAngularVelocity = 20; PW.align.Responsiveness = 50; PW.align.Parent = seat
        end

        bind(RunService.Heartbeat:Connect(function(dt)
            if not S.WheeliePulsar then if PW.active then stopPulsarWheelie() end; return end
            if S.AutoWheelie then S.AutoWheelie = false end; if S.AutoTricks then S.AutoTricks = false end
            if St.phase ~= "idle" then St.phase, St.phaseAt = "idle", os.clock(); releaseRide() end
            local hum = getHum(); local seat = hum and hum.SeatPart; if not seat then if PW.active then stopPulsarWheelie() end; return end
            if not PW.active or PW.seat ~= seat or not PW.align or PW.align.Parent ~= seat then startPulsarWheelie(seat) end
            local steer = seat.SteerFloat or seat.Steer or 0; PW.yaw = PW.yaw - steer * 3.0 * dt
            PW.align.CFrame = CFrame.new(seat.Position) * CFrame.Angles(0, PW.yaw, 0) * CFrame.Angles(math.rad(S.WheeliePulsarAngle), 0, 0)
            if S.WheeliePulsarFreeze then seat.Anchored = true elseif seat.Anchored then seat.Anchored = false end
        end))

        -- TRICKS
        local SPIN_JUMP_VELOCITY = 15; local SPIN_ASCEND_TIME = 0.35; local SPIN_DESCENT_SPEED = -90
        local SPIN_REPEAT_DELAY = 0.35; local SPIN_MAX_DESCENT_TIME = 1.6; local SPIN_GROUND_CHECK_DISTANCE = 3.5
        local function setSpinPhase(n) Spin.phase, Spin.phaseAt = n, os.clock() end
        local function getSpinParts()
            local char = lp.Character; if not char then return nil end
            local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root or hum.Health <= 0 then return nil end
            local seat = hum.SeatPart
            if not seat and Hub.SeatLock and Hub.SeatLock.Part1 and Hub.SeatLock.Part1.Parent then seat = Hub.SeatLock.Part1 end
            if not seat and Spin.seat and Spin.seat.Parent then seat = Spin.seat end
            local body, vehicle = root, nil
            if seat then body = seat.AssemblyRootPart or seat; vehicle = seat:FindFirstAncestorOfClass("Model") end
            return char, hum, root, body, vehicle, seat
        end
        local function removeSpinAligner() if Spin.align then pcall(function() Spin.align:Destroy() end) end; if Spin.attach then pcall(function() Spin.attach:Destroy() end) end; Spin.align, Spin.attach, Spin.currentBody = nil, nil, nil end
        local function setSpinOrientation(body, angle)
            if not body or not body.Parent then return end
            if Spin.currentBody ~= body then
                removeSpinAligner(); Spin.currentBody = body; Spin.attach = Instance.new("Attachment"); Spin.attach.Parent = body
                Spin.align = Instance.new("AlignOrientation"); Spin.align.Mode = Enum.OrientationAlignmentMode.OneAttachment; Spin.align.Attachment0 = Spin.attach
                Spin.align.Responsiveness = 300; Spin.align.MaxTorque = 1e9; Spin.align.MaxAngularVelocity = 1e6; Spin.align.Parent = body
            end
            if Spin.mode == "Backflip" or Spin.mode == "Frontflip" then Spin.align.CFrame = CFrame.Angles(0, Spin.baseYaw, 0) * CFrame.Angles(angle, 0, 0) else Spin.align.CFrame = CFrame.Angles(0, angle, 0) end
        end
        local function setSpinVel(body, y) if body and body.Parent then body.AssemblyLinearVelocity = Vector3.new(0, y, 0) end end
        local function isSpinGrounded(char, body, vehicle)
            local filter = { char }; if vehicle then table.insert(filter, vehicle) end; if body and body.Parent then table.insert(filter, body) end
            local p = RaycastParams.new(); p.FilterType = Enum.RaycastFilterType.Exclude; p.FilterDescendantsInstances = filter
            return workspace:Raycast(body.Position, Vector3.new(0, -SPIN_GROUND_CHECK_DISTANCE, 0), p) ~= nil
        end
        local function releaseSpin(hum, body)
            removeSpinAligner()
            if hum and not Spin.cycleSeated then hum.AutoRotate = Spin.savedAutoRotate; hum.PlatformStand = Spin.savedPlatformStand end
            if body and body.Parent then body.AssemblyAngularVelocity = Vector3.zero; body.AssemblyLinearVelocity = Vector3.zero end
            Spin.cycleSeated = false
        end
        local function resetSpin() Spin.phase, Spin.totalAngle, Spin.seat = "Idle", 0, nil; removeSpinAligner() end
        local function stopSpin() local _, hum, _, body = getSpinParts(); releaseSpin(hum, body or Spin.currentBody); resetSpin(); Spin.idleAt = 0 end
        Hub.stopSpin = stopSpin
        local function chooseTrickMode() local m = S.TrickMode; if m == "Random" then m = (math.random() < 0.75) and "Spin" or "180" end; return m end
        local function startSpinCycle()
            local char, hum, _, body, _, seat = getSpinParts(); if not char then return false end
            if seat and not Spin.ownerFixed then
                Spin.ownerFixed = true
                pcall(function() local veh = seat:FindFirstAncestorOfClass("Model"); if veh then for _, p in ipairs(veh:GetDescendants()) do if p:IsA("BasePart") and p:CanSetNetworkOwnership() then p:SetNetworkOwner(lp) end end elseif seat:CanSetNetworkOwnership() then seat:SetNetworkOwner(lp) end end)
            end
            Spin.cycleSeated = seat ~= nil
            if not Spin.cycleSeated then Spin.savedAutoRotate = hum.AutoRotate; Spin.savedPlatformStand = hum.PlatformStand; hum.AutoRotate = false; hum.PlatformStand = true end
            Spin.mode = chooseTrickMode(); Spin.totalAngle = 0; Spin.baseYaw = select(2, body.CFrame:ToOrientation()); Spin.seat = seat
            if Spin.mode == "Spin" then Spin.targetAngle = math.rad(1440); Spin.rate = math.rad(720) * (S.TrickSpeed or 1)
            elseif Spin.mode == "Backflip" then Spin.targetAngle = math.rad(360); Spin.rate = math.rad(540) * (S.TrickSpeed or 1)
            elseif Spin.mode == "Frontflip" then Spin.targetAngle = math.rad(-360); Spin.rate = math.rad(-540) * (S.TrickSpeed or 1)
            else Spin.targetAngle = math.rad(180); Spin.rate = math.rad(540) * (S.TrickSpeed or 1) end
            setSpinOrientation(body, 0); setSpinVel(body, SPIN_JUMP_VELOCITY); setSpinPhase("Ascend"); return true
        end
        local function updateSpin(dt)
            if not S.AutoTricks or S.Fly or S.AutoWheelie or S.WheeliePulsar then if Spin.phase ~= "Idle" then stopSpin() end; return end
            local char, hum, _, body, vehicle, seat = getSpinParts()
            if not char or not seat then if Spin.phase ~= "Idle" then releaseSpin(nil, Spin.currentBody); resetSpin() end; return end
            local now, elapsed = os.clock(), os.clock() - Spin.phaseAt
            if Spin.phase == "Idle" then if now - Spin.idleAt >= SPIN_REPEAT_DELAY then startSpinCycle() end
            elseif Spin.phase == "Ascend" then setSpinVel(body, SPIN_JUMP_VELOCITY); setSpinOrientation(body, 0); if elapsed >= SPIN_ASCEND_TIME then setSpinPhase("Spin") end
            elseif Spin.phase == "Spin" then setSpinVel(body, 0); Spin.totalAngle = Spin.totalAngle + Spin.rate * dt; if math.abs(Spin.totalAngle) >= math.abs(Spin.targetAngle) then Spin.totalAngle = Spin.targetAngle; setSpinPhase("Descend") end; setSpinOrientation(body, Spin.totalAngle)
            elseif Spin.phase == "Descend" then setSpinVel(body, SPIN_DESCENT_SPEED); setSpinOrientation(body, Spin.targetAngle); if isSpinGrounded(char, body, vehicle) or elapsed >= SPIN_MAX_DESCENT_TIME then setSpinPhase("Landed") end
            elseif Spin.phase == "Landed" then setSpinVel(body, 0); if elapsed >= 0.05 then releaseSpin(hum, body); Spin.totalAngle = 0; Spin.idleAt = now; setSpinPhase("Idle") end end
        end
        if R.TrickState then bind(R.TrickState.OnClientEvent:Connect(function(kind, name, amount) if kind == "landed" and type(amount) == "number" and amount > 0 then St.session.lastTrick = name or "trick" end end)) end
        bind(RunService.Heartbeat:Connect(function(dt)
            local hum = getHum(); local seat = hum and hum.SeatPart
            if (S.AutoTricks or S.AutoWheelie or S.WheeliePulsar) and seat and S.SeatLock then lockSeat()
            elseif Hub.SeatLock and not (S.AutoTricks or S.AutoWheelie or S.WheeliePulsar) then unlockSeat() end
            if (S.AutoWheelie or S.AutoTricks) and hum and hum:GetState() == Enum.HumanoidStateType.Physics then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
            if S.AutoTricks then updateSpin(dt) elseif Spin.phase ~= "Idle" then stopSpin() end
        end))
    end
    setupFarm()

    -- =====================================================================
    -- ESP
    -- =====================================================================
    local function setupESP()
        Hub.Esp.folder = Instance.new("Folder"); Hub.Esp.folder.Name = "RubenESP"
        local S, tags = Hub.Settings, Hub.Esp.tags
        local function espTag(target, adornee)
            local tag = tags[target]
            if not tag then
                local gui = new("BillboardGui", { Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(200, 34), StudsOffset = Vector3.new(0, 3, 0), Parent = Hub.Esp.folder })
                local label = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = 0.4, Parent = gui })
                local hl = new("Highlight", { Adornee = target, FillTransparency = 0.75, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = Hub.Esp.folder })
                tag = { gui = gui, label = label, highlight = hl }; tags[target] = tag
            end
            tag.seen = true; return tag
        end
        local function clear(keep) for target, tag in pairs(tags) do if not (keep and tag.seen and target.Parent) then tag.gui:Destroy(); tag.highlight:Destroy(); tags[target] = nil end; tag.seen = false end end
        local function paint(tag, color, name, dist)
            local text = S.ESPNames and name or ""; if S.ESPDistance then text = (text == "" and "" or text .. "  ") .. string.format("[%dm]", dist // 1) end
            tag.label.Text = text; tag.label.TextColor3 = color; tag.highlight.FillColor = color; tag.highlight.OutlineColor = color; tag.highlight.Enabled = S.ESPBoxes
        end
        task.spawn(function()
            while _G.RubenHubLoaded do
                local root = getRoot()
                if root and (S.PlayerESP or S.RideESP or S.PoliceESP or S.CustomerESP or S.DropESP) then
                    Hub.Esp.folder.Parent = guiParent; local maxD = S.ESPMaxDistance
                    local pC = Color3.fromHSV(S.ESPPlayerColor / 360, 0.85, 1); local rC = Color3.fromHSV(S.ESPRideColor / 360, 0.85, 1)
                    if S.PlayerESP then for _, p in ipairs(Players:GetPlayers()) do local head = p ~= lp and p.Character and p.Character:FindFirstChild("Head"); local dist = head and (head.Position - root.Position).Magnitude; if head and (maxD == 0 or dist <= maxD) then paint(espTag(p.Character, head), pC, p.DisplayName, dist) end end end
                    if S.RideESP then for _, r in ipairs(workspace.Rides:GetChildren()) do local oid = r:GetAttribute("OwnerUserId"); local body = oid and oid ~= lp.UserId and r:FindFirstChild("DriveSeat", true); local dist = body and (body.Position - root.Position).Magnitude; if body and (maxD == 0 or dist <= maxD) then paint(espTag(r, body), rC, string.format("%s's %s", r.Name:gsub("^Ride_", ""), tostring(r:GetAttribute("TemplateName") or "ride")), dist) end end end
                    local function mark(target, adornee, color, name) local dist = (adornee.Position - root.Position).Magnitude; if maxD == 0 or dist <= maxD then paint(espTag(target, adornee), color, name, dist) end end
                    if S.PoliceESP then local police = workspace:FindFirstChild("PoliceNPCs"); for _, car in ipairs(police and police:GetChildren() or {}) do local body = car:FindFirstChild("DriveSeat", true) or car:FindFirstChildWhichIsA("BasePart", true); if body then mark(car, body, Color3.fromRGB(70, 140, 255), "Police") end end end
                    if S.CustomerESP then local c = workspace:FindFirstChild("DeliveryCustomer"); local hrp = c and c:FindFirstChild("HumanoidRootPart"); if hrp then mark(c, hrp, Color3.fromRGB(255, 205, 40), "Customer") end end
                    if S.DropESP then local drops = workspace:FindFirstChild("MoneyRain"); for _, d in ipairs(drops and drops:GetChildren() or {}) do if d:IsA("BasePart") and d.Transparency < 1 then mark(d, d, Color3.fromRGB(90, 220, 110), "$") end end end
                    clear(true)
                else clear(false) end
                task.wait(0.3)
            end
        end)
    end
    setupESP()

    -- =====================================================================
    -- ANTI-POLICE
    -- =====================================================================
    local function setupPolicePush()
        local S, P, R, St = Hub.Settings, Hub.Police, Hub.Remotes, Hub.State
        local function installHook()
            if P.hookOn or not R.PoliceHit or not (getrawmetatable and newcclosure and getnamecallmethod) then return end
            pcall(function()
                local mt = getrawmetatable(game); P.hookMt, P.hookOld = mt, mt.__namecall; setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...) if self == R.PoliceHit and getnamecallmethod() == "FireServer" then return end; return P.hookOld(self, ...) end)
                setreadonly(mt, true); P.hookOn = true
            end)
        end
        Hub.removeHook = function() if not P.hookOn then return end; pcall(function() setreadonly(P.hookMt, false); rawset(P.hookMt, "__namecall", P.hookOld); setreadonly(P.hookMt, true) end); P.hookOn = false end
        local function refresh() P.models = {}; local folder = workspace:FindFirstChild("PoliceNPCs"); if not folder then return end; for _, obj in ipairs(folder:GetChildren()) do if obj:IsA("Model") then P.models[#P.models + 1] = obj end end end
        local function push()
            local char = lp.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
            if os.clock() - P.scanAt > 2 then P.scanAt = os.clock(); refresh() end
            local ppos = root.Position
            for _, m in ipairs(P.models) do
                if m.Parent then
                    local primary = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if primary then
                        local delta = primary.Position - ppos; local flat = Vector3.new(delta.X, 0, delta.Z); local dist = flat.Magnitude
                        if dist < 180 then P.stuck[m] = (P.stuck[m] or 0) + 1; if P.stuck[m] >= 8 then pcall(function() m.Parent = nil end); P.stuck[m] = nil end
                        else P.stuck[m] = 0 end
                        if dist < 450 then
                            local dir = dist > 0.5 and flat.Unit or Vector3.new(math.cos(math.random() * math.pi * 2), 0, math.sin(math.random() * math.pi * 2))
                            local pivot = m:GetPivot(); local rot = pivot - pivot.Position; local target = ppos + dir * 520 + Vector3.new(0, 200, 0)
                            pcall(function() m:PivotTo(CFrame.new(target) * rot) end)
                            for _, x in ipairs(m:GetDescendants()) do if x:IsA("BasePart") then x.CanCollide = false; x.CanTouch = false; x.Massless = true; x.AssemblyLinearVelocity = dir * 350 + Vector3.new(0, 120, 0) end end
                            St.session.pushed += 1
                        end
                    end
                end
            end
        end
        bind(RunService.Heartbeat:Connect(function()
            if S.AntiPolice then if not P.hookOn then installHook() end; if os.clock() - St.lastPush > 0.08 then St.lastPush = os.clock(); pcall(push) end
            elseif P.hookOn then Hub.removeHook() end
        end))
    end
    setupPolicePush()

    -- =====================================================================
    -- SPEED
    -- =====================================================================
    local function setupSpeed()
        local S = Hub.Settings
        bind(RunService.Heartbeat:Connect(function(dt)
            local seat = myDriveSeat(); local hum = getHum(); if not (seat and hum and hum.SeatPart == seat) then return end
            local body = seat.AssemblyRootPart or seat; if not body then return end
            local W = UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up)
            local vel = body.AssemblyLinearVelocity; local look = seat.CFrame.LookVector; local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude < 0.1 then return end; flat = flat.Unit
            if S.RideSpeedBoost > 0 and W then body.AssemblyLinearVelocity = body.AssemblyLinearVelocity + flat * S.RideSpeedBoost * dt end
            if S.SpeedUncap and W then body.AssemblyLinearVelocity = flat * 300 + Vector3.new(0, vel.Y * 0.9, 0) end
            if S.SpeedLimit > 0 then
                local v2 = body.AssemblyLinearVelocity; local flatV = Vector3.new(v2.X, 0, v2.Z)
                if flatV.Magnitude > S.SpeedLimit then local scaled = flatV.Unit * S.SpeedLimit; body.AssemblyLinearVelocity = Vector3.new(scaled.X, v2.Y * 0.9, scaled.Z) end
            end
        end))
    end
    setupSpeed()

    -- =====================================================================
    -- MOVEMENT
    -- =====================================================================
    local function setupMovement()
        local S = Hub.Settings
        bind(RunService.Stepped:Connect(function() if not S.Noclip then return end; local c = lp.Character; if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then Hub.NoclipSaved[p] = true; p.CanCollide = false end end end))
        Hub.restoreNoclip = function() for p in pairs(Hub.NoclipSaved) do if p.Parent then p.CanCollide = true end end; Hub.NoclipSaved = {} end
        bind(UIS.JumpRequest:Connect(function() if not S.InfJump then return end; local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end))
        bind(RunService.Heartbeat:Connect(function()
            local h, root = getHum(), getRoot(); if not (h and root) then return end
            h.WalkSpeed = S.WalkSpeed; h.UseJumpPower = false; h.JumpHeight = S.JumpHeight; h.HipHeight = S.HipHeight; root.Anchored = S.Anchor
            if S.Fly then
                h.PlatformStand = true; local cf = workspace.CurrentCamera.CFrame; local dir = Vector3.zero; local K = Enum.KeyCode
                if UIS:IsKeyDown(K.W) then dir += cf.LookVector end; if UIS:IsKeyDown(K.S) then dir -= cf.LookVector end; if UIS:IsKeyDown(K.D) then dir += cf.RightVector end; if UIS:IsKeyDown(K.A) then dir -= cf.RightVector end
                if dir.Magnitude == 0 then dir = h.MoveDirection end
                if UIS:IsKeyDown(K.Space) then dir += Vector3.yAxis end; if UIS:IsKeyDown(K.LeftControl) then dir -= Vector3.yAxis end
                root.AssemblyLinearVelocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * S.FlySpeed
            elseif h.PlatformStand and not S.Fly then h.PlatformStand = false end
            workspace.CurrentCamera.FieldOfView = S.FOV
        end))
        local function applyDesync() if Hub.DesyncState then return end; pcall(function() local root = getRoot(); if not root or not getrawmetatable then return end; local mt = getrawmetatable(root); local old = mt.__index; setreadonly(mt, false); mt.__index = newcclosure(function(self, key) local v = old(self, key); if key == "CFrame" and not checkcaller() then local ok, name = pcall(function() local sc = getcallingscript and getcallingscript(); return sc and sc.Name end); if ok and (name == "CameraModule" or name == "FirstPersonCamera") then return v * CFrame.Angles(0, math.rad(90), 0) end end; return v end); setreadonly(mt, true); Hub.DesyncState = { mt = mt, old = old } end) end
        Hub.removeDesync = function() if not Hub.DesyncState then return end; pcall(function() setreadonly(Hub.DesyncState.mt, false); rawset(Hub.DesyncState.mt, "__index", Hub.DesyncState.old); setreadonly(Hub.DesyncState.mt, true) end); Hub.DesyncState = nil end
        bind(RunService.Heartbeat:Connect(function() if S.Desync then if not Hub.DesyncState then applyDesync() end elseif Hub.DesyncState then Hub.removeDesync() end end))
    end
    setupMovement()

    -- =====================================================================
    -- MISC
    -- =====================================================================
    local function setupMisc()
        local S = Hub.Settings
        bind(lp.Idled:Connect(function() if not S.AntiAFK then return end; pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end))
        local function quickPrompt(p) if not p:IsA("ProximityPrompt") then return end; if Hub.PromptSaved[p] == nil then Hub.PromptSaved[p] = p.HoldDuration end; p.HoldDuration = 0 end
        Hub.restorePrompt = function() for p, v in pairs(Hub.PromptSaved) do if p.Parent then p.HoldDuration = v end end; Hub.PromptSaved = {} end
        bind(workspace.DescendantAdded:Connect(function(d) if S.QuickInteract then quickPrompt(d) end end))
        Hub.restoreHidden = function() for p in pairs(Hub.HiddenParts) do if p.Parent then p.LocalTransparencyModifier = 0 end end; Hub.HiddenParts = {} end
        task.spawn(function() while _G.RubenHubLoaded do if S.HidePlayers then for _, p in ipairs(Players:GetPlayers()) do if p ~= lp and p.Character then for _, d in ipairs(p.Character:GetDescendants()) do if d:IsA("BasePart") or d:IsA("Decal") then Hub.HiddenParts[d] = true; d.LocalTransparencyModifier = 1 end end end end; task.wait(0.5) end end)
        bind(RunService.Heartbeat:Connect(function() RunService:Set3dRenderingEnabled(not S.BlackScreen) end))
        bind(RunService.Heartbeat:Connect(function() if setfpscap then setfpscap(S.FPSCap) end end))
        local LAG_FX = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function killFx(d) if LAG_FX[d.ClassName] and d.Enabled then Hub.LagFx[d] = true; d.Enabled = false end end
        Hub.restoreLag = function() if Hub.LagShadows ~= nil then Lighting.GlobalShadows = Hub.LagShadows; Hub.LagShadows = nil end; for d in pairs(Hub.LagFx) do if d.Parent then d.Enabled = true end end; Hub.LagFx = {} end
        bind(RunService.Heartbeat:Connect(function() if S.AntiLag then if Hub.LagShadows == nil then Hub.LagShadows = Lighting.GlobalShadows end; Lighting.GlobalShadows = false; for _, d in ipairs(workspace:GetDescendants()) do killFx(d) end end end))
        bind(workspace.DescendantAdded:Connect(function(d) if S.AntiLag then killFx(d) end end))
        Hub.restoreFb = function() if not Hub.FbSaved then return end; Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd = Hub.FbSaved.Brightness, Hub.FbSaved.ClockTime, Hub.FbSaved.FogEnd; Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = Hub.FbSaved.GlobalShadows, Hub.FbSaved.Ambient, Hub.FbSaved.OutdoorAmbient; Hub.FbSaved = nil end
        bind(RunService.Heartbeat:Connect(function() if S.Fullbright then if not Hub.FbSaved then Hub.FbSaved = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient } end; Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e9; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.new(1, 1, 1); Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end end))
    end
    setupMisc()

    -- =====================================================================
    -- SMOOTH CAMERA v2
    -- =====================================================================
    local function setupSmoothCamera()
        local S = Hub.Settings; local Cam = Hub.Camera; local cam = workspace.CurrentCamera
        Cam.targetMin, Cam.targetMax = S.CameraWalkMin, S.CameraWalkMax
        Cam.origMin, Cam.origMax = cam.CameraMinZoomDistance, cam.CameraMaxZoomDistance
        local function installCameraHook()
            if Cam.hookActive then return end
            if not (getrawmetatable and newcclosure and setreadonly) then return end
            pcall(function()
                local mt = getrawmetatable(cam); Cam.oldNewIndex, Cam.oldIndex = mt.__newindex, mt.__index; setreadonly(mt, false)
                mt.__newindex = newcclosure(function(self, key, value)
                    if self == cam and Cam.rideActive then
                        if key == "CameraSubject" then local h = getHum(); if h then Cam.oldNewIndex(self, key, h); return end end
                        if key == "CameraMinZoomDistance" or key == "CameraMaxZoomDistance" then return end
                    end
                    Cam.oldNewIndex(self, key, value)
                end)
                mt.__index = newcclosure(function(self, key) if self == cam and Cam.rideActive and key == "CameraSubject" then local h = getHum(); if h then return h end end; return Cam.oldIndex(self, key) end)
                setreadonly(mt, true); Cam.hookActive = true
            end)
        end
        Hub.removeCameraHook = function()
            if not Cam.hookActive then return end
            pcall(function() local mt = getrawmetatable(cam); setreadonly(mt, false); rawset(mt, "__newindex", Cam.oldNewIndex); rawset(mt, "__index", Cam.oldIndex); setreadonly(mt, true) end)
            Cam.hookActive = false
        end
        RunService:BindToRenderStep("RubenSmoothCam", Enum.RenderPriority.Camera.Value + 10, function(dt)
            if not S.SmoothCamera then if Cam.rideActive then Cam.rideActive = false; Hub.removeCameraHook() end; return end
            local hum = getHum(); if not hum then return end
            local nowRiding = hum.SeatPart ~= nil and (hum.SeatPart:IsA("VehicleSeat") or hum.SeatPart.Name == "DriveSeat")
            if nowRiding and not Cam.rideActive then
                Cam.rideActive = true; Cam.targetMin, Cam.targetMax = S.CameraRideMin, S.CameraRideMax
                installCameraHook(); pcall(function() cam.CameraSubject = hum end)
            elseif not nowRiding and Cam.rideActive then
                Cam.rideActive = false; Cam.targetMin, Cam.targetMax = S.CameraWalkMin, S.CameraWalkMax
                task.delay(0.3, function() Hub.removeCameraHook() end)
            end
            if Cam.rideActive then
                if cam.CameraSubject ~= hum then pcall(function() cam.CameraSubject = hum end) end
                local a = math.min(1, (1 / math.max(S.SmoothCameraDuration, 0.05)) * dt)
                local cmin, cmax = cam.CameraMinZoomDistance or 0, cam.CameraMaxZoomDistance or 20
                pcall(function() cam.CameraMinZoomDistance = cmin + (Cam.targetMin - cmin) * a; cam.CameraMaxZoomDistance = cmax + (Cam.targetMax - cmax) * a end)
            end
        end)
        bind(lp.CharacterAdded:Connect(function() Cam.rideActive = false; Hub.removeCameraHook() end))
        Hub.resetCamera = function() Cam.rideActive = false; Hub.removeCameraHook(); pcall(function() cam.CameraMinZoomDistance = Cam.origMin; cam.CameraMaxZoomDistance = Cam.origMax; local h = getHum(); if h then cam.CameraSubject = h end end) end
    end
    setupSmoothCamera()

    -- =====================================================================
    -- UI
    -- =====================================================================
    local function buildUI()
        local S, St, R = Hub.Settings, Hub.State, Hub.Remotes
        local MB1, MOVE, TOUCH = Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch
        local Theme = {
            Bg = Color3.fromRGB(16, 18, 27), Panel = Color3.fromRGB(24, 27, 38), Panel2 = Color3.fromRGB(34, 38, 52),
            Border = Color3.fromRGB(42, 48, 66), Accent = Color3.fromRGB(91, 140, 255), AccentHi = Color3.fromRGB(130, 170, 255),
            Accent2 = Color3.fromRGB(168, 110, 255), Text = Color3.fromRGB(238, 242, 252), TextSub = Color3.fromRGB(150, 158, 180),
            TextDim = Color3.fromRGB(90, 98, 120)
        }
        local FB, FM, F = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham
        local function grad(p, c1, c2, rot) local g = new("UIGradient", { Parent = p }); g.Color = ColorSequence.new(c1, c2); if rot then g.Rotation = rot end; return g end
        local ui = new("ScreenGui", { Name = "RubenHubUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = guiParent })
        local WIN_W, WIN_H = 640, 520
        local glow = new("Frame", { Size = UDim2.fromOffset(WIN_W + 20, WIN_H + 20), Position = UDim2.new(0.5, -(WIN_W + 20) / 2, 0.5, -(WIN_H + 20) / 2), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 0, Parent = ui }); corner(glow, 22); grad(glow, Theme.Accent, Theme.Accent2, 45)
        local win = new("Frame", { Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Active = true, Parent = ui }); corner(win, 16); new("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = win })
        local topLine = new("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = win }); grad(topLine, Theme.Accent, Theme.Accent2, 0)
        local header = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, Active = true, ZIndex = 3, Parent = win })
        local logoBox = new("Frame", { Position = UDim2.fromOffset(20, 14), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4, Parent = header }); corner(logoBox, 8); grad(logoBox, Theme.Accent, Theme.Accent2, 45)
        new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 15, TextColor3 = Theme.Text, Text = "R", ZIndex = 5, Parent = logoBox })
        new("TextLabel", { Position = UDim2.fromOffset(58, 12), Size = UDim2.new(0, 300, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = "RUBEN-HUB", ZIndex = 4, Parent = header })
        new("TextLabel", { Position = UDim2.fromOffset(60, 34), Size = UDim2.new(0, 300, 0, 14), BackgroundTransparency = 1, Font = F, TextSize = 9, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Text = "KUKIRIN LIFE", ZIndex = 4, Parent = header })
        local function topBtn(text, x, accent)
            local b = new("TextButton", { Text = text, Font = FB, TextSize = 15, AutoButtonColor = false, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, x, 0, 14), BackgroundColor3 = accent and Theme.Accent or Theme.Panel2, TextColor3 = Theme.Text, ZIndex = 4, Parent = header })
            corner(b, 8); new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = b }); return b
        end
        local minBtn = topBtn("−", -70, false); local closeBtn = topBtn("×", -36, true)
        new("Frame", { Size = UDim2.new(1, -40, 0, 1), Position = UDim2.fromOffset(20, 56), BackgroundColor3 = Theme.Border, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = win })
        local body = new("Frame", { Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), BackgroundTransparency = 1, ZIndex = 3, Parent = win })
        local sidebar = new("Frame", { Position = UDim2.fromOffset(14, 10), Size = UDim2.new(0, 150, 1, -24), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Parent = body }); corner(sidebar, 12); new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.35, Parent = sidebar })
        new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar }); new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sidebar })
        local pages = new("Frame", { Position = UDim2.fromOffset(178, 10), Size = UDim2.new(1, -192, 1, -24), BackgroundTransparency = 1, Parent = body })
        local tabs, sideOrder, currentTab = {}, 0, nil
        local function selectTab(sel) currentTab = sel; for _, t in ipairs(tabs) do local on = t == sel; t.page.Visible = on; tween(t.btn, { BackgroundColor3 = on and Theme.Accent or Theme.Panel2, TextColor3 = on and Theme.Text or Theme.TextSub }, 0.16); if t.bar then t.bar.Visible = on end end end
        local function SideHeader(text) sideOrder += 1; new("TextLabel", { Text = text, Font = FB, TextSize = 9, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = sideOrder, Parent = sidebar, TextColor3 = Theme.TextDim }) end
        local function Tab(name)
            sideOrder += 1; local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = sideOrder, Parent = sidebar })
            local bar = new("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, -4, 0.5, -9), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false, Parent = wrap }); corner(bar, 2); grad(bar, Theme.Accent, Theme.Accent2, 90)
            local btn = new("TextButton", { Text = "   " .. name, Font = FB, TextSize = 12, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Panel2, TextColor3 = Theme.TextSub, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap }); corner(btn, 8)
            local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = pages, ScrollBarImageColor3 = Theme.Accent })
            new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page }); new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = page })
            local t = { btn = btn, page = page, order = 0, bar = bar }; btn.MouseButton1Click:Connect(function() selectTab(t) end); table.insert(tabs, t); return t
        end
        local function row(t, h) t.order += 1; local r = new("Frame", { Size = UDim2.new(1, 0, 0, h or 38), BorderSizePixel = 0, BackgroundColor3 = Theme.Panel2, LayoutOrder = t.order, Parent = t.page }); corner(r, 8); new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Parent = r }); return r end
        local function lbl(r, text) return new("TextLabel", { Text = text, Font = FM, TextSize = 12, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -24, 0, 38), TextXAlignment = Enum.TextXAlignment.Left, Parent = r, TextColor3 = Theme.Text }) end
        local function Section(t, text) t.order += 1; new("TextLabel", { Text = text:upper(), Font = FB, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = t.order, Parent = t.page, TextColor3 = Theme.AccentHi }) end
        local function Note(t, text) t.order += 1; return new("TextLabel", { Text = text, Font = F, TextSize = 10, BackgroundTransparency = 1, TextWrapped = true, Size = UDim2.new(1, 0, 0, 28), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = t.order, Parent = t.page, TextColor3 = Theme.TextDim }) end
        local function Toggle(t, text, key)
            local r = row(t); lbl(r, text); local sw = new("Frame", { Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -56, 0.5, -11), BackgroundColor3 = Theme.Border, Parent = r }); corner(sw, 11)
            local knob = new("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Theme.TextSub, Parent = sw }); corner(knob, 8)
            local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = r })
            local function render() local on = S[key]; tween(sw, { BackgroundColor3 = on and Theme.Accent or Theme.Border }, 0.16); tween(knob, { Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = on and Theme.Text or Theme.TextSub }, 0.16) end
            hit.MouseButton1Click:Connect(function() S[key] = not S[key]; render() end); render(); table.insert(Hub.UI.refreshers, render)
        end
        local function Slider(t, text, key, mn, mx, step, fmt)
            local r = row(t, 56); lbl(r, text)
            local value = new("TextLabel", { Font = FB, TextSize = 11, BackgroundTransparency = 1, Position = UDim2.new(1, -112, 0, 0), Size = UDim2.fromOffset(100, 38), TextXAlignment = Enum.TextXAlignment.Right, Parent = r, TextColor3 = Theme.AccentHi })
            local bar = new("Frame", { Size = UDim2.new(1, -28, 0, 4), Position = UDim2.fromOffset(14, 40), BorderSizePixel = 0, Parent = r, BackgroundColor3 = Theme.Border }); corner(bar, 2)
            local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = bar, BackgroundColor3 = Theme.Accent }); corner(fill, 2); grad(fill, Theme.Accent, Theme.Accent2, 0)
            local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Parent = bar }); corner(knob, 7)
            local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0.5, -12), Parent = bar })
            local function render() local v = S[key]; local rel = math.clamp((v - mn) / (mx - mn), 0, 1); fill.Size = UDim2.fromScale(rel, 1); knob.Position = UDim2.new(rel, 0, 0.5, 0); value.Text = fmt(v) end
            local dragging = false
            local function update(x) local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); S[key] = math.clamp(math.floor((mn + a * (mx - mn)) / step + 0.5) * step, mn, mx); render() end
            hit.InputBegan:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = true; update(i.Position.X) end end)
            bind(UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == MOVE or i.UserInputType == TOUCH) then update(i.Position.X) end end))
            bind(UIS.InputEnded:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = false end end))
            render(); table.insert(Hub.UI.refreshers, render)
        end
        local function Cycle(t, text, key, opts)
            local r = row(t); lbl(r, text); local b = new("TextButton", { Font = FB, TextSize = 11, AutoButtonColor = false, Size = UDim2.fromOffset(120, 26), Position = UDim2.new(1, -134, 0.5, -13), Parent = r, BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text }); corner(b, 7)
            local function render() b.Text = tostring(S[key]) end
            b.MouseButton1Click:Connect(function() local idx = table.find(opts, S[key]) or 0; S[key] = opts[idx % #opts + 1]; render() end); render(); table.insert(Hub.UI.refreshers, render)
        end
        local function Button(t, text, role, cb)
            t.order += 1; local b = new("TextButton", { Text = text, Font = FB, TextSize = 12, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = t.order, Parent = t.page, BackgroundColor3 = role == "Accent" and Theme.Accent or Theme.Panel, TextColor3 = Theme.Text }); corner(b, 8)
            new("UIStroke", { Color = role == "Accent" and Theme.AccentHi or Theme.Border, Thickness = 1, Transparency = 0.3, Parent = b })
            b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.15 }, 0.1) end); b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 0 }, 0.1) end); b.MouseButton1Click:Connect(cb)
        end
        local function Keybind(t, text, key)
            local r = row(t); lbl(r, text); local b = new("TextButton", { Font = FB, TextSize = 11, AutoButtonColor = false, Size = UDim2.fromOffset(120, 26), Position = UDim2.new(1, -134, 0.5, -13), Parent = r, BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text }); corner(b, 7)
            local listening = false; local function render() b.Text = listening and "Press key..." or tostring(S[key]) end
            b.MouseButton1Click:Connect(function() listening = not listening; Hub.UI.bindCapture = listening; render() end)
            bind(UIS.InputBegan:Connect(function(i) if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end; listening = false; S[key] = i.KeyCode.Name; render(); task.defer(function() Hub.UI.bindCapture = false end) end))
            render(); table.insert(Hub.UI.refreshers, render)
        end

        SideHeader("FARM")
        local farmTab = Tab("Farm")
        Section(farmTab, "Rewards"); Toggle(farmTab, "Auto claim quests", "AutoQuests"); Toggle(farmTab, "Auto claim achievements", "AutoAchievements"); Toggle(farmTab, "Auto daily reward", "AutoDaily")
        Section(farmTab, "Delivery"); Toggle(farmTab, "Auto delivery", "AutoDelivery"); local deliveryNote = Note(farmTab, "")
        Section(farmTab, "Wheelie (Cookies)"); Toggle(farmTab, "Auto wheelie", "AutoWheelie"); Toggle(farmTab, "Quest helpers", "QuestHelpers"); Slider(farmTab, "Wheelie angle", "WheelieAngle", 20, 60, 1, function(v) return math.floor(v + 0.5) .. "°" end); local areaNote = Note(farmTab, "Default: open field."); Button(farmTab, "Set wheelie area here", "Row", function() local seat = myDriveSeat(); local from = (seat and seat.Position) or (getRoot() and getRoot().Position); local g = from and groundBelow(from, 30); if not g then areaNote.Text = "Stand on ground." return end; local clear = Hub.clearRadius(g.Position); if clear < 140 then areaNote.Text = string.format("Too cramped (%d).", clear) return end; Hub.setWheelieArea(g.Position, clear); areaNote.Text = string.format("Area set (%d).", clear) end); Button(farmTab, "Use default area", "Row", function() Hub.setWheelieArea(Vector3.new(1100, 56.4, -1500), 320); areaNote.Text = "Default." end)
        Section(farmTab, "Wheelie (Pulsar)"); Toggle(farmTab, "Auto wheelie (Pulsar)", "WheeliePulsar"); Slider(farmTab, "Pulsar wheelie angle", "WheeliePulsarAngle", -80, 80, 1, function(v) return math.floor(v + 0.5) .. "°" end); Toggle(farmTab, "Freeze position", "WheeliePulsarFreeze")
        Section(farmTab, "Tricks (Pulsar)"); Toggle(farmTab, "Auto tricks", "AutoTricks"); Cycle(farmTab, "Trick mode", "TrickMode", { "Random", "Spin", "Backflip", "Frontflip", "180" }); Slider(farmTab, "Trick speed", "TrickSpeed", 0.3, 1.5, 0.1, function(v) return string.format("x%.1f", v) end)
        Section(farmTab, "Rides"); Toggle(farmTab, "Auto buy faster", "AutoBuyRide"); Toggle(farmTab, "Collect money rain", "MoneyRain"); local statsCash = Note(farmTab, ""); local statsMore = Note(farmTab, ""); task.spawn(function() while _G.RubenHubLoaded do local cash = tonumber(lp:GetAttribute("Cash")) or 0; local elapsed = os.clock() - St.session.startedAt; local earned = cash - St.session.startCash; statsCash.Text = string.format("Cash $%s  ·  +$%s  ·  $%s/h", math.floor(cash), math.floor(earned), math.floor(earned / math.max(elapsed, 1) * 3600)); statsMore.Text = string.format("Lvl %s  ·  Q %d  ·  A %d  ·  D %d  ·  Del %d (+$%d)", tostring(lp:GetAttribute("Level") or "?"), St.session.quests, St.session.achievements, St.session.daily, St.session.deliveries, St.session.deliveryCash); deliveryNote.Text = S.AutoDelivery and St.deliveryStatus or ""; task.wait(1) end end)

        local rideTab = Tab("Ride")
        Section(rideTab, "Spawn"); local rideDisplays, rideNameByDisplay = {}, {}; for _, s in ipairs(RS.Scooters:GetChildren()) do local d = s.Name:gsub("^Scooter", ""); table.insert(rideDisplays, d); rideNameByDisplay[d] = s.Name end; table.sort(rideDisplays); if #rideDisplays == 0 then rideDisplays = { "G2" }; rideNameByDisplay["G2"] = "ScooterG2" end; if S.QuickRide == "" or not rideNameByDisplay[S.QuickRide] then S.QuickRide = rideDisplays[1] end; Cycle(rideTab, "Ride", "QuickRide", rideDisplays); Button(rideTab, "Spawn selected", "Row", function() local n = rideNameByDisplay[S.QuickRide]; if R.SpawnRide and n then pcall(function() R.SpawnRide:InvokeServer(n) end) end end); Button(rideTab, "Respawn current", "Row", function() if R.SpawnRide then pcall(function() R.SpawnRide:InvokeServer(myRide() and myRide():GetAttribute("TemplateName")) end) end end); Button(rideTab, "Sit on my ride", "Row", function() local seat, hum = myDriveSeat(), getHum(); if seat and hum then local root = getRoot(); if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end; task.wait(0.3); pcall(function() seat:Sit(hum) end) end end); if R.GoToDealership then Button(rideTab, "Go to dealership", "Row", function() pcall(function() R.GoToDealership:InvokeServer() end) end) end
        Section(rideTab, "Speed"); Slider(rideTab, "Speed boost", "RideSpeedBoost", 0, 300, 10, function(v) return v == 0 and "Off" or (math.floor(v) .. " st/s²") end); Toggle(rideTab, "Speed uncap (300)", "SpeedUncap"); Slider(rideTab, "Speed limit", "SpeedLimit", 0, 400, 5, function(v) return v == 0 and "Off" or (math.floor(v) .. " st/s") end); Toggle(rideTab, "Seat lock", "SeatLock")
        Section(rideTab, "Police"); Toggle(rideTab, "Anti police", "AntiPolice")

        local visualsTab = Tab("Visuals")
        Section(visualsTab, "ESP"); Toggle(visualsTab, "Player ESP", "PlayerESP"); Toggle(visualsTab, "Ride ESP", "RideESP"); Toggle(visualsTab, "Police ESP", "PoliceESP"); Toggle(visualsTab, "Delivery customer ESP", "CustomerESP"); Toggle(visualsTab, "Money drop ESP", "DropESP"); Toggle(visualsTab, "Names", "ESPNames"); Toggle(visualsTab, "Distance", "ESPDistance"); Toggle(visualsTab, "Boxes", "ESPBoxes"); Slider(visualsTab, "Max distance", "ESPMaxDistance", 0, 3000, 50, function(v) return v == 0 and "Unlimited" or (math.floor(v) .. " st") end); Slider(visualsTab, "Player colour", "ESPPlayerColor", 0, 360, 5, function(v) return math.floor(v + 0.5) .. "°" end); Slider(visualsTab, "Ride colour", "ESPRideColor", 0, 360, 5, function(v) return math.floor(v + 0.5) .. "°" end)
        Section(visualsTab, "World"); Toggle(visualsTab, "Fullbright", "Fullbright")
        Section(visualsTab, "Camera"); Toggle(visualsTab, "Smooth camera on mount", "SmoothCamera"); Slider(visualsTab, "Smooth duration", "SmoothCameraDuration", 0.1, 1.5, 0.05, function(v) return string.format("%.2fs", v) end); Slider(visualsTab, "Ride min zoom", "CameraRideMin", 0, 30, 1, function(v) return math.floor(v + 0.5) .. " st" end); Slider(visualsTab, "Ride max zoom", "CameraRideMax", 1, 60, 1, function(v) return math.floor(v + 0.5) .. " st" end)

        local playerTab = Tab("Player")
        Section(playerTab, "Movement"); Slider(playerTab, "WalkSpeed", "WalkSpeed", 0, 200, 1, function(v) return tostring(math.floor(v + 0.5)) end); Slider(playerTab, "Jump height", "JumpHeight", 0, 100, 0.5, function(v) return string.format("%.1f", v) end); Slider(playerTab, "Hip height", "HipHeight", 0, 20, 0.1, function(v) return string.format("%.1f", v) end); Toggle(playerTab, "Infinite jump", "InfJump"); Toggle(playerTab, "Noclip", "Noclip"); Toggle(playerTab, "Fly", "Fly"); Slider(playerTab, "Fly speed", "FlySpeed", 10, 300, 5, function(v) return tostring(math.floor(v)) end); Toggle(playerTab, "Anchor", "Anchor")
        Section(playerTab, "Camera"); Slider(playerTab, "FOV", "FOV", 30, 120, 1, function(v) return math.floor(v + 0.5) .. "°" end); Toggle(playerTab, "Desync", "Desync")

        local miscTab = Tab("Misc")
        Section(miscTab, "Utility"); Toggle(miscTab, "Anti AFK", "AntiAFK"); Toggle(miscTab, "Quick interact", "QuickInteract"); Toggle(miscTab, "Hide players", "HidePlayers")
        Section(miscTab, "Performance"); Toggle(miscTab, "Black screen", "BlackScreen"); if setfpscap then Slider(miscTab, "FPS cap", "FPSCap", 15, 240, 5, function(v) return tostring(math.floor(v + 0.5)) end) end; Toggle(miscTab, "Anti lag", "AntiLag")
        Section(miscTab, "Restore"); Button(miscTab, "Restore hooks / stop all", "Accent", function() unlockSeat(); if Hub.stopSpin then Hub.stopSpin() end; if Hub.stopPulsarWheelie then Hub.stopPulsarWheelie() end; if Hub.removeDesync then Hub.removeDesync() end; if Hub.removeHook then Hub.removeHook() end; if Hub.restoreNoclip then Hub.restoreNoclip() end; if Hub.restoreLag then Hub.restoreLag() end; if Hub.restoreFb then Hub.restoreFb() end; if Hub.restoreHidden then Hub.restoreHidden() end; if Hub.restorePrompt then Hub.restorePrompt() end; if Hub.resetCamera then Hub.resetCamera() end; St.phase, St.phaseAt = "idle", os.clock(); releaseRide(); for k, v in pairs(S) do if type(v) == "boolean" then S[k] = false end end; for _, r in ipairs(Hub.UI.refreshers) do r() end end)

        local cfgTab = Tab("Config")
        Section(cfgTab, "Config"); local CFG_DIR, CFG_FILE = "RubenHub", "RubenHub/KukirinLife.json"; local canFiles = writefile ~= nil and readfile ~= nil and isfile ~= nil; if canFiles then Button(cfgTab, "Save config", "Row", function() if makefolder and isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end; pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(S)) end) end); Button(cfgTab, "Load config", "Row", function() if not isfile(CFG_FILE) then return end; local ok, tbl = pcall(HttpService.JSONDecode, HttpService, readfile(CFG_FILE)); if ok and type(tbl) == "table" then for k, v in pairs(tbl) do if S[k] ~= nil and type(S[k]) == type(v) then S[k] = v end end; for _, r in ipairs(Hub.UI.refreshers) do r() end end end) end; Button(cfgTab, "Export to clipboard", "Row", function() if setclipboard then setclipboard(HttpService:JSONEncode(S)) end end)
        Section(cfgTab, "Interface"); Slider(cfgTab, "Transparency", "UITransparency", 0, 0.6, 0.05, function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end); Keybind(cfgTab, "Toggle UI key", "ToggleKey"); Toggle(cfgTab, "Show profile tag", "ShowProfile"); Toggle(cfgTab, "Show FPS tag", "ShowFPS"); Toggle(cfgTab, "Show ping tag", "ShowPing"); Button(cfgTab, "Unload", "Accent", function() _G.RubenHubUnload() end)

        SideHeader("BINDS")
        local bindsTab = Tab("Binds")
        Section(bindsTab, "Key binds"); Note(bindsTab, "Click 'Bind' then press any key to toggle.")
        local bindables = { { "AutoQuests", "Auto Quests" }, { "AutoAchievements", "Auto Achievements" }, { "AutoDaily", "Auto Daily" }, { "AutoDelivery", "Auto Delivery" }, { "AutoWheelie", "Auto Wheelie (Cookies)" }, { "WheeliePulsar", "Auto Wheelie (Pulsar)" }, { "AutoTricks", "Auto Tricks" }, { "AutoBuyRide", "Auto Buy Ride" }, { "MoneyRain", "Money Rain" }, { "AntiPolice", "Anti Police" }, { "SpeedUncap", "Speed Uncap" }, { "SeatLock", "Seat Lock" }, { "SmoothCamera", "Smooth Camera" }, { "PlayerESP", "Player ESP" }, { "RideESP", "Ride ESP" }, { "PoliceESP", "Police ESP" }, { "CustomerESP", "Customer ESP" }, { "DropESP", "Drop ESP" }, { "Fullbright", "Fullbright" }, { "Noclip", "Noclip" }, { "Fly", "Fly" }, { "InfJump", "Infinite Jump" }, { "Anchor", "Anchor" }, { "AntiAFK", "Anti AFK" }, { "HidePlayers", "Hide Players" } }
        for _, fn in ipairs(bindables) do local r = row(bindsTab); lbl(r, fn[2]); local b = new("TextButton", { Font = FB, TextSize = 11, AutoButtonColor = false, Size = UDim2.fromOffset(100, 26), Position = UDim2.new(1, -114, 0.5, -13), Parent = r, BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text }); corner(b, 7); local listening = false; local function render() local bindKey = nil; for k, v in pairs(Hub.Binds) do if v == fn[1] then bindKey = k; break end end; b.Text = listening and "Press..." or (bindKey and ("[" .. bindKey .. "]") or "Bind"); b.BackgroundColor3 = listening and Theme.Accent or Theme.Panel end; b.MouseButton1Click:Connect(function() listening = not listening; Hub.UI.bindCapture = listening; render() end); bind(UIS.InputBegan:Connect(function(i) if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end; listening = false; Hub.UI.bindCapture = false; for k, v in pairs(Hub.Binds) do if v == fn[1] then Hub.Binds[k] = nil end end; Hub.Binds[i.KeyCode.Name] = fn[1]; render() end)); render(); table.insert(Hub.UI.refreshers, render) end

        selectTab(farmTab)

        do local dragging, dragStart, startPos; header.InputBegan:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging, dragStart, startPos = true, i.Position, win.Position end end); bind(UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == MOVE or i.UserInputType == TOUCH) then local d = i.Position - dragStart; win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)); bind(UIS.InputEnded:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = false end end)) end

        local minimized = false; minBtn.MouseButton1Click:Connect(function() minimized = not minimized; body.Visible = not minimized; tween(win, { Size = UDim2.fromOffset(WIN_W, minimized and 56 or WIN_H) }, 0.22); tween(glow, { Size = UDim2.fromOffset(WIN_W + 20, (minimized and 56 or WIN_H) + 20) }, 0.22) end); closeBtn.MouseButton1Click:Connect(function() _G.RubenHubUnload() end)
        bind(UIS.InputBegan:Connect(function(i, gp) if gp or Hub.UI.bindCapture then return end; local ok, key = pcall(function() return Enum.KeyCode[S.ToggleKey] end); if ok and i.KeyCode == key then ui.Enabled = not ui.Enabled end; for k, fn in pairs(Hub.Binds) do local ok2, e = pcall(function() return Enum.KeyCode[k] end); if ok2 and i.KeyCode == e and type(S[fn]) == "boolean" then S[fn] = not S[fn]; for _, r in ipairs(Hub.UI.refreshers) do r() end end end end))
        Hub.UI.win, Hub.UI.glow, Hub.UI.ui = win, glow, ui
    end
    buildUI()

    -- =====================================================================
    -- TAGS
    -- =====================================================================
    local function setupTags()
        local S = Hub.Settings
        local tagGui = new("ScreenGui", { Name = "RubenTags", ResetOnSpawn = false, DisplayOrder = 997, Parent = guiParent })
        local holder = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 54), Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = tagGui })
        new("UIListLayout", { Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
        local function makeTag(order, accent)
            local wrap = new("Frame", { Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(24, 27, 38), BackgroundTransparency = 0.1, BorderSizePixel = 0, LayoutOrder = order, Parent = holder }); corner(wrap, 6); new("UIStroke", { Color = Color3.fromRGB(42, 48, 66), Thickness = 1, Transparency = 0.4, Parent = wrap })
            if accent then local side = new("Frame", { Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Color3.fromRGB(91, 140, 255), BorderSizePixel = 0, Parent = wrap }); local g = new("UIGradient", { Parent = side }); g.Color = ColorSequence.new(Color3.fromRGB(91, 140, 255), Color3.fromRGB(168, 110, 255)); g.Rotation = 90 end
            new("UIPadding", { PaddingLeft = UDim.new(0, accent and 12 or 10), PaddingRight = UDim.new(0, 10), Parent = wrap })
            return new("TextLabel", { Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(238, 242, 252), TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap })
        end
        local profTag, fpsTag, pingTag = makeTag(1, true), makeTag(2), makeTag(3)
        profTag.Text = "@" .. lp.Name; local frames = 0; bind(RunService.RenderStepped:Connect(function() frames += 1 end))
        task.spawn(function()
            while _G.RubenHubLoaded do
                profTag.Parent.Visible = S.ShowProfile; fpsTag.Parent.Visible = S.ShowFPS; pingTag.Parent.Visible = S.ShowPing
                fpsTag.Text = "FPS " .. frames * 2; frames = 0
                local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end); if not ok then ping = lp:GetNetworkPing() * 1000 end
                pingTag.Text = "Ping " .. math.floor(ping) .. " ms"; task.wait(0.5)
            end
        end)
        Hub.UI.tagGui = tagGui
    end
    setupTags()

    -- =====================================================================
    -- UNLOAD
    -- =====================================================================
    _G.RubenHubUnload = function()
        if not _G.RubenHubLoaded then return end; _G.RubenHubLoaded = false
        if Hub.State.phase ~= "idle" then releaseRide() end; local seat = myDriveSeat()
        if Hub.State.oneHandByHelper and seat and seat:GetAttribute("OneHanderActive") == true and Hub.Remotes.RiderArmEvent then Hub.Remotes.RiderArmEvent:FireServer() end
        if Hub.State.policeBefore and Hub.Remotes.PoliceMode then Hub.Remotes.PoliceMode:FireServer(Hub.State.policeBefore) end
        for _, c in ipairs(Hub.Conns) do pcall(function() c:Disconnect() end) end
        local h = getHum(); if h then h.WalkSpeed = 16; h.JumpHeight = 50; h.PlatformStand = false end
        unlockSeat(); if Hub.stopSpin then Hub.stopSpin() end; if Hub.stopPulsarWheelie then Hub.stopPulsarWheelie() end
        if Hub.removeDesync then Hub.removeDesync() end; if Hub.removeHook then Hub.removeHook() end; if Hub.restoreNoclip then Hub.restoreNoclip() end
        if Hub.restoreLag then Hub.restoreLag() end; if Hub.restoreFb then Hub.restoreFb() end; if Hub.restoreHidden then Hub.restoreHidden() end; if Hub.restorePrompt then Hub.restorePrompt() end
        if Hub.removeCameraHook then Hub.removeCameraHook() end
        if Hub.Esp.folder then Hub.Esp.folder:Destroy() end; if Hub.UI.ui then Hub.UI.ui:Destroy() end; if Hub.UI.tagGui then Hub.UI.tagGui:Destroy() end
        _G.RubenHubLoaded = nil; print("[Ruben-Hub] Unloaded.")
    end

    print("[Ruben-Hub] Kukirin Life loaded. Press " .. Hub.Settings.ToggleKey .. " to toggle.")
end)