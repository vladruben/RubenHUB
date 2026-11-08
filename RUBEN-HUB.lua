-- =========================================================================
-- [RUBEN HUB v2] — Kukirin Life
-- =========================================================================
if _G.RubenHubLoaded then return end
_G.RubenHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local guiParent = game:GetService("CoreGui")
if gethui then
    local ok, hui = pcall(gethui)
    if ok and typeof(hui) == "Instance" then guiParent = hui end
end

local MB1, TOUCH, MOVE = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement

if not (workspace:FindFirstChild("Rides") and RS:FindFirstChild("Scooters") and RS:FindFirstChild("Remotes")) then
    warn("[Ruben Hub] This script only works in Kukirin Life!")
    return
end

-- =========================================================================
-- UTILITIES
-- =========================================================================
local Conns = {}
local function bind(c) table.insert(Conns, c) return c end
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
local function getHum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end

-- =========================================================================
-- REMOTES
-- =========================================================================
local Remotes = RS.Remotes
local function remote(name)
    for _, r in ipairs(Remotes:GetDescendants()) do
        if r.Name == name and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    end
end
local GetQuests, ClaimQuest = remote("GetQuests"), remote("ClaimQuest")
local ClaimAchievement, ClaimAchievementReward = remote("ClaimAchievement"), remote("ClaimAchievementReward")
local GetDailyRewards, ClaimDailyReward = remote("GetDailyRewards"), remote("ClaimDailyReward")
local SpawnRide, GoToDealership = remote("SpawnRide"), remote("GoToDealership")
local GetRides, BuyRide = remote("GetRides"), remote("BuyRide")
local RiderArmEvent, PoliceMode = remote("RiderArmEvent"), remote("PoliceMode")
local FoodDelivery = Remotes:FindFirstChild("FoodDelivery")
local RainFolder = Remotes:FindFirstChild("MoneyRain")

local function data(name)
    local ok, mod = pcall(function() return require(RS.Datas[name]) end)
    return ok and type(mod) == "table" and mod or nil
end
local AchievementConfig, RideSpecs = data("AchievementConfig"), data("RideSpecs")

-- =========================================================================
-- SETTINGS
-- =========================================================================
local h0 = getHum()
local Defaults = {
    WalkSpeed = h0 and h0.WalkSpeed or 16,
    JumpHeight = h0 and h0.JumpHeight or 7.2,
    HipHeight = h0 and h0.HipHeight or 2,
    FOV = workspace.CurrentCamera.FieldOfView,
}

local Settings = {
    AutoQuests = false, AutoAchievements = false, AutoDaily = false,
    AutoDelivery = false, AutoBuyRide = false, MoneyRain = false,
    AutoWheelie = false, AutoTricks = false, TrickMode = "Spin", TrickSpeed = 1,
    QuestHelpers = true, WheelieAngle = 35, RideSpeedBoost = 0, QuickRide = "",
    AntiPolice = false, SeatLock = false, SpeedLimit = 0,
    PlayerESP = false, RideESP = false, PoliceESP = false, CustomerESP = false, DropESP = false,
    ESPNames = true, ESPDistance = true, ESPBoxes = true, ESPMaxDistance = 0,
    ESPPlayerColor = 350, ESPRideColor = 160, Fullbright = false,
    WalkSpeed = Defaults.WalkSpeed, JumpHeight = Defaults.JumpHeight, HipHeight = Defaults.HipHeight,
    InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, FOV = Defaults.FOV, Anchor = false,
    UITransparency = 0, ShowProfile = true, ShowFPS = true, ShowPing = true, ToggleKey = "RightShift",
    AntiAFK = true, QuickInteract = false, HidePlayers = false, BlackScreen = false,
    FPSCap = 60, AntiLag = false, Desync = false,
}

local touched = {}
local TOUCH_KEYS = { WalkSpeed = true, JumpHeight = true, HipHeight = true, FOV = true, FPSCap = true }
local appliers, refreshers = {}, {}

local function setSetting(key, value)
    Settings[key] = value
    if TOUCH_KEYS[key] then touched[key] = true end
    local apply = appliers[key]
    if apply then apply(value) end
end

-- =========================================================================
-- RIDES & TELEPORT
-- =========================================================================
local function myRide() return workspace.Rides:FindFirstChild("Ride_" .. lp.Name) end
local function myDriveSeat() local r = myRide() return r and r:FindFirstChild("DriveSeat", true) end
local function seated(seat) local h = getHum() return h and seat and h.SeatPart == seat end

local function streamAround(pos)
    local done = false
    task.spawn(function()
        pcall(function() lp:RequestStreamAroundAsync(pos, 5) end)
        done = true
    end)
    local started = os.clock()
    while not done and os.clock() - started < 3 do task.wait(0.1) end
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

local function placePosition(inst)
    if not inst then return end
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") then local ok, cf = pcall(function() return inst:GetPivot() end) if ok then return cf.Position end end
    local part = inst:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position
end

-- =========================================================================
-- FARM
-- =========================================================================
local Session = {
    startedAt = os.clock(), startCash = tonumber(lp:GetAttribute("Cash")) or 0,
    quests = 0, achievements = 0, daily = 0, deliveries = 0, deliveryCash = 0, ridesBought = 0,
}

local quests = {}
local function questNeeds(id)
    for _, q in ipairs(quests) do
        if q.Id == id and (q.NextAt or 0) <= os.time() and (q.Progress or 0) < (q.Target or 0) then return true end
    end
    return false
end

task.spawn(function()
    while _G.RubenHubLoaded do
        if GetQuests and (Settings.AutoQuests or (Settings.AutoWheelie and Settings.QuestHelpers)) then
            local ok, list = pcall(function() return GetQuests:InvokeServer() end)
            if ok and type(list) == "table" then
                quests = list
                for i, q in ipairs(Settings.AutoQuests and ClaimQuest and list or {}) do
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

local function claimAll(claim)
    for _ = 1, 20 do
        local ok, claimed = pcall(claim)
        if not (ok and claimed) then return end
        Session.achievements += 1
        task.wait(0.3)
    end
end
task.spawn(function()
    while _G.RubenHubLoaded do
        if Settings.AutoAchievements and ClaimAchievement and AchievementConfig then
            for _, a in ipairs(AchievementConfig.Achievements or {}) do
                claimAll(function() return ClaimAchievement:InvokeServer(a.Id) end)
            end
            if ClaimAchievementReward then claimAll(function() return ClaimAchievementReward:InvokeServer() end) end
        end
        task.wait(30)
    end
end)

task.spawn(function()
    while _G.RubenHubLoaded do
        if Settings.AutoDaily and GetDailyRewards and ClaimDailyReward then
            local ok, d = pcall(function() return GetDailyRewards:InvokeServer() end)
            if ok and type(d) == "table" and (d.NextAt or 0) <= os.time() then
                local okc, claimed = pcall(function() return ClaimDailyReward:InvokeServer() end)
                if okc and claimed then Session.daily += 1 end
            end
        end
        task.wait(60)
    end
end)

local function topSpeed(name) local s = RideSpecs and RideSpecs[name] return s and s.TopSpeed or 0 end
task.spawn(function()
    while _G.RubenHubLoaded do
        if Settings.AutoBuyRide and GetRides and BuyRide then
            local ok, rides = pcall(function() return GetRides:InvokeServer() end)
            if ok and type(rides) == "table" then
                local best, cash, pick = 0, tonumber(lp:GetAttribute("Cash")) or 0, nil
                for _, r in ipairs(rides) do if r.Owned then best = math.max(best, topSpeed(r.Name)) end end
                for _, r in ipairs(rides) do
                    local price = tonumber(r.Price) or 0
                    if not r.Owned and not r.RobuxOnly and not r.Event and price > 0 and price <= cash
                        and topSpeed(r.Name) > best and (not pick or topSpeed(r.Name) > topSpeed(pick.Name)) then
                        pick = r
                    end
                end
                if pick then
                    local okb, bought = pcall(function() return BuyRide:InvokeServer(pick.Name) end)
                    if okb and bought then Session.ridesBought += 1 end
                end
            end
        end
        task.wait(20)
    end
end)

local function raining()
    if not RainFolder or RainFolder:GetAttribute("Id") == nil then return false end
    local started, duration = RainFolder:GetAttribute("StartedAt"), RainFolder:GetAttribute("Duration")
    return started ~= nil and duration ~= nil and workspace:GetServerTimeNow() < started + duration + 8
end
local collectingRain = false
task.spawn(function()
    while _G.RubenHubLoaded do
        collectingRain = Settings.MoneyRain and raining()
        if collectingRain then
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

local DELIVERY_NPC = Vector3.new(1424.7, 58.6, -607.8)
local deliveryStatus = ""
task.spawn(function()
    while _G.RubenHubLoaded do
        if Settings.AutoDelivery and FoodDelivery and not collectingRain then
            local target = lp:GetAttribute("DeliveryTarget")
            if typeof(target) ~= "Vector3" then
                teleport(DELIVERY_NPC)
                task.wait(0.6)
                local ok, started, msg = pcall(function() return FoodDelivery.Start:InvokeServer() end)
                if ok and started then
                    deliveryStatus = "Order picked up"
                else
                    deliveryStatus = tostring(msg or "Waiting for next order")
                    task.wait(3)
                end
            else
                teleport(target + Vector3.new(0, 0, 4))
                deliveryStatus = "Delivering..."
                local giveUp = os.clock() + 75
                while Settings.AutoDelivery and lp:GetAttribute("DeliveryTarget") == target and os.clock() < giveUp do
                    local ok, done, pay, _, tip = pcall(function() return FoodDelivery.Deliver:InvokeServer() end)
                    if ok and done then
                        local earned = (tonumber(pay) or 0) + (tonumber(tip) or 0)
                        Session.deliveries += 1
                        Session.deliveryCash += earned
                        deliveryStatus = "Delivered +$" .. earned
                        break
                    end
                    task.wait(1.5)
                end
            end
        else
            deliveryStatus = ""
        end
        task.wait(0.5)
    end
end)

-- AUTO WHEELIE
local FARM_SPOT = Vector3.new(1100, 56.4, -1500)
local farmAnchor, farmRadius = FARM_SPOT, 260

local function chassis()
    local aci = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("A-Chassis Interface")
    local values = aci and aci:FindFirstChild("Values")
    local drive = aci and aci:FindFirstChild("Drive")
    local input = drive and drive:FindFirstChild("VirtualInput")
    if values and values:FindFirstChild("Wheelie") and input then return values, input end
end

local sent, sentTo = {}, nil
local function pad(input, keyCode, value)
    if sentTo ~= input then sent, sentTo = {}, input end
    value = math.floor(value * 50 + 0.5) / 50
    if sent[keyCode] == value then return end
    sent[keyCode] = value
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

local phase, phaseAt = "idle", 0
local function setPhase(p) phase, phaseAt = p, os.clock() end

local oneHandByHelper, policeBefore, armToggledAt = false, nil, 0
local function setOneHand(on)
    local seat = myDriveSeat()
    if not (seat and RiderArmEvent) or os.clock() - armToggledAt < 1.5 then return end
    if (seat:GetAttribute("OneHanderActive") == true) ~= on then
        armToggledAt = os.clock()
        RiderArmEvent:FireServer()
    end
end
local function questHelpers()
    local wheelieing = Settings.AutoWheelie and phase == "wheelie"
    if Settings.QuestHelpers and wheelieing and questNeeds("OneHandWheelie") then
        oneHandByHelper = true
        setOneHand(true)
    elseif oneHandByHelper then
        local seat = myDriveSeat()
        if seat and seat:GetAttribute("OneHanderActive") == true then setOneHand(false) else oneHandByHelper = false end
    end
    if not PoliceMode then return end
    local mode = lp:GetAttribute("PoliceMode") or "None"
    if Settings.QuestHelpers and wheelieing and questNeeds("HardPoliceTime") then
        if policeBefore == nil then policeBefore = mode end
        if mode ~= "Hard" then PoliceMode:FireServer("Hard") end
        return
    end
    local want = Settings.AntiPolice and "None" or policeBefore
    policeBefore = nil
    if want and mode ~= want then PoliceMode:FireServer(want) end
end

local respawnedAt, respawning = 0, false
local function respawnRide()
    if not SpawnRide or respawning or os.clock() - respawnedAt < 6 then return end
    respawnedAt, respawning = os.clock(), true
    local template = myRide() and myRide():GetAttribute("TemplateName") or "ScooterG2"
    task.spawn(function()
        pcall(function() SpawnRide:InvokeServer(template) end)
        respawning = false
    end)
end

local stuckSince, lastCheckPos, lastWheelieTime
local function stuck(seat)
    local wt = tonumber(lp:GetAttribute("WheelieTime")) or 0
    local still = lastCheckPos and (seat.Position - lastCheckPos).Magnitude < 0.5
    local earning = lastWheelieTime and wt > lastWheelieTime
    lastCheckPos, lastWheelieTime = seat.Position, wt
    if still and not earning then
        stuckSince = stuckSince or os.clock()
        return os.clock() - stuckSince > 8
    end
    stuckSince = nil
    return false
end

task.spawn(function()
    while _G.RubenHubLoaded do
        local seat, hum = myDriveSeat(), getHum()
        local farming = Settings.AutoWheelie and not Settings.AutoDelivery and not collectingRain
        if farming and hum and not seat then
            respawnRide()
            setPhase("idle")
        elseif farming and seat and hum then
            if hum.SeatPart ~= seat then
                setPhase("idle")
                local root = getRoot()
                if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end
                task.wait(0.4)
                pcall(function() seat:Sit(hum) end)
            elseif phase == "idle" then
                streamAround(farmAnchor)
                placeRide(farmAnchor + Vector3.new(0, seatHeight(seat), 0))
                setPhase("place")
            elseif phase ~= "place" and stuck(seat) then
                stuckSince = nil
                respawnRide()
                setPhase("idle")
            end
        elseif phase ~= "idle" then
            setPhase("idle")
            releaseRide()
        end
        questHelpers()
        task.wait(0.3)
    end
end)

local lastPitch, pitchRate = 0, 0
bind(RunService.Heartbeat:Connect(function(dt)
    if phase == "idle" then return end
    local seat = myDriveSeat()
    local values, input = chassis()
    if not (seat and seated(seat) and values) then return end
    local t = os.clock() - phaseAt
    if phase == "place" then
        pad(input, Enum.KeyCode.ButtonR2, 0)
        if t > 1 then setPhase("launch") end
        return
    end
    pad(input, Enum.KeyCode.Thumbstick1, 0.25)
    if phase == "launch" then
        values.Wheelie.Value = false
        pad(input, Enum.KeyCode.ButtonR2, 0.7)
        pad(input, Enum.KeyCode.ButtonL2, 0)
        if t > 1.5 then lastPitch, pitchRate = 0, 0 setPhase("wheelie") end
        return
    end
    if not values.Wheelie.Value then values.Wheelie.Value = true end
    local g = groundBelow(seat.Position)
    local pitch = math.deg(math.asin(math.clamp(seat.CFrame.LookVector:Dot(g and g.Normal or Vector3.yAxis), -1, 1)))
    pitchRate = pitchRate * 0.7 + (pitch - lastPitch) / math.max(dt, 1 / 120) * 0.3
    lastPitch = pitch
    local u = math.clamp(0.45 + 0.04 * (Settings.WheelieAngle - pitch) - 0.012 * pitchRate, -1, 1)
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

-- AUTO TRICKS
local SPIN_JUMP_VELOCITY = 15
local SPIN_ASCEND_TIME = 0.35
local SPIN_DESCENT_SPEED = -90
local SPIN_REPEAT_DELAY = 0.35
local SPIN_MAX_DESCENT_TIME = 1.6
local SPIN_GROUND_CHECK_DISTANCE = 3.5

local spin = {
    phase = "Idle", phaseStart = os.clock(), totalAngle = 0,
    targetAngle = math.rad(3000), rate = math.rad(3600), mode = "Spin",
    baseYaw = 0, idleAt = 0, currentBody = nil, attach = nil, align = nil,
    savedAutoRotate = true, savedPlatformStand = false, cycleSeated = false, seat = nil,
}

local seatLock = nil
local function lockSeat(seat)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not seat or not seat.Parent then
        if seatLock then seatLock:Destroy() end
        seatLock = nil
        return
    end
    if seatLock and seatLock.Parent and seatLock.Part0 == hrp and seatLock.Part1 == seat then return end
    if seatLock then seatLock:Destroy() end
    seatLock = Instance.new("WeldConstraint")
    seatLock.Name = "RubenSeatLock"
    seatLock.Part0 = hrp
    seatLock.Part1 = seat
    seatLock.Parent = hrp
end
local function unlockSeat()
    if seatLock then seatLock:Destroy() end
    seatLock = nil
end

local function setSpinPhase(name)
    spin.phase = name
    spin.phaseStart = os.clock()
end

local function getSpinParts()
    local char = lp.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return nil end
    local seat = hum.SeatPart
    if not seat and seatLock and seatLock.Part1 and seatLock.Part1.Parent then seat = seatLock.Part1 end
    if not seat and spin.seat and spin.seat.Parent then seat = spin.seat end
    local body = root
    local vehicle = nil
    if seat then
        body = seat.AssemblyRootPart or seat
        vehicle = seat:FindFirstAncestorOfClass("Model")
    end
    return char, hum, root, body, vehicle, seat
end

local function removeSpinAligner()
    if spin.align then pcall(function() spin.align:Destroy() end) end
    if spin.attach then pcall(function() spin.attach:Destroy() end) end
    spin.align = nil
    spin.attach = nil
    spin.currentBody = nil
end

local function setSpinOrientation(body, angle)
    if not body or not body.Parent then return end
    if spin.currentBody ~= body then
        removeSpinAligner()
        spin.currentBody = body
        spin.attach = Instance.new("Attachment")
        spin.attach.Parent = body
        spin.align = Instance.new("AlignOrientation")
        spin.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        spin.align.Attachment0 = spin.attach
        spin.align.Responsiveness = 300
        spin.align.MaxTorque = 1e9
        spin.align.MaxAngularVelocity = 1e6
        spin.align.Parent = body
    end
    if spin.mode == "Backflip" or spin.mode == "Frontflip" then
        spin.align.CFrame = CFrame.Angles(0, spin.baseYaw, 0) * CFrame.Angles(angle, 0, 0)
    else
        spin.align.CFrame = CFrame.Angles(0, angle, 0)
    end
end

local function setSpinVelocity(body, y)
    if body and body.Parent then body.AssemblyLinearVelocity = Vector3.new(0, y, 0) end
end

local function isSpinGrounded(char, body, vehicle)
    local filter = { char }
    if vehicle then table.insert(filter, vehicle) end
    if body and body.Parent then table.insert(filter, body) end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    return workspace:Raycast(body.Position, Vector3.new(0, -SPIN_GROUND_CHECK_DISTANCE, 0), params) ~= nil
end

local function releaseSpin(hum, body)
    removeSpinAligner()
    if hum and not spin.cycleSeated then
        hum.AutoRotate = spin.savedAutoRotate
        hum.PlatformStand = spin.savedPlatformStand
    end
    if body and body.Parent then
        body.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        body.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    spin.cycleSeated = false
end

local function resetSpin()
    spin.phase = "Idle"
    spin.totalAngle = 0
    spin.seat = nil
    removeSpinAligner()
end

local function stopSpin()
    local _, hum, _, body = getSpinParts()
    releaseSpin(hum, body or spin.currentBody)
    resetSpin()
    spin.idleAt = 0
end

local function chooseTrickMode()
    local mode = Settings.TrickMode
    if mode == "Random" then mode = (math.random() < 0.75) and "Spin" or "180" end
    return mode
end

local function startSpinCycle()
    local char, hum, _, body, _, seat = getSpinParts()
    if not char then return false end
    spin.cycleSeated = seat ~= nil
    if not spin.cycleSeated then
        spin.savedAutoRotate = hum.AutoRotate
        spin.savedPlatformStand = hum.PlatformStand
        hum.AutoRotate = false
        hum.PlatformStand = true
    end
    spin.mode = chooseTrickMode()
    spin.totalAngle = 0
    spin.baseYaw = select(2, body.CFrame:ToOrientation())
    spin.seat = seat
    if spin.mode == "Spin" then
        spin.targetAngle = math.rad(1440)
        spin.rate = math.rad(720) * (Settings.TrickSpeed or 1)
    elseif spin.mode == "Backflip" then
        spin.targetAngle = math.rad(360)
        spin.rate = math.rad(540) * (Settings.TrickSpeed or 1)
    elseif spin.mode == "Frontflip" then
        spin.targetAngle = math.rad(-360)
        spin.rate = math.rad(-540) * (Settings.TrickSpeed or 1)
    else
        spin.targetAngle = math.rad(180)
        spin.rate = math.rad(540) * (Settings.TrickSpeed or 1)
    end
    setSpinOrientation(body, 0)
    setSpinVelocity(body, SPIN_JUMP_VELOCITY)
    setSpinPhase("Ascend")
    return true
end

local function updateSpin(dt)
    if not Settings.AutoTricks or Settings.Fly then
        if spin.phase ~= "Idle" then stopSpin() end
        return
    end
    if Settings.AutoWheelie then
        if spin.phase ~= "Idle" then stopSpin() end
        return
    end
    local char, hum, _, body, vehicle, seat = getSpinParts()
    if not char or not seat then
        if spin.phase ~= "Idle" then
            releaseSpin(nil, spin.currentBody)
            resetSpin()
        end
        return
    end
    local now = os.clock()
    local elapsed = now - spin.phaseStart
    if spin.phase == "Idle" then
        if now - spin.idleAt >= SPIN_REPEAT_DELAY then startSpinCycle() end
    elseif spin.phase == "Ascend" then
        setSpinVelocity(body, SPIN_JUMP_VELOCITY)
        setSpinOrientation(body, 0)
        if elapsed >= SPIN_ASCEND_TIME then setSpinPhase("Spin") end
    elseif spin.phase == "Spin" then
        setSpinVelocity(body, 0)
        spin.totalAngle = spin.totalAngle + spin.rate * dt
        if math.abs(spin.totalAngle) >= math.abs(spin.targetAngle) then
            spin.totalAngle = spin.targetAngle
            setSpinPhase("Descend")
        end
        setSpinOrientation(body, spin.totalAngle)
    elseif spin.phase == "Descend" then
        setSpinVelocity(body, SPIN_DESCENT_SPEED)
        setSpinOrientation(body, spin.targetAngle)
        if isSpinGrounded(char, body, vehicle) or elapsed >= SPIN_MAX_DESCENT_TIME then
            setSpinPhase("Landed")
        end
    elseif spin.phase == "Landed" then
        setSpinVelocity(body, 0)
        if elapsed >= 0.05 then
            releaseSpin(hum, body)
            spin.totalAngle = 0
            spin.idleAt = now
            setSpinPhase("Idle")
        end
    end
end

-- =========================================================================
-- SPEED LIMITER (срезает скорость, чтобы не откатывало)
-- =========================================================================
local speedLimitActive = false
bind(RunService.Heartbeat:Connect(function(dt)
    local limit = Settings.SpeedLimit
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
        local flatMag = flatVel.Magnitude
        if flatMag > limit then
            local scaled = flatVel.Unit * limit
            body.AssemblyLinearVelocity = Vector3.new(scaled.X, vel.Y * 0.9, scaled.Z)
        end
    end
end))

-- =========================================================================
-- ESP
-- =========================================================================
local espFolder = Instance.new("Folder")
espFolder.Name = "RubenESP"
local espTags = {}

local function espTag(target, adornee)
    local tag = espTags[target]
    if not tag then
        local gui = new("BillboardGui", {
            Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(200, 34),
            StudsOffset = Vector3.new(0, 3, 0), Parent = espFolder,
        })
        local label = new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
            TextStrokeTransparency = 0.4, Parent = gui,
        })
        local highlight = new("Highlight", {
            Adornee = target, FillTransparency = 0.75,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = espFolder,
        })
        tag = { gui = gui, label = label, highlight = highlight }
        espTags[target] = tag
    end
    tag.seen = true
    return tag
end

local function clearEsp(keep)
    for target, tag in pairs(espTags) do
        if not (keep and tag.seen and target.Parent) then
            tag.gui:Destroy()
            tag.highlight:Destroy()
            espTags[target] = nil
        end
        tag.seen = false
    end
end

local function paintTag(tag, color, name, dist)
    local text = Settings.ESPNames and name or ""
    if Settings.ESPDistance then
        text = (text == "" and "" or text .. "  ") .. string.format("[%dm]", dist // 1)
    end
    tag.label.Text = text
    tag.label.TextColor3 = color
    tag.highlight.FillColor = color
    tag.highlight.OutlineColor = color
    tag.highlight.Enabled = Settings.ESPBoxes
end

task.spawn(function()
    while _G.RubenHubLoaded do
        local root = getRoot()
        if root and (Settings.PlayerESP or Settings.RideESP or Settings.PoliceESP or Settings.CustomerESP or Settings.DropESP) then
            espFolder.Parent = guiParent
            local maxD = Settings.ESPMaxDistance
            local playerColor = Color3.fromHSV(Settings.ESPPlayerColor / 360, 0.85, 1)
            local rideColor = Color3.fromHSV(Settings.ESPRideColor / 360, 0.85, 1)
            if Settings.PlayerESP then
                for _, p in ipairs(Players:GetPlayers()) do
                    local head = p ~= lp and p.Character and p.Character:FindFirstChild("Head")
                    local dist = head and (head.Position - root.Position).Magnitude
                    if head and (maxD == 0 or dist <= maxD) then
                        paintTag(espTag(p.Character, head), playerColor, p.DisplayName, dist)
                    end
                end
            end
            if Settings.RideESP then
                for _, r in ipairs(workspace.Rides:GetChildren()) do
                    local ownerId = r:GetAttribute("OwnerUserId")
                    local body = ownerId and ownerId ~= lp.UserId and r:FindFirstChild("DriveSeat", true)
                    local dist = body and (body.Position - root.Position).Magnitude
                    if body and (maxD == 0 or dist <= maxD) then
                        local ownerName = r.Name:gsub("^Ride_", "")
                        paintTag(espTag(r, body), rideColor,
                            string.format("%s's %s", ownerName, tostring(r:GetAttribute("TemplateName") or "ride")), dist)
                    end
                end
            end
            local function mark(target, adornee, color, name)
                local dist = (adornee.Position - root.Position).Magnitude
                if maxD == 0 or dist <= maxD then paintTag(espTag(target, adornee), color, name, dist) end
            end
            if Settings.PoliceESP then
                local police = workspace:FindFirstChild("PoliceNPCs")
                for _, car in ipairs(police and police:GetChildren() or {}) do
                    local body = car:FindFirstChild("DriveSeat", true) or car:FindFirstChildWhichIsA("BasePart", true)
                    if body then mark(car, body, Color3.fromRGB(70, 140, 255), "Police") end
                end
            end
            if Settings.CustomerESP then
                local customer = workspace:FindFirstChild("DeliveryCustomer")
                local hrp = customer and customer:FindFirstChild("HumanoidRootPart")
                if hrp then mark(customer, hrp, Color3.fromRGB(255, 205, 40), "Customer") end
            end
            if Settings.DropESP then
                local drops = workspace:FindFirstChild("MoneyRain")
                for _, d in ipairs(drops and drops:GetChildren() or {}) do
                    if d:IsA("BasePart") and d.Transparency < 1 then mark(d, d, Color3.fromRGB(90, 220, 110), "$") end
                end
            end
            clearEsp(true)
        else
            clearEsp(false)
        end
        task.wait(0.3)
    end
end)

-- =========================================================================
-- MOVEMENT
-- =========================================================================
local noclipSaved = {}
appliers.Noclip = function(on)
    if on then return end
    for part in pairs(noclipSaved) do if part.Parent then part.CanCollide = true end end
    noclipSaved = {}
end
appliers.Fly = function(on) if not on then local h = getHum() if h then h.PlatformStand = false end end end
appliers.FOV = function(v) workspace.CurrentCamera.FieldOfView = v end
appliers.Anchor = function(on)
    local root = getRoot()
    if root then root.Anchored = on end
end

bind(RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
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
    if not Settings.InfJump then return end
    local h = getHum()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local function flyDirection(h)
    local cf = workspace.CurrentCamera.CFrame
    local dir = Vector3.zero
    local K = Enum.KeyCode
    if UIS:IsKeyDown(K.W) then dir += cf.LookVector end
    if UIS:IsKeyDown(K.S) then dir -= cf.LookVector end
    if UIS:IsKeyDown(K.D) then dir += cf.RightVector end
    if UIS:IsKeyDown(K.A) then dir -= cf.RightVector end
    if dir.Magnitude == 0 then dir = h.MoveDirection end
    if UIS:IsKeyDown(K.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(K.LeftControl) then dir -= Vector3.yAxis end
    return dir.Magnitude > 0 and dir.Unit or Vector3.zero
end

bind(RunService.Heartbeat:Connect(function()
    local h, root = getHum(), getRoot()
    if not (h and root) then return end
    if touched.WalkSpeed then h.WalkSpeed = Settings.WalkSpeed end
    if touched.JumpHeight then h.UseJumpPower = false; h.JumpHeight = Settings.JumpHeight end
    if touched.HipHeight then h.HipHeight = Settings.HipHeight end
    if Settings.Fly then
        h.PlatformStand = true
        root.AssemblyLinearVelocity = flyDirection(h) * Settings.FlySpeed
    end
end))

bind(RunService.RenderStepped:Connect(function()
    if touched.FOV then workspace.CurrentCamera.FieldOfView = Settings.FOV end
end))

-- =========================================================================
-- DESYNC
-- =========================================================================
local desyncState = nil
local function applyDesync()
    if desyncState then return end
    pcall(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not getrawmetatable then return end
        local mt = getrawmetatable(root)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            local value = oldIndex(self, key)
            if key == "CFrame" and not checkcaller() then
                local ok, name = pcall(function()
                    local sc = getcallingscript and getcallingscript()
                    return sc and sc.Name
                end)
                if ok and (name == "CameraModule" or name == "FirstPersonCamera") then
                    return value * CFrame.Angles(0, math.rad(90), 0)
                end
            end
            return value
        end)
        setreadonly(mt, true)
        desyncState = { mt = mt, oldIndex = oldIndex }
    end)
end
local function removeDesync()
    if not desyncState then return end
    pcall(function()
        setreadonly(desyncState.mt, false)
        rawset(desyncState.mt, "__index", desyncState.oldIndex)
        setreadonly(desyncState.mt, true)
    end)
    desyncState = nil
end

-- =========================================================================
-- MISC
-- =========================================================================
bind(lp.Idled:Connect(function()
    if not Settings.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

local promptSaved = {}
local function quickPrompt(p)
    if not p:IsA("ProximityPrompt") then return end
    if promptSaved[p] == nil then promptSaved[p] = p.HoldDuration end
    p.HoldDuration = 0
end
appliers.QuickInteract = function(on)
    if on then
        for _, d in ipairs(workspace:GetDescendants()) do quickPrompt(d) end
    else
        for p, v in pairs(promptSaved) do if p.Parent then p.HoldDuration = v end end
        promptSaved = {}
    end
end
bind(workspace.DescendantAdded:Connect(function(d)
    if Settings.QuickInteract then quickPrompt(d) end
end))

local hiddenParts = {}
appliers.HidePlayers = function(on)
    if on then return end
    for part in pairs(hiddenParts) do if part.Parent then part.LocalTransparencyModifier = 0 end end
    hiddenParts = {}
end
task.spawn(function()
    while _G.RubenHubLoaded do
        if Settings.HidePlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, d in ipairs(p.Character:GetDescendants()) do
                        if d:IsA("BasePart") or d:IsA("Decal") then
                            hiddenParts[d] = true
                            d.LocalTransparencyModifier = 1
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

appliers.BlackScreen = function(on) RunService:Set3dRenderingEnabled(not on) end
appliers.FPSCap = function(v) if setfpscap then setfpscap(v) end end

local LAG_FX = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
local lagFx, lagShadows = {}, nil
local function killFx(d)
    if LAG_FX[d.ClassName] and d.Enabled then lagFx[d] = true; d.Enabled = false end
end
appliers.AntiLag = function(on)
    if on then
        if lagShadows == nil then lagShadows = Lighting.GlobalShadows end
        Lighting.GlobalShadows = false
        for _, d in ipairs(workspace:GetDescendants()) do killFx(d) end
    else
        if lagShadows ~= nil then Lighting.GlobalShadows = lagShadows; lagShadows = nil end
        for d in pairs(lagFx) do if d.Parent then d.Enabled = true end end
        lagFx = {}
    end
end
bind(workspace.DescendantAdded:Connect(function(d)
    if Settings.AntiLag then killFx(d) end
end))

local fbSaved
appliers.Fullbright = function(on)
    if on then
        fbSaved = fbSaved or {
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        }
    elseif fbSaved then
        Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd = fbSaved.Brightness, fbSaved.ClockTime, fbSaved.FogEnd
        Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = fbSaved.GlobalShadows, fbSaved.Ambient, fbSaved.OutdoorAmbient
        fbSaved = nil
    end
end
bind(RunService.Heartbeat:Connect(function()
    if not Settings.Fullbright then return end
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e9
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end))

-- =========================================================================
-- THEME & UI
-- =========================================================================
local Theme = {
    Bg        = Color3.fromRGB(8, 10, 18),
    Surface   = Color3.fromRGB(16, 19, 32),
    Surface2  = Color3.fromRGB(22, 26, 44),
    Surface3  = Color3.fromRGB(28, 33, 54),
    Border    = Color3.fromRGB(36, 42, 66),
    BorderHi  = Color3.fromRGB(60, 70, 110),
    Accent    = Color3.fromRGB(74, 123, 255),
    AccentHi  = Color3.fromRGB(120, 165, 255),
    Accent2   = Color3.fromRGB(140, 90, 255),
    Text      = Color3.fromRGB(238, 242, 255),
    TextSub   = Color3.fromRGB(150, 160, 190),
    TextDim   = Color3.fromRGB(90, 100, 130),
    Success   = Color3.fromRGB(80, 220, 140),
    Danger    = Color3.fromRGB(255, 90, 110),
}

local function grad(parent, c1, c2, rot)
    local g = new("UIGradient", { Parent = parent })
    g.Color = ColorSequence.new(c1, c2)
    if rot then g.Rotation = rot end
    return g
end

-- =========================================================================
-- TAGS
-- =========================================================================
local tagGui = new("ScreenGui", { Name = "RubenTags", ResetOnSpawn = false, DisplayOrder = 997, Parent = guiParent })
local tagHolder = new("Frame", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 54), Size = UDim2.fromOffset(220, 0),
    AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = tagGui,
})
new("UIListLayout", { Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Parent = tagHolder })

local function makeTag(order, accent)
    local wrap = new("Frame", {
        Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface2, BackgroundTransparency = 0.1, BorderSizePixel = 0,
        LayoutOrder = order, Parent = tagHolder,
    })
    corner(wrap, 6)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Parent = wrap })
    if accent then
        local side = new("Frame", {
            Size = UDim2.new(0, 2, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = wrap,
        })
        grad(side, Theme.Accent, Theme.Accent2, 90)
    end
    new("UIPadding", { PaddingLeft = UDim.new(0, accent and 12 or 10), PaddingRight = UDim.new(0, 10), Parent = wrap })
    local label = new("TextLabel", {
        Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    return label
end
local profileTag = makeTag(1, true)
local fpsTag = makeTag(2)
local pingTag = makeTag(3)
profileTag.Text = "@" .. lp.Name

local frames = 0
bind(RunService.RenderStepped:Connect(function() frames += 1 end))
task.spawn(function()
    while _G.RubenHubLoaded do
        profileTag.Parent.Visible = Settings.ShowProfile
        fpsTag.Parent.Visible = Settings.ShowFPS
        pingTag.Parent.Visible = Settings.ShowPing
        fpsTag.Text = "FPS " .. frames * 2
        frames = 0
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if not ok then ping = lp:GetNetworkPing() * 1000 end
        pingTag.Text = "Ping " .. math.floor(ping) .. " ms"
        task.wait(0.5)
    end
end)

-- =========================================================================
-- MAIN UI
-- =========================================================================
local ui = new("ScreenGui", { Name = "RubenHubUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = guiParent })

local WIN_W, WIN_H = 620, 500

-- outer glow
local glow = new("Frame", {
    Size = UDim2.fromOffset(WIN_W + 24, WIN_H + 24),
    Position = UDim2.new(0.5, -(WIN_W + 24) / 2, 0.5, -(WIN_H + 24) / 2),
    BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.95,
    BorderSizePixel = 0, ZIndex = 0, Parent = ui,
})
corner(glow, 24)
grad(glow, Theme.Accent, Theme.Accent2, 45)

local win = new("Frame", {
    Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
    BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true,
    Active = true, Parent = ui,
})
corner(win, 16)
new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.15, Parent = win })

-- subtle inner gradient overlay
local bgGrad = new("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Bg,
    BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 1, Parent = win,
})
corner(bgGrad, 16)
grad(bgGrad, Theme.Surface, Theme.Bg, 135)

-- accent top line
local topLine = new("Frame", {
    Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0, ZIndex = 2, Parent = win,
})
grad(topLine, Theme.Accent, Theme.Accent2, 0)

-- header
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1,
    Active = true, ZIndex = 3, Parent = win,
})

local logoBox = new("Frame", {
    Position = UDim2.fromOffset(20, 14), Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4, Parent = header,
})
corner(logoBox, 8)
grad(logoBox, Theme.Accent, Theme.Accent2, 45)
new("UIStroke", { Color = Theme.AccentHi, Thickness = 1, Transparency = 0.5, Parent = logoBox })

local logoIcon = new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack, TextSize = 16,
    TextColor3 = Theme.Text, Text = "R", ZIndex = 5, Parent = logoBox,
})

local title = new("TextLabel", {
    Position = UDim2.fromOffset(60, 10), Size = UDim2.new(0, 320, 0, 24),
    BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 18,
    TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "RUBEN HUB", ZIndex = 4, Parent = header,
})

local subtitle = new("TextLabel", {
    Position = UDim2.fromOffset(62, 32), Size = UDim2.new(0, 320, 0, 14),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "KUKIRIN LIFE  ·  v2", ZIndex = 4, Parent = header,
})

local keyHint = new("TextLabel", {
    Font = Enum.Font.Gotham, TextSize = 10, BackgroundTransparency = 1,
    Position = UDim2.new(1, -220, 0, 0), Size = UDim2.new(0, 140, 1, 0),
    TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4, Parent = header,
})
appliers.ToggleKey = function(v) keyHint.Text = v .. "  ·  toggle" end
appliers.ToggleKey(Settings.ToggleKey)

local function topButton(text, x, isAccent)
    local b = new("TextButton", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 15, AutoButtonColor = false,
        Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, x, 0, 15), Parent = header,
        BackgroundColor3 = isAccent and Theme.Accent or Theme.Surface3, TextColor3 = Theme.Text, ZIndex = 4,
    })
    corner(b, 8)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = b })
    b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = isAccent and Theme.AccentHi or Theme.Surface2 }, 0.1) end)
    b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = isAccent and Theme.Accent or Theme.Surface3 }, 0.1) end)
    return b
end
local minBtn = topButton("−", -72, false)
local closeBtn = topButton("×", -38, true)

-- divider
local headerDiv = new("Frame", {
    Size = UDim2.new(1, -40, 0, 1), Position = UDim2.fromOffset(20, 58),
    BackgroundColor3 = Theme.Border, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 3, Parent = win,
})
grad(headerDiv, Theme.Border, Theme.Bg, 90)

-- body
local body = new("Frame", {
    Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 1, -58),
    BackgroundTransparency = 1, ZIndex = 3, Parent = win,
})

-- sidebar
local sidebar = new("Frame", {
    Position = UDim2.fromOffset(16, 10), Size = UDim2.new(0, 148, 1, -26),
    BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, ZIndex = 3, Parent = body,
})
corner(sidebar, 12)
new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = sidebar })
new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar })
new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = sidebar })

local pages = new("Frame", {
    Position = UDim2.fromOffset(176, 10), Size = UDim2.new(1, -192, 1, -26),
    BackgroundTransparency = 1, ZIndex = 3, Parent = body,
})

local tabs, sideOrder, currentTab, rowFrames = {}, 0, nil, {}

local function selectTab(sel)
    currentTab = sel
    for _, t in ipairs(tabs) do
        local on = t == sel
        t.page.Visible = on
        tween(t.btn, { BackgroundColor3 = on and Theme.Accent or Theme.Surface2 }, 0.16)
        tween(t.btn, { BackgroundTransparency = on and 0 or 1 }, 0.16)
        t.btn.TextColor3 = on and Theme.Text or Theme.TextSub
        if t.bar then t.bar.Visible = on end
    end
end

local function SideHeader(text)
    sideOrder += 1
    local lbl = new("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 9, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = sideOrder, Parent = sidebar,
        TextColor3 = Theme.TextDim,
    })
    new("UIPadding", { PaddingLeft = UDim.new(0, 4), Parent = lbl })
end

local function Tab(name)
    sideOrder += 1
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
        LayoutOrder = sideOrder, Parent = sidebar,
    })
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, -4, 0.5, -9),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        Visible = false, Parent = wrap,
    })
    corner(bar, 2)
    grad(bar, Theme.Accent, Theme.Accent2, 90)
    local btn = new("TextButton", {
        Text = "   " .. name, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Surface2, TextColor3 = Theme.TextSub,
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    corner(btn, 8)
    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = pages, ScrollBarImageColor3 = Theme.Accent,
    })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = page })
    local t = { btn = btn, page = page, order = 0, bar = bar }
    btn.MouseButton1Click:Connect(function() selectTab(t) end)
    table.insert(tabs, t)
    return t
end

local function row(t, h)
    t.order += 1
    local r = new("Frame", {
        Size = UDim2.new(1, 0, 0, h or 38), BorderSizePixel = 0,
        BackgroundColor3 = Theme.Surface2, LayoutOrder = t.order, Parent = t.page,
    })
    corner(r, 8)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Parent = r })
    table.insert(rowFrames, r)
    return r
end

local function rowLabel(r, text)
    return new("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -24, 0, 38),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = r, TextColor3 = Theme.Text,
    })
end

local function Section(t, text)
    t.order += 1
    new("TextLabel", {
        Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 10, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24), TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom, LayoutOrder = t.order, Parent = t.page,
        TextColor3 = Theme.AccentHi,
    })
end

local function Note(t, text)
    t.order += 1
    return new("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 10, BackgroundTransparency = 1, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 28), TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = t.order, Parent = t.page, TextColor3 = Theme.TextDim,
    })
end

local function Toggle(t, text, key)
    local r = row(t)
    rowLabel(r, text)
    local sw = new("Frame", {
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = Theme.Surface3, Parent = r,
    })
    corner(sw, 11)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = sw })
    local swGrad = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sw,
    })
    corner(swGrad, 11)
    grad(swGrad, Theme.Accent, Theme.Accent2, 0)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Theme.TextSub, Parent = sw,
    })
    corner(knob, 8)
    new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.7, Parent = knob })
    local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = r })
    local function render()
        local on = Settings[key]
        tween(swGrad, { BackgroundTransparency = on and 0 or 1 }, 0.18)
        tween(knob, { Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, 0.18)
        tween(knob, { BackgroundColor3 = on and Theme.Text or Theme.TextSub }, 0.18)
    end
    hit.MouseButton1Click:Connect(function() setSetting(key, not Settings[key]) render() end)
    render()
    table.insert(refreshers, render)
end

local function Slider(t, text, key, min, max, step, fmt)
    local r = row(t, 56)
    rowLabel(r, text)
    local value = new("TextLabel", {
        Font = Enum.Font.GothamBold, TextSize = 11, BackgroundTransparency = 1,
        Position = UDim2.new(1, -112, 0, 0), Size = UDim2.fromOffset(100, 38),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = r, TextColor3 = Theme.AccentHi,
    })
    local bar = new("Frame", {
        Size = UDim2.new(1, -28, 0, 4), Position = UDim2.fromOffset(14, 40),
        BorderSizePixel = 0, Parent = r, BackgroundColor3 = Theme.Surface3,
    })
    corner(bar, 2)
    local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = bar, BackgroundColor3 = Theme.Accent })
    corner(fill, 2)
    grad(fill, Theme.Accent, Theme.Accent2, 0)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Parent = bar,
    })
    corner(knob, 7)
    new("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.2, Parent = knob })
    local hit = new("TextButton", {
        Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0.5, -12), Parent = bar,
    })
    local function render()
        local v = Settings[key]
        local rel = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.fromScale(rel, 1)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        value.Text = fmt(v)
    end
    local dragging = false
    local function update(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setSetting(key, math.clamp(math.floor((min + a * (max - min)) / step + 0.5) * step, min, max))
        render()
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = true; update(i.Position.X) end
    end)
    bind(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == MOVE or i.UserInputType == TOUCH) then update(i.Position.X) end
    end))
    bind(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = false end
    end))
    render()
    table.insert(refreshers, render)
end

local function Cycle(t, text, key, options)
    local r = row(t)
    rowLabel(r, text)
    local b = new("TextButton", {
        Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        Size = UDim2.fromOffset(120, 26), Position = UDim2.new(1, -134, 0.5, -13), Parent = r,
        BackgroundColor3 = Theme.Surface3, TextColor3 = Theme.Text,
    })
    corner(b, 7)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = b })
    local function render() b.Text = tostring(Settings[key]) end
    b.MouseButton1Click:Connect(function()
        local idx = table.find(options, Settings[key]) or 0
        setSetting(key, options[idx % #options + 1])
        render()
    end)
    render()
    table.insert(refreshers, render)
end

local capturingKey = false
local function Keybind(t, text, key)
    local r = row(t)
    rowLabel(r, text)
    local b = new("TextButton", {
        Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        Size = UDim2.fromOffset(120, 26), Position = UDim2.new(1, -134, 0.5, -13), Parent = r,
        BackgroundColor3 = Theme.Surface3, TextColor3 = Theme.Text,
    })
    corner(b, 7)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = b })
    local listening = false
    local function render() b.Text = listening and "Press key..." or tostring(Settings[key]) end
    b.MouseButton1Click:Connect(function() listening = not listening; capturingKey = listening; render() end)
    bind(UIS.InputBegan:Connect(function(i)
        if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        setSetting(key, i.KeyCode.Name)
        render()
        task.defer(function() capturingKey = false end)
    end))
    render()
    table.insert(refreshers, render)
end

local function Button(t, text, role, cb)
    t.order += 1
    local b = new("TextButton", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 36), LayoutOrder = t.order, Parent = t.page,
        BackgroundColor3 = role == "Accent" and Theme.Accent or Theme.Surface3,
        TextColor3 = Theme.Text,
    })
    corner(b, 8)
    local stroke = new("UIStroke", {
        Color = role == "Accent" and Theme.AccentHi or Theme.Border,
        Thickness = 1, Transparency = 0.3, Parent = b,
    })
    if role == "Accent" then
        local bGrad = new("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0, Parent = b,
        })
        corner(bGrad, 8)
        grad(bGrad, Theme.Accent, Theme.Accent2, 45)
        b.TextColor3 = Theme.Text
        b.ZIndex = 1
    end
    b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.15 }, 0.1) end)
    b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 0 }, 0.1) end)
    b.MouseButton1Click:Connect(cb)
end

local function repaint()
    for _, r in ipairs(refreshers) do r() end
    if currentTab then selectTab(currentTab) end
end

function _G.RubenHubSet(key, value)
    if Settings[key] == nil or type(Settings[key]) ~= type(value) then return end
    setSetting(key, value)
    repaint()
end

appliers.UITransparency = function(v)
    win.BackgroundTransparency = v
    sidebar.BackgroundTransparency = v
    for _, r in ipairs(rowFrames) do r.BackgroundTransparency = v end
end

local pct   = function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end
local int   = function(v) return tostring(math.floor(v + 0.5)) end
local one   = function(v) return string.format("%.1f", v) end
local deg   = function(v) return math.floor(v + 0.5) .. "°" end
local studs = function(v) return v == 0 and "Unlimited" or (math.floor(v) .. " st") end

-- =========================================================================
-- BINDS
-- =========================================================================
local Binds = {}
local function toggleFunc(funcKey)
    if Settings[funcKey] == nil then return end
    setSetting(funcKey, not Settings[funcKey])
    repaint()
end

-- =========================================================================
-- PAGES
-- =========================================================================
SideHeader("FARM")
local farmTab = Tab("Farm")
Section(farmTab, "Rewards")
Toggle(farmTab, "Auto claim quests", "AutoQuests")
Toggle(farmTab, "Auto claim achievements", "AutoAchievements")
Toggle(farmTab, "Auto daily reward", "AutoDaily")
Note(farmTab, "Claims finished quests, every achievement tier you've reached, and the daily reward.")
Section(farmTab, "Delivery")
Toggle(farmTab, "Auto delivery", "AutoDelivery")
Note(farmTab, "Takes food orders and delivers them (~$110 each, about one a minute).")
local deliveryNote = Note(farmTab, "")
Section(farmTab, "Wheelie")
Toggle(farmTab, "Auto wheelie ride", "AutoWheelie")
Note(farmTab, "Takes your ride to the wheelie area and holds a steady wheelie there.")
Toggle(farmTab, "Quest helpers", "QuestHelpers")
Note(farmTab, "Rides one-handed and Hard police mode while quests need it.")
Slider(farmTab, "Wheelie angle", "WheelieAngle", 20, 60, 1, deg)
local areaNote
local function useArea(ground, clear)
    farmAnchor, farmRadius = ground, math.min(260, clear - 60)
    if phase ~= "idle" then setPhase("idle") end
end
Button(farmTab, "Set wheelie area here", "Row", function()
    local seat = myDriveSeat()
    local from = (seat and seated(seat) and seat.Position) or (getRoot() and getRoot().Position)
    local g = from and groundBelow(from, 30)
    if not g then areaNote.Text = "Stand on the ground first." return end
    local clear = clearRadius(g.Position)
    if clear < 140 then
        areaNote.Text = string.format("Too cramped here (only %d studs clear).", clear)
        return
    end
    useArea(g.Position, clear)
    areaNote.Text = string.format("Wheelie area set (%d studs clear).", clear)
end)
Button(farmTab, "Use default wheelie area", "Row", function()
    useArea(FARM_SPOT, 320)
    areaNote.Text = "Using the default area (open field south of town)."
end)
areaNote = Note(farmTab, "Default area: open field south of town.")
Section(farmTab, "Tricks")
Toggle(farmTab, "Auto tricks", "AutoTricks")
Note(farmTab, "Automatically performs spins/flips on your ride.")
Cycle(farmTab, "Trick mode", "TrickMode", { "Random", "Spin", "Backflip", "Frontflip", "180" })
Slider(farmTab, "Trick speed", "TrickSpeed", 0.3, 1.5, 0.1, function(v) return string.format("x%.1f", v) end)
Section(farmTab, "Rides & events")
Toggle(farmTab, "Auto buy faster rides", "AutoBuyRide")
Toggle(farmTab, "Collect money rain", "MoneyRain")
Section(farmTab, "Session")
local statsCash = Note(farmTab, "")
local statsMore = Note(farmTab, "")
task.spawn(function()
    while _G.RubenHubLoaded do
        local cash = tonumber(lp:GetAttribute("Cash")) or 0
        local elapsed = os.clock() - Session.startedAt
        local earned = cash - Session.startCash
        statsCash.Text = string.format("Cash $%s  ·  +$%s this session  ·  $%s/hour",
            commas(cash), commas(earned), commas(earned / math.max(elapsed, 1) * 3600))
        statsMore.Text = string.format("Level %s  ·  Quests %d  ·  Achievements %d  ·  Dailies %d  ·  Deliveries %d (+$%s)",
            tostring(lp:GetAttribute("Level") or "?"), Session.quests, Session.achievements, Session.daily,
            Session.deliveries, commas(Session.deliveryCash))
        deliveryNote.Text = Settings.AutoDelivery and deliveryStatus or ""
        task.wait(1)
    end
end)

local rideTab = Tab("Ride")
Section(rideTab, "Spawn")
local rideDisplays, rideNameByDisplay = {}, {}
for _, s in ipairs(RS.Scooters:GetChildren()) do
    local disp = (s.Name:gsub("^Scooter", ""))
    table.insert(rideDisplays, disp)
    rideNameByDisplay[disp] = s.Name
end
table.sort(rideDisplays)
if #rideDisplays == 0 then rideDisplays = { "G2" }; rideNameByDisplay["G2"] = "ScooterG2" end
if Settings.QuickRide == "" or not rideNameByDisplay[Settings.QuickRide] then Settings.QuickRide = rideDisplays[1] end
Cycle(rideTab, "Ride", "QuickRide", rideDisplays)
Button(rideTab, "Spawn selected ride", "Row", function()
    local name = rideNameByDisplay[Settings.QuickRide]
    if SpawnRide and name then pcall(function() SpawnRide:InvokeServer(name) end) end
end)
Button(rideTab, "Respawn current ride", "Row", function()
    if SpawnRide then pcall(function() SpawnRide:InvokeServer(myRide() and myRide():GetAttribute("TemplateName")) end) end
end)
Button(rideTab, "Sit on my ride", "Row", function()
    local seat, hum = myDriveSeat(), getHum()
    if seat and hum then
        local root = getRoot()
        if root then root.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0) end
        task.wait(0.3)
        pcall(function() seat:Sit(hum) end)
    end
end)
if GoToDealership then
    Button(rideTab, "Go to dealership", "Row", function() pcall(function() GoToDealership:InvokeServer() end) end)
end
Section(rideTab, "Speed")
Slider(rideTab, "Speed boost", "RideSpeedBoost", 0, 300, 10, function(v) return v == 0 and "Off" or (math.floor(v) .. " st/s²") end)
Note(rideTab, "Extra push while you hold W / Up.")
Slider(rideTab, "Speed limit", "SpeedLimit", 0, 400, 5, function(v) return v == 0 and "Off" or (math.floor(v) .. " st/s") end)
Note(rideTab, "Caps your scooter's speed. Higher values may get you rubber-banded by the server.")
Toggle(rideTab, "Seat lock (auto wheelie/tricks)", "SeatLock")
Note(rideTab, "Pins you to the seat during wheelie and tricks.")
Section(rideTab, "Police")
Toggle(rideTab, "Anti police", "AntiPolice")
Note(rideTab, "Keeps police mode on \"No Police\".")

local teleportTab = Tab("Teleport")
Section(teleportTab, "Places")
local PLACES = {
    { "Dealership", Vector3.new(1313, 59.3, 28) },
    { "Halloween", Vector3.new(1265, 59.3, -6) },
    { "Tuning", Vector3.new(1409, 59.3, -57) },
    { "Delivery", Vector3.new(1420, 74.3, -597) },
    { "Skatepark", Vector3.new(2038, 124.6, 730) },
}
local listed = {}
for _, place in ipairs(PLACES) do
    listed[place[1]] = true
    Button(teleportTab, place[1], "Row", function() teleport(place[2]) end)
end
Button(teleportTab, "Wheelie area", "Row", function() teleport(farmAnchor) end)
local POI_FOLDER = workspace:FindFirstChild("POIs")
for _, poi in ipairs(POI_FOLDER and POI_FOLDER:GetChildren() or {}) do
    if not listed[poi.Name] then
        Button(teleportTab, poi.Name, "Row", function()
            local pos = poi.Parent and placePosition(poi)
            if pos then teleport(pos) end
        end)
    end
end
Note(teleportTab, "Teleports you (and your ride if you're on it) to the spot.")

local visualsTab = Tab("Visuals")
Section(visualsTab, "ESP")
Toggle(visualsTab, "Player ESP", "PlayerESP")
Toggle(visualsTab, "Ride ESP", "RideESP")
Toggle(visualsTab, "Police ESP", "PoliceESP")
Toggle(visualsTab, "Delivery customer ESP", "CustomerESP")
Toggle(visualsTab, "Money drop ESP", "DropESP")
Note(visualsTab, "Through walls. Ride ESP shows other players' scooters.")
Toggle(visualsTab, "Names", "ESPNames")
Toggle(visualsTab, "Distance", "ESPDistance")
Toggle(visualsTab, "Boxes", "ESPBoxes")
Slider(visualsTab, "Max distance", "ESPMaxDistance", 0, 3000, 50, studs)
Slider(visualsTab, "Player colour", "ESPPlayerColor", 0, 360, 5, deg)
Slider(visualsTab, "Ride colour", "ESPRideColor", 0, 360, 5, deg)
Section(visualsTab, "World")
Toggle(visualsTab, "Fullbright", "Fullbright")

local playerTab = Tab("Player")
Section(playerTab, "Movement")
Slider(playerTab, "WalkSpeed", "WalkSpeed", 0, 200, 1, int)
Slider(playerTab, "Jump height", "JumpHeight", 0, 100, 0.5, one)
Slider(playerTab, "Hip height", "HipHeight", 0, 20, 0.1, one)
Toggle(playerTab, "Infinite jump", "InfJump")
Toggle(playerTab, "Noclip", "Noclip")
Toggle(playerTab, "Fly", "Fly")
Slider(playerTab, "Fly speed", "FlySpeed", 10, 300, 5, int)
Note(playerTab, "Fly: WASD + Space up / Ctrl down.")
Toggle(playerTab, "Anchor (freeze position)", "Anchor")
Note(playerTab, "Anchors your character in place. Useful for AFK.")
Section(playerTab, "Camera")
Slider(playerTab, "FOV", "FOV", 30, 120, 1, deg)
Section(playerTab, "Tools")
Button(playerTab, "Give teleport tool", "Row", function()
    local tpTool = new("Tool", { Name = "Click Teleport", RequiresHandle = false, CanBeDropped = false, Parent = lp:WaitForChild("Backpack") })
    tpTool.Activated:Connect(function()
        local root = getRoot()
        if not root then return end
        local hit = lp:GetMouse().Hit
        if hit then root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * root.CFrame.Rotation end
    end)
end)

local miscTab = Tab("Misc")
Section(miscTab, "Utility")
Toggle(miscTab, "Anti AFK", "AntiAFK")
Toggle(miscTab, "Quick interact", "QuickInteract")
Toggle(miscTab, "Hide players", "HidePlayers")
Section(miscTab, "Performance")
Toggle(miscTab, "Reduce CPU (black screen)", "BlackScreen")
if setfpscap then
    Slider(miscTab, "FPS cap", "FPSCap", 15, 240, 5, int)
else
    Note(miscTab, "FPS cap isn't supported by this executor.")
end
Toggle(miscTab, "Anti lag", "AntiLag")
Section(miscTab, "Desync")
Toggle(miscTab, "Desync (camera offset)", "Desync")
Note(miscTab, "Rotates your character's CFrame for the camera only.")
Section(miscTab, "Restore")
Button(miscTab, "Restore hooks / stop all", "Accent", function()
    unlockSeat()
    stopSpin()
    if wheelie and wheelie.active then stopWheelie() end
    if flyPos then stopFly() end
    removeDesync()
    for key in pairs(Settings) do
        if type(Settings[key]) == "boolean" then setSetting(key, false) end
    end
    repaint()
end)

local bindsTab = Tab("Binds")
Section(bindsTab, "Key Binds")
Note(bindsTab, "Click 'Bind' then press a key. Press again to unbind.")
local function addBindRow(funcKey, label)
    local r = row(bindsTab)
    rowLabel(r, label)
    local btn = new("TextButton", {
        Text = "Bind", Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        Size = UDim2.fromOffset(100, 26), Position = UDim2.new(1, -114, 0.5, -13), Parent = r,
        BackgroundColor3 = Theme.Surface3, TextColor3 = Theme.Text,
    })
    corner(btn, 7)
    new("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = btn })
    local listening = false
    local function render()
        local bindKey = nil
        for k, v in pairs(Binds) do
            if v == funcKey then bindKey = k; break end
        end
        btn.Text = listening and "Press key..." or (bindKey and ("[" .. bindKey .. "]") or "Bind")
        btn.BackgroundColor3 = listening and Theme.Accent or Theme.Surface3
    end
    btn.MouseButton1Click:Connect(function()
        listening = not listening
        capturingKey = listening
        render()
    end)
    bind(UIS.InputBegan:Connect(function(i)
        if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        capturingKey = false
        for k, v in pairs(Binds) do
            if v == funcKey then Binds[k] = nil end
        end
        Binds[i.KeyCode.Name] = funcKey
        render()
    end))
    render()
    table.insert(refreshers, render)
end

local bindableFuncs = {
    { "AutoQuests", "Auto Quests" },
    { "AutoAchievements", "Auto Achievements" },
    { "AutoDaily", "Auto Daily" },
    { "AutoDelivery", "Auto Delivery" },
    { "AutoWheelie", "Auto Wheelie" },
    { "AutoTricks", "Auto Tricks" },
    { "AntiPolice", "Anti Police" },
    { "PlayerESP", "Player ESP" },
    { "RideESP", "Ride ESP" },
    { "PoliceESP", "Police ESP" },
    { "CustomerESP", "Customer ESP" },
    { "DropESP", "Drop ESP" },
    { "Fullbright", "Fullbright" },
    { "Noclip", "Noclip" },
    { "Fly", "Fly" },
    { "InfJump", "Infinite Jump" },
    { "Anchor", "Anchor" },
    { "Desync", "Desync" },
    { "AntiAFK", "Anti AFK" },
}
for _, func in ipairs(bindableFuncs) do
    addBindRow(func[1], func[2])
end

-- =========================================================================
-- DRAG & MINIMIZE
-- =========================================================================
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(i)
        if i.UserInputType == MB1 or i.UserInputType == TOUCH then
            dragging, dragStart, startPos = true, i.Position, win.Position
        end
    end)
    bind(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == MOVE or i.UserInputType == TOUCH) then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    bind(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == MB1 or i.UserInputType == TOUCH then dragging = false end
    end))
end

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    tween(win, { Size = UDim2.fromOffset(WIN_W, minimized and 58 or WIN_H) }, 0.22)
    tween(glow, { Size = UDim2.fromOffset(WIN_W + 24, (minimized and 58 or WIN_H) + 24) }, 0.22)
end)
closeBtn.MouseButton1Click:Connect(function() _G.RubenHubUnload() end)

bind(UIS.InputBegan:Connect(function(i, processed)
    if processed or capturingKey then return end
    local ok, key = pcall(function() return Enum.KeyCode[Settings.ToggleKey] end)
    if ok and i.KeyCode == key then ui.Enabled = not ui.Enabled end
    for keyName, funcKey in pairs(Binds) do
        local ok2, keyEnum = pcall(function() return Enum.KeyCode[keyName] end)
        if ok2 and i.KeyCode == keyEnum then
            toggleFunc(funcKey)
        end
    end
end))

-- =========================================================================
-- UNLOAD
-- =========================================================================
_G.RubenHubUnload = function()
    if not _G.RubenHubLoaded then return end
    _G.RubenHubLoaded = false
    if phase ~= "idle" then releaseRide() end
    local seat = myDriveSeat()
    if oneHandByHelper and seat and seat:GetAttribute("OneHanderActive") == true and RiderArmEvent then RiderArmEvent:FireServer() end
    if policeBefore and PoliceMode then PoliceMode:FireServer(policeBefore) end
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    local h = getHum()
    if h then
        if touched.WalkSpeed then h.WalkSpeed = Defaults.WalkSpeed end
        if touched.JumpHeight then h.JumpHeight = Defaults.JumpHeight end
        if touched.HipHeight then h.HipHeight = Defaults.HipHeight end
        if Settings.Fly then h.PlatformStand = false end
    end
    if touched.FOV then workspace.CurrentCamera.FieldOfView = Defaults.FOV end
    appliers.Noclip(false)
    appliers.QuickInteract(false)
    appliers.HidePlayers(false)
    appliers.AntiLag(false)
    appliers.Fullbright(false)
    if Settings.BlackScreen then RunService:Set3dRenderingEnabled(true) end
    if touched.FPSCap and setfpscap then setfpscap(60) end
    unlockSeat()
    stopSpin()
    if wheelie and wheelie.active then stopWheelie() end
    if flyPos then stopFly() end
    removeDesync()
    espFolder:Destroy()
    ui:Destroy()
    tagGui:Destroy()
    _G.RubenHubLoaded = nil
    print("[Ruben Hub] Unloaded.")
end

selectTab(farmTab)
print("[Ruben Hub] Kukirin Life loaded. Press " .. Settings.ToggleKey .. " to toggle.")