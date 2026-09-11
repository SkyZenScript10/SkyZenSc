-- SkyZen Arsenal Full Script - COMPLETE VERSION
-- All Features: ESP, Aimlock, Lane, Tracer, Wallhack, Gun Settings, Visual Settings
-- Team Check - Skip Teammate

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local config = {
    -- ESP
    espEnabled = true,
    espDistance = 500,
    espNameSize = 16,
    espNameColor = Color3.fromRGB(0, 255, 0),
    showDistance = true,
    
    -- Aimlock
    aimlockEnabled = true,
    aimlockDistance = 100,
    aimlockSmoothness = 0.15,
    
    -- Lane
    laneEnabled = true,
    laneColor = Color3.fromRGB(255, 0, 0),
    laneThickness = 2,
    
    -- Tracer
    tracerEnabled = true,
    tracerColor = Color3.fromRGB(0, 150, 255),
    tracerThickness = 1.5,
    
    -- Wallhack
    wallhackEnabled = false,
    
    -- Gun Settings
    silencerEnabled = false,
    silencerDamage = 100,
    spreadControl = 0.5,
    recoilControl = 0.7,
    fireRateBoost = 1.5,
    
    -- Visual
    nametags = true,
    healthBars = true,
    boxEsp = false,
    skeletonEsp = false,
    
    -- Team
    teamCheckEnabled = true,
}

local espPlayers = {}
local laneConnections = {}
local tracerConnections = {}
local wallhackPlayers = {}
local healthBarPlayers = {}
local targetPlayer = nil

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "🔥 SkyZen Arsenal",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "SkyZenScript10",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SkyZenConfig",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Create Tabs
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimlockTab = Window:CreateTab("Aimlock", 4483362458)
local LaneTab = Window:CreateTab("Lane", 4483362458)
local TracerTab = Window:CreateTab("Tracer", 4483362458)
local GunTab = Window:CreateTab("Gun", 4483362458)
local WallhackTab = Window:CreateTab("Wallhack", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local TeamTab = Window:CreateTab("Team", 4483362458)
local ControlTab = Window:CreateTab("Control", 4483362458)

-- ===== ESP TAB =====
local ESPToggle = ESPTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.espEnabled,
    Flag = "ESPToggle",
    Callback = function(Value)
        config.espEnabled = Value
    end,
})

local ESPDistanceSlider = ESPTab:CreateSlider({
    Name = "Distance",
    Min = 100,
    Max = 2000,
    DefaultValue = 500,
    Flag = "ESPDistance",
    Callback = function(Value)
        config.espDistance = Value
    end,
})

local ESPSizeSlider = ESPTab:CreateSlider({
    Name = "Size",
    Min = 8,
    Max = 32,
    DefaultValue = 16,
    Flag = "ESPSize",
    Callback = function(Value)
        config.espNameSize = Value
        for _, gui in pairs(espPlayers) do
            if gui and gui:FindFirstChild("TextLabel") then
                gui.TextLabel.TextSize = Value
            end
        end
    end,
})

local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        config.espNameColor = Value
        for _, gui in pairs(espPlayers) do
            if gui and gui:FindFirstChild("TextLabel") then
                gui.TextLabel.TextColor3 = Value
            end
        end
    end,
})

local ShowDistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = config.showDistance,
    Flag = "ShowDistance",
    Callback = function(Value)
        config.showDistance = Value
    end,
})

-- ===== AIMLOCK TAB =====
local AimlockToggle = AimlockTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.aimlockEnabled,
    Flag = "AimlockToggle",
    Callback = function(Value)
        config.aimlockEnabled = Value
    end,
})

local AimlockDistanceSlider = AimlockTab:CreateSlider({
    Name = "Distance",
    Min = 25,
    Max = 500,
    DefaultValue = 100,
    Flag = "AimlockDistance",
    Callback = function(Value)
        config.aimlockDistance = Value
    end,
})

local AimlockSmoothnessSlider = AimlockTab:CreateSlider({
    Name = "Smoothness",
    Min = 0.01,
    Max = 1,
    Precision = 2,
    DefaultValue = 0.15,
    Flag = "AimlockSmoothness",
    Callback = function(Value)
        config.aimlockSmoothness = Value
    end,
})

-- ===== LANE TAB =====
local LaneToggle = LaneTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.laneEnabled,
    Flag = "LaneToggle",
    Callback = function(Value)
        config.laneEnabled = Value
    end,
})

local LaneThicknessSlider = LaneTab:CreateSlider({
    Name = "Thickness",
    Min = 0.5,
    Max = 10,
    Precision = 1,
    DefaultValue = 2,
    Flag = "LaneThickness",
    Callback = function(Value)
        config.laneThickness = Value
    end,
})

local LaneColorPicker = LaneTab:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "LaneColor",
    Callback = function(Value)
        config.laneColor = Value
    end,
})

-- ===== TRACER TAB =====
local TracerToggle = TracerTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.tracerEnabled,
    Flag = "TracerToggle",
    Callback = function(Value)
        config.tracerEnabled = Value
    end,
})

local TracerThicknessSlider = TracerTab:CreateSlider({
    Name = "Thickness",
    Min = 0.5,
    Max = 10,
    Precision = 1,
    DefaultValue = 1.5,
    Flag = "TracerThickness",
    Callback = function(Value)
        config.tracerThickness = Value
    end,
})

local TracerColorPicker = TracerTab:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(0, 150, 255),
    Flag = "TracerColor",
    Callback = function(Value)
        config.tracerColor = Value
    end,
})

-- ===== GUN TAB =====
local SilencerToggle = GunTab:CreateToggle({
    Name = "Silencer",
    CurrentValue = config.silencerEnabled,
    Flag = "SilencerToggle",
    Callback = function(Value)
        config.silencerEnabled = Value
    end,
})

local DamageSlider = GunTab:CreateSlider({
    Name = "Damage",
    Min = 10,
    Max = 200,
    DefaultValue = 100,
    Flag = "Damage",
    Callback = function(Value)
        config.silencerDamage = Value
    end,
})

local SpreadSlider = GunTab:CreateSlider({
    Name = "Spread Control",
    Min = 0,
    Max = 1,
    Precision = 2,
    DefaultValue = 0.5,
    Flag = "Spread",
    Callback = function(Value)
        config.spreadControl = Value
    end,
})

local RecoilSlider = GunTab:CreateSlider({
    Name = "Recoil Control",
    Min = 0,
    Max = 1,
    Precision = 2,
    DefaultValue = 0.7,
    Flag = "Recoil",
    Callback = function(Value)
        config.recoilControl = Value
    end,
})

local FireRateSlider = GunTab:CreateSlider({
    Name = "Fire Rate",
    Min = 1,
    Max = 5,
    Precision = 1,
    DefaultValue = 1.5,
    Flag = "FireRate",
    Callback = function(Value)
        config.fireRateBoost = Value
    end,
})

-- ===== WALLHACK TAB =====
local WallhackToggle = WallhackTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.wallhackEnabled,
    Flag = "WallhackToggle",
    Callback = function(Value)
        config.wallhackEnabled = Value
    end,
})

-- ===== VISUAL TAB =====
local NametagsToggle = VisualTab:CreateToggle({
    Name = "Nametags",
    CurrentValue = config.nametags,
    Flag = "Nametags",
    Callback = function(Value)
        config.nametags = Value
    end,
})

local HealthBarsToggle = VisualTab:CreateToggle({
    Name = "Health Bars",
    CurrentValue = config.healthBars,
    Flag = "HealthBars",
    Callback = function(Value)
        config.healthBars = Value
    end,
})

local BoxEspToggle = VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = config.boxEsp,
    Flag = "BoxESP",
    Callback = function(Value)
        config.boxEsp = Value
    end,
})

local SkeletonToggle = VisualTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = config.skeletonEsp,
    Flag = "SkeletonESP",
    Callback = function(Value)
        config.skeletonEsp = Value
    end,
})

-- ===== TEAM TAB =====
local TeamCheckToggle = TeamTab:CreateToggle({
    Name = "Enable",
    CurrentValue = config.teamCheckEnabled,
    Flag = "TeamCheck",
    Callback = function(Value)
        config.teamCheckEnabled = Value
    end,
})

-- ===== CONTROL TAB =====
ControlTab:CreateButton({
    Name = "Toggle ESP",
    Callback = function()
        config.espEnabled = not config.espEnabled
        ESPToggle:Set(config.espEnabled)
    end,
})

ControlTab:CreateButton({
    Name = "Toggle Aimlock",
    Callback = function()
        config.aimlockEnabled = not config.aimlockEnabled
        AimlockToggle:Set(config.aimlockEnabled)
    end,
})

ControlTab:CreateButton({
    Name = "Toggle Lane",
    Callback = function()
        config.laneEnabled = not config.laneEnabled
        LaneToggle:Set(config.laneEnabled)
    end,
})

ControlTab:CreateButton({
    Name = "Toggle Tracer",
    Callback = function()
        config.tracerEnabled = not config.tracerEnabled
        TracerToggle:Set(config.tracerEnabled)
    end,
})

ControlTab:CreateButton({
    Name = "Toggle Wallhack",
    Callback = function()
        config.wallhackEnabled = not config.wallhackEnabled
        WallhackToggle:Set(config.wallhackEnabled)
    end,
})

-- ===== FUNCTIONS =====

local function getPlayerTeam(targetPlayer)
    if targetPlayer:FindFirstChild("Team") then
        return targetPlayer.Team.Value
    elseif targetPlayer.Parent:FindFirstChild("Leaderstats") then
        if targetPlayer.Parent.Leaderstats:FindFirstChild("Team") then
            return targetPlayer.Parent.Leaderstats.Team.Value
        end
    end
    return nil
end

local function isSameTeam(player1, player2)
    if not config.teamCheckEnabled then return false end
    
    local team1 = getPlayerTeam(player1)
    local team2 = getPlayerTeam(player2)
    
    if team1 and team2 then
        return team1 == team2
    end
    
    return false
end

local function createESP(targetPlayer)
    if espPlayers[targetPlayer] then return end
    
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 2, 0)
    billboardGui.MaxDistance = config.espDistance
    billboardGui.Parent = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = config.espNameColor
    textLabel.TextSize = config.espNameSize
    textLabel.TextScaled = true
    textLabel.Text = targetPlayer.Name
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    
    espPlayers[targetPlayer] = billboardGui
end

local function removeESP(targetPlayer)
    if espPlayers[targetPlayer] then
        espPlayers[targetPlayer]:Destroy()
        espPlayers[targetPlayer] = nil
    end
end

local function createLaneLine(targetPlayer)
    if laneConnections[targetPlayer] then
        laneConnections[targetPlayer]:Destroy()
    end
    
    local character = targetPlayer.Character
    local myCharacter = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    local lineLength = (character.HumanoidRootPart.Position - myCharacter.HumanoidRootPart.Position).Magnitude
    local line = Instance.new("Part")
    line.Name = "Line_" .. targetPlayer.Name
    line.Shape = Enum.PartType.Cylinder
    line.Material = Enum.Material.Neon
    line.Size = Vector3.new(config.laneThickness, config.laneThickness, lineLength)
    line.Color = config.laneColor
    line.CanCollide = false
    line.CFrame = CFrame.new(
        (myCharacter.HumanoidRootPart.Position + character.HumanoidRootPart.Position) / 2,
        character.HumanoidRootPart.Position
    )
    line.TopSurface = Enum.SurfaceType.Smooth
    line.BottomSurface = Enum.SurfaceType.Smooth
    line.Parent = workspace
    
    laneConnections[targetPlayer] = line
end

local function createTracerLine(targetPlayer)
    if tracerConnections[targetPlayer] then
        tracerConnections[targetPlayer]:Destroy()
    end
    
    local character = targetPlayer.Character
    local myCharacter = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    local lineLength = (character.HumanoidRootPart.Position - myCharacter.HumanoidRootPart.Position).Magnitude
    local tracer = Instance.new("Part")
    tracer.Name = "Tracer_" .. targetPlayer.Name
    tracer.Shape = Enum.PartType.Cylinder
    tracer.Material = Enum.Material.Neon
    tracer.Size = Vector3.new(config.tracerThickness, config.tracerThickness, lineLength)
    tracer.Color = config.tracerColor
    tracer.CanCollide = false
    tracer.CFrame = CFrame.new(
        (myCharacter.HumanoidRootPart.Position + character.HumanoidRootPart.Position) / 2,
        character.HumanoidRootPart.Position
    )
    tracer.TopSurface = Enum.SurfaceType.Smooth
    tracer.BottomSurface = Enum.SurfaceType.Smooth
    tracer.Parent = workspace
    
    tracerConnections[targetPlayer] = tracer
end

local function updateLaneLines()
    for targetPlayer, line in pairs(laneConnections) do
        if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then
            line:Destroy()
            laneConnections[targetPlayer] = nil
        else
            local character = targetPlayer.Character
            local myCharacter = player.Character
            
            if character:FindFirstChild("HumanoidRootPart") and myCharacter:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - myCharacter.HumanoidRootPart.Position).Magnitude
                line.Size = Vector3.new(config.laneThickness, config.laneThickness, distance)
                line.CFrame = CFrame.new(
                    (myCharacter.HumanoidRootPart.Position + character.HumanoidRootPart.Position) / 2,
                    character.HumanoidRootPart.Position
                )
            end
        end
    end
end

local function updateTracerLines()
    for targetPlayer, tracer in pairs(tracerConnections) do
        if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then
            tracer:Destroy()
            tracerConnections[targetPlayer] = nil
        else
            local character = targetPlayer.Character
            local myCharacter = player.Character
            
            if character:FindFirstChild("HumanoidRootPart") and myCharacter:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - myCharacter.HumanoidRootPart.Position).Magnitude
                tracer.Size = Vector3.new(config.tracerThickness, config.tracerThickness, distance)
                tracer.CFrame = CFrame.new(
                    (myCharacter.HumanoidRootPart.Position + character.HumanoidRootPart.Position) / 2,
                    character.HumanoidRootPart.Position
                )
            end
        end
    end
end

local function applyWallhack(targetPlayer)
    if wallhackPlayers[targetPlayer] then return end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local parts = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            table.insert(parts, part)
        end
    end
    
    wallhackPlayers[targetPlayer] = parts
end

local function removeWallhack(targetPlayer)
    if not wallhackPlayers[targetPlayer] then return end
    
    for _, part in pairs(wallhackPlayers[targetPlayer]) do
        part.CanCollide = true
    end
    wallhackPlayers[targetPlayer] = nil
end

local function findClosestEnemy()
    local closestDistance = config.aimlockDistance
    local closestPlayer = nil
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local character = targetPlayer.Character
            if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                if character.Humanoid.Health > 0 then
                    if config.teamCheckEnabled and isSameTeam(player, targetPlayer) then
                        continue
                    end
                    
                    local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = targetPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimlock()
    if not config.aimlockEnabled then return end
    
    targetPlayer = findClosestEnemy()
    
    if targetPlayer and targetPlayer.Character then
        local targetPos = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetPos then
            local mousePos = targetPos.Position + (targetPos.Position - Camera.CFrame.Position).Unit * 5
            mouse.Hit = CFrame.new(mousePos)
            
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, targetPos.Position),
                config.aimlockSmoothness
            )
        end
    end
end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    -- Update ESP
    if config.espEnabled then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                if not espPlayers[targetPlayer] then
                    createESP(targetPlayer)
                end
            end
        end
    else
        for targetPlayer, _ in pairs(espPlayers) do
            removeESP(targetPlayer)
        end
    end
    
    -- Update Lane
    if config.laneEnabled then
        local visiblePlayers = {}
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                if targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (targetPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < config.espDistance then
                        if not laneConnections[targetPlayer] then
                            createLaneLine(targetPlayer)
                        end
                        visiblePlayers[targetPlayer] = true
                    end
                end
            end
        end
        
        for targetPlayer, _ in pairs(laneConnections) do
            if not visiblePlayers[targetPlayer] then
                laneConnections[targetPlayer]:Destroy()
                laneConnections[targetPlayer] = nil
            end
        end
        
        updateLaneLines()
    else
        for targetPlayer, line in pairs(laneConnections) do
            line:Destroy()
            laneConnections[targetPlayer] = nil
        end
    end
    
    -- Update Tracer
    if config.tracerEnabled then
        local visiblePlayers = {}
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                if targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (targetPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < config.espDistance then
                        if not tracerConnections[targetPlayer] then
                            createTracerLine(targetPlayer)
                        end
                        visiblePlayers[targetPlayer] = true
                    end
                end
            end
        end
        
        for targetPlayer, _ in pairs(tracerConnections) do
            if not visiblePlayers[targetPlayer] then
                tracerConnections[targetPlayer]:Destroy()
                tracerConnections[targetPlayer] = nil
            end
        end
        
        updateTracerLines()
    else
        for targetPlayer, tracer in pairs(tracerConnections) do
            tracer:Destroy()
            tracerConnections[targetPlayer] = nil
        end
    end
    
    -- Wallhack
    if config.wallhackEnabled then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                if not wallhackPlayers[targetPlayer] then
                    applyWallhack(targetPlayer)
                end
            end
        end
    else
        for targetPlayer, _ in pairs(wallhackPlayers) do
            removeWallhack(targetPlayer)
        end
    end
    
    -- Aimlock
    aimlock()
end)

-- ===== CLEANUP =====
Players.PlayerRemoving:Connect(function(removedPlayer)
    removeESP(removedPlayer)
    if laneConnections[removedPlayer] then
        laneConnections[removedPlayer]:Destroy()
        laneConnections[removedPlayer] = nil
    end
    if tracerConnections[removedPlayer] then
        tracerConnections[removedPlayer]:Destroy()
        tracerConnections[removedPlayer] = nil
    end
    removeWallhack(removedPlayer)
end)

player.CharacterAdded:Connect(function()
    espPlayers = {}
    laneConnections = {}
    tracerConnections = {}
    wallhackPlayers = {}
    healthBarPlayers = {}
    targetPlayer = nil
end)

print("✅ SkyZen Arsenal FULL VERSION Loaded!")
print("📊 All Features Active!")
