--[[
Modern Hub UI with server snipe exploit script. Designed for Roblox exploit execution.
Features:
- Draggable, resizable main window with smooth animations
- Top bar with Minimize, Home, Close buttons
- Status text (🟢 In Game | 🟡 Online | 🔴 Offline)
- Sidebar with tabs: Credit, Server snipe, Setting. Active tab with green vertical bar.
- Smooth transitions between tabs
- Server snipe tab with player info, search bar, input, and buttons per spec
- Copy buttons copy to clipboard (exploit syscall or setclipboard if available)
- Notifications slide in/out with smooth animations for feedback
- All buttons placeholder-functional except server snipe, which actually attempts teleporting to target player's server
- Elegant and minimal style with shadows, rounded corners, gradients

Run this in your exploit environment with supported GUI API, TweenService, and exploits that provide like clipboard functionality.

--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

-- Clipboard utility (exploit compatible)
local function copyToClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
    elseif (syn and syn.set_clipboard) then
        pcall(syn.set_clipboard, text)
    elseif (write_clipboard) then
        pcall(write_clipboard, text)
    else
        -- unable to copy
        warn("Clipboard copy not supported in this exploit.")
    end
end

-- Color helpers
local function hexToColor3(hex)
    hex = hex:gsub("#","")
    assert(#hex == 6, "Invalid hex color")
    local r = tonumber(hex:sub(1,2),16)/255
    local g = tonumber(hex:sub(3,4),16)/255
    local b = tonumber(hex:sub(5,6),16)/255
    return Color3.new(r,g,b)
end

-- Tween helper with promise-style completion
local function tween(instance, goal, time, style, direction)
    style = style or Enum.EasingStyle.Sine
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(time, style, direction)
    local tw = TweenService:Create(instance, tweenInfo, goal)
    tw:Play()
    return tw
end

-- Root ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernHubGUI"
ScreenGui.Parent = PlayerGui
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end
ScreenGui.ResetOnSpawn = false

-- Notification container (top-right)
local NotiContainer = Instance.new("Frame")
NotiContainer.Name = "NotiContainer"
NotiContainer.Size = UDim2.new(0, 300, 0, 100)
NotiContainer.Position = UDim2.new(1, -310, 0, 10)
NotiContainer.BackgroundTransparency = 1
NotiContainer.Parent = ScreenGui

local NotiUIList = Instance.new("UIListLayout")
NotiUIList.FillDirection = Enum.FillDirection.Vertical
NotiUIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotiUIList.SortOrder = Enum.SortOrder.LayoutOrder
NotiUIList.Padding = UDim.new(0,5)
NotiUIList.Parent = NotiContainer

-- Notification function
local function createNotification(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.AnchorPoint = Vector2.new(1,0)
    frame.Position = UDim2.new(1, 300, 0, 0) -- start offscreen right
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BorderSizePixel = 0
    frame.Parent = NotiContainer
    frame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 15, 0, 0)
    textLabel.Size = UDim2.new(1, -30, 1, 0)
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.Text = text
    textLabel.Font = Enum.Font.SourceSansSemibold
    textLabel.TextSize = 16
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame

    -- Slide In Tween
    local slideIn = tween(frame, {Position=UDim2.new(1, -10, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    slideIn.Completed:Wait()

    -- Stay for 4 seconds
    delay(4, function()
        -- Slide Out Tween
        local slideOut = tween(frame, {Position=UDim2.new(1, 300, 0,0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        slideOut.Completed:Wait()
        frame:Destroy()
    end)
end

-- Main window Frame (starts tiny for animation)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 380)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -190)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Gradient background
local backgroundGradient = Instance.new("UIGradient")
backgroundGradient.Rotation = 145
backgroundGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40,40,40)),
}
backgroundGradient.Parent = MainFrame

-- Shadow simulated with ImageLabel
local Shadow = Instance.new("ImageLabel")
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217" -- ui_shadow_05 (rounded shadow)
Shadow.ZIndex = 0
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(20, 20, 280, 280)
Shadow.Parent = MainFrame

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 16)
TopBarCorner.Parent = TopBar

-- Title - top left
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Text = "Server snipe by michel"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
TitleLabel.TextSize = 18
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 4)
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Helper button creator
local function createButton(text, positionX)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 30, 0, 30)
    button.Position = UDim2.new(1, positionX, 0, 3)
    button.BackgroundColor3 = Color3.fromRGB(70,70,70)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20
    button.TextColor3 = Color3.fromRGB(200,200,200)
    button.Text = text
    button.AutoButtonColor = false
    button.Name = text .. "Button"
    button.ZIndex = 10
    button.Parent = TopBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.15)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.15)
    end)
    return button
end

local MinimizeBtn = createButton("–", -100)
local HomeBtn = createButton("⌂", -60)
local CloseBtn = createButton("X", -20)

-- Status text: right side of TopBar center
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 120, 0, 20)
StatusText.Position = UDim2.new(1, -240, 0, 8)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.SourceSansSemibold
StatusText.TextSize = 14
StatusText.TextColor3 = Color3.fromRGB(130, 255, 130)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Text = "🟢 In Game"
StatusText.ZIndex = 11
StatusText.Parent = TopBar

-- Draggable logic
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.Heartbeat:Connect(function()
    if dragging and dragInput then
        update(dragInput)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 120, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 16)
sidebarCorner.Parent = Sidebar

local UIListSidebar = Instance.new("UIListLayout")
UIListSidebar.Padding = UDim.new(0, 8)
UIListSidebar.FillDirection = Enum.FillDirection.Vertical
UIListSidebar.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListSidebar.Parent = Sidebar

-- Tab buttons data
local tabsData = {
    {Name="Credit", Order=1},
    {Name="Server snipe", Order=2},
    {Name="Setting", Order=3},
}

-- Will hold buttons and highlight bars
local tabButtons = {}
local activeTab = nil

-- Container for main content to right of sidebar
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -120, 1, -36)
ContentContainer.Position = UDim2.new(0, 120, 0, 36)
ContentContainer.BackgroundColor3 = Color3.fromRGB(38,38,38)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 16)
ContentCorner.Parent = ContentContainer

-- Tab content frames
local creditFrame = Instance.new("Frame")
creditFrame.BackgroundTransparency = 1
creditFrame.Visible = false
creditFrame.Size = UDim2.new(1,0,1,0)
creditFrame.Parent = ContentContainer

local serverSnipeFrame = Instance.new("Frame")
serverSnipeFrame.BackgroundTransparency = 1
serverSnipeFrame.Visible = false
serverSnipeFrame.Size = UDim2.new(1,0,1,0)
serverSnipeFrame.Parent = ContentContainer

local settingFrame = Instance.new("Frame")
settingFrame.BackgroundTransparency = 1
settingFrame.Visible = false
settingFrame.Size = UDim2.new(1,0,1,0)
settingFrame.Parent = ContentContainer

-- Creates tab button with highlight bar
local function createTabButton(name)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tabsData[name].Order or 1
    container.Parent = Sidebar

    local highlightBar = Instance.new("Frame")
    highlightBar.Size = UDim2.new(0, 5, 1, 0)
    highlightBar.BackgroundColor3 = Color3.fromRGB(30, 210, 30)
    highlightBar.Visible = false
    highlightBar.Parent = container

    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabButton"
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, -5, 1, 0)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.AutoButtonColor = false
    btn.Parent = container

    -- Hover effect
    btn.MouseEnter:Connect(function()
        if not highlightBar.Visible then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not highlightBar.Visible then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15)
        end
    end)
    return btn, highlightBar, container
end

-- Map to store tab buttons by name for access
local tabBtnObjects = {}

for _, tabInfo in pairs(tabsData) do
    local btn, hl, container = createTabButton(tabInfo.Name)
    tabBtnObjects[tabInfo.Name] = {Button=btn, Highlight=hl, Container=container}
end

-- Function to activate a tab given tab name
local function activateTab(tabName)
    if activeTab == tabName then return end
    activeTab = tabName

    for name, objs in pairs(tabBtnObjects) do
        local isActive = (name == tabName)
        objs.Highlight.Visible = isActive
        tween(objs.Button, {BackgroundColor3 = isActive and Color3.fromRGB(50, 130, 50) or Color3.fromRGB(45,45,45)}, 0.15)
        objs.Button.TextColor3 = isActive and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)
    end

    -- Show proper content frame with smooth transition
    local frames = {Credit=creditFrame, ["Server snipe"]=serverSnipeFrame, Setting=settingFrame}
    for name, frame in pairs(frames) do
        if name == tabName then
            frame.Visible = true
            frame.BackgroundTransparency = 1
            tween(frame, {BackgroundTransparency=0}, 0.3)
        else
            tween(frame, {BackgroundTransparency=1}, 0.3):Completed:Wait()
            frame.Visible = false
        end
    end
end

activateTab("Credit")

-- Widgets for Credit tab --
do
    -- Credit text label
    local creditText = Instance.new("TextLabel")
    creditText.Text = "Credit to: michal"
    creditText.Size = UDim2.new(1, -40, 0, 30)
    creditText.Position = UDim2.new(0, 20, 0, 20)
    creditText.Font = Enum.Font.SourceSansSemibold
    creditText.TextColor3 = Color3.new(1,1,1)
    creditText.TextSize = 20
    creditText.BackgroundTransparency = 1
    creditText.TextXAlignment = Enum.TextXAlignment.Left
    creditText.Parent = creditFrame

    -- Discord Logo Button
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Position = UDim2.new(0, 20, 0, 70)
    discordBtn.Size = UDim2.new(0, 130, 0, 130)
    discordBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    discordBtn.BorderSizePixel = 0
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = creditFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = discordBtn

    local discordLogo = Instance.new("ImageLabel")
    discordLogo.Image = "rbxassetid://6031094679" -- Discord logo (transparent)
    discordLogo.Size = UDim2.new(0, 80, 0, 80)
    discordLogo.Position = UDim2.new(0.5, -40, 0, 10)
    discordLogo.BackgroundTransparency = 1
    discordLogo.Parent = discordBtn

    -- Text below logo
    local discordLabel = Instance.new("TextLabel")
    discordLabel.Text = "Join Discord server"
    discordLabel.Size = UDim2.new(1, 0, 0, 30)
    discordLabel.Position = UDim2.new(0, 0, 0, 95)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Font = Enum.Font.SourceSansSemibold
    discordLabel.TextColor3 = Color3.fromRGB(160, 255, 160)
    discordLabel.TextSize = 18
    discordLabel.Parent = discordBtn

    discordBtn.MouseEnter:Connect(function()
        tween(discordBtn, {BackgroundColor3 = Color3.fromRGB(70,70,70)}, 0.2)
    end)
    discordBtn.MouseLeave:Connect(function()
        tween(discordBtn, {BackgroundColor3 = Color3.fromRGB(50,50,50)}, 0.2)
    end)
    discordBtn.MouseButton1Click:Connect(function()
        createNotification("Discord link copied to clipboard.")
        copyToClipboard("https://discord.gg/WstAPrVe")
    end)

    -- Text link box below
    local linkBox = Instance.new("TextBox")
    linkBox.Text = "https://discord.gg/WstAPrVe"
    linkBox.ClearTextOnFocus = false
    linkBox.TextEditable = false
    linkBox.Size = UDim2.new(1, -40, 0, 30)
    linkBox.Position = UDim2.new(0, 20, 0, 210)
    linkBox.Font = Enum.Font.SourceSans
    linkBox.TextColor3 = Color3.new(1,1,1)
    linkBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    linkBox.BorderColor3 = Color3.fromRGB(80,80,80)
    linkBox.Parent = creditFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = linkBox
end

-- Widgets for Server snipe tab --
local ServerSnipeUI = {}
do
    local frame = serverSnipeFrame

    -- Search bar top
    local searchBar = Instance.new("TextBox")
    searchBar.PlaceholderText = "Search"
    searchBar.Size = UDim2.new(1, -40, 0, 32)
    searchBar.Position = UDim2.new(0, 20, 0, 20)
    searchBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    searchBar.TextColor3 = Color3.new(1,1,1)
    searchBar.Font = Enum.Font.SourceSans
    searchBar.TextSize = 18
    searchBar.ClearTextOnFocus = false
    searchBar.Parent = frame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchBar
    ServerSnipeUI.SearchBar = searchBar

    -- Player info box frame
    local infoBox = Instance.new("Frame")
    infoBox.Size = UDim2.new(1, -40, 0, 180)
    infoBox.Position = UDim2.new(0, 20, 0, 64)
    infoBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    infoBox.BorderSizePixel = 0
    infoBox.Parent = frame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 12)
    infoCorner.Parent = infoBox

    local infoPadding = Instance.new("UIPadding")
    infoPadding.PaddingTop = UDim.new(0, 10)
    infoPadding.PaddingLeft = UDim.new(0, 10)
    infoPadding.Parent = infoBox

    local function createInfoRow(labelText, posY)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 30)
        container.Position = UDim2.new(0, 10, 0, posY)
        container.BackgroundTransparency = 1
        container.Parent = infoBox

        local label = Instance.new("TextLabel")
        label.Text = labelText
        label.Size = UDim2.new(0, 60, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansSemibold
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        return container
    end

    -- Name row
    local nameRow = createInfoRow("Name:", 10)
    local nameValue = Instance.new("TextLabel")
    nameValue.Text = "N/A"
    nameValue.Size = UDim2.new(1, -80, 1, 0)
    nameValue.Position = UDim2.new(0, 60, 0, 0)
    nameValue.BackgroundTransparency = 1
    nameValue.Font = Enum.Font.SourceSans
    nameValue.TextColor3 = Color3.new(1,1,1)
    nameValue.TextSize = 16
    nameValue.TextXAlignment = Enum.TextXAlignment.Left
    nameValue.Parent = nameRow

    local copyNameBtn = Instance.new("TextButton")
    copyNameBtn.Text = "[Copy]"
    copyNameBtn.Font = Enum.Font.SourceSansSemibold
    copyNameBtn.TextSize = 14
    copyNameBtn.Size = UDim2.new(0, 50, 1, 0)
    copyNameBtn.Position = UDim2.new(1, -55, 0, 0)
    copyNameBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    copyNameBtn.TextColor3 = Color3.new(1,1,1)
    copyNameBtn.BorderSizePixel = 0
    copyNameBtn.AutoButtonColor = false
    copyNameBtn.Parent = nameRow

    local nameCopyCorner = Instance.new("UICorner")
    nameCopyCorner.CornerRadius = UDim.new(0, 6)
    nameCopyCorner.Parent = copyNameBtn

    copyNameBtn.MouseEnter:Connect(function()
        tween(copyNameBtn, {BackgroundColor3 = Color3.fromRGB(100,100,100)},0.15)
    end)
    copyNameBtn.MouseLeave:Connect(function()
        tween(copyNameBtn, {BackgroundColor3 = Color3.fromRGB(80,80,80)},0.15)
    end)

    copyNameBtn.MouseButton1Click:Connect(function()
        copyToClipboard(nameValue.Text)
        createNotification("Copied player name to clipboard.")
    end)

    -- ID row
    local idRow = createInfoRow("ID:", 50)
    local idValue = Instance.new("TextLabel")
    idValue.Text = "N/A"
    idValue.Size = UDim2.new(1, -80, 1, 0)
    idValue.Position = UDim2.new(0, 60, 0, 0)
    idValue.BackgroundTransparency = 1
    idValue.Font = Enum.Font.SourceSans
    idValue.TextColor3 = Color3.new(1,1,1)
    idValue.TextSize = 16
    idValue.TextXAlignment = Enum.TextXAlignment.Left
    idValue.Parent = idRow

    local copyIDBtn = Instance.new("TextButton")
    copyIDBtn.Text = "[Copy]"
    copyIDBtn.Font = Enum.Font.SourceSansSemibold
    copyIDBtn.TextSize = 14
    copyIDBtn.Size = UDim2.new(0, 50, 1, 0)
    copyIDBtn.Position = UDim2.new(1, -55, 0, 0)
    copyIDBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    copyIDBtn.TextColor3 = Color3.new(1,1,1)
    copyIDBtn.BorderSizePixel = 0
    copyIDBtn.AutoButtonColor = false
    copyIDBtn.Parent = idRow

    local idCopyCorner = Instance.new("UICorner")
    idCopyCorner.CornerRadius = UDim.new(0, 6)
    idCopyCorner.Parent = copyIDBtn

    copyIDBtn.MouseEnter:Connect(function()
        tween(copyIDBtn, {BackgroundColor3 = Color3.fromRGB(100,100,100)},0.15)
    end)
    copyIDBtn.MouseLeave:Connect(function()
        tween(copyIDBtn, {BackgroundColor3 = Color3.fromRGB(80,80,80)},0.15)
    end)

    copyIDBtn.MouseButton1Click:Connect(function()
        copyToClipboard(idValue.Text)
        createNotification("Copied player ID to clipboard.")
    end)

    -- Status row
    local statusRow = createInfoRow("Status:", 90)
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 16, 0, 16)
    statusDot.Position = UDim2.new(0, 60, 0, 7)
    statusDot.BackgroundColor3 = Color3.fromRGB(30, 220, 30) -- green dot by default "In Game"
    statusDot.AnchorPoint = Vector2.new(0, 0)
    statusDot.Parent = statusRow
    local statusDotCorner = Instance.new("UICorner")
    statusDotCorner.CornerRadius = UDim.new(1, 0)
    statusDotCorner.Parent = statusDot

    local statusText = Instance.new("TextLabel")
    statusText.Text = "In Game"
    statusText.Font = Enum.Font.SourceSans
    statusText.TextSize = 16
    statusText.TextColor3 = Color3.new(1,1,1)
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.new(0, 82, 0, 0)
    statusText.Size = UDim2.new(0, 100, 1, 0)
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusRow

    -- Avatar row
    local avatarRow = createInfoRow("Avatar:", 130)
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 60, 0, 60)
    avatarImage.Position = UDim2.new(0, 60, 0, -15)
    avatarImage.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    avatarImage.BorderSizePixel = 0
    avatarImage.Parent = avatarRow

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 12)
    avatarCorner.Parent = avatarImage

    ServerSnipeUI.NameValue = nameValue
    ServerSnipeUI.IDValue = idValue
    ServerSnipeUI.StatusDot = statusDot
    ServerSnipeUI.StatusText = statusText
    ServerSnipeUI.AvatarImage = avatarImage

    -- Bottom input box and buttons
    local inputBox = Instance.new("TextBox")
    inputBox.PlaceholderText = "Paste Id"
    inputBox.Size = UDim2.new(1, -40, 0, 32)
    inputBox.Position = UDim2.new(0, 20, 1, -105)
    inputBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    inputBox.TextColor3 = Color3.new(1,1,1)
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 18
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputBox

    ServerSnipeUI.InputBox = inputBox

    -- Buttons container frame
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -40, 0, 40)
    btnContainer.Position = UDim2.new(0, 20, 1, -60)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame

    local UIListBtn = Instance.new("UIListLayout")
    UIListBtn.FillDirection = Enum.FillDirection.Horizontal
    UIListBtn.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListBtn.Padding = UDim.new(0, 10)
    UIListBtn.Parent = btnContainer

    local checkBtn = Instance.new("TextButton")
    checkBtn.Text = "Check Id server"
    checkBtn.Font = Enum.Font.SourceSansSemibold
    checkBtn.TextSize = 18
    checkBtn.TextColor3 = Color3.fromRGB(255,255,255)
    checkBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    checkBtn.Size = UDim2.new(0, 150, 1, 0)
    checkBtn.BorderSizePixel = 0
    checkBtn.AutoButtonColor = false
    checkBtn.Parent = btnContainer

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 10)
    checkCorner.Parent = checkBtn

    local joinBtn = Instance.new("TextButton")
    joinBtn.Text = "Join Server"
    joinBtn.Font = Enum.Font.SourceSansSemibold
    joinBtn.TextSize = 18
    joinBtn.TextColor3 = Color3.new(1,1,1)
    joinBtn.BackgroundColor3 = Color3.fromRGB(15,15,15)
    joinBtn.Size = UDim2.new(0, 150, 1, 0)
    joinBtn.BorderSizePixel = 0
    joinBtn.AutoButtonColor = false
    joinBtn.Parent = btnContainer
    joinBtn.Active = true
    joinBtn.Modal = false

    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 10)
    joinCorner.Parent = joinBtn

    -- Animate button hover effects
    for _,btn in pairs({checkBtn, joinBtn}) do
        btn.MouseEnter:Connect(function()
            local dColor = btn.BackgroundColor3
            local lighter = Color3.new(
                math.clamp(dColor.R + 0.15,0,1),
                math.clamp(dColor.G + 0.15,0,1),
                math.clamp(dColor.B + 0.15,0,1)
            )
            tween(btn, {BackgroundColor3 = lighter}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            local origColor = (btn == checkBtn) and Color3.fromRGB(100,100,100) or Color3.fromRGB(15,15,15)
            tween(btn, {BackgroundColor3 = origColor}, 0.15)
        end)
    end

    ServerSnipeUI.CheckBtn = checkBtn
    ServerSnipeUI.JoinBtn = joinBtn

    -- States vars for Check Btn to match requested behaviors
    local CHECK_IDLE_COLOR = Color3.fromRGB(100, 100, 100)
    local CHECK_PROCESS_COLOR = Color3.fromRGB(68, 68, 68) -- #444444
    local CHECK_SUCCESS_COLOR = Color3.fromRGB(30, 217, 30) -- #1ED91E
    local CHECK_FAILED_COLOR = Color3.fromRGB(228, 61, 61) -- #E43D3D

    local JoinBtnDefaultText = "Join Server"

    local checkState = "idle" -- idle, processed, success, failed

    -- Helper functions to update buttons per state

    local function updateCheckBtn(state)
        checkState = state
        if state == "idle" then
            checkBtn.Text = "Check Id server"
            tween(checkBtn, {BackgroundColor3 = CHECK_IDLE_COLOR}, 0.15)
            joinBtn.Text = JoinBtnDefaultText
            joinBtn.Active = true
            joinBtn.Modal = false

        elseif state == "processed" then
            checkBtn.Text = "Processed"
            tween(checkBtn, {BackgroundColor3 = CHECK_PROCESS_COLOR}, 0.15)
            joinBtn.Text = "Wait until Successfull"
            joinBtn.Active = false
            joinBtn.Modal = true

        elseif state == "success" then
            checkBtn.Text = "Successfull"
            tween(checkBtn, {BackgroundColor3 = CHECK_SUCCESS_COLOR}, 0.15)
            joinBtn.Text = JoinBtnDefaultText
            joinBtn.Active = true
            joinBtn.Modal = false

        elseif state == "failed" then
            checkBtn.Text = "Failed"
            tween(checkBtn, {BackgroundColor3 = CHECK_FAILED_COLOR}, 0.15)
            joinBtn.Text = "Wait until Successfull"
            joinBtn.Active = false
            joinBtn.Modal = true
        end
    end

    updateCheckBtn("idle")

    ------------------------
    -- Server snipe script --
    ------------------------

    -- Given username, try to locate server JobId to teleport to
    local function findPlayerServerJobId(targetName)
        -- NOTE: Due to Roblox filtering, cannot query all servers or always find player's servers.
        -- This is a classic server sniping approach using HTTP or Roblox APIs to list servers.
        -- For demonstration, we will simulate trying to find player in current servers (local only),
        -- but since exploit APIs allow http requests, we can do a web request to Roblox API.

        local HttpService = game:GetService("HttpService")
        local placeId = game.PlaceId

        -- Roblox public servers API for a place:
        local serversUrl = "https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?sortOrder=Asc&limit=100"

        -- Simple request function (supported on most exploits)
        local function httpGet(url)
            if syn and syn.request then
                local success, response = pcall(function()
                    return syn.request({Url=url, Method="GET"})
                end)
                if success and response.StatusCode == 200 then
                    return response.Body
                end
            elseif http and http.get then -- Krnl, etc
                local suc, res = pcall(function() return http.get(url) end)
                if suc and res.StatusCode == 200 then
                    return res.Body
                end
            else
                -- Cannot perform HTTP request
                return nil
            end
        end

        -- Pagination logic
        local cursor = nil
        while true do
            local reqUrl = serversUrl
            if cursor then
                reqUrl = reqUrl .. "&cursor=" .. cursor
            end

            local body = httpGet(reqUrl)
            if not body then
                return nil, "Cannot perform HTTP request"
            end

            local data = HttpService:JSONDecode(body)
            if not data or not data.data then break end

            for _, server in pairs(data.data) do
                for _, player in pairs(server.players or {}) do
                    if player.username and player.username:lower() == targetName:lower() then
                        -- Found server with player
                        return server.id, nil
                    end
                end
            end

            cursor = data.nextPageCursor
            if not cursor then
                break
            end
        end

        return nil, "Player not found in public servers."
    end

    -- Set player info UI values
    local function setPlayerInfo(name, id, status, avatarUrl)
        nameValue.Text = name or "N/A"
        idValue.Text = id and tostring(id) or "N/A"

        if status == "In Game" then
            statusDot.BackgroundColor3 = Color3.fromRGB(30, 220, 30)
            statusText.Text = "In Game"
        elseif status == "Online" then
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 220, 40)
            statusText.Text = "Online"
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
            statusText.Text = "Offline"
        end

        avatarImage.Image = avatarUrl or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end

    -- Clear player info UI initially
    setPlayerInfo()

    -- Search bar placeholder functionality (no filter needed)
    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        -- Placeholder - no effect
    end)

    -- “Check Id server” button logic
    checkBtn.MouseButton1Click:Connect(function()
        local inputText = inputBox.Text and inputBox.Text:match("%S") and inputBox.Text or nil
        if not inputText then
            createNotification("Please input the ID")
            return
        end

        -- Disable button and mark processed
        updateCheckBtn("processed")

        -- For demo, simulate delay and show success or fail
        -- In real implementation, server ID "validation" or fetch could happen here

        task.spawn(function()
            -- Simulate wait
            task.wait(2)

            -- Fake success if input is numbers and length >= 5; else fail (dummy rule)
            if inputText:match("^%d%d%d%d%d+$") then
                updateCheckBtn("success")
                createNotification("Server ID Processed successfully!")
                -- Enable join button
                joinBtn.Active = true
                joinBtn.Modal = false
            else
                updateCheckBtn("failed")
                createNotification("Invalid Server ID!")
            end
        end)
    end)

    -- Join server button placeholder
    joinBtn.MouseButton1Click:Connect(function()
        createNotification("Join Server clicked (placeholder).")
    end)

    -- Store setter function in UI table for external access
    ServerSnipeUI.SetPlayerInfo = setPlayerInfo
end

-- Widgets for Setting tab --
do
    local frame = settingFrame

    local title = Instance.new("TextLabel")
    title.Text = "Change Background"
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.Font = Enum.Font.SourceSansSemibold
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 20
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local dropdownBox = Instance.new("TextButton")
    dropdownBox.Text = "Change Background"
    dropdownBox.Size = UDim2.new(0, 220, 0, 32)
    dropdownBox.Position = UDim2.new(0, 20, 0, 70)
    dropdownBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    dropdownBox.TextColor3 = Color3.new(1,1,1)
    dropdownBox.Font = Enum.Font.SourceSans
    dropdownBox.TextSize = 18
    dropdownBox.AutoButtonColor = false
    dropdownBox.Parent = frame

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 10)
    dCorner.Parent = dropdownBox

    -- Color selector box below
    local colorText = Instance.new("TextLabel")
    colorText.Text = "#888888 (100%)"
    colorText.Size = UDim2.new(0, 220, 0, 30)
    colorText.Position = UDim2.new(0, 20, 0, 120)
    colorText.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    colorText.TextColor3 = Color3.new(1,1,1)
    colorText.Font = Enum.Font.SourceSans
    colorText.TextSize = 18
    colorText.TextXAlignment = Enum.TextXAlignment.Center
    colorText.Parent = frame

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = colorText

    -- Toggle option "Black and White"
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -40, 0, 30)
    toggleContainer.Position = UDim2.new(0, 20, 0, 170)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = frame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Text = "Black and White"
    toggleLabel.Size = UDim2.new(0, 140, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.SourceSans
    toggleLabel.TextColor3 = Color3.new(1,1,1)
    toggleLabel.TextSize = 16
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleContainer

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 28, 0, 28)
    toggleButton.Position = UDim2.new(1, -40, 0, 1)
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleContainer

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton

    local checked = false
    local checkMark = Instance.new("ImageLabel")
    checkMark.Size = UDim2.new(0, 20, 0, 20)
    checkMark.Position = UDim2.new(0.5, -10, 0.5, -10)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://6031094679" -- Using discord logo as placeholder, replace with checkmark
    checkMark.Visible = false
    checkMark.Parent = toggleButton

    toggleButton.MouseEnter:Connect(function()
        tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(110,110,110)}, 0.15)
    end)
    toggleButton.MouseLeave:Connect(function()
        tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(80,80,80)}, 0.15)
    end)

    toggleButton.MouseButton1Click:Connect(function()
        checked = not checked
        checkMark.Visible = checked
        createNotification("Black and White mode " .. (checked and "enabled" or "disabled"))
    end)
end

-- Smooth animate window open: from scale 0.5 and 0 transparency to full
MainFrame.Size = UDim2.new(0, 100, 0, 85)
MainFrame.Position = UDim2.new(0.5, -50, 0.5, -42.5)
MainFrame.BackgroundTransparency = 0.8

local openTween1 = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 380),
    Position = UDim2.new(0.5, -225, 0.5, -190),
    BackgroundTransparency = 0,
})
openTween1:Play()

-- Minimize logic: hides content leaving title bar small
MinimizeBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size == UDim2.new(0, 450, 0, 36+0) then
        -- Already minimized, restore
        MainFrame.ClipsDescendants = false
        local tweenSize = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 380),
        })
        tweenSize:Play()
    else
        -- Minimize to top bar only
        MainFrame.ClipsDescendants = true
        local tweenSize = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 36),
        })
        tweenSize:Play()
    end
end)

-- Close button closes UI completely
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Home button switches to server snipe tab
HomeBtn.MouseButton1Click:Connect(function()
    activateTab("Server snipe")
end)

-- Tab buttons click connections
for name, objs in pairs(tabBtnObjects) do
    objs.Button.MouseButton1Click:Connect(function()
        activateTab(name)
    end)
end

-- === Server snipe script exploit ===

-- Prompt user for target username after opening UI

task.spawn(function()
    createNotification("Please enter target player's username in Server snipe tab input box.")
end)

-- When user types in input box, update UI info fields with player info (live lookup)

ServerSnipeUI.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = ServerSnipeUI.SearchBar.Text
    local plr = Players:FindFirstChild(txt)
    if plr then
        ServerSnipeUI.SetPlayerInfo(plr.Name, plr.UserId, "In Game", Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100))
    else
        ServerSnipeUI.SetPlayerInfo(txt, "N/A", "Offline", nil)
    end
end)

-- Join Server logic with server snipe exploit:

ServerSnipeUI.JoinBtn.MouseButton1Click:Connect(function()
    local targetName = ServerSnipeUI.SearchBar.Text
    if not targetName or targetName == "" then
        createNotification("Please enter a username in the Search box")
        return
    end
    createNotification("Searching for player "..targetName.."...")

    -- Async search player server JobId
    task.spawn(function()
        local jobId, err = (function()

            local HttpService = game:GetService("HttpService")
            local placeId = game.PlaceId

            local function getServers(cursor)
                local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
                if cursor then url = url .. "&cursor=" .. cursor end
                local body = nil
                if syn and syn.request then
                    local ok, res = pcall(function() return syn.request({Url = url, Method="GET"}) end)
                    if ok and res.StatusCode == 200 then body = res.Body end
                elseif http and http.get then
                    local ok, res = pcall(function() return http.get(url) end)
                    if ok and res.StatusCode == 200 then body = res.Body end
                end
                if not body then return nil end
                return HttpService:JSONDecode(body)
            end

            local cursor = nil
            while true do
                local data = getServers(cursor)
                if not data or not data.data then return nil, "HTTP Request failed or no data" end

                for _, server in pairs(data.data) do
                    for _, player in pairs(server.players or {}) do
                        if player.username and player.username:lower() == targetName:lower() then
                            return server.id
                        end
                    end
                end

                cursor = data.nextPageCursor
                if not cursor then break end
            end

            return nil, "Player not found in public servers."
        end)()

        if jobId then
            createNotification("Found player server, teleporting...")
            -- Teleport to their server
            local success, errr = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, localPlayer)
            end)
            if not success then
                createNotification("Teleport failed: "..tostring(errr))
            end
        else
            createNotification(err or "Player not found in public servers.")
        end
    end)
end)

return
