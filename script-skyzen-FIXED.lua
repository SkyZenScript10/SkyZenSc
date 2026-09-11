-- SkyZen Arsenal Aimlock + ESP Script (FIXED VERSION)
-- Perbaikan: ESP jarak jauh, Lane lines, Team check untuk aimlock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configuration
local config = {
    espEnabled = true,
    aimlockEnabled = true,
    laneEnabled = true,
    teamCheckEnabled = true,
    espDistance = 500, -- Jarak jauh untuk ESP visibility
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

-- Function untuk mendapatkan team dari player
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

-- Function untuk check apakah player 1 same team dengan player 2
local function isSameTeam(player1, player2)
    if not config.teamCheckEnabled then return false end
    
    local team1 = getPlayerTeam(player1)
    local team2 = getPlayerTeam(player2)
    
    if team1 and team2 then
        return team1 == team2
    end
    
    return false
end

-- Function untuk create ESP
local function createESP(targetPlayer)
    if espPlayers[targetPlayer] then return end
    
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Create Billboard GUI
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 2, 0)
    billboardGui.MaxDistance = config.espDistance -- Terlihat dari jarak jauh
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

-- Function untuk remove ESP
local function removeESP(targetPlayer)
    if espPlayers[targetPlayer] then
        espPlayers[targetPlayer]:Destroy()
        espPlayers[targetPlayer] = nil
    end
end

-- Function untuk create lane line
local function createLaneLine(targetPlayer)
    if laneConnections[targetPlayer] then
        laneConnections[targetPlayer]:Destroy()
    end
    
    local character = targetPlayer.Character
    local myCharacter = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    -- Create line using Part
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

-- Function untuk update lane lines
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

-- Function untuk find closest enemy (dengan team check)
local function findClosestEnemy()
    local closestDistance = config.aimlockDistance
    local closestPlayer = nil
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local character = targetPlayer.Character
            if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                if character.Humanoid.Health > 0 then
                    -- Check team
                    if config.teamCheckEnabled and isSameTeam(player, targetPlayer) then
                        continue -- Skip teammate
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

-- Function untuk aimlock
local function aimlock()
    if not config.aimlockEnabled then return end
    
    targetPlayer = findClosestEnemy()
    
    if targetPlayer and targetPlayer.Character then
        local targetPos = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetPos then
            local mousePos = targetPos.Position + (targetPos.Position - Camera.CFrame.Position).Unit * 5
            mouse.Hit = CFrame.new(mousePos)
            
            -- Smooth aimlock
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, targetPos.Position),
                config.aimlockSmoothness
            )
        end
    end
end

-- Function untuk toggle features
local function toggleESP()
    config.espEnabled = not config.espEnabled
    print("ESP: " .. (config.espEnabled and "ON" or "OFF"))
end

local function toggleAimlock()
    config.aimlockEnabled = not config.aimlockEnabled
    print("Aimlock: " .. (config.aimlockEnabled and "ON" or "OFF"))
end

local function toggleLane()
    config.laneEnabled = not config.laneEnabled
    print("Lane: " .. (config.laneEnabled and "ON" or "OFF"))
end

local function toggleTeamCheck()
    config.teamCheckEnabled = not config.teamCheckEnabled
    print("Team Check: " .. (config.teamCheckEnabled and "ON" or "OFF"))
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        toggleESP()
    elseif input.KeyCode == Enum.KeyCode.L then
        toggleAimlock()
    elseif input.KeyCode == Enum.KeyCode.O then
        toggleLane()
    elseif input.KeyCode == Enum.KeyCode.T then
        toggleTeamCheck()
    end
end)

-- Main loop
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
        
        -- Remove lane lines untuk players yang tidak visible
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

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(removedPlayer)
    removeESP(removedPlayer)
    if laneConnections[removedPlayer] then
        laneConnections[removedPlayer]:Destroy()
        laneConnections[removedPlayer] = nil
    end
end)

-- Cleanup when character respawns
player.CharacterAdded:Connect(function()
    espPlayers = {}
    laneConnections = {}
    targetPlayer = nil
end)

print("=== SkyZen Arsenal Aimlock + ESP FIXED ===")
print("E - Toggle ESP")
print("L - Toggle Aimlock")
print("O - Toggle Lane")
print("T - Toggle Team Check")
print("=====================================")
