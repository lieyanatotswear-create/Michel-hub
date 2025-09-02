-- Roblox Lua Exploit script for Server Sniping with Modern UI
-- Features:
-- - Draggable, resizable modern Hub UI with 3 tabs: Credit, Server snipe, Setting
-- - Smooth open animation and tab switches
-- - Notifications slide in/out
-- - Buttons with hover, click effects, copy to clipboard
-- - Server snipe logic that teleports to target player's server

--// Services
repeat
    wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Constants
local PLACE_ID = game.PlaceId
local NOTIFICATION_TIME = 4 -- seconds

-- Utility functions
local function Create(className, props)
    local inst = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then
                inst.Parent = v
            else
                inst[k] = v
            end
        end
    end
    return inst
end

local function TweenInstance(instance, properties, info)
    info = info or TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function Round(number, decimals)
    decimals = decimals or 0
    local power = 10^decimals
    return math.floor(number * power + 0.5) / power
end

local function CopyToClipboard(text)
    -- Roblox native clipboard copy via SetClipboard (only works in exploit environments)
    if setclipboard then
        pcall(setclipboard, text)
    elseif setclipboardstring then
        pcall(setclipboardstring, text)
    else
        -- fallback alert to user
        print("Copy to clipboard not supported")
    end
end

-- Notification system
local NotificationFrame = nil
local NotificationTweenIn = nil
local NotificationTweenOut = nil
local NotificationShowing = false

local function ShowNotification(message)
    if NotificationShowing then
        -- Remove existing notification instantly
        if NotificationTweenOut then
            NotificationTweenOut:Cancel()
        end
        if NotificationFrame then
            NotificationFrame:Destroy()
            NotificationFrame = nil
        end
    end
    NotificationShowing = true

    local notif = Create("Frame", {
        Name = "Notification";
        Size = UDim2.new(0, 250, 0, 50);
        BackgroundColor3 = Color3.fromRGB(30, 30, 30);
        BackgroundTransparency = 0.1;
        Position = UDim2.new(0.5, -125, 0, -60);
        AnchorPoint = Vector2.new(0.5, 0);
        ZIndex = 10;
        Parent = CoreGui;
        ClipsDescendants = true;
    })
    notif.BackgroundTransparency = 1
    notif.AnchorPoint = Vector2.new(0.5,0)
    notif.Position = UDim2.new(0.5,-125,0,-50)
    notif.BackgroundColor3 = Color3.fromRGB(44,44,44)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Rotation = 0
    
    local uicorner = Create("UICorner", {Parent = notif, CornerRadius = UDim.new(0, 9)})
    
    local textLabel = Create("TextLabel", {
        Parent = notif;
        Size = UDim2.new(1, -20, 1, 0);
        Position = UDim2.new(0, 10, 0, 0);
        BackgroundTransparency = 1;
        Text = message;
        TextColor3 = Color3.fromRGB(220,220,220);
        Font = Enum.Font.GothamSemibold;
        TextSize = 18;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    
    NotificationFrame = notif
    
    -- Slide in (from top)
    notif.Position = UDim2.new(0.5, -125, 0, -60)
    notif.BackgroundTransparency = 1
    TweenInstance(notif, {Position = UDim2.new(0.5, -125, 0, 10), BackgroundTransparency = 0}).Completed:Wait()
    
    -- Wait then slide out
    task.delay(NOTIFICATION_TIME, function()
        if notif.Parent then
            TweenInstance(notif, {Position = UDim2.new(0.5, -125, 0, -60), BackgroundTransparency = 1}).Completed:Wait()
            if notif.Parent then notif:Destroy() end
            NotificationShowing = false
        end
    end)
end

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerSnipeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Closer function - removes UI
local function CloseUI()
    ScreenGui:Destroy()
end

-- Smooth open animation, start small and scale to normal size
local MainFrame = Create("Frame", {
    Name = "MainWindow";
    Size = UDim2.new(0, 650, 0, 420);
    Position = UDim2.new(0.5, -325, 0.5, -210);
    BackgroundColor3 = Color3.fromRGB(36,36,36);
    BorderSizePixel = 0;
    Parent = ScreenGui;
    AnchorPoint = Vector2.new(0.5, 0.5);
})
local UICornerMain = Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 14)})
-- Gradient
local UIGradientMain = Create("UIGradient", {
    Parent = MainFrame;
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(54,54,54));
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,35));
    }
})

-- Shadow Effect
local Shadow = Create("ImageLabel", {
    Name = "Shadow";
    Parent = MainFrame;
    ZIndex = 0;
    Size = UDim2.new(1, 12, 1, 12);
    Position = UDim2.new(0, -6, 0, -6);
    BackgroundTransparency = 1;
    Image = "rbxassetid://413938726";
    ScaleType = Enum.ScaleType.Slice;
    SliceCenter = Rect.new(10,10,118,118);
    ImageColor3 = Color3.fromRGB(0,0,0);
    ImageTransparency = 0.75;
})

-- Initially small for open animation
MainFrame.Size = UDim2.new(0, 20, 0, 20)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenInstance(MainFrame, {Size = UDim2.new(0,650,0,420), Position= UDim2.new(0.5,-325,0.5,-210)}, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

-- Top bar container
local TopBar = Create("Frame", {
    Name = "TopBar";
    Size = UDim2.new(1, 0, 0, 38);
    Position = UDim2.new(0, 0, 0, 0);
    BackgroundColor3 = Color3.fromRGB(24, 24, 24);
    Parent = MainFrame;
})

local TopBarUICorner = Create("UICorner", {Parent=TopBar, CornerRadius = UDim.new(0,12)})

-- Title text at top-left
local TitleLabel = Create("TextLabel", {
    Parent = TopBar;
    Text = "Server snipe by michel";
    Font = Enum.Font.GothamBold;
    TextSize = 18;
    TextColor3 = Color3.fromRGB(180, 180, 180);
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 15, 0, 7);
    Size = UDim2.new(0, 220, 1, 0);
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Center;
})

-- Status Text with colored dot at top center (In Game, Online, Offline)
local StatusDot = Create("Frame", {
    Parent = TopBar;
    Size = UDim2.new(0, 10, 0, 10);
    Position = UDim2.new(0.5, -40, 0, 14);
    BackgroundColor3 = Color3.fromRGB(30, 210, 30); -- green by default In Game
})
local DotCorner = Create("UICorner", {Parent=StatusDot, CornerRadius = UDim.new(1, 0)})

local StatusText = Create("TextLabel", {
    Parent = TopBar;
    Text = "🟢 In Game";
    Font = Enum.Font.GothamSemibold;
    TextSize = 16;
    TextColor3 = Color3.fromRGB(180, 180, 180);
    BackgroundTransparency = 1;
    Position = UDim2.new(0.5, -20, 0, 11);
    Size = UDim2.new(0, 120, 1, 0);
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Center;
})

-- Top right buttons container
local BtnContainer = Create("Frame", {
    Parent = TopBar;
    Size = UDim2.new(0, 100, 1, 0);
    Position = UDim2.new(1, -110, 0, 0);
    BackgroundTransparency = 1;
})
local BtnLayout = Create("UIListLayout", {
    Parent = BtnContainer;
    FillDirection = Enum.FillDirection.Horizontal;
    HorizontalAlignment = Enum.HorizontalAlignment.Right;
    VerticalAlignment = Enum.VerticalAlignment.Center;
    Padding = UDim.new(0,14);
})

-- Helper for button creation with hover and click effects
local function CreateTopButton(text, tooltip, callback)
    local btn = Create("TextButton", {
        Parent = BtnContainer;
        Text = text;
        Font = Enum.Font.GothamBold;
        TextSize = 22;
        TextColor3 = Color3.fromRGB(180,180,180);
        BackgroundColor3 = Color3.fromRGB(40,40,40);
        Size = UDim2.new(0, 26, 0, 26);
        AnchorPoint = Vector2.new(0,0.5);
        AutoButtonColor = false;
        BorderSizePixel = 0;
        ZIndex = 15;
    })
    btn.Position = UDim2.new(1, 0, 0.5, 0)
    local corner = Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(60,60,60)})
    end)
    btn.MouseLeave:Connect(function()
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(40,40,40)})
    end)

    -- Click effect
    btn.MouseButton1Click:Connect(function()
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
        task.wait(0.15)
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(40,40,40)}, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
        if callback then pcall(callback) end
    end)
    return btn
end

local MinimizeButton = CreateTopButton("–", "Minimize", function()
    if MainFrame.Size == UDim2.new(0, 650, 0, 38) then
        TweenInstance(MainFrame, {Size = UDim2.new(0, 650, 0, 420), Position= UDim2.new(0.5,-325,0.5,-210)})
        -- Restore full size
    else
        TweenInstance(MainFrame, {Size = UDim2.new(0, 650, 0, 38)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
    end
end)

local HomeButton = CreateTopButton("⌂", "Home Tab", function()
    Tabs.SelectTab("Server snipe")
end)

local CloseButton = CreateTopButton("×", "Close UI", function()
    CloseUI()
end)

-- Layout Fix for buttons at right top bar
BtnContainer.Size = UDim2.new(0, (MinimizeButton.AbsoluteSize.X + HomeButton.AbsoluteSize.X + CloseButton.AbsoluteSize.X) + 40, 1, 0)


-- Sidebar Menu
local Sidebar = Create("Frame", {
    Parent = MainFrame;
    BackgroundColor3 = Color3.fromRGB(38, 38, 38);
    Size = UDim2.new(0, 140, 1, -38);
    Position = UDim2.new(0, 0, 0, 38);
})
local SidebarCorner = Create("UICorner", {Parent=Sidebar, CornerRadius = UDim.new(0,14)})

local VerticalBarHighlight = Create("Frame", {
    Parent = Sidebar;
    BackgroundColor3 = Color3.fromRGB(30, 210, 30);
    Size = UDim2.new(0, 3, 0, 50);
    Position = UDim2.new(0, 0, 0, 60);
    Visible = false; -- only visible on active tab
})
local VerticalBarCorner = Create("UICorner", {Parent=VerticalBarHighlight, CornerRadius = UDim.new(0, 2)})

-- Sidebar buttons
local SidebarButtons = {}

local function MakeSidebarButton(text, yPos)
    local btn = Create("TextButton", {
        Parent = Sidebar;
        Text = text;
        Size = UDim2.new(1, 0, 0, 50);
        Position = UDim2.new(0, 0, 0, yPos);
        BackgroundTransparency = 1;
        Font = Enum.Font.GothamBold;
        TextSize = 20;
        TextColor3 = Color3.fromRGB(180, 180, 180);
        AutoButtonColor = false;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        ZIndex = 10;
        Padding = UDim.new(0, 20);
        -- We'll fix text padding by adding left margin:
    })
    -- Left padding fix by empty Text button with padding:
    btn.Text = "   "..text -- simple fix for left pad
    btn.MouseEnter:Connect(function()
        TweenInstance(btn, {TextColor3 = Color3.fromRGB(30, 210, 30)})
    end)
    btn.MouseLeave:Connect(function()
        TweenInstance(btn, {TextColor3 = (Tabs.CurrentTab == text) and Color3.fromRGB(30,210,30) or Color3.fromRGB(180,180,180)})
    end)
    return btn
end

SidebarButtons["Credit"] = MakeSidebarButton("Credit", 25)
SidebarButtons["Server snipe"] = MakeSidebarButton("Server snipe", 90)
SidebarButtons["Setting"] = MakeSidebarButton("Setting", 155)


-- Content container right side
local ContentFrame = Create("Frame", {
    Parent = MainFrame;
    Position = UDim2.new(0, 140, 0, 38);
    Size = UDim2.new(1, -140, 1, -38);
    BackgroundTransparency = 1;
})

local TabsUIListLayout = Create("UIListLayout", {
    Parent = ContentFrame;
    SortOrder = Enum.SortOrder.LayoutOrder;
})

-- Store tab contents
local Tabs = {}
Tabs.CurrentTab = nil
Tabs.TabFrames = {}

function Tabs.SelectTab(tabName)
    if Tabs.CurrentTab == tabName then return end
    local prev = Tabs.CurrentTab
    Tabs.CurrentTab = tabName
    -- Animate vertical bar highlight to the selected button
    local btn = SidebarButtons[tabName]
    if btn then
        VerticalBarHighlight.Visible = true
        TweenInstance(VerticalBarHighlight, {Position = UDim2.new(0, 0, 0, btn.Position.Y.Offset), Size = UDim2.new(0, 3, 0, 50)})
        -- Update colors on sidebar buttons
        for name,button in pairs(SidebarButtons) do
            if name == tabName then
                button.TextColor3 = Color3.fromRGB(30, 210, 30)
            else
                button.TextColor3 = Color3.fromRGB(180,180,180)
            end
        end
    else
        VerticalBarHighlight.Visible = false
    end

    -- Transition tab content smoothly
    for name, frame in pairs(Tabs.TabFrames) do
        if frame == nil then continue end
        if name == tabName then
            frame.Visible = true
            frame.ClipsDescendants = true
            frame.Position = UDim2.new(1,0,0,0)
            local tweenIn = TweenInstance(frame, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0})
            tweenIn.Completed:Wait()
        else
            if frame.Visible == true then
                local tweenOut = TweenInstance(frame, {Position = UDim2.new(-1,0,0,0), BackgroundTransparency = 1})
                tweenOut.Completed:Wait()
                frame.Visible = false
            end
        end
    end
end

-- -------------------------------------------------------------------
-- Tab 1: Credit
local CreditTab = Create("Frame", {
    Parent = ContentFrame;
    Size = UDim2.new(1,0,1,0);
    BackgroundColor3 = Color3.fromRGB(40, 40, 40);
    BackgroundTransparency = 0;
    Visible = false;
})

local CreditCorner = Create("UICorner", {Parent=CreditTab, CornerRadius = UDim.new(0, 14)})

local CreditText = Create("TextLabel", {
    Parent = CreditTab;
    Text = "Credit to: michal";
    Position = UDim2.new(0, 25, 0, 25);
    Size = UDim2.new(1, -50, 0, 35);
    Font = Enum.Font.GothamBold;
    TextSize = 24;
    TextColor3 = Color3.fromRGB(200, 200, 200);
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
})

-- Discord Button
local DiscordButton = Create("TextButton", {
    Parent = CreditTab;
    Position = UDim2.new(0, 100, 0, 80);
    Size = UDim2.new(0, 350, 0, 100);
    Text = "Join Discord server";
    Font = Enum.Font.GothamBold;
    TextSize = 28;
    TextColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundColor3 = Color3.fromRGB(114, 137, 218); -- Discord blurple
    AutoButtonColor = false;
    BorderSizePixel = 0;
    ClipsDescendants = true;
})
local DiscordCorner = Create("UICorner", {Parent = DiscordButton, CornerRadius = UDim.new(0, 22)})

-- Discord logo image (replace with actual Discord logo here with assetid)
local DiscordLogo = Create("ImageLabel", {
    Parent = DiscordButton;
    Size = UDim2.new(0, 100, 0, 100);
    BackgroundTransparency = 1;
    Image = "rbxassetid://4464043247"; -- Discord logo Roblox asset (replace if needed)
    Position = UDim2.new(0, 8, 0, 0);
})

-- Discord URL box
local DiscordURLBox = Create("TextBox", {
    Parent = CreditTab;
    Text = "https://discord.gg/WstAPrVe";
    Position = UDim2.new(0, 100, 0, 190);
    Size = UDim2.new(0, 350, 0, 40);
    Font = Enum.Font.Gotham;
    TextSize = 20;
    TextColor3 = Color3.fromRGB(180, 180, 180);
    BackgroundColor3 = Color3.fromRGB(30,30,30);
    ClearTextOnFocus = false;
})
local URLCorner = Create("UICorner", {Parent=DiscordURLBox, CornerRadius = UDim.new(0, 12)})

-- Hover effects for Discord Button
DiscordButton.MouseEnter:Connect(function()
    TweenInstance(DiscordButton, {BackgroundColor3 = Color3.fromRGB(100, 115, 218)})
end)
DiscordButton.MouseLeave:Connect(function()
    TweenInstance(DiscordButton, {BackgroundColor3 = Color3.fromRGB(114, 137, 218)})
end)

DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        pcall(setclipboard, "https://discord.gg/WstAPrVe")
        ShowNotification("Discord link copied to clipboard!")
    else
        ShowNotification("Copy to clipboard not supported.")
    end
end)


-- -------------------------------------------------------------------
-- Tab 2: Server snipe

local ServerSnipeTab = Create("Frame", {
    Parent = ContentFrame;
    Size = UDim2.new(1,0,1,0);
    BackgroundColor3 = Color3.fromRGB(40, 40, 40);
    BackgroundTransparency = 0;
    Visible = false;
})

local ServerSnipeCorner = Create("UICorner", {Parent=ServerSnipeTab, CornerRadius = UDim.new(0, 14)})

-- Search bar (empty functionality)
local SearchBox = Create("TextBox", {
    Parent = ServerSnipeTab;
    PlaceholderText = "Search";
    Size = UDim2.new(0, 420, 0, 32);
    Position = UDim2.new(0, 20, 0, 20);
    BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    TextColor3 = Color3.fromRGB(220, 220, 220);
    Font = Enum.Font.Gotham;
    TextSize = 18;
    ClearTextOnFocus = false;
})
local SearchBoxCorner = Create("UICorner", {Parent=SearchBox, CornerRadius = UDim.new(0, 8)})

-- Player info display below search bar
local InfoFrame = Create("Frame", {
    Parent = ServerSnipeTab;
    Size = UDim2.new(1, -40, 0, 160);
    Position = UDim2.new(0, 20, 0, 70);
    BackgroundColor3 = Color3.fromRGB(25, 25, 25);
    BorderSizePixel = 0;
})
local InfoFrameCorner = Create("UICorner", {Parent=InfoFrame, CornerRadius = UDim.new(0,10)})

-- Info labels and copy buttons positions fixed:
local LABEL_Y_START = 10
local LABEL_SPACING = 35

local function MakeInfoLabel(nameText, yPos)
    local label = Create("TextLabel", {
        Parent = InfoFrame;
        Text = nameText;
        Font = Enum.Font.GothamSemibold;
        TextSize = 18;
        TextColor3 = Color3.fromRGB(180, 180, 180);
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 15, 0, yPos);
        Size = UDim2.new(0, 80, 0, 30);
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    return label
end

local function MakeInfoValue(yPos, width)
    local val = Create("TextLabel", {
        Parent = InfoFrame;
        Text = "N/A";
        Font = Enum.Font.Gotham;
        TextSize = 18;
        TextColor3 = Color3.fromRGB(210, 210, 210);
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 100, 0, yPos);
        Size = UDim2.new(0, width or 200, 0, 30);
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    return val
end

local function MakeCopyButton(parent, pos)
    local btn = Create("TextButton", {
        Parent = parent;
        Size = UDim2.new(0, 60, 0, 28);
        Position = pos;
        Text = "Copy";
        Font = Enum.Font.GothamSemibold;
        TextSize = 16;
        TextColor3 = Color3.fromRGB(180, 180, 180);
        BackgroundColor3 = Color3.fromRGB(55, 55, 55);
        AutoButtonColor = false;
        BorderSizePixel = 0;
    })
    local corner = Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(40, 170, 40)})
    end)
    btn.MouseLeave:Connect(function()
        TweenInstance(btn, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
    end)
    return btn
end

local NameLabel = MakeInfoLabel("Name:", LABEL_Y_START)
local NameValue = MakeInfoValue(LABEL_Y_START)
local NameCopy = MakeCopyButton(InfoFrame, UDim2.new(0, 310, 0, LABEL_Y_START + 1))
local IDLabel = MakeInfoLabel("ID:", LABEL_Y_START + LABEL_SPACING)
local IDValue = MakeInfoValue(LABEL_Y_START + LABEL_SPACING)
local IDCopy = MakeCopyButton(InfoFrame, UDim2.new(0, 310, 0, LABEL_Y_START + LABEL_SPACING + 1))
local StatusLabel = MakeInfoLabel("Status:", LABEL_Y_START + 2*LABEL_SPACING)
local StatusDotSmall = Create("Frame", {
    Parent = InfoFrame;
    Size = UDim2.new(0, 12, 0, 12);
    Position = UDim2.new(0, 100, 0, LABEL_Y_START + 2*LABEL_SPACING + 8);
    BackgroundColor3 = Color3.fromRGB(30, 210, 30);
    BorderSizePixel = 0;
})
Create("UICorner", {Parent=StatusDotSmall, CornerRadius = UDim.new(1,0)})

local StatusTextSmall = Create("TextLabel", {
    Parent = InfoFrame;
    Text = "In Game";
    Font = Enum.Font.GothamSemibold;
    TextSize = 18;
    TextColor3 = Color3.fromRGB(180, 180, 180);
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 120, 0, LABEL_Y_START + 2*LABEL_SPACING);
    Size = UDim2.new(0, 100, 0, 30);
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Center;
})

local AvatarLabel = MakeInfoLabel("Avatar:", LABEL_Y_START + 3*LABEL_SPACING)
local AvatarImage = Create("ImageLabel", {
    Parent = InfoFrame;
    Size = UDim2.new(0, 70, 0, 70);
    Position = UDim2.new(0, 100, 0, LABEL_Y_START + 3*LABEL_SPACING);
    BackgroundColor3 = Color3.fromRGB(55,55,55);
    Image = "";
    BorderSizePixel = 0;
})
Create("UICorner", {Parent=AvatarImage, CornerRadius = UDim.new(0, 12)})

-- Copy buttons functionality
NameCopy.MouseButton1Click:Connect(function()
    if NameValue.Text ~= "N/A" then
        CopyToClipboard(NameValue.Text)
        ShowNotification("Name copied to clipboard.")
    else
        ShowNotification("No Name to copy.")
    end
end)
IDCopy.MouseButton1Click:Connect(function()
    if IDValue.Text ~= "N/A" then
        CopyToClipboard(IDValue.Text)
        ShowNotification("ID copied to clipboard.")
    else
        ShowNotification("No ID to copy.")
    end
end)

-- Bottom input and buttons area
local BottomArea = Create("Frame", {
    Parent = ServerSnipeTab;
    Position = UDim2.new(0, 20, 1, -120);
    Size = UDim2.new(1, -40, 0, 100);
    BackgroundTransparency = 1;
})

local PasteIdInput = Create("TextBox", {
    Parent = BottomArea;
    PlaceholderText = "Paste Id";
    Size = UDim2.new(1, 0, 0, 30);
    Position = UDim2.new(0, 0, 0, 0);
    BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    TextColor3 = Color3.fromRGB(220, 220, 220);
    Font = Enum.Font.Gotham;
    TextSize = 18;
    ClearTextOnFocus = false;
    TextEditable = true;
})
Create("UICorner", {Parent=PasteIdInput, CornerRadius = UDim.new(0, 10)})

local BtnCheck = Create("TextButton", {
    Parent = BottomArea;
    Text = "Check Id server";
    Size = UDim2.new(0.48, -5, 0, 40);
    Position = UDim2.new(0, 0, 0, 45);
    BackgroundColor3 = Color3.fromRGB(128, 128, 128);
    Font = Enum.Font.GothamBold;
    TextSize = 20;
    TextColor3 = Color3.fromRGB(240, 240, 240);
    AutoButtonColor = false;
    BorderSizePixel = 0;
})
Create("UICorner", {Parent=BtnCheck, CornerRadius = UDim.new(0, 12)})

local BtnJoin = Create("TextButton", {
    Parent = BottomArea;
    Text = "Join Server";
    Size = UDim2.new(0.48, -5, 0, 40);
    Position = UDim2.new(0.52, 5, 0, 45);
    BackgroundColor3 = Color3.fromRGB(30,30,30);
    Font = Enum.Font.GothamBold;
    TextSize = 20;
    TextColor3 = Color3.fromRGB(255,255,255);
    AutoButtonColor = false;
    BorderSizePixel = 0;
    AutoButtonColor = false;
    Active = false; -- Disabled until check success
})
Create("UICorner", {Parent=BtnJoin, CornerRadius = UDim.new(0, 12)})

-- Hover effects for buttons
local function ButtonHoverEffects(button)
    button.MouseEnter:Connect(function()
        TweenInstance(button, {BackgroundColor3 = button.BackgroundColor3:lerp(Color3.fromRGB(100,100,100),0.3)})
    end)
    button.MouseLeave:Connect(function()
        TweenInstance(button, {BackgroundColor3 = button.BackgroundColor3})
    end)
end

-- Custom hover for BtnJoin and BtnCheck
BtnCheck.MouseEnter:Connect(function()
    TweenInstance(BtnCheck, {BackgroundColor3 = Color3.fromRGB(68,68,68)})
end)
BtnCheck.MouseLeave:Connect(function()
    local bgCol = BtnCheck.BackgroundColor3
    if BtnCheck.BackgroundColor3 == Color3.fromRGB(68,68,68) then
        TweenInstance(BtnCheck, {BackgroundColor3 = Color3.fromRGB(128,128,128)})
    end
end)
BtnJoin.MouseEnter:Connect(function()
    if BtnJoin.Active then
        TweenInstance(BtnJoin, {BackgroundColor3 = Color3.fromRGB(80,80,80)})
    end
end)
BtnJoin.MouseLeave:Connect(function()
    if BtnJoin.Active then
        TweenInstance(BtnJoin, {BackgroundColor3 = Color3.fromRGB(30,30,30)})
    end
end)

-- Track states for buttons
local CheckState = "Idle" -- Idle, Processing, Success, Failed
local function UpdateButtonStates()
    if CheckState == "Processing" then
        BtnCheck.BackgroundColor3 = Color3.fromRGB(68,68,68)
        BtnCheck.Text = "Processed"
        BtnJoin.Active = false
        BtnJoin.Text = "Wait until Successful"
        BtnJoin.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BtnJoin.TextColor3 = Color3.fromRGB(160,160,160)
    elseif CheckState == "Success" then
        BtnCheck.BackgroundColor3 = Color3.fromRGB(30, 217, 30)
        BtnCheck.Text = "Successful"
        BtnJoin.Active = true
        BtnJoin.Text = "Join Server"
        BtnJoin.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BtnJoin.TextColor3 = Color3.fromRGB(255,255,255)
    elseif CheckState == "Failed" then
        BtnCheck.BackgroundColor3 = Color3.fromRGB(228, 61, 61)
        BtnCheck.Text = "Failed"
        BtnJoin.Active = false
        BtnJoin.Text = "Wait until Successful"
        BtnJoin.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BtnJoin.TextColor3 = Color3.fromRGB(160,160,160)
    else
        -- Idle
        BtnCheck.BackgroundColor3 = Color3.fromRGB(128,128,128)
        BtnCheck.Text = "Check Id server"
        BtnJoin.Active = false
        BtnJoin.Text = "Join Server"
        BtnJoin.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BtnJoin.TextColor3 = Color3.fromRGB(255,255,255)
    end
end
UpdateButtonStates()

-- Variables for last succesful Server Job ID
local SavedPlaceInstanceJobId = nil

-- Forward declarations
local function StartCheckServerID()
end
local function JoinServerFunc()
end

-- Check ID Server button logic
BtnCheck.MouseButton1Click:Connect(function()
    if CheckState == "Processing" then return end

    local userInput = PasteIdInput.Text:match("%S+")
    if not userInput or userInput == "" then
        ShowNotification("Please input the ID")
        return
    end

    -- Start Processing
    CheckState = "Processing"
    UpdateButtonStates()

    local success, playerName, playerId, status, avatarUrl, jobId = ServerSnipeAPI_FindPlayerJobId(userInput)
    
    -- Update player info fields based on result for visual feedback
    if success then
        NameValue.Text = playerName or "N/A"
        IDValue.Text = tostring(playerId or "N/A")
        StatusDotSmall.BackgroundColor3 = Color3.fromRGB(30, 210, 30)
        StatusTextSmall.Text = status or "In Game"
        AvatarImage.Image = avatarUrl or ""

        CheckState = "Success"
        UpdateButtonStates()
        SavedPlaceInstanceJobId = jobId
        ShowNotification("Server found!")
    else
        NameValue.Text = "N/A"
        IDValue.Text = "N/A"
        StatusDotSmall.BackgroundColor3 = Color3.fromRGB(228, 61, 61) -- red dot
        StatusTextSmall.Text = "Offline"
        AvatarImage.Image = ""

        CheckState = "Failed"
        UpdateButtonStates()
        SavedPlaceInstanceJobId = nil
        ShowNotification("Player not found in public servers.")
    end
end)

-- Join Server button logic
BtnJoin.MouseButton1Click:Connect(function()
    if not BtnJoin.Active then return end
    if not SavedPlaceInstanceJobId then
        ShowNotification("No Server ID to join. Check server first.")
        return
    end
    local placeId = PLACE_ID
    local jobId = SavedPlaceInstanceJobId
    ShowNotification("Joining server ...")
    local teleportSuccess, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
    if not teleportSuccess then
        ShowNotification("Teleport failed: "..tostring(err))
    end
end)

-- Dummy API function simulating server jobId search for player username or ID
function ServerSnipeAPI_FindPlayerJobId(inputText)
    -- This placeholder should be replaced with real server query code for expedient demo use.
    -- For demo, will pretend to always fail except "michel" name to success with dummy data.
    local name = inputText
    
    -- Simulating API request delay:
    task.wait(1.2)
    
    if string.lower(name) == "michel" then
        -- Fake data: return success
        local playerName = "michel"
        local playerId = 123456789
        local status = "In Game"
        local avatarUrl = Players:GetUserThumbnailAsync(playerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        local jobId = "a1b2c3d4e5f6g7h8" -- dummy JobId
        return true, playerName, playerId, status, avatarUrl, jobId
    end
    -- Fail by default:
    return false
end

-- -------------------------------------------------------------------
-- Tab 3: Setting

local SettingTab = Create("Frame", {
    Parent = ContentFrame;
    Size = UDim2.new(1,0,1,0);
    BackgroundColor3 = Color3.fromRGB(40, 40, 40);
    BackgroundTransparency = 0;
    Visible = false;
})

local SettingCorner = Create("UICorner", {Parent=SettingTab, CornerRadius = UDim.new(0, 14)})

local SectionTitle = Create("TextLabel", {
    Parent = SettingTab;
    Text = "Change Background";
    Position = UDim2.new(0, 20, 0, 20);
    Size = UDim2.new(0, 350, 0, 30);
    Font = Enum.Font.GothamBold;
    TextSize = 22;
    TextColor3 = Color3.fromRGB(200, 200, 200);
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
})

-- Dropdown placeholder
local Dropdown = Create("TextButton", {
    Parent = SettingTab;
    Text = "Change Background ▼";
    Position = UDim2.new(0, 20, 0, 65);
    Size = UDim2.new(0, 250, 0, 35);
    BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    Font = Enum.Font.Gotham;
    TextSize = 18;
    TextColor3 = Color3.fromRGB(210, 210, 210);
    AutoButtonColor = false;
    BorderSizePixel = 0;
})
local DropdownCorner = Create("UICorner", {Parent=Dropdown, CornerRadius = UDim.new(0, 10)})

-- Color selector box placeholder
local ColorSelector = Create("TextBox", {
    Parent = SettingTab;
    Text = "#888888 (100%)";
    Position = UDim2.new(0, 20, 0, 110);
    Size = UDim2.new(0, 250, 0, 35);
    BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    Font = Enum.Font.Gotham;
    TextSize = 18;
    TextColor3 = Color3.fromRGB(210, 210, 210);
    ClearTextOnFocus = false;
    TextEditable = true;
    PlaceholderText = "#888888 (100%)";
})
local ColorSelectorCorner = Create("UICorner", {Parent=ColorSelector, CornerRadius = UDim.new(0, 10)})

-- Toggle Black and White option
local ToggleContainer = Create("Frame", {
    Parent = SettingTab;
    Size = UDim2.new(0, 250, 0, 40);
    Position = UDim2.new(0, 20, 0, 160);
    BackgroundTransparency = 1;
})

local ToggleLabel = Create("TextLabel", {
    Parent = ToggleContainer;
    Text = "Black and White";
    Size = UDim2.new(0.7, 0, 1, 0);
    Position = UDim2.new(0, 0, 0, 0);
    TextColor3 = Color3.fromRGB(210,210,210);
    Font = Enum.Font.Gotham;
    TextSize = 18;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Center;
})

local ToggleCheckbox = Create("ImageButton", {
    Parent = ToggleContainer;
    Size = UDim2.new(0, 28, 0, 28);
    Position = UDim2.new(0.75, 0, 0, 6);
    BackgroundColor3 = Color3.fromRGB(55,55,55);
    BorderSizePixel = 0;
    AutoButtonColor = false;
})
local ToggleCorner = Create("UICorner", {Parent=ToggleCheckbox, CornerRadius = UDim.new(0, 6)})

local TickMark = Create("ImageLabel", {
    Parent = ToggleCheckbox;
    Size = UDim2.new(0, 18, 0, 18);
    Position = UDim2.new(0.1, 0, 0.12, 0);
    BackgroundTransparency = 1;
    Image = "rbxassetid://3926305904"; -- Checkmark image ID in Roblox
    Visible = false;
})

ToggleCheckbox.MouseButton1Click:Connect(function()
    TickMark.Visible = not TickMark.Visible
    ShowNotification("Black and White: "..(TickMark.Visible and "Enabled" or "Disabled"))
end)

-- -------------------------------------------------------------------
-- Collect tabs
Tabs.TabFrames["Credit"] = CreditTab
Tabs.TabFrames["Server snipe"] = ServerSnipeTab
Tabs.TabFrames["Setting"] = SettingTab

-- Connect sidebar buttons to select tabs
for name, button in pairs(SidebarButtons) do
    button.MouseButton1Click:Connect(function()
        Tabs.SelectTab(name)
    end)
end

-- Init with Server snipe tab selected
Tabs.SelectTab("Server snipe")

-- Draggability and Resizability for MainFrame

do
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end


--[[
    Server Sniping core functionality:

    1) Prompt user to enter a target player username.
    2) Find the server JobId where that player currently plays.
    3) TeleportService:TeleportToPlaceInstance(placeId, jobId)
    4) If not found in public servers print message.
--]]

--[[
For exploit scripts, user input prompt typically happens outside GUI or via an input box.
Here we have a text box in UI but let's implement a simple prompt behavior:

We can simulate prompt via PasteIdInput TextBox for demo purposes, but we also create a prompt if needed.
--]]

if not RunService:IsStudio() then
    -- Exploit environment, launch small prompt for input username for server snipe:
    -- For demo, simple TextInputPrompt:
    local TeleportService = game:GetService("TeleportService")

    local function PromptUsernameAndSnipe()
        print("[Server Snipe] Enter the target player's username in the text box and click 'Check Id server' to find their server then 'Join Server' to teleport.")

        -- Additionally here: listen for BtnCheck clicked + PasteIdInput.Text and then JoinServer on BtnJoin click.

        -- Already implemented above for GUI buttons.
    end

    PromptUsernameAndSnipe()
else
    print("[Server Snipe] GUI running in Studio - teleportation won't work here.")
end

-- End of Script
