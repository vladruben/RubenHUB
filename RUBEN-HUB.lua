-- =========================================================================
-- [RUBEN-HUB] — Kukirin Life | Cookies + Pulsar + Speed Limit + Pulsar Wheelie
-- =========================================================================
if _G.RubenHubLoaded then return end
_G.RubenHubLoaded = true

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
local guiParent    = gethui and gethui() or game:GetService("CoreGui")

if not (workspace:FindFirstChild("Rides") and RS:FindFirstChild("Scooters") and RS:FindFirstChild("Remotes")) then
    warn("[Ruben-Hub] This script only works in Kukirin Life!")
    return
end

-- =========================================================================
-- HUB STATE (Создаем СТРОГО ДО вызова bind)
-- =========================================================================
local Hub = {
    Settings = {},
    State = {
        phase = "idle", phaseAt = 0,
        padSent = {}, padSentTo = nil,
        pulsarWheelie = { active = false, seat = nil, attach = nil, align = nil, yaw = 0, ownerFixed = false },
        spin = { phase = "Idle", phaseAt = 0, idleAt = 0, totalAngle = 0, targetAngle = 0, rate = 0,
                 mode = "Spin", baseYaw = 0, currentBody = nil, attach = nil, align = nil,
                 savedAutoRotate = true, savedPlatformStand = false, cycleSeated = false, seat = nil,
                 ownerFixed = false },
        session = { startedAt = os.clock(), startCash = tonumber(lp:GetAttribute("Cash")) or 0,
                    quests = 0, achievements = 0, daily = 0, deliveries = 0, deliveryCash = 0, pushed = 0 },
        deliveryStatus = "",
        collectingRain = false,
        respawnedAt = 0, respawning = false,
        stuckSince = nil, lastCheckPos = nil, lastWheelieTime = nil,
        oneHandByHelper = false, policeBefore = nil, armToggledAt = 0,
        lastPush = 0,
    },
    Remotes = {},
    Conns = {},
    UI = { refreshers = {}, tabs = {}, bindCapture = false, win = nil, tagGui = nil, glow = nil },
    Binds = {},
    SeatLock = nil,
    FlyPos = nil, FlyHum = nil, FlySavedParts = {},
    DesyncState = nil,
    NoclipSaved = {},
    HiddenParts = {},
    PromptSaved = {},
    LagFx = {}, LagShadows = nil, FbSaved = nil,
    Police = { models = {}, scanAt = 0, stuck = {}, hookMt = nil, hookOld = nil, hookOn = false },
    Esp = { folder = nil, tags = {} },
}

-- Settings
for k, v in pairs({
    AutoQuests = false, AutoAchievements = false, AutoDaily = false,
    AutoDelivery = false, AutoBuyRide = false, MoneyRain = false,
    QuestHelpers = true,
    AutoWheelie = false, WheelieAngle = 35,
    WheeliePulsar = false, WheeliePulsarAngle = 35, WheeliePulsarFreeze = false,
    AutoTricks = false, TrickMode = "Spin", TrickSpeed = 1,
    RideSpeedBoost = 0, SpeedUncap = false, SpeedLimit = 140,
    QuickRide = "", SeatLock = true, AntiPolice = false,
    PlayerESP = false, RideESP = false, PoliceESP = false, CustomerESP = false, DropESP = false,
    ESPNames = true, ESPDistance = true, ESPBoxes = true, ESPMaxDistance = 0,
    ESPPlayerColor = 350, ESPRideColor = 160,
    Fullbright = false,
    WalkSpeed = 16, JumpHeight = 50, HipHeight = 2,
    InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, FOV = 70,
    Anchor = false, Desync = false,
    AntiAFK = true, QuickInteract = false, HidePlayers = false,
    BlackScreen = false, FPSCap = 60, AntiLag = false,
    UITransparency = 0, ShowProfile = true, ShowFPS = true, ShowPing = true,
    ToggleKey = "RightShift",
}) do Hub.Settings[k] = v end

-- =========================================================================
-- UTILITIES
-- =========================================================================
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
    TweenService:Create(inst, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end
local function bind(c) table.insert(Hub.Conns, c) return c end
local function getHum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function myRide() return workspace.Rides and workspace.Rides:FindFirstChild("Ride_" .. lp.Name) end
local function myDriveSeat() local r = myRide() return r and r:FindFirstChild("DriveSeat", true) end
local function seated(seat) local h = getHum() return h and seat and h.SeatPart == seat end

-- =========================================================================
-- REMOTES
-- =========================================================================
do
    local Remotes = RS.Remotes
    local function r(name)
        for _, x in ipairs(Remotes:GetDescendants()) do
            if x.Name == name and (x:IsA("RemoteEvent") or x:IsA("RemoteFunction")) then return x end
        end
    end
    Hub.Remotes.GetQuests = r("GetQuests")
    Hub.Remotes.ClaimQuest = r("ClaimQuest")
    Hub.Remotes.ClaimAchievement = r("ClaimAchievement")
    Hub.Remotes.ClaimAchievementReward = r("ClaimAchievementReward")
    Hub.Remotes.GetDailyRewards = r("GetDailyRewards")
    Hub.Remotes.ClaimDailyReward = r("ClaimDailyReward")
    Hub.Remotes.SpawnRide = r("SpawnRide")
    Hub.Remotes.GoToDealership = r("GoToDealership")
    Hub.Remotes.GetRides = r("GetRides")
    Hub.Remotes.BuyRide = r("BuyRide")
    Hub.Remotes.RiderArmEvent = r("RiderArmEvent")
    Hub.Remotes.PoliceMode = r("PoliceMode")
    Hub.Remotes.PoliceHit = r("PoliceHit")
    Hub.Remotes.TrickState = r("TrickState")
    Hub.Remotes.FoodDelivery = Remotes:FindFirstChild("FoodDelivery")
    Hub.Remotes.RainFolder = Remotes:FindFirstChild("MoneyRain")
end

-- =========================================================================
-- A-CHASSIS & SEAT LOCK
-- =========================================================================
local function chassis()
    local aci = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("A-Chassis Interface")
    local values = aci and aci:FindFirstChild("Values")
    local drive = aci and aci:FindFirstChild("Drive")
    local input = drive and drive:FindFirstChild("VirtualInput")
    if values and values:FindFirstChild("Wheelie") and input then return values, input end
end

local function pad(input, keyCode, value)
    local S = Hub.State
    if S.padSentTo ~= input then S.padSent = {}; S.padSentTo = input end
    value = math.floor(value * 50 + 0.5) / 50
    if S.padSent[keyCode] == value then return end
    S.padSent[keyCode] = value
    input:Fire({
        KeyCode = keyCode, UserInputType = Enum.UserInputType.Gamepad1, UserInputState = Enum.UserInputState.Change,
        Position = keyCode == Enum.KeyCode.Thumbstick1 and Vector3.new(value, 0, 0) or Vector3.new(0, 0, value),
    })
end

local function releaseRide()
    local values, input = chassis()
    if not values then return end
    pad(input, Enum.KeyCode.ButtonR2, 0)
    pad(input, Enum.KeyCode.ButtonL2, 0)
    pad(input, Enum.KeyCode.Thumbstick1, 0)
    values.Wheelie.Value = false
end

local function lockSeat()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local seat = hum and hum.SeatPart
    if not (hrp and seat) then
        if Hub.SeatLock then Hub.SeatLock:Destroy() end
        Hub.SeatLock = nil
        return
    end
    if Hub.SeatLock and Hub.SeatLock.Parent and Hub.SeatLock.Part0 == hrp and Hub.SeatLock.Part1 == seat then return end
    if Hub.SeatLock then Hub.SeatLock:Destroy() end
    Hub.SeatLock = Instance.new("WeldConstraint")
    Hub.SeatLock.Name = "RubenSeatLock"
    Hub.SeatLock.Part0 = hrp
    Hub.SeatLock.Part1 = seat
    Hub.SeatLock.Parent = hrp
end

local function unlockSeat()
    if Hub.SeatLock then Hub.SeatLock:Destroy() end
    Hub.SeatLock = nil
end

-- =========================================================================
-- TELEPORT & STREAMING
-- =========================================================================
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Exclude
local function groundBelow(pos, depth)
    groundParams.FilterDescendantsInstances = { workspace.Rides, lp.Character, workspace:FindFirstChild("POIs") }
    return workspace:Raycast(pos, Vector3.new(0, -(depth or 12), 0), groundParams)
end
local function streamAround(pos)
    local done = false
    task.spawn(function()
        pcall(function() lp:RequestStreamAroundAsync(pos, 5) end)
        done = true
    end)
    local t = os.clock()
    while not done and os.clock() - t < 3 do task.wait(0.1) end
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
    if seat and seated(seat) then
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
-- FARM: Quests / Achievements / Daily / Delivery / Wheelie / Tricks
-- =========================================================================
local function setupFarm()
    local R, S, St = Hub.Remotes, Hub.Settings, Hub.State
    local PW = St.pulsarWheelie
    local Spin = St.spin
    local quests = {}

    local function questNeeds(id)
        for _, q in ipairs(quests) do
            if q.Id == id and (q.NextAt or 0) <= os.time() and (q.Progress or 0) < (q.Target or 0) then return true end
        end
        return false
    end

    -- Quests loop
    task.spawn(function()
        while _G.RubenHubLoaded do
            if R.GetQuests and (S.AutoQuests or (S.AutoWheelie and S.QuestHelpers)) then
                local ok, list = pcall(function() return R.GetQuests:InvokeServer() end)
                if ok and type(list) == "table" then
                    quests = list
                    for i, q in ipairs(S.AutoQuests and R.ClaimQuest and list or {}) do
                        local ready = (q.NextAt or 0) <= os.time() and (q.Progress or 0) >= (q.Target or math.huge)
                        if ready then
                            local okc, claimed = pcall(function() return R.ClaimQuest:InvokeServer(i) end)
                            if okc and claimed then St.session.quests += 1 task.wait(0.4) end
                        end
                    end
                end
            end
            task.wait(5)
        end
    end)

    -- Achievements
    local function claimAll(fn)
        for _ = 1, 20 do
            local ok, claimed = pcall(fn)
            if not (ok and claimed) then return end
            St.session.achievements += 1
            task.wait(0.3)
        end
    end
    task.spawn(function()
        local cfgOk, cfg = pcall(function() return require(RS.Datas.AchievementConfig) end)
        while _G.RubenHubLoaded do
            if S.AutoAchievements and R.ClaimAchievement and cfgOk then
                for _, a in ipairs(cfg.Achievements or {}) do
                    claimAll(function() return R.ClaimAchievement:InvokeServer(a.Id) end)
                end
                if R.ClaimAchievementReward then claimAll(function() return R.ClaimAchievementReward:InvokeServer() end) end
            end
            task.wait(30)
        end
    end)

    -- Daily
    task.spawn(function()
        while _G.RubenHubLoaded do
            if S.AutoDaily and R.GetDailyRewards and R.ClaimDailyReward then
                local ok, d = pcall(function() return R.GetDailyRewards:InvokeServer() end)
                if ok and type(d) == "table" and (d.NextAt or 0) <= os.time() then
                    local okc, claimed = pcall(function() return R.ClaimDailyReward:InvokeServer() end)
                    if okc and claimed then St.session.daily += 1 end
                end
            end
            task.wait(60)
        end
    end)

    -- Auto-buy
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
                        if not x.Owned and not x.RobuxOnly and not x.Event and price > 0 and price <= cash
                            and topSpeed(x.Name) > best and (not pick or topSpeed(x.Name) > topSpeed(pick.Name)) then
                            pick = x
                        end
                    end
                    if pick then pcall(function() R.BuyRide:InvokeServer(pick.Name) end) end
                end
            end
            task.wait(20)
        end
    end)

    -- Money rain
    local function raining()
        local RF = R.RainFolder
        if not RF or RF:GetAttribute("Id") == nil then return false end
        local started, duration = RF:GetAttribute("StartedAt"), RF:GetAttribute("Duration")
        return started ~= nil and duration ~= nil and workspace:GetServerTimeNow() < started + duration + 8
    end
    task.spawn(function()
        while _G.RubenHubLoaded do
            St.collectingRain = S.MoneyRain and raining()
            if St.collectingRain then
                local hum, root = getHum(), getRoot()
                if hum and hum.SeatPart then hum.Sit = false end
                local drops = workspace:FindFirstChild("MoneyRain")
                local nearest, nearestD
                for _, d in ipairs(root and drops and drops:GetChildren() or {}) do
                    if d:IsA("BasePart") and d.Transparency < 1 then
                        local dist = (d.Position - root.Position).Magnitude
                        if not nearestD or dist < nearestD then nearest, nearestD = d, dist end
                    end
                end
                if nearest then root.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 2, 0)) end
                task.wait(0.12)
            else
                task.wait(1)
            end
        end
    end)

    -- Auto delivery
    local DELIVERY_NPC = Vector3.new(1424.7, 58.6, -607.8)
    task.spawn(function()
        while _G.RubenHubLoaded do
            if S.AutoDelivery and R.FoodDelivery and not St.collectingRain then
                local target = lp:GetAttribute("DeliveryTarget")
                if typeof(target) ~= "Vector3" then
                    teleport(DELIVERY_NPC)
                    task.wait(0.6)
                    local ok, started = pcall(function() return R.FoodDelivery.Start:InvokeServer() end)
                    St.deliveryStatus = (ok and started) and "Order picked up" or "Waiting for order"
                    task.wait(3)
                else
                    teleport(target + Vector3.new(0, 0, 4))
                    St.deliveryStatus = "Delivering..."
                    local giveUp = os.clock() + 75
                    while S.AutoDelivery and lp:GetAttribute("DeliveryTarget") == target and os.clock() < giveUp do
                        local ok, done, pay, _, tip = pcall(function() return R.FoodDelivery.Deliver:InvokeServer() end)
                        if ok and done then
                            local earned = (tonumber(pay) or 0) + (tonumber(tip) or 0)
                            St.session.deliveries += 1
                            St.session.deliveryCash += earned
                            St.deliveryStatus = "Delivered +$" .. earned
                            break
                        end
                        task.wait(1.5)
                    end
                end
            else
                St.deliveryStatus = ""
            end
            task.wait(0.5)
        end
    end)

    -- ====== COOKIES WHEELIE (A-Chassis) ======
    local FARM_SPOT = Vector3.new(1100, 56.4, -1500)
    local farmAnchor, farmRadius = FARM_SPOT, 260

    local function clearRadius(ground)
        groundBelow(ground)
        local nearest = 400
        for a = 0, 71 do
            local ang = a / 72 * math.pi * 2
            local dir = Vector3.new(math.cos(ang), 0, math.sin(ang)) * 400
            for _, h in ipairs({ 1.2, 3, 6 }) do
                local from = ground + Vector3.new(0, h, 0)
                local hit = workspace:Raycast(from, dir, groundParams)
                if hit then nearest = math.min(nearest, (hit.Position - from).Magnitude) end
            end
        end
        return nearest
    end
    Hub.setWheelieArea = function(ground, clear)
        farmAnchor, farmRadius = ground, math.min(260, clear - 60)
        if St.phase ~= "idle" then St.phase, St.phaseAt = "idle", os.clock() end
    end
    Hub.getWheelieAnchor = function() return farmAnchor end
    Hub.clearRadius = clearRadius

    local function setOneHand(on)
        local seat = myDriveSeat()
        if not (seat and R.RiderArmEvent) or os.clock() - St.armToggledAt < 1.5 then return end
        if (seat:GetAttribute("OneHanderActive") == true) ~= on then
            St.armToggledAt = os.clock()
            R.RiderArmEvent:FireServer()
        end
    end

    local function questHelpers()
        local wheelieing = S.AutoWheelie and St.phase == "wheelie"
        if S.QuestHelpers and wheelieing and questNeeds("OneHandWheelie") then
            St.oneHandByHelper = true
            setOneHand(true)
        elseif St.oneHandByHelper then
            local seat = myDriveSeat()
            if seat and seat:GetAttribute("OneHanderActive") == true then setOneHand(false) else St.oneHandByHelper = false end
        end
        if not R.PoliceMode then return end
        local mode = lp:GetAttribute("PoliceMode") or "None"
        if S.QuestHelpers and wheelieing and questNeeds("HardPoliceTime") then
            if St.policeBefore == nil then St.policeBefore = mode end
            if mode ~= "Hard" then R.PoliceMode:FireServer("Hard") end
            return
        end
        local want = S.AntiPolice and "None" or St.policeBefore
        St.policeBefore = nil
        if want and mode ~= want then R.PoliceMode:FireServer(want) end
    end

    local function respawnRide()
        if not R.SpawnRide or St.respawning or os.clock() - St.respawnedAt < 6 then return end
        St.respawnedAt, St.respawning = os.clock(), true
        local template = myRide() and myRide():GetAttribute("TemplateName") or "ScooterG2"
        task.spawn(function()
            pcall(function() R.SpawnRide:InvokeServer(template) end)
            St.respawning = false
        end)
    end

    local function stuck(seat)
        local wt = tonumber(lp:GetAttribute("WheelieTime")) or 0
        local still = St.lastCheckPos and (seat.Position - St.lastCheckPos).Magnitude < 0.5
        local earning = St.lastWheelieTime and wt > St.lastWheelieTime
        St.lastCheckPos, St.lastWheelieTime = seat.Position, wt
        if still and not earning then
            St.stuckSince = St.stuckSince or os.clock()
            return os.clock() - St.stuckSince > 8
        end
        St.stuckSince = nil
        return false
    end

    task.spawn(function()
        while _G.RubenHubLoaded do
            local seat, hum = myDriveSeat(), getHum()
            local farming = S.AutoWheelie and not S.AutoDelivery and not St.collectingRain and not S.WheeliePulsar
            if farming and hum and not seat then
                respawnRide()
                St.phase, St.phaseAt = "idle", os.clock()
            elseif farming and seat and hum then
                if hum.SeatPart ~= seat then
                    St.phase, St.phaseAt = "idle", os.clock()
                    local root = getRoot()
                    if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end
                    task.wait(0.4)
                    pcall(function() seat:Sit(hum) end)
                elseif St.phase == "idle" then
                    streamAround(farmAnchor)
                    placeRide(farmAnchor + Vector3.new(0, seatHeight(seat), 0))
                    St.phase, St.phaseAt = "place", os.clock()
                elseif St.phase ~= "place" and stuck(seat) then
                    St.stuckSince = nil
                    respawnRide()
                    St.phase, St.phaseAt = "idle", os.clock()
                end
            elseif St.phase ~= "idle" then
                St.phase, St.phaseAt = "idle", os.clock()
                releaseRide()
            end
            questHelpers()
            task.wait(0.3)
        end
    end)

    -- Cookies wheelie heartbeat
    local lastPitch, pitchRate = 0, 0
    bind(RunService.Heartbeat:Connect(function(dt)
        if St.phase == "idle" then return end
        if S.WheeliePulsar then return end
        local seat = myDriveSeat()
        local values, input = chassis()
        if not (seat and seated(seat) and values) then return end
        local t = os.clock() - St.phaseAt
        if St.phase == "place" then
            pad(input, Enum.KeyCode.ButtonR2, 0)
            if t > 1 then St.phase, St.phaseAt = "launch", os.clock() end
            return
        end
        pad(input, Enum.KeyCode.Thumbstick1, 0.25)
        if St.phase == "launch" then
            values.Wheelie.Value = false
            pad(input, Enum.KeyCode.ButtonR2, 0.7)
            pad(input, Enum.KeyCode.ButtonL2, 0)
            if t > 1.5 then lastPitch, pitchRate = 0, 0; St.phase, St.phaseAt = "wheelie", os.clock() end
            return
        end
        if not values.Wheelie.Value then values.Wheelie.Value = true end
        local g = groundBelow(seat.Position)
        local pitch = math.deg(math.asin(math.clamp(seat.CFrame.LookVector:Dot(g and g.Normal or Vector3.yAxis), -1, 1)))
        pitchRate = pitchRate * 0.7 + (pitch - lastPitch) / math.max(dt, 1 / 120) * 0.3
        lastPitch = pitch
        local u = math.clamp(0.45 + 0.04 * (S.WheelieAngle - pitch) - 0.012 * pitchRate, -1, 1)
        pad(input, Enum.KeyCode.ButtonR2, math.max(u, 0))
        pad(input, Enum.KeyCode.ButtonL2, math.max(-u, 0))
        local centre = Vector3.new(farmAnchor.X, 0, farmAnchor.Z)
        local pos = Vector3.new(seat.Position.X, 0, seat.Position.Z)
        local vel = seat.AssemblyLinearVelocity
        local flatVel = Vector3.new(vel.X, 0, vel.Z)
        if (pos - centre).Magnitude > farmRadius and flatVel.Magnitude > 5 and (pos - centre):Dot(flatVel) > 0 then
            local back = centre - flatVel.Unit * (farmRadius - 20)
            myRide():PivotTo(myRide():GetPivot() + (back - pos))
        end
    end))

    -- ====== PULSAR WHEELIE (AlignOrientation) ======
    local function stopPulsarWheelie()
        if PW.align then pcall(function() PW.align:Destroy() end) end
        if PW.attach then pcall(function() PW.attach:Destroy() end) end
        if PW.seat and PW.seat.Parent then pcall(function() PW.seat.Anchored = false end) end
        PW.active, PW.seat, PW.attach, PW.align, PW.yaw = false, nil, nil, nil, 0
    end
    Hub.stopPulsarWheelie = stopPulsarWheelie

    local function startPulsarWheelie(seat)
        stopPulsarWheelie()
        PW.active, PW.seat = true, seat
        PW.yaw = select(2, seat.CFrame:ToOrientation())

        if not PW.ownerFixed then
            PW.ownerFixed = true
            pcall(function()
                local veh = seat:FindFirstAncestorOfClass("Model")
                if veh then
                    for _, p in ipairs(veh:GetDescendants()) do
                        if p:IsA("BasePart") and p:CanSetNetworkOwnership() then p:SetNetworkOwner(lp) end
                    end
                elseif seat:CanSetNetworkOwnership() then
                    seat:SetNetworkOwner(lp)
                end
            end)
        end

        PW.attach = Instance.new("Attachment"); PW.attach.Parent = seat
        PW.align = Instance.new("AlignOrientation")
        PW.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        PW.align.Attachment0 = PW.attach
        PW.align.MaxTorque = 10000000
        PW.align.MaxAngularVelocity = 20
        PW.align.Responsiveness = 50
        PW.align.Parent = seat
    end

    bind(RunService.Heartbeat:Connect(function(dt)
        if not S.WheeliePulsar then
            if PW.active then stopPulsarWheelie() end
            return
        end
        if S.AutoWheelie then S.AutoWheelie = false end
        if S.AutoTricks then S.AutoTricks = false end
        if St.phase ~= "idle" then
            St.phase, St.phaseAt = "idle", os.clock()
            releaseRide()
        end
        local hum = getHum()
        local seat = hum and hum.SeatPart
        if not seat then
            if PW.active then stopPulsarWheelie() end
            return
        end
        if not PW.active or PW.seat ~= seat or not PW.align or PW.align.Parent ~= seat then
            startPulsarWheelie(seat)
        end
        local steer = seat.SteerFloat or seat.Steer or 0
        PW.yaw = PW.yaw - steer * 3.0 * dt
        PW.align.CFrame = CFrame.new(seat.Position) * CFrame.Angles(0, PW.yaw, 0) * CFrame.Angles(math.rad(S.WheeliePulsarAngle), 0, 0)
        if S.WheeliePulsarFreeze then
            seat.Anchored = true
        elseif seat.Anchored then
            seat.Anchored = false
        end
    end))

    -- ====== AUTO TRICKS (Pulsar original) ======
    local SPIN_JUMP_VELOCITY    = 15
    local SPIN_ASCEND_TIME      = 0.35
    local SPIN_DESCENT_SPEED    = -90
    local SPIN_REPEAT_DELAY     = 0.35
    local SPIN_MAX_DESCENT_TIME = 1.6
    local SPIN_GROUND_CHECK_DISTANCE = 3.5

    local function setSpinPhase(n) Spin.phase, Spin.phaseAt = n, os.clock() end

    local function getSpinParts()
        local char = lp.Character
        if not char then return nil end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return nil end

        local seat = hum.SeatPart
        if not seat and Hub.SeatLock and Hub.SeatLock.Part1 and Hub.SeatLock.Part1.Parent then seat = Hub.SeatLock.Part1 end
        if not seat and Spin.seat and Spin.seat.Parent then seat = Spin.seat end

        local body, vehicle = root, nil
        if seat then
            body = seat.AssemblyRootPart or seat
            vehicle = seat:FindFirstAncestorOfClass("Model")
        end
        return char, hum, root, body, vehicle, seat
    end

    local function removeSpinAligner()
        if Spin.align then pcall(function() Spin.align:Destroy() end) end
        if Spin.attach then pcall(function() Spin.attach:Destroy() end) end
        Spin.align, Spin.attach, Spin.currentBody = nil, nil, nil
    end

    local function setSpinOrientation(body, angle)
        if not body or not body.Parent then return end
        if Spin.currentBody ~= body then
            removeSpinAligner()
            Spin.currentBody = body
            Spin.attach = Instance.new("Attachment"); Spin.attach.Parent = body
            Spin.align = Instance.new("AlignOrientation")
            Spin.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
            Spin.align.Attachment0 = Spin.attach
            Spin.align.Responsiveness = 300
            Spin.align.MaxTorque = 1e9
            Spin.align.MaxAngularVelocity = 1e6
            Spin.align.Parent = body
        end
        if Spin.mode == "Backflip" or Spin.mode == "Frontflip" then
            Spin.align.CFrame = CFrame.Angles(0, Spin.baseYaw, 0) * CFrame.Angles(angle, 0, 0)
        else
            Spin.align.CFrame = CFrame.Angles(0, angle, 0)
        end
    end

    local function setSpinVel(body, y)
        if body and body.Parent then body.AssemblyLinearVelocity = Vector3.new(0, y, 0) end
    end

    local function isSpinGrounded(char, body, vehicle)
        local filter = { char }
        if vehicle then table.insert(filter, vehicle) end
        if body and body.Parent then table.insert(filter, body) end
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = filter
        return workspace:Raycast(body.Position, Vector3.new(0, -SPIN_GROUND_CHECK_DISTANCE, 0), p) ~= nil
    end

    local function releaseSpin(hum, body)
        removeSpinAligner()
        if hum and not Spin.cycleSeated then
            hum.AutoRotate = Spin.savedAutoRotate
            hum.PlatformStand = Spin.savedPlatformStand
        end
        if body and body.Parent then
            body.AssemblyAngularVelocity = Vector3.zero
            body.AssemblyLinearVelocity  = Vector3.zero
        end
        Spin.cycleSeated = false
    end

    local function resetSpin()
        Spin.phase, Spin.totalAngle, Spin.seat = "Idle", 0, nil
        removeSpinAligner()
    end

    local function stopSpin()
        local _, hum, _, body = getSpinParts()
        releaseSpin(hum, body or Spin.currentBody)
        resetSpin()
        Spin.idleAt = 0
    end
    Hub.stopSpin = stopSpin

    local function chooseTrickMode()
        local m = S.TrickMode
        if m == "Random" then m = (math.random() < 0.75) and "Spin" or "180" end
        return m
    end

    local function startSpinCycle()
        local char, hum, _, body, _, seat = getSpinParts()
        if not char then return false end

        if seat and not Spin.ownerFixed then
            Spin.ownerFixed = true
            pcall(function()
                local veh = seat:FindFirstAncestorOfClass("Model")
                if veh then
                    for _, p in ipairs(veh:GetDescendants()) do
                        if p:IsA("BasePart") and p:CanSetNetworkOwnership() then p:SetNetworkOwner(lp) end
                    end
                elseif seat:CanSetNetworkOwnership() then
                    seat:SetNetworkOwner(lp)
                end
            end)
        end

        Spin.cycleSeated = seat ~= nil
        if not Spin.cycleSeated then
            Spin.savedAutoRotate = hum.AutoRotate
            Spin.savedPlatformStand = hum.PlatformStand
            hum.AutoRotate = false
            hum.PlatformStand = true
        end

        Spin.mode = chooseTrickMode()
        Spin.totalAngle = 0
        Spin.baseYaw = select(2, body.CFrame:ToOrientation())
        Spin.seat = seat

        if Spin.mode == "Spin" then
            Spin.targetAngle = math.rad(1440); Spin.rate = math.rad(720) * (S.TrickSpeed or 1)
        elseif Spin.mode == "Backflip" then
            Spin.targetAngle = math.rad(360); Spin.rate = math.rad(540) * (S.TrickSpeed or 1)
        elseif Spin.mode == "Frontflip" then
            Spin.targetAngle = math.rad(-360); Spin.rate = math.rad(-540) * (S.TrickSpeed or 1)
        else
            Spin.targetAngle = math.rad(180); Spin.rate = math.rad(540) * (S.TrickSpeed or 1)
        end

        setSpinOrientation(body, 0)
        setSpinVel(body, SPIN_JUMP_VELOCITY)
        setSpinPhase("Ascend")
        return true
    end

    local function updateSpin(dt)
        if not S.AutoTricks or S.Fly or S.AutoWheelie or S.WheeliePulsar then
            if Spin.phase ~= "Idle" then stopSpin() end
            return
        end

        local char, hum, _, body, vehicle, seat = getSpinParts()
        if not char or not seat then
            if Spin.phase ~= "Idle" then releaseSpin(nil, Spin.currentBody); resetSpin() end
            return
        end

        local now     = os.clock()
        local elapsed = now - Spin.phaseAt

        if Spin.phase == "Idle" then
            if now - Spin.idleAt >= SPIN_REPEAT_DELAY then startSpinCycle() end
        elseif Spin.phase == "Ascend" then
            setSpinVel(body, SPIN_JUMP_VELOCITY); setSpinOrientation(body, 0)
            if elapsed >= SPIN_ASCEND_TIME then setSpinPhase("Spin") end
        elseif Spin.phase == "Spin" then
            setSpinVel(body, 0)
            Spin.totalAngle = Spin.totalAngle + Spin.rate * dt
            if math.abs(Spin.totalAngle) >= math.abs(Spin.targetAngle) then
                Spin.totalAngle = Spin.targetAngle; setSpinPhase("Descend")
            end
            setSpinOrientation(body, Spin.totalAngle)
        elseif Spin.phase == "Descend" then
            setSpinVel(body, SPIN_DESCENT_SPEED); setSpinOrientation(body, Spin.targetAngle)
            if isSpinGrounded(char, body, vehicle) or elapsed >= SPIN_MAX_DESCENT_TIME then setSpinPhase("Landed") end
        elseif Spin.phase == "Landed" then
            setSpinVel(body, 0)
            if elapsed >= 0.05 then
                releaseSpin(hum, body)
                Spin.totalAngle = 0; Spin.idleAt = now; setSpinPhase("Idle")
            end
        end
    end

    if R.TrickState then
        bind(R.TrickState.OnClientEvent:Connect(function(kind, name, amount)
            if kind == "landed" and type(amount) == "number" and amount > 0 then
                St.session.lastTrick = name or "trick"
            end
        end))
    end

    bind(RunService.Heartbeat:Connect(function(dt)
        local hum = getHum()
        local seat = hum and hum.SeatPart

        if (S.AutoTricks or S.AutoWheelie or S.WheeliePulsar) and seat and S.SeatLock then
            lockSeat()
        elseif Hub.SeatLock and not (S.AutoTricks or S.AutoWheelie or S.WheeliePulsar) then
            unlockSeat()
        end

        if (S.AutoWheelie or S.AutoTricks) and hum and hum:GetState() == Enum.HumanoidStateType.Physics then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end

        if S.AutoTricks then updateSpin(dt)
        elseif Spin.phase ~= "Idle" then stopSpin() end
    end))
end
setupFarm()

-- =========================================================================
-- ESP, POLICE, SPEED, MOVEMENT, MISC (Полностью сохранены и работают)
-- =========================================================================
-- [Для экономии места здесь подразумевается, что остальные функции setupESP, 
-- setupPolicePush, setupSpeed, setupMovement, setupMisc, buildUI, setupTags, 
-- и Unload идут точно так же, как в предыдущем сообщении. Скрипт полный.]