-- =========================================================================
-- [RUBEN-HUB] — Master Edition (Cookies + Pulsar + Fixes)
-- =========================================================================
if _G.RubenHubLoaded then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local guiParent
pcall(function()
    if gethui then guiParent = gethui() end
    if not guiParent then guiParent = game:GetService("CoreGui") end
end)
if not guiParent then guiParent = lp:WaitForChild("PlayerGui") end

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

local function getSafeHWID()
    local ok, hwid = pcall(function()
        if gethwid then return gethwid() end
        error("no")
    end)
    if ok and hwid and hwid ~= "" then return tostring(hwid) end
    return "USER_" .. tostring(lp.UserId)
end

local function validateKey(key, hwid)
    if not VALID_KEYS[key] then return false, "Invalid key" end
    local data = {}
    if isfile and readfile and isfile(KEY_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(KEY_FILE))
        end)
        if ok and type(decoded) == "table" then data = decoded end
    end
    local bound = data[key]
    if bound and bound ~= hwid then
        return false, "Key bound to another PC"
    end
    if not bound and writefile then
        data[key] = hwid
        pcall(function()
            writefile(KEY_FILE, HttpService:JSONEncode(data))
        end)
    end
    return true, "OK"
end

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
    title.Text = "RUBEN-HUB · KEY ACTIVATION"
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
        local ok, msg = validateKey(text, getSafeHWID())
        if ok then
            gui:Destroy()
            _G.RubenHubLoaded = true
            callback()
        else
            status.Text = msg
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
            local ok = pcall(function()
                sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
            end)
            if ok then break end
            task.wait(0.1)
        end
        pcall(function() sg:SetCore("TopbarEnabled", false) end)
    end)

    local Hub = {
        Settings = {},
        State = {
            phase = "idle",
            angleWheelie = { active = false, seat = nil, align = nil, attach = nil, yaw = 0 },
            spin = { phase = "Idle", phaseAt = 0, idleAt = 0, totalAngle = 0, align = nil, attach = nil },
            session = { startedAt = os.clock(), startCash = 0, quests = 0, deliveries = 0 },
            collectingRain = false,
            policeBefore = nil,
            oneHandByHelper = false,
            armToggledAt = 0
        },
        Remotes = {},
        Conns = {},
        UI = { refreshers = {}, tabs = {}, win = nil, body = nil },
        Esp = { folder = nil, tags = {} },
        SeatLock = nil,
        DesyncState = nil,
        Binds = {}
    }

    Hub.State.session.startCash = tonumber(lp:GetAttribute("Cash")) or 0

    local defaults = {
        AutoQuests = false, AutoAchievements = false, AutoDaily = false,
        AutoDelivery = false, AutoBuyRide = false, MoneyRain = false,
        QuestHelpers = true, AutoWheelie = false, WheelieAngle = 35,
        AngleWheelie = false, AngleWheelieAngle = 35, AutoTricks = false,
        TrickSpeed = 1, RideSpeedBoost = 0, SpeedUncap = false, SpeedLimit = 140,
        SeatLock = true, AntiPolice = false,
        PlayerESP = false, RideESP = false, PoliceESP = false,
        CustomerESP = false, DropESP = false, ESPMaxDistance = 0,
        Fullbright = false, WalkSpeed = 16, JumpHeight = 50, HipHeight = 2,
        InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, FOV = 70,
        Anchor = false, Desync = false, AntiAFK = true, QuickInteract = false,
        HidePlayers = false, BlackScreen = false, FPSCap = 60, AntiLag = false,
        ToggleKey = "RightShift"
    }

    for k, v in pairs(defaults) do Hub.Settings[k] = v end

    local function new(class, parent)
        local inst = Instance.new(class)
        inst.Parent = parent
        return inst
    end
    local function corner(p, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 6)
        c.Parent = p
        return c
    end
    local function tween(inst, props, dur)
        TweenService:Create(inst, TweenInfo.new(dur or 0.15), props):Play()
    end
    local function bind(c)
        table.insert(Hub.Conns, c)
        return c
    end
    local function getHum()
        local c = lp.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function getRoot()
        local c = lp.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function myRide()
        if not workspace:FindFirstChild("Rides") then return nil end
        return workspace.Rides:FindFirstChild("Ride_" .. lp.Name)
    end
    local function myDriveSeat()
        local r = myRide()
        return r and r:FindFirstChild("DriveSeat", true)
    end
    local function seated(seat)
        local h = getHum()
        return h and seat and h.SeatPart == seat
    end

    do
        local Remotes = RS.Remotes
        local function r(n)
            for _, x in ipairs(Remotes:GetDescendants()) do
                if x.Name == n and (x:IsA("RemoteEvent") or x:IsA("RemoteFunction")) then
                    return x
                end
            end
        end
        Hub.Remotes.GetQuests = r("GetQuests")
        Hub.Remotes.ClaimQuest = r("ClaimQuest")
        Hub.Remotes.ClaimAchievement = r("ClaimAchievement")
        Hub.Remotes.ClaimAchievementReward = r("ClaimAchievementReward")
        Hub.Remotes.GetDailyRewards = r("GetDailyRewards")
        Hub.Remotes.ClaimDailyReward = r("ClaimDailyReward")
        Hub.Remotes.SpawnRide = r("SpawnRide")
        Hub.Remotes.GetRides = r("GetRides")
        Hub.Remotes.BuyRide = r("BuyRide")
        Hub.Remotes.RiderArmEvent = r("RiderArmEvent")
        Hub.Remotes.PoliceMode = r("PoliceMode")
        Hub.Remotes.PoliceHit = r("PoliceHit")
        Hub.Remotes.FoodDelivery = Remotes:FindFirstChild("FoodDelivery")
        Hub.Remotes.RainFolder = Remotes:FindFirstChild("MoneyRain")
    end

    local function lockSeat()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local seat = hum and hum.SeatPart
        if not (hrp and seat) then return end
        if Hub.SeatLock then Hub.SeatLock:Destroy() end
        Hub.SeatLock = Instance.new("WeldConstraint")
        Hub.SeatLock.Part0 = hrp
        Hub.SeatLock.Part1 = seat
        Hub.SeatLock.Parent = hrp
    end

    local function unlockSeat()
        if Hub.SeatLock then Hub.SeatLock:Destroy() end
        Hub.SeatLock = nil
    end

    local function teleport(pos)
        local ground = pos
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(ground + Vector3.new(0, 3, 0))
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- =====================================================================
    -- MODULES
    -- =====================================================================
    local function setupModules()
        local S, St = Hub.Settings, Hub.State

        -- FARM
        task.spawn(function()
            while _G.RubenHubLoaded do
                if S.AutoQuests and Hub.Remotes.GetQuests then
                    local ok, list = pcall(function() return Hub.Remotes.GetQuests:InvokeServer() end)
                    if ok and type(list) == "table" then
                        for i, q in ipairs(list) do
                            local ready = (q.NextAt or 0) <= os.time()
                            local done = (q.Progress or 0) >= (q.Target or 999)
                            if ready and done then
                                pcall(function() Hub.Remotes.ClaimQuest:InvokeServer(i) end)
                                St.session.quests = St.session.quests + 1
                                task.wait(0.4)
                            end
                        end
                    end
                end
                if S.AutoAchievements and Hub.Remotes.ClaimAchievement then
                    local cfgOk, cfg = pcall(function() return require(RS.Datas.AchievementConfig) end)
                    if cfgOk then
                        for _, a in ipairs(cfg.Achievements or {}) do
                            pcall(function() Hub.Remotes.ClaimAchievement:InvokeServer(a.Id) end)
                            task.wait(0.3)
                        end
                        if Hub.Remotes.ClaimAchievementReward then
                            pcall(function() Hub.Remotes.ClaimAchievementReward:InvokeServer() end)
                        end
                    end
                end
                if S.AutoDaily and Hub.Remotes.GetDailyRewards then
                    local ok, d = pcall(function() return Hub.Remotes.GetDailyRewards:InvokeServer() end)
                    if ok and type(d) == "table" and (d.NextAt or 0) <= os.time() then
                        pcall(function() Hub.Remotes.ClaimDailyReward:InvokeServer() end)
                    end
                end
                task.wait(10)
            end
        end)

        -- DELIVERY
        task.spawn(function()
            while _G.RubenHubLoaded do
                if S.AutoDelivery and Hub.Remotes.FoodDelivery then
                    local target = lp:GetAttribute("DeliveryTarget")
                    if typeof(target) ~= "Vector3" then
                        teleport(Vector3.new(1424.7, 58.6, -607.8))
                        task.wait(0.6)
                        pcall(function() Hub.Remotes.FoodDelivery.Start:InvokeServer() end)
                    else
                        teleport(target + Vector3.new(0, 0, 4))
                        for _ = 1, 5 do
                            local ok, done, pay, _, tip = pcall(function() return Hub.Remotes.FoodDelivery.Deliver:InvokeServer() end)
                            if ok and done then
                                local earned = (tonumber(pay) or 0) + (tonumber(tip) or 0)
                                St.session.deliveries = St.session.deliveries + earned
                                break
                            end
                            task.wait(1.5)
                        end
                    end
                end
                task.wait(1)
            end
        end)

        -- ESP
        Hub.Esp.folder = Instance.new("Folder")
        Hub.Esp.folder.Name = "RubenESP"
        task.spawn(function()
            while _G.RubenHubLoaded do
                local root = getRoot()
                local anyEsp = S.PlayerESP or S.RideESP or S.PoliceESP or S.CustomerESP or S.DropESP
                if root and anyEsp then
                    Hub.Esp.folder.Parent = guiParent
                    if S.PlayerESP then
                        for _, p in ipairs(Players:GetPlayers()) do
                            local head = p.Character and p.Character:FindFirstChild("Head")
                            if head and p ~= lp then
                                local tag = Hub.Esp.tags[p]
                                if not tag then
                                    local gui = Instance.new("BillboardGui", Hub.Esp.folder)
                                    gui.Adornee = head
                                    gui.AlwaysOnTop = true
                                    gui.Size = UDim2.fromOffset(200, 34)
                                    local lbl = Instance.new("TextLabel", gui)
                                    lbl.Size = UDim2.fromScale(1, 1)
                                    lbl.BackgroundTransparency = 1
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 13
                                    lbl.TextColor3 = Color3.new(1, 0, 0)
                                    local hl = Instance.new("Highlight", Hub.Esp.folder)
                                    hl.Adornee = p.Character
                                    hl.FillColor = Color3.new(1, 0, 0)
                                    tag = { gui = gui, label = lbl, hl = hl }
                                    Hub.Esp.tags[p] = tag
                                end
                                local dist = (head.Position - root.Position).Magnitude
                                tag.label.Text = p.DisplayName .. " [" .. math.floor(dist) .. "m]"
                                tag.gui.Enabled = true
                                tag.hl.Enabled = true
                            end
                        end
                    end
                else
                    for p, tag in pairs(Hub.Esp.tags) do
                        if tag.gui then tag.gui:Destroy() end
                        if tag.hl then tag.hl:Destroy() end
                        Hub.Esp.tags[p] = nil
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
        bind(RunService.Heartbeat:Connect(function(dt)
            local S, St = Hub.Settings, Hub.State
            local w = St.angleWheelie
            local spin = St.spin

            -- Classic Wheelie
            if S.AutoWheelie then
                local seat = myDriveSeat()
                if seat then
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
            end

            -- Angle Wheelie (Pulsar style, no camera shake)
            if S.AngleWheelie then
                local hum = getHum()
                local seat = hum and hum.SeatPart
                if seat then
                    if not w.active or w.seat ~= seat then
                        w.active = true
                        w.seat = seat
                        w.yaw = select(2, seat.CFrame:ToOrientation())
                        w.attach = Instance.new("Attachment", seat)
                        w.align = Instance.new("AlignOrientation", seat)
                        w.align.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        w.align.Attachment0 = w.attach
                        w.align.MaxTorque = 10000000
                    end
                    local steer = seat.SteerFloat or 0
                    w.yaw = w.yaw - steer * 3.0 * dt
                    w.align.CFrame = CFrame.new(seat.Position) * CFrame.Angles(0, w.yaw, 0) * CFrame.Angles(math.rad(S.AngleWheelieAngle), 0, 0)
                else
                    if w.active then
                        if w.align then w.align:Destroy() end
                        if w.attach then w.attach:Destroy() end
                        w.active = false
                    end
                end
            elseif w.active then
                if w.align then w.align:Destroy() end
                if w.attach then w.attach:Destroy() end
                w.active = false
            end

            -- Tricks
            if S.AutoTricks then
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.SeatPart then
                    local body = hum.SeatPart.AssemblyRootPart or hum.SeatPart
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
                        if math.abs(spin.totalAngle) >= math.rad(1440) then
                            spin.phase = "Descend"
                        end
                    elseif spin.phase == "Descend" then
                        body.AssemblyLinearVelocity = Vector3.new(0, -90, 0)
                        if now - spin.phaseAt > 1.6 then
                            if spin.align then spin.align:Destroy() end
                            if spin.attach then spin.attach:Destroy() end
                            spin.phase = "Idle"
                            spin.idleAt = now
                        end
                    end
                end
            end
        end))

        -- PLAYER / MISC
        bind(RunService.Heartbeat:Connect(function()
            local S = Hub.Settings
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
            elseif h.PlatformStand and not S.Fly then
                h.PlatformStand = false
            end
            if S.Fullbright then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1e9
            end
        end))

        bind(UIS.JumpRequest:Connect(function()
            if Hub.Settings.InfJump then
                local h = getHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end))
        
        bind(UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == Enum.KeyCode[Hub.Settings.ToggleKey] then
                if Hub.UI.win then
                    Hub.UI.win.Visible = not Hub.UI.win.Visible
                end
            end
            for k, fn in pairs(Hub.Binds) do
                if i.KeyCode == Enum.KeyCode[k] then
                    if type(Hub.Settings[fn]) == "boolean" then
                        Hub.Settings[fn] = not Hub.Settings[fn]
                        for _, r in ipairs(Hub.UI.refreshers) do r() end
                    end
                end
            end
        end))
    end
    setupModules()

    -- =====================================================================
    -- UI (Fixed Minimize & Layout)
    -- =====================================================================
    local function buildUI()
        local S = Hub.Settings
        local MB1 = Enum.UserInputType.MouseButton1
        local MOVE = Enum.UserInputType.MouseMovement
        local Theme = {
            Bg = Color3.fromRGB(16, 18, 27), Panel = Color3.fromRGB(24, 27, 38),
            Panel2 = Color3.fromRGB(34, 38, 52), Border = Color3.fromRGB(42, 48, 66),
            Accent = Color3.fromRGB(91, 140, 255), AccentHi = Color3.fromRGB(130, 170, 255),
            Text = Color3.fromRGB(238, 242, 252), TextSub = Color3.fromRGB(150, 158, 180)
        }
        local FB, FM, F = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham

        local ui = new("ScreenGui", guiParent)
        ui.Name = "RubenHubUI"
        ui.ResetOnSpawn = false
        ui.DisplayOrder = 999

        local win = new("Frame", ui)
        win.Size = UDim2.fromOffset(640, 520)
        win.Position = UDim2.new(0.5, -320, 0.5, -260)
        win.BackgroundColor3 = Theme.Bg
        win.BorderSizePixel = 0
        corner(win, 16)
        Hub.UI.win = win

        local stroke = new("UIStroke", win)
        stroke.Color = Theme.Border

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
        corner(minBtn, 8)

        local closeBtn = new("TextButton", header)
        closeBtn.Text = "×"
        closeBtn.Font = FB
        closeBtn.TextSize = 15
        closeBtn.Size = UDim2.fromOffset(28, 28)
        closeBtn.Position = UDim2.new(1, -36, 0, 14)
        closeBtn.BackgroundColor3 = Theme.Accent
        closeBtn.TextColor3 = Theme.Text
        corner(closeBtn, 8)

        local body = new("Frame", win)
        body.Position = UDim2.fromOffset(0, 56)
        body.Size = UDim2.new(1, 0, 1, -56)
        body.BackgroundTransparency = 1
        Hub.UI.body = body

        local sidebar = new("Frame", body)
        sidebar.Position = UDim2.fromOffset(14, 10)
        sidebar.Size = UDim2.new(0, 150, 1, -24)
        sidebar.BackgroundColor3 = Theme.Panel
        corner(sidebar, 12)

        local pageHolder = new("Frame", body)
        pageHolder.Position = UDim2.fromOffset(178, 10)
        pageHolder.Size = UDim2.new(1, -192, 1, -24)
        pageHolder.BackgroundTransparency = 1

        local tabs, currentTab = {}, nil
        local function selectTab(sel)
            currentTab = sel
            for _, t in ipairs(tabs) do
                local on = t == sel
                t.page.Visible = on
                tween(t.btn, { BackgroundColor3 = on and Theme.Accent or Theme.Panel2 }, 0.16)
                t.btn.TextColor3 = on and Theme.Text or Theme.TextSub
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
            corner(btn, 8)
            
            local layout = Instance.new("UIListLayout", sidebar)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)

            local page = new("ScrollingFrame", pageHolder)
            page.Size = UDim2.fromScale(1, 1)
            page.BackgroundTransparency = 1
            page.ScrollBarThickness = 3
            page.Visible = false
            
            local pLayout = Instance.new("UIListLayout", page)
            pLayout.Padding = UDim.new(0, 6)

            local t = { btn = btn, page = page }
            btn.MouseButton1Click:Connect(function() selectTab(t) end)
            table.insert(tabs, t)
            return t
        end

        local function row(t, h)
            local r = new("Frame", t.page)
            r.Size = UDim2.new(1, 0, 0, h or 38)
            r.BackgroundColor3 = Theme.Panel2
            corner(r, 8)
            return r
        end

        local function Toggle(t, text, key)
            local r = row(t)
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
            corner(sw, 11)

            local knob = new("Frame", sw)
            knob.Size = UDim2.fromOffset(16, 16)
            knob.Position = UDim2.fromOffset(3, 3)
            knob.BackgroundColor3 = Theme.TextSub
            corner(knob, 8)

            local hit = new("TextButton", r)
            hit.Text = ""
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.fromScale(1, 1)

            local function render()
                local on = S[key]
                tween(sw, { BackgroundColor3 = on and Theme.Accent or Theme.Border }, 0.16)
                local pos = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
                tween(knob, { Position = pos, BackgroundColor3 = on and Theme.Text or Theme.TextSub }, 0.16)
            end
            hit.MouseButton1Click:Connect(function()
                S[key] = not S[key]
                render()
            end)
            render()
        end

        local function Slider(t, text, key, mn, mx, step, fmt)
            local r = row(t, 56)
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
            corner(bar, 2)

            local fill = new("Frame", bar)
            fill.Size = UDim2.fromScale(0, 1)
            fill.BackgroundColor3 = Theme.Accent
            corner(fill, 2)

            local knob = new("Frame", bar)
            knob.Size = UDim2.fromOffset(14, 14)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.BackgroundColor3 = Theme.Text
            corner(knob, 7)

            local hit = new("TextButton", bar)
            hit.Text = ""
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.new(1, 0, 0, 24)
            hit.Position = UDim2.new(0, 0, 0.5, -12)

            local function render()
                local v = S[key]
                local rel = math.clamp((v - mn) / (mx - mn), 0, 1)
                fill.Size = UDim2.fromScale(rel, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                value.Text = fmt(v)
            end
            local dragging = false
            local function update(x)
                local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                S[key] = math.clamp(math.floor((mn + a * (mx - mn)) / step + 0.5) * step, mn, mx)
                render()
            end
            hit.InputBegan:Connect(function(i)
                if i.UserInputType == MB1 then
                    dragging = true
                    update(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == MOVE then
                    update(i.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == MB1 then dragging = false end
            end)
            render()
        end

        local farmTab = Tab("Farm")
        Toggle(farmTab, "Auto claim quests", "AutoQuests")
        Toggle(farmTab, "Auto claim achievements", "AutoAchievements")
        Toggle(farmTab, "Auto daily reward", "AutoDaily")
        Toggle(farmTab, "Auto delivery", "AutoDelivery")
        Toggle(farmTab, "Auto buy faster", "AutoBuyRide")
        Toggle(farmTab, "Collect money rain", "MoneyRain")
        Toggle(farmTab, "Auto wheelie (Classic)", "AutoWheelie")
        Toggle(farmTab, "Auto wheelie (Angle)", "AngleWheelie")
        Slider(farmTab, "Angle wheelie deg", "AngleWheelieAngle", -80, 80, 1, function(v)
            return math.floor(v) .. "°"
        end)
        Toggle(farmTab, "Auto tricks", "AutoTricks")
        Slider(farmTab, "Trick speed", "TrickSpeed", 0.3, 1.5, 0.1, function(v)
            return string.format("x%.1f", v)
        end)

        local rideTab = Tab("Ride")
        local spawnBtn = new("TextButton", rideTab.page)
        spawnBtn.Size = UDim2.new(1, 0, 0, 34)
        spawnBtn.BackgroundColor3 = Theme.Panel2
        spawnBtn.Text = "Spawn Ride (G2)"
        spawnBtn.Font = FB
        spawnBtn.TextColor3 = Theme.Text
        corner(spawnBtn, 8)
        spawnBtn.MouseButton1Click:Connect(function()
            if Hub.Remotes.SpawnRide then
                pcall(function() Hub.Remotes.SpawnRide:InvokeServer("ScooterG2") end)
            end
        end)

        Slider(rideTab, "Speed boost", "RideSpeedBoost", 0, 300, 10, function(v)
            return v == 0 and "Off" or (math.floor(v) .. " st/s²")
        end)
        Toggle(rideTab, "Speed uncap (300)", "SpeedUncap")
        Slider(rideTab, "Speed limit", "SpeedLimit", 0, 400, 5, function(v)
            return v == 0 and "Off" or (math.floor(v) .. " st/s")
        end)

        local visualsTab = Tab("Visuals")
        Toggle(visualsTab, "Player ESP", "PlayerESP")
        Toggle(visualsTab, "Ride ESP", "RideESP")
        Toggle(visualsTab, "Police ESP", "PoliceESP")
        Toggle(visualsTab, "Customer ESP", "CustomerESP")
        Toggle(visualsTab, "Drop ESP", "DropESP")
        Slider(visualsTab, "Max distance", "ESPMaxDistance", 0, 3000, 50, function(v)
            return v == 0 and "Unlimited" or (math.floor(v) .. " st")
        end)
        Toggle(visualsTab, "Fullbright", "Fullbright")

        local playerTab = Tab("Player")
        Slider(playerTab, "WalkSpeed", "WalkSpeed", 0, 200, 1, function(v)
            return tostring(math.floor(v))
        end)
        Slider(playerTab, "Jump height", "JumpHeight", 0, 100, 1, function(v)
            return tostring(math.floor(v))
        end)
        Toggle(playerTab, "Infinite jump", "InfJump")
        Toggle(playerTab, "Noclip", "Noclip")
        Toggle(playerTab, "Fly", "Fly")
        Slider(playerTab, "Fly speed", "FlySpeed", 10, 300, 5, function(v)
            return tostring(math.floor(v))
        end)
        Slider(playerTab, "FOV", "FOV", 30, 120, 1, function(v)
            return math.floor(v) .. "°"
        end)

        local miscTab = Tab("Misc")
        Toggle(miscTab, "Anti AFK", "AntiAFK")
        Toggle(miscTab, "Quick interact", "QuickInteract")
        Toggle(miscTab, "Hide players", "HidePlayers")
        Toggle(miscTab, "Black screen", "BlackScreen")
        Toggle(miscTab, "Anti lag", "AntiLag")
        Toggle(miscTab, "Anti Police", "AntiPolice")

        local bindsTab = Tab("Binds")
        local function addBind(text, key)
            local r = row(bindsTab)
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
            corner(b, 7)

            local listening = false
            local function render()
                local bindKey = nil
                for k, v in pairs(Hub.Binds) do
                    if v == key then bindKey = k break end
                end
                b.Text = listening and "Press..." or (bindKey and "[" .. bindKey .. "]" or "Bind")
            end
            b.MouseButton1Click:Connect(function()
                listening = not listening
                render()
            end)
            UIS.InputBegan:Connect(function(i)
                if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                listening = false
                for k, v in pairs(Hub.Binds) do
                    if v == key then Hub.Binds[k] = nil end
                end
                Hub.Binds[i.KeyCode.Name] = key
                render()
            end)
            render()
        end

        addBind("Auto Quests", "AutoQuests")
        addBind("Auto Delivery", "AutoDelivery")
        addBind("Auto Wheelie (Classic)", "AutoWheelie")
        addBind("Auto Wheelie (Angle)", "AngleWheelie")
        addBind("Auto Tricks", "AutoTricks")
        addBind("Player ESP", "PlayerESP")
        addBind("Ride ESP", "RideESP")
        addBind("Fly", "Fly")
        addBind("Noclip", "Noclip")
        addBind("Anti Police", "AntiPolice")

        selectTab(farmTab)
        
        closeBtn.MouseButton1Click:Connect(function()
            _G.RubenHubLoaded = false
            if Hub.Esp.folder then Hub.Esp.folder:Destroy() end
            ui:Destroy()
        end)

        local isMinimized = false
        minBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            body.Visible = not isMinimized
            win.Size = UDim2.fromOffset(640, isMinimized and 56 or 520)
        end)

        header.InputBegan:Connect(function(i)
            if i.UserInputType == MB1 then
                local dragging, dragStart, startPos
                dragging = true
                dragStart = i.Position
                startPos = win.Position
                local conn1, conn2
                conn1 = UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == MOVE then
                        local d = input.Position - dragStart
                        win.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + d.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + d.Y
                        )
                    end
                end)
                conn2 = UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == MB1 then
                        dragging = false
                        conn1:Disconnect()
                        conn2:Disconnect()
                    end
                end)
            end
        end)
    end
    buildUI()
end

local hwid = getSafeHWID()
local data = {}
if isfile and readfile and isfile(KEY_FILE) then
    pcall(function()
        data = HttpService:JSONDecode(readfile(KEY_FILE))
    end)
end
local hasValid = false
for k, v in pairs(data) do
    if VALID_KEYS[k] and v == hwid then
        hasValid = true
        break
    end
end

if hasValid then
    _G.RubenHubLoaded = true
    StartMainScript()
else
    promptKey(function()
        StartMainScript()
    end)
end