-- SkyZen Arsenal Aimlock + ESP Script dengan Rayfield GUI (Mobile Only)
-- Perbaikan: ESP jarak jauh, Lane lines, Team check, Mobile Touch Controls

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local config = {
    espEnabled = true,
    aimlockEnabled = true,
    laneEnabled = true,
    teamCheckEnabled = true,
    espDistance = 500,
    espNameSize = 16,
    espNameColor = Color3.fromRGB(0, 255, 0),
    laneColor = Color3.fromRGB(255, 0, 0),
    laneThickness = 2,
    aimlockDistance = 100,
    aimlockSmoothness = 0.15,
}

local espPlayers = {}
local laneConnections = {}
local targetPlayer = nil

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "🔥 SkyZen Arsenal Script",
    LoadingTitle = "SkyZen Loading...",
    LoadingSubtitle = "by SkyZenScript10 (Mobile)",
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
local ESPTab = Window:CreateTab("🎯 ESP Settings", 4483362458)
local AimlockTab = Window:CreateTab("🔒 Aimlock Settings", 4483362458)
local LaneTab = Window:CreateTab("📍 Lane Settings", 4483362458)
local TeamTab = Window:CreateTab("👥 Team Settings", 4483362458)
local MobileTab = Window:CreateTab("📱 Mobile Controls", 4483362458)
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

-- ===== ESP TAB =====
local ESPToggle = ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = config.espEnabled,
    Flag = "ESPToggle",
    Callback = function(Value)
        config.espEnabled = Value
        print("ESP: " .. (Value and "✅ ON" or "❌ OFF"))
    end,
})

local ESPDistanceSlider = ESPTab:CreateSlider({
    Name = "ESP Distance",
    Min = 100,
    Max = 2000,
    DefaultValue = 500,
    Flag = "ESPDistance",
    Callback = function(Value)
        config.espDistance = Value
        print("ESP Distance: " .. Value)
    end,
})

local ESPSizeSlider = ESPTab:CreateSlider({
    Name = "ESP Name Size",
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
    Name = "ESP Name Color",
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

-- ===== AIMLOCK TAB =====
local AimlockToggle = AimlockTab:CreateToggle({
    Name = "Enable Aimlock",
    CurrentValue = config.aimlockEnabled,
    Flag = "AimlockToggle",
    Callback = function(Value)
        config.aimlockEnabled = Value
        print("Aimlock: " .. (Value and "✅ ON" or "❌ OFF"))
    end,
})

local AimlockDistanceSlider = AimlockTab:CreateSlider({
    Name = "Aimlock Distance",
    Min = 25,
    Max = 500,
    DefaultValue = 100,
    Flag = "AimlockDistance",
    Callback = function(Value)
        config.aimlockDistance = Value
        print("Aimlock Distance: " .. Value)
    end,
})

local AimlockSmoothnessSlider = AimlockTab:CreateSlider({
    Name = "Aimlock Smoothness",
    Min = 0.01,
    Max = 1,
    Precision = 2,
    DefaultValue = 0.15,
    Flag = "AimlockSmoothness",
    Callback = function(Value)
        config.aimlockSmoothness = Value
        print("Aimlock Smoothness: " .. Value)
    end,
})

AimlockTab:CreateLabel("Lower = Smoother | Higher = Faster")

-- ===== LANE TAB =====
local LaneToggle = LaneTab:CreateToggle({
    Name = "Enable Lane Lines",
    CurrentValue = config.laneEnabled,
    Flag = "LaneToggle",
    Callback = function(Value)
        config.laneEnabled = Value
        print("Lane Lines: " .. (Value and "✅ ON" or "❌ OFF"))
    end,
})

local LaneThicknessSlider = LaneTab:CreateSlider({
    Name = "Line Thickness",
    Min = 0.5,
    Max = 10,
    Precision = 1,
    DefaultValue = 2,
    Flag = "LaneThickness",
    Callback = function(Value)
        config.laneThickness = Value
        print("Lane Thickness: " .. Value)
    end,
})

local LaneColorPicker = LaneTab:CreateColorPicker({
    Name = "Lane Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "LaneColor",
    Callback = function(Value)
        config.laneColor = Value
    end,
})

-- ===== TEAM TAB =====
local TeamCheckToggle = TeamTab:CreateToggle({
    Name = "Enable Team Check",
    CurrentValue = config.teamCheckEnabled,
    Flag = "TeamCheck",
    Callback = function(Value)
        config.teamCheckEnabled = Value
        print("Team Check: " .. (Value and "✅ ON (Skip Teammates)" or "❌ OFF"))
    end,
})

TeamTab:CreateLabel("Aimlock tidak akan lock ke 1 team")
TeamTab:CreateLabel("Aktifkan untuk fairplay")

-- ===== MOBILE TAB =====
MobileTab:CreateLabel("📱 MOBILE TOUCH CONTROLS")
MobileTab:CreateDivider()

MobileTab:CreateLabel("✅ All features automatically ON at startup")
MobileTab:CreateLabel("✅ Swipe di screen untuk settings")
MobileTab:CreateLabel("✅ Tap tombol di layar untuk toggle")

MobileTab:CreateButton({
    Name = "Toggle ESP (Touch)",
    Callback = function()
        config.espEnabled = not config.espEnabled
        ESPToggle:Set(config.espEnabled)
        print("ESP: " .. (config.espEnabled and "✅ ON" or "❌ OFF"))
    end,
})

MobileTab:CreateButton({
    Name = "Toggle Aimlock (Touch)",
    Callback = function()
        config.aimlockEnabled = not config.aimlockEnabled
        AimlockToggle:Set(config.aimlockEnabled)
        print("Aimlock: " .. (config.aimlockEnabled and "✅ ON" or "❌ OFF"))
    end,
})

MobileTab:CreateButton({
    Name = "Toggle Lane (Touch)",
    Callback = function()
        config.laneEnabled = not config.laneEnabled
        LaneToggle:Set(config.laneEnabled)
        print("Lane: " .. (config.laneEnabled and "✅ ON" or "❌ OFF"))
    end,
})

MobileTab:CreateButton({
    Name = "Toggle Team Check (Touch)",
    Callback = function()
        config.teamCheckEnabled = not config.teamCheckEnabled
        TeamCheckToggle:Set(config.teamCheckEnabled)
        print("Team Check: " .. (config.teamCheckEnabled and "✅ ON" or "❌ OFF"))
    end,
})

-- ===== INFO TAB =====
InfoTab:CreateLabel("🎮 FITUR UTAMA:")
InfoTab:CreateLabel("✅ ESP jarak jauh (500 meter)")
InfoTab:CreateLabel("✅ Lane lines real-time")
InfoTab:CreateLabel("✅ Team check automatic")
InfoTab:CreateLabel("✅ Aimlock smooth")
InfoTab:CreateLabel("✅ GUI Rayfield")
InfoTab:CreateLabel("✅ Mobile Touch Controls")

InfoTab:CreateDivider()

InfoTab:CreateLabel("📊 AUTO START:")
InfoTab:CreateLabel("Semua fitur sudah ON di awal game")
InfoTab:CreateLabel("Tinggal gunakan tombol di Mobile Tab")

InfoTab:CreateDivider()

InfoTab:CreateLabel("Made by SkyZenScript10")
InfoTab:CreateLabel("Version: 2.0 MOBILE")

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
    line.Name = "LaneLine_" .. targetPlayer.Name
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
    
    -- Update Lane lines
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
end)

player.CharacterAdded:Connect(function()
    espPlayers = {}
    laneConnections = {}
    targetPlayer = nil
end)

print("✅ SkyZen Arsenal Script Loaded!")
print("📋 Buka GUI untuk settings")
print("📱 Gunakan tombol di Mobile Tab untuk toggle")
print("✨ Semua fitur ON by default!")
