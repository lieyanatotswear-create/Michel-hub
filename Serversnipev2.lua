---------------------------------------------------------------------
--                      SERVER SNIPE UI + SYSTEM
--          Gabungan UI Modern (Script 1) + Server Snipe Logic (Script 2)
--          Dibahagi ikut section supaya senang update
---------------------------------------------------------------------



---------------------------------------------------------------------
-- 🖥️ UI SECTION
---------------------------------------------------------------------

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Main UI Frame
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Active = true
MainFrame.Draggable = true

-- Tabs
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(0, 120, 1, 0)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, 0)
ContentFrame.Position = UDim2.new(0, 120, 0, 0)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Tab Buttons Factory
local function CreateTabButton(name, order)
    local btn = Instance.new("TextButton", TabButtons)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    return btn
end

-- Content Factory
local function CreateTabPage()
    local frame = Instance.new("Frame", ContentFrame)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    return frame
end

-- Tab system
local Tabs = {}
local function AddTab(name, order)
    local btn = CreateTabButton(name, order)
    local page = CreateTabPage()
    Tabs[name] = page
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Tabs) do p.Visible = false end
        page.Visible = true
    end)
    if order == 1 then page.Visible = true end
    return page
end

-- 🟢 Server Snipe Tab
local SnipeTab = AddTab("Server Snipe", 1)

local PlaceBox = Instance.new("TextBox", SnipeTab)
PlaceBox.Size = UDim2.new(0, 250, 0, 30)
PlaceBox.Position = UDim2.new(0, 20, 0, 20)
PlaceBox.PlaceholderText = "PlaceID"
PlaceBox.Text = ""

local UserBox = Instance.new("TextBox", SnipeTab)
UserBox.Size = UDim2.new(0, 250, 0, 30)
UserBox.Position = UDim2.new(0, 20, 0, 60)
UserBox.PlaceholderText = "Username / UserID"
UserBox.Text = ""

local ModeDropdown = Instance.new("TextButton", SnipeTab)
ModeDropdown.Size = UDim2.new(0, 250, 0, 30)
ModeDropdown.Position = UDim2.new(0, 20, 0, 100)
ModeDropdown.Text = "Mode: TP"

local modes = {"TP", "Log", "TPLog"}
local modeIndex = 1
ModeDropdown.MouseButton1Click:Connect(function()
    modeIndex = modeIndex % #modes + 1
    ModeDropdown.Text = "Mode: " .. modes[modeIndex]
end)

local SnipeBtn = Instance.new("TextButton", SnipeTab)
SnipeBtn.Size = UDim2.new(0, 250, 0, 35)
SnipeBtn.Position = UDim2.new(0, 20, 0, 140)
SnipeBtn.Text = "🎯 Snipe Now"
SnipeBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SnipeBtn.TextColor3 = Color3.new(1,1,1)

-- ⚙️ Settings Tab
local SettingsTab = AddTab("Settings", 2)

local BgLabel = Instance.new("TextLabel", SettingsTab)
BgLabel.Size = UDim2.new(0, 200, 0, 30)
BgLabel.Position = UDim2.new(0, 20, 0, 20)
BgLabel.Text = "Background Mode"
BgLabel.BackgroundTransparency = 1
BgLabel.TextColor3 = Color3.new(1,1,1)

local BgBtn = Instance.new("TextButton", SettingsTab)
BgBtn.Size = UDim2.new(0, 200, 0, 30)
BgBtn.Position = UDim2.new(0, 20, 0, 60)
BgBtn.Text = "Grey"
BgBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
BgBtn.TextColor3 = Color3.new(1,1,1)

local bgColors = {
    Grey = Color3.fromRGB(50,50,50),
    Black = Color3.fromRGB(0,0,0),
    White = Color3.fromRGB(255,255,255),
}
local bgKeys = {"Grey","Black","White"}
local bgIndex = 1

BgBtn.MouseButton1Click:Connect(function()
    bgIndex = bgIndex % #bgKeys + 1
    local mode = bgKeys[bgIndex]
    BgBtn.Text = mode
    MainFrame.BackgroundColor3 = bgColors[mode]
end)



---------------------------------------------------------------------
-- ⚡ SYSTEM SECTION
---------------------------------------------------------------------

-- (💡 ambil logic dari Script Kedua, disusun semula)
-- Utility functions
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function runScript(code)
    loadstring(code)()
end

local function json(data)
    return HttpService:JSONEncode(data)
end

local function json2(str)
    return HttpService:JSONDecode(str)
end

local function playertoken(user)
    local success, result = pcall(function()
        return game:HttpGet("https://api.roblox.com/users/get-by-username?username="..user)
    end)
    if success then
        local data = json2(result)
        return data.Id
    end
    return nil
end

-- Main Snipe Action
local function ServerSnipe(placeid, username, mode)
    local userid = tonumber(username) or playertoken(username)
    if not userid then
        warn("❌ Invalid username/UserID")
        return
    end

    print("🔎 Snipe Request → PlaceID:", placeid, " UserID:", userid, " Mode:", mode)

    if mode == "TP" then
        TeleportService:TeleportToPlaceInstance(placeid, tostring(userid), LocalPlayer)
    elseif mode == "Log" then
        print("📝 Logging only (no teleport).")
    elseif mode == "TPLog" then
        print("📝 Logging & Teleporting...")
        TeleportService:TeleportToPlaceInstance(placeid, tostring(userid), LocalPlayer)
    end
end

-- 🔘 Connect Button
SnipeBtn.MouseButton1Click:Connect(function()
    local placeid = PlaceBox.Text
    local user = UserBox.Text
    local mode = modes[modeIndex]
    ServerSnipe(placeid, user, mode)
end)



---------------------------------------------------------------------
-- ✅ END OF SCRIPT
---------------------------------------------------------------------
