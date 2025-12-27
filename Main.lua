local Players = game:GetService("Players")
local player = Players.LocalPlayer

local WhitelistedUserIds = {
    8606003741,
    1395397712,
    97551868,
    8843649052,
    5400555417,
}

local WhitelistedNames = {
    "Not_happy300",
}

local function isWhitelisted(plr)
    for _, id in ipairs(WhitelistedUserIds) do
        if plr.UserId == id then
            return true
        end
    end

    for _, name in ipairs(WhitelistedNames) do
        if plr.Name:lower() == name:lower() 
        or plr.DisplayName:lower() == name:lower() then
            return true
        end
    end

    return false
end

if not isWhitelisted(player) then
    player:Kick("Not whitelisted")
end
-- =========================
-- SERVICES
-- =========================
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local backpack = player:WaitForChild("Backpack")
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- =========================
-- GUI
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisionTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 230)
Frame.Position = UDim2.new(0.5, -120, 0.5, -115)
Frame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 140, 255)

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -20, 0, 36)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Text = "KA Teleport"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Center

-- TELEPORT BUTTON
local TeleportButton = Instance.new("TextButton", Frame)
TeleportButton.Size = UDim2.new(0, 190, 0, 50)
TeleportButton.Position = UDim2.new(0, 25, 0, 60)
TeleportButton.Text = "TELEPORT"
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextSize = 16
TeleportButton.TextColor3 = Color3.fromRGB(255,255,255)
TeleportButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
TeleportButton.BorderSizePixel = 0
Instance.new("UICorner", TeleportButton).CornerRadius = UDim.new(0, 10)

-- KEYBIND BUTTON
local KeybindButton = Instance.new("TextButton", Frame)
KeybindButton.Size = UDim2.new(0, 190, 0, 50)
KeybindButton.Position = UDim2.new(0, 25, 0, 120)
KeybindButton.Text = "Keybind: [F]"
KeybindButton.Font = Enum.Font.GothamBold
KeybindButton.TextSize = 16
KeybindButton.TextColor3 = Color3.fromRGB(255,255,255)
KeybindButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
KeybindButton.BorderSizePixel = 0
Instance.new("UICorner", KeybindButton).CornerRadius = UDim.new(0, 10)

-- =========================
-- TELEPORT DATA
-- =========================
local spots = {
    CFrame.new(-402.18, -6.34, 131.83) * CFrame.Angles(0, math.rad(-20), 0),
    CFrame.new(-416.66, -6.34, -2.05) * CFrame.Angles(0, math.rad(-63), 0),
    CFrame.new(-329.37, -4.68, 18.12) * CFrame.Angles(0, math.rad(-31), 0),
}

local REQUIRED_TOOL = "Flying Carpet"
local teleportKey = Enum.KeyCode.F
local waitingForKey = false
local lastStealer = nil

-- =========================
-- TOOL EQUIP
-- =========================
local function equipFlyingCarpet()
    local tool = char:FindFirstChild(REQUIRED_TOOL) or backpack:FindFirstChild(REQUIRED_TOOL)
    if not tool then return false end
    humanoid:EquipTool(tool)
    repeat task.wait() until char:FindFirstChildOfClass("Tool") == tool
    return true
end

-- =========================
-- AUTO BLOCK (UNTOUCHED)
-- =========================
local function blockPlayer(plr)
    if not plr or plr == player then return end
    pcall(function()
        StarterGui:SetCore("PromptBlockPlayer", plr)
    end)
end

-- =========================
-- TELEPORT FUNCTION
-- =========================
local function teleportAll()
    if not equipFlyingCarpet() then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            lastStealer = plr
            break
        end
    end

    for _, spot in ipairs(spots) do
        hrp.CFrame = spot
        task.wait(0.12)
    end

    if lastStealer then
        blockPlayer(lastStealer)
    end
end

-- =========================
-- BUTTONS / KEYBINDS
-- =========================
TeleportButton.MouseButton1Click:Connect(teleportAll)

KeybindButton.MouseButton1Click:Connect(function()
    waitingForKey = true
    KeybindButton.Text = "Press a key..."
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        teleportKey = input.KeyCode
        KeybindButton.Text = "Keybind: [" .. teleportKey.Name .. "]"
        waitingForKey = false
    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == teleportKey then
        teleportAll()
    end
end)
