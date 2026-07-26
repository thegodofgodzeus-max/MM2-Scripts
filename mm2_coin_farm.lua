local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Settings = {
    FarmEnabled = true,
    FarmRange = 25,
    FarmDelay = 0.1,
    UseClickDetector = true,
    UseTouchInterest = true,
    UseTeleport = true,
    ShowESP = true,
}

local function FindCoins()
    local coins = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    return coins
end

local function CollectWithClick(part)
    if not Settings.UseClickDetector then return false end
    local cd = part:FindFirstChildOfClass("ClickDetector")
    if cd then
        pcall(function()
            fireclickdetector(cd)
            return true
        end)
        return true
    end
    return false
end

local function CollectWithTouch(part)
    if not Settings.UseTouchInterest then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            wait(0.05)
            firetouchinterest(hrp, part, 1)
            return true
        end)
        return true
    end
    return false
end

local function CollectWithTeleport(part)
    if not Settings.UseTeleport then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            local oldPos = hrp.Position
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
            wait(0.05)
            CollectWithClick(part)
            CollectWithTouch(part)
            wait(0.05)
            hrp.CFrame = CFrame.new(oldPos)
            return true
        end)
        return true
    end
    return false
end

local function Farm()
    if not Settings.FarmEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local coins = FindCoins()
    local collected = 0
    for _, coin in pairs(coins) do
        local dist = (coin.Position - hrp.Position).Magnitude
        if dist > Settings.FarmRange then continue end
        local success = false
        if not success and Settings.UseClickDetector then
            success = CollectWithClick(coin)
        end
        if not success and Settings.UseTouchInterest then
            success = CollectWithTouch(coin)
        end
        if not success and Settings.UseTeleport then
            success = CollectWithTeleport(coin)
        end
        if success then
            collected = collected + 1
        end
        wait(Settings.FarmDelay)
    end
    if collected > 0 then
        print("[FARM] " .. collected .. " coin toplandı!")
    end
end

local ESPObjects = {}

local function CreateESP()
    if not Settings.ShowESP then
        for _, data in pairs(ESPObjects) do
            if data then pcall(function() data:Destroy() end) end
        end
        ESPObjects = {}
        return
    end
    local coins = FindCoins()
    for _, coin in pairs(coins) do
        if not ESPObjects[coin] then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 80, 0, 30)
            bill.StudsOffset = Vector3.new(0, 1.5, 0)
            bill.AlwaysOnTop = true
            bill.Adornee = coin
            bill.Parent = coin
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.2
            frame.BackgroundColor3 = Color3.new(1, 0.8, 0)
            frame.BorderSizePixel = 1
            frame.Parent = bill
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "💰"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.Parent = frame
            ESPObjects[coin] = bill
        end
    end
end

local function CreateMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CoinFarm"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 280)
    frame.Position = UDim2.new(0.5, -125, 0.5, -140)
    frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.15)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "💰 COIN FARM"
    title.TextColor3 = Color3.new(1, 0.8, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.Parent = frame
    local y = 45
    local function Toggle(text, setting)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 30)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.Text = text .. ": " .. (Settings[setting] and "AÇIK" or "KAPALI")
        btn.TextColor3 = Settings[setting] and Color3.new(0.2, 0.9, 0.2) or Color3.new(0.9, 0.2, 0.2)
        btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
        btn.BorderSizePixel = 0
        btn.Parent = frame
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            btn.Text = text .. ": " .. (Settings[setting] and "AÇIK" or "KAPALI")
            btn.TextColor3 = Settings[setting] and Color3.new(0.2, 0.9, 0.2) or Color3.new(0.9, 0.2, 0.2)
        end)
        y = y + 38
    end
    Toggle("Farm", "FarmEnabled")
    Toggle("Click Detector", "UseClickDetector")
    Toggle("Touch Interest", "UseTouchInterest")
    Toggle("Teleport", "UseTeleport")
    Toggle("ESP", "ShowESP")
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.4, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.3, 0, 0, y + 10)
    closeBtn.Text = "KAPAT"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

spawn(function()
    while wait(0.5) do
        pcall(Farm)
    end
end)

spawn(function()
    while wait(1) do
        pcall(CreateESP)
    end
end)

CreateMenu()

print("💰 MM2 COIN FARM YÜKLENDİ!")
