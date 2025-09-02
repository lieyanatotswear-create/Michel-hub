-- Roblox Lua: Modern, draggable, animated Hub UI (only UI creation as requested)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ClipboardService = (syn and syn.set_clipboard) or (setclipboard) or nil -- clipboard function

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Helper to create instances
local function New(className, props)
	local obj = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			if k == "Children" and type(v) == "table" then
				for _, child in ipairs(v) do
					child.Parent = obj
				end
			elseif k == "Parent" then
				-- handled later
			else
				obj[k] = v
			end
		end
	end
	return obj
end

-- Colors
local COLOR_GREEN = Color3.fromHex("1ED91E")
local COLOR_RED = Color3.fromHex("E43D3D")
local COLOR_DARK_GREY = Color3.fromHex("444444")
local COLOR_BLACK = Color3.fromRGB(20,20,20)
local COLOR_GREY_BG_START = Color3.fromHex("222222")
local COLOR_GREY_BG_END = Color3.fromHex("2B2B2B")
local COLOR_LIGHT_GREY = Color3.fromHex("888888")
local COLOR_ACCENT = COLOR_GREEN

-- Gui setup
local ScreenGui = New("ScreenGui", {
	ResetOnSpawn = false,
	DisplayOrder = 1000,
	Name = "ServerSnipeHub",
	Parent = player:WaitForChild("PlayerGui"),
})

-- Main Frame (window)
local MainFrame = New("Frame", {
	Name = "MainFrame",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 650, 0, 420),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	Parent = ScreenGui,
})

-- Rounded corners
local UICorner_Main = New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = MainFrame })
-- Gradient background
local UIGradient_BG = New("UIGradient", {
	Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, COLOR_GREY_BG_START), ColorSequenceKeypoint.new(1, COLOR_GREY_BG_END)}),
	Transparency = NumberSequence.new(0),
	Parent = MainFrame
})

-- Soft shadow around MainFrame
local Shadow = New("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5,0,0.5,0),
	Size = UDim2.new(1.1,0,1.1,0),
	BackgroundTransparency = 1,
	Image = "rbxassetid://7826182047", -- soft shadow image
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(20,20,180,180),
	Parent = MainFrame,
	ZIndex = 0,
})

-- Title bar frame
local TitleBar = New("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1,0,0,36),
	BackgroundTransparency = 1,
	Parent = MainFrame,
	ZIndex = 3,
})

local TitleText = New("TextLabel", {
	Name = "TitleText",
	Text = "Server snipe by michel",
	Font = Enum.Font.SegoeUI,
	TextSize = 18,
	TextColor3 = Color3.new(1,1,1),
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Size = UDim2.new(0.5, 12, 1, 0),
	Position = UDim2.new(0, 14, 0, 0),
	Parent = TitleBar,
	ZIndex = 3,
})

-- Window control buttons container
local ControlsFrame = New("Frame", {
	Name = "ControlsFrame",
	Size = UDim2.new(0, 120, 1, 0),
	Position = UDim2.new(1, -130, 0, 0),
	BackgroundTransparency = 1,
	Parent = TitleBar,
	ZIndex = 3,
})

-- Define control buttons with hover effect and icons
local function MakeControlButton(name, iconText)
	local btn = New("TextButton", {
		Name = name,
		Size = UDim2.new(0, 32, 1, 0),
		Text = iconText,
		Font = Enum.Font.SegoeUI,
		TextSize = 20,
		TextColor3 = Color3.new(1,1,1),
		BackgroundColor3 = COLOR_GREY_BG_END,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = ControlsFrame,
	})
	local corner = New("UICorner", { CornerRadius = UDim.new(0,6), Parent = btn })
	
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = COLOR_ACCENT}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = COLOR_GREY_BG_END}):Play()
	end)
	
	return btn
end

local BtnMinimize = MakeControlButton("MinimizeBtn", "–")
local BtnHome = MakeControlButton("HomeBtn", "□")
local BtnClose = MakeControlButton("CloseBtn", "X")

-- Layout control buttons horizontally
local buttonsLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 8),
	Parent = ControlsFrame,
})

-- Sidebar menu
local SidebarFrame = New("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 140, 1, -36),
	Position = UDim2.new(0, 0, 0, 36),
	BackgroundColor3 = COLOR_GREY_BG_END,
	BorderSizePixel = 0,
	Parent = MainFrame,
	ZIndex = 2,
})

local UISidebarCorner = New("UICorner", {CornerRadius = UDim.new(0, 14), Parent = SidebarFrame})

-- Vertical green bar for active tab
local SelectedBar = New("Frame", {
	Name = "SelectedBar",
	Size = UDim2.new(0, 4, 0, 40),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = COLOR_ACCENT,
	BorderSizePixel = 0,
	Parent = SidebarFrame,
	ZIndex = 3,
	Visible = false,
})

-- Buttons: Credit, Server snipe, Setting
local tabNames = {"Credit", "Server snipe", "Setting"}
local tabs = {}
local buttonsLayoutSidebar = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 8),
	Parent = SidebarFrame,
})

-- Function to create sidebar button with highlight indicator
local function MakeTabButton(text, ypos)
	local btn = New("TextButton", {
		Name = text.."Btn",
		Size = UDim2.new(1, 0, 0, 40),
		Text = text,
		Font = Enum.Font.SegoeUI,
		TextSize = 16,
		TextColor3 = Color3.new(1,1,1),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = SidebarFrame,
		ZIndex = 3,
	})
	btn.PaddingLeft = Instance.new("UIPadding", btn)
	btn.PaddingLeft.PaddingLeft = UDim.new(0, 16)
	return btn
end

for i, tabName in ipairs(tabNames) do
	local btn = MakeTabButton(tabName)
	btn.LayoutOrder = i
	tabs[tabName] = btn
end

-- Main content frame
local ContentFrame = New("Frame", {
	Name = "ContentFrame",
	Size = UDim2.new(1, -140, 1, -36),
	Position = UDim2.new(0, 140, 0, 36),
	BackgroundTransparency = 1,
	Parent = MainFrame,
	ZIndex = 2,
})

-- UIListLayout for cleaning inner content (vertical stacking)
local ContentLayout = New("UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
	Parent = ContentFrame,
})

-- Fade tween utility for content switch
local function FadeFrame(frame, fadeOut, duration)
	if not frame then return end
	local tween = TweenService:Create(frame, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad), {Transparency = fadeOut and 1 or 0})
	tween:Play()
end

-- Animate MainFrame from small to full size on open
MainFrame.Size = UDim2.new(0, 0, 0, 0)
local tweenOpen = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 420)})
tweenOpen:Play()

-- Draggable window functionality
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		local newPos = UDim2.new(
			math.clamp(framePos.X.Scale, 0, 1),
			math.clamp(framePos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - MainFrame.AbsoluteSize.X),
			math.clamp(framePos.Y.Scale, 0, 1),
			math.clamp(framePos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - MainFrame.AbsoluteSize.Y)
		)
		MainFrame.Position = newPos
	end
end)

-- Resizable window (bottom-right corner drag)
local resizeGrabSize = 22
local ResizeGrab = New("Frame", {
	Name = "ResizeGrab",
	Size = UDim2.new(0, resizeGrabSize, 0, resizeGrabSize),
	Position = UDim2.new(1, -resizeGrabSize, 1, -resizeGrabSize),
	BackgroundTransparency = 0.7,
	BackgroundColor3 = COLOR_GREY_BG_END,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1,1),
	ZIndex = 5,
	Parent = MainFrame,
})

local ResizeCorner = New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ResizeGrab})

local resizing = false
local resizeInput, resizeStartPos, resizeStartSize

ResizeGrab.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStartPos = input.Position
		resizeStartSize = MainFrame.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input == resizeInput then
		local delta = input.Position - resizeStartPos
		local newX = math.clamp(resizeStartSize.X.Offset + delta.X, 450, workspace.CurrentCamera.ViewportSize.X - MainFrame.AbsolutePosition.X)
		local newY = math.clamp(resizeStartSize.Y.Offset + delta.Y, 300, workspace.CurrentCamera.ViewportSize.Y - MainFrame.AbsolutePosition.Y)
		MainFrame.Size = UDim2.new(0, newX, 0, newY)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		resizeInput = input
	end
end)

-- Hover effect on ResizeGrab
ResizeGrab.MouseEnter:Connect(function()
	TweenService:Create(ResizeGrab, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
end)
ResizeGrab.MouseLeave:Connect(function()
	TweenService:Create(ResizeGrab, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
end)

-- Content pages setup -------------------
local Pages = {}

-- Common function for fade transition between pages:
local function ShowPage(pageName)
	for k, frame in pairs(Pages) do
		if k == pageName then
			frame.Visible = true
			TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
			SelectedBar.Visible = true
			local btn = tabs[k]
			if btn then
				SelectedBar.Position = UDim2.new(0, 0, 0, btn.LayoutOrder * 48 - 40) -- 40 offset + 8 padding + 40 per button
			end
		else
			frame.Visible = false
		end
	end
end

-- =========== Page: Credit ================
local CreditPage = New("Frame", {
	Name = "CreditPage",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Parent = ContentFrame,
})
Pages["Credit"] = CreditPage
CreditPage.Visible = false

local CreditText = New("TextLabel", {
	Name = "CreditText",
	Size = UDim2.new(1, -24, 0, 40),
	Position = UDim2.new(0, 12, 0, 12),
	BackgroundTransparency = 1,
	Text = "Credit to: michal",
	Font = Enum.Font.SegoeUI,
	TextSize = 20,
	TextColor3 = Color3.new(1,1,1),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = CreditPage,
})

-- Discord button with logo and text
local DiscordButton = New("TextButton", {
	Name = "DiscordButton",
	Size = UDim2.new(1, -24, 0, 70),
	Position = UDim2.new(0, 12, 0, 60),
	BackgroundColor3 = COLOR_BLACK,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = true,
	Parent = CreditPage,
})
local DiscordCorner = New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = DiscordButton})

local DiscordLayout = New("UIListLayout", {Padding = UDim.new(0,12), FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = DiscordButton})

-- Discord icon image (Large)
local DiscordLogo = New("ImageLabel", {
	Name = "DiscordLogo",
	Size = UDim2.new(0, 56, 0, 56),
	Image = "rbxassetid://8560597200", -- Discord logo (rounded)
	BackgroundTransparency = 1,
	Parent = DiscordButton,
})

local DiscordText = New("TextLabel", {
	Name = "DiscordText",
	Text = "Join Discord server",
	Font = Enum.Font.SegoeUI,
	TextSize = 24,
	TextColor3 = Color3.new(1,1,1),
	BackgroundTransparency = 1,
	Parent = DiscordButton,
	Size = UDim2.new(1, -68, 1, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
})

-- Discord button hover effect
DiscordButton.MouseEnter:Connect(function()
	TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_ACCENT}):Play()
end)
DiscordButton.MouseLeave:Connect(function()
	TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_BLACK}):Play()
end)

-- Discord link text box below Discord button
local DiscordLinkBox = New("TextBox", {
	Name = "DiscordLinkBox",
	Size = UDim2.new(1, -24, 0, 30),
	Position = UDim2.new(0, 12, 0, 140),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	Text = "https://discord.gg/WstAPrVe",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 15,
	ClearTextOnFocus = false,
	PlaceholderText = "",
	Parent = CreditPage,
})
local DiscordLinkCorner = New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DiscordLinkBox})

-- Clicking Discord button opens Discord link in browser (placeholder)
DiscordButton.MouseButton1Click:Connect(function()
	-- Normally, we can't open external links in Roblox, just placeholder
	print("Discord button clicked (placeholder)")
end)

-- =========== Page: Server snipe ================
local ServerSnipePage = New("Frame", {
	Name = "ServerSnipePage",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Parent = ContentFrame,
})
Pages["Server snipe"] = ServerSnipePage
ServerSnipePage.Visible = false

-- Search bar top
local SearchBox = New("TextBox", {
	Name = "SearchBox",
	Size = UDim2.new(1, -24, 0, 32),
	Position = UDim2.new(0, 12, 0, 12),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	Text = "",
	PlaceholderText = "Search",
	Parent = ServerSnipePage,
})

local SearchCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SearchBox })

-- Player Info container
local PlayerInfoFrame = New("Frame", {
	Name = "PlayerInfoFrame",
	Size = UDim2.new(1, -24, 0, 170),
	Position = UDim2.new(0, 12, 0, 56),
	BackgroundColor3 = COLOR_GREY_BG_END,
	BorderSizePixel = 0,
	Parent = ServerSnipePage,
})
local PlayerInfoCorner = New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = PlayerInfoFrame})

local PlayerInfoLayout = New("UIListLayout", {Padding = UDim.new(0, 12), FillDirection = Enum.FillDirection.Vertical, Parent = PlayerInfoFrame})

-- Info rows: Name, ID, Status, Avatar

local function CreateInfoRow(labelText, hasCopy)
	local row = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = PlayerInfoFrame})
	local label = New("TextLabel", {
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = labelText,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.SegoeUI,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	
	local value = New("TextLabel", {
		Name = "Value",
		Size = UDim2.new(0.6, -60, 1, 0),
		Position = UDim2.new(0, 72, 0, 0),
		BackgroundTransparency = 1,
		Text = "---",
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.SegoeUI,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	
	if hasCopy then
		local btn = New("TextButton", {
			Name = "CopyBtn",
			Size = UDim2.new(0, 50, 1, -6),
			Position = UDim2.new(1, -58, 0, 3),
			BackgroundColor3 = COLOR_GREY_BG_START,
			BorderSizePixel = 0,
			Text = "Copy",
			Font = Enum.Font.SegoeUI,
			TextSize = 14,
			TextColor3 = Color3.new(1,1,1),
			Parent = row,
			AutoButtonColor = true,
		})
		local copyCorner = New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
		
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLOR_ACCENT}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLOR_GREY_BG_START}):Play()
		end)
		
		btn.MouseButton1Click:Connect(function()
			local textToCopy = value.Text
			if ClipboardService then
				ClipboardService(textToCopy)
				-- Confirmation feedback (can be added)
				btn.Text = "Copied!"
				delay(1.5, function()
					if btn and btn.Parent then
						btn.Text = "Copy"
					end
				end)
			else
				warn("Clipboard not supported on this executor")
			end
		end)
	end
	
	return row, value
end

local NameRow, NameValue = CreateInfoRow("Name:", true)
local IDRow, IDValue = CreateInfoRow("ID:", true)

-- Status row (with colored dot and text)
local StatusRow = New("Frame", {Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Parent = PlayerInfoFrame})
do
	local label = New("TextLabel", {
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = "Status:",
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.SegoeUI,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = StatusRow,
	})
	local dot = New("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 76, 0, 6),
		BackgroundColor3 = COLOR_GREEN,
		BorderSizePixel = 0,
		Parent = StatusRow,
	})
	local dotCorner = New("UICorner", {CornerRadius = UDim.new(1,0), Parent = dot})
	
	local statusText = New("TextLabel", {
		Name = "StatusText",
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 98, 0, 0),
		BackgroundTransparency = 1,
		Text = "In Game",
		Font = Enum.Font.SegoeUI,
		TextSize = 16,
		TextColor3 = Color3.new(1,1,1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = StatusRow,
	})
end

-- Avatar row (imagebox)
local AvatarRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 100),
	BackgroundTransparency = 1,
	Parent = PlayerInfoFrame,
})
local AvatarLabel = New("TextLabel", {
	Size = UDim2.new(0, 60, 1, 0),
	Position = UDim2.new(0, 8, 0, 0),
	BackgroundTransparency = 1,
	Text = "Avatar:",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = AvatarRow,
})
local AvatarImage = New("ImageLabel", {
	Size = UDim2.new(0, 96, 0, 96),
	Position = UDim2.new(0, 80, 0, 2),
	BackgroundColor3 = Color3.new(0,0,0),
	Image = "rbxasset://textures/ui/AvatarPlaceholder.png",
	BorderSizePixel = 0,
	Parent = AvatarRow,
})
local AvatarCorner = New("UICorner", {CornerRadius = UDim.new(0, 16), Parent = AvatarImage})

-- Below PlayerInfoFrame, bottom input and buttons area

local BottomArea = New("Frame", {
	Size = UDim2.new(1, -24, 0, 110),
	Position = UDim2.new(0, 12, 1, -110),
	BackgroundTransparency = 1,
	Parent = ServerSnipePage,
})

-- Input box: Paste Id
local PasteIdInput = New("TextBox", {
	Size = UDim2.new(1, 0, 0, 32),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	Text = "",
	PlaceholderText = "Paste Id",
	Parent = BottomArea,
})
local PasteIdCorner = New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = PasteIdInput})

local ButtonsFrame = New("Frame", {
	Size = UDim2.new(1, 0, 0, 48),
	Position = UDim2.new(0, 0, 0, 50),
	BackgroundTransparency = 1,
	Parent = BottomArea,
})

local ButtonsLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Spacing = 16,
	Parent = ButtonsFrame,
})

-- Check ID server button (grey)
local BtnCheckID = New("TextButton", {
	Name = "BtnCheckID",
	Size = UDim2.new(0, 140, 1, 0),
	BackgroundColor3 = COLOR_GREY_BG_END,
	Text = "Check ID server",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 18,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	Parent = ButtonsFrame,
})
New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BtnCheckID})

-- Join Server button (black)
local BtnJoinServer = New("TextButton", {
	Name = "BtnJoinServer",
	Size = UDim2.new(0, 140, 1, 0),
	BackgroundColor3 = Color3.new(0,0,0),
	Text = "Join Server",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 18,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	Parent = ButtonsFrame,
	-- Disabled initially
})
New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BtnJoinServer})

-- Buttons hover effect
local function ButtonHoverEffects(btn)
	btn.MouseEnter:Connect(function()
		if btn.BackgroundColor3 ~= COLOR_DARK_GREY then
			TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = COLOR_ACCENT}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if btn == BtnCheckID then
			TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = COLOR_GREY_BG_END}):Play()
		elseif btn == BtnJoinServer then
			TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = COLOR_BLACK}):Play()
		end
	end)
end
ButtonHoverEffects(BtnCheckID)
ButtonHoverEffects(BtnJoinServer)

-- Functionality placeholders for buttons (highlight and text changes)

local checkIDState = "idle" -- idle, processing, failed, success

local function UpdateButtonsStateBasedOnCheck(state)
	checkIDState = state
	if state == "processing" then
		BtnCheckID.BackgroundColor3 = COLOR_DARK_GREY
		BtnCheckID.Text = "Processed"
		BtnJoinServer.Text = "Wait until Successfull"
		BtnJoinServer.AutoButtonColor = false
		BtnJoinServer.BackgroundColor3 = Color3.fromRGB(70,70,70)
		BtnJoinServer.Active = false
		BtnJoinServer.Selectable = false
	elseif state == "success" then
		BtnCheckID.BackgroundColor3 = COLOR_GREEN
		BtnCheckID.Text = "Successfull"
		BtnJoinServer.Text = "Join Server"
		BtnJoinServer.BackgroundColor3 = COLOR_BLACK
		BtnJoinServer.Active = true
		BtnJoinServer.Selectable = true
	elseif state == "failed" then
		BtnCheckID.BackgroundColor3 = COLOR_RED
		BtnCheckID.Text = "Failed"
		-- Join stays disabled
		BtnJoinServer.Text = "Wait until Successfull"
		BtnJoinServer.BackgroundColor3 = Color3.fromRGB(70,70,70)
		BtnJoinServer.Active = false
		BtnJoinServer.Selectable = false
	else -- idle
		BtnCheckID.BackgroundColor3 = COLOR_GREY_BG_END
		BtnCheckID.Text = "Check ID server"
		BtnJoinServer.Text = "Join Server"
		BtnJoinServer.BackgroundColor3 = COLOR_BLACK
		BtnJoinServer.Active = true
		BtnJoinServer.Selectable = true
	end
end
UpdateButtonsStateBasedOnCheck("idle") -- start idle

-- ========== Page: Setting =================
local SettingPage = New("Frame", {
	Name = "SettingPage",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Parent = ContentFrame,
})
Pages["Setting"] = SettingPage
SettingPage.Visible = false

local SettingLayout = New("UIListLayout", {
	Padding = UDim.new(0, 12),
	FillDirection = Enum.FillDirection.Vertical,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Parent = SettingPage,
})

local ChangeBgTitle = New("TextLabel", {
	Text = "Change Background",
	TextColor3 = Color3.new(1,1,1),
	BackgroundTransparency = 1,
	Font = Enum.Font.SegoeUI,
	TextSize = 20,
	Size = UDim2.new(1, -24, 0, 30),
	Parent = SettingPage,
})

-- Dropdown placeholder (button + label)
local DropdownBox = New("TextButton", {
	Size = UDim2.new(0, 200, 0, 36),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	Text = "Change Background",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	Parent = SettingPage,
	AutoButtonColor = true
})
local DropdownCorner = New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownBox})

-- Color selector box placeholder
local ColorSelectorBox = New("TextBox", {
	Size = UDim2.new(0, 200, 0, 32),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	Text = "#888888 (100%)",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	ClearTextOnFocus = false,
	PlaceholderText = "",
	Parent = SettingPage,
})
local ColorSelectorCorner = New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ColorSelectorBox})

-- Toggle option "Black and White" - with Checkbox
local ToggleFrame = New("Frame", {
	Size = UDim2.new(0, 200, 0, 36),
	BackgroundTransparency = 1,
	Parent = SettingPage,
})

local ToggleLabel = New("TextLabel", {
	Text = "Black and White",
	TextColor3 = Color3.new(1,1,1),
	BackgroundTransparency = 1,
	Font = Enum.Font.SegoeUI,
	TextSize = 16,
	Size = UDim2.new(1, -36, 1, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = ToggleFrame,
})

local Checkbox = New("ImageButton", {
	Size = UDim2.new(0, 24, 0, 24),
	BackgroundColor3 = COLOR_GREY_BG_START,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -30, 0.5, -12),
	AutoButtonColor = true,
	Parent = ToggleFrame,
})
local CheckboxCorner = New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Checkbox})

local isChecked = false
local Checkmark = New("ImageLabel", {
	Size = UDim2.new(0.6,0,0.6,0),
	Position = UDim2.new(0.2,0,0.2,0),
	BackgroundTransparency = 1,
	Image = "rbxassetid://3926309567", -- checkmark
	ImageColor3 = COLOR_ACCENT,
	Visible = false,
	Parent = Checkbox,
})

Checkbox.MouseButton1Click:Connect(function()
	isChecked = not isChecked
	Checkmark.Visible = isChecked
	-- Placeholder to trigger setting change
	print("Black and White toggled:", isChecked)
end)

-- ============= Tab switching logic =====================

local currentTab = "Credit" -- default tab

for name, btn in pairs(tabs) do
	btn.MouseButton1Click:Connect(function()
		if currentTab ~= name then
			currentTab = name
			ShowPage(name)
		end
	end)
end

-- Initial show
ShowPage(currentTab)

-- ============ Button behaviors in Server snipe page -------------

BtnCheckID.MouseButton1Click:Connect(function()
	-- Validate input
	local inputText = PasteIdInput.Text:gsub("%s","")
	if inputText == "" then
		-- Show sliding notification "Please input the ID"
		if ScreenGui:FindFirstChild("NotificationFrame") then
			ScreenGui.NotificationFrame:Destroy()
		end

		local notification = New("Frame", {
			Name = "NotificationFrame",
			Size = UDim2.new(0, 250, 0, 40),
			Position = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Color3.fromRGB(40,40,40),
			BorderSizePixel = 0,
			Parent = ScreenGui,
			ZIndex = 100,
		})
		New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = notification})
		local notifText = New("TextLabel", {
			Text = "Please input the ID",
			TextColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 1,
			Font = Enum.Font.SegoeUI,
			TextSize = 18,
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = notification,
		})
		
		local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -258, 0, 60)})
		local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 0, 0, 60)})
		
		tweenIn:Play()
		tweenIn.Completed:Wait()
		
		task.delay(4, function()
			tweenOut:Play()
			tweenOut.Completed:Wait()
			if notification and notification.Parent then
				notification:Destroy()
			end
		end)
		
		return
	end
	
	-- Otherwise, start processing
	UpdateButtonsStateBasedOnCheck("processing")
	
	-- Simulated delay and random success/fail for example
	delay(1.8, function()
		local success = math.random() > 0.3
		if success then
			UpdateButtonsStateBasedOnCheck("success")
		else
			UpdateButtonsStateBasedOnCheck("failed")
		end
	end)
end)

-- Join Server button placeholder
BtnJoinServer.MouseButton1Click:Connect(function()
	if checkIDState == "success" then
		print("Join Server button clicked (placeholder)")
	else
		print("Join Server button disabled (waiting for success)")
	end
end)

-- ================ Top bar buttons ===============

BtnClose.MouseButton1Click:Connect(function()
	-- Close window (animate closure then destroy)
	local tweenClose = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0,0,0,0)})
	tweenClose:Play()
	tweenClose.Completed:Wait()
	ScreenGui:Destroy()
end)

BtnMinimize.MouseButton1Click:Connect(function()
	if MainFrame.Visible then
		-- Minimize (hide content, shrink window height)
		TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 650, 0, 40)}):Play()
		ContentFrame.Visible = false
		SidebarFrame.Visible = false
	else
		-- Restore
		TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 650, 0, 420)}):Play()
		ContentFrame.Visible = true
		SidebarFrame.Visible = true
	end
end)

BtnHome.MouseButton1Click:Connect(function()
	-- Switch to home tab = 'Credit'
	currentTab = "Credit"
	ShowPage(currentTab)
end)

-- ================ Initial player info fill ================

local plr = player
NameValue.Text = plr.Name
IDValue.Text = tostring(plr.UserId)
StatusRow.StatusText.Text = "In Game"
StatusRow.StatusText.TextColor3 = COLOR_GREEN

local success, thumb = pcall(function()
	return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)

if success then
	AvatarImage.Image = thumb
else
	AvatarImage.Image = "rbxasset://textures/ui/AvatarPlaceholder.png"
end


-- All code done


--[[
Note: This code only builds the complete UI with the described look, animations, toggles, and all components.
Functionality like searching, joining servers, actual teleporting and server sniping is to be scripted later.

Clipboard copy works if executor supports clipboard functions (syn.set_clipboard or setclipboard).

If you want me to also script the teleport based on username input, please ask separately.
--]]

print("ServerSnipeHub UI loaded.")

repeat wait() until game:IsLoaded()
local h = game:GetService("HttpService")
local RequestFunction
if syn and syn.request then
	RequestFunction = syn.request
elseif request then
	RequestFunction = request
elseif http and http.request then
	RequestFunction = http.request
elseif http_request then
	RequestFunction = http_request
end

-- ambil cursor
if _G.cursor == nil then
	_G.cursor =
		RequestFunction(
			{["Url"] = "https://raw.githubusercontent.com/LeymansGuz/playerTokens/main/cursor.txt", ["Method"] = "GET"}
		)
	_G.cursor = h:JSONDecode(_G.cursor.Body)
end

-- fungsi utama
function runScript(placeId, user, mode)
	spawn(function()
		local timecount = tick()

		if _G.available == nil then
			_G.available = true
		end

		-- helper: bulatkan nombor
		local function round(num)
			return tostring(math.floor(num * 100 + 0.5) / 100)
		end

		-- semak token player
		local function checktokens(tokens)
			local payload = {
				Url = "https://thumbnails.roblox.com/v1/batch",
				Headers = {["Content-Type"] = "application/json"},
				Method = "POST",
				Body = {}
			}
			for i, v in pairs(tokens) do
				table.insert(payload.Body, {
					requestId = "0:" .. v[3] .. ":AvatarHeadshot:150x150:png:regular",
					type = "AvatarHeadShot",
					targetId = 0,
					token = v[3],
					format = "png",
					size = "150x150"
				})
			end
			payload.Body = h:JSONEncode(payload.Body)
			local result = RequestFunction(payload)
			local s, data = pcall(h.JSONDecode, h, result.Body)
			return data.data
		end

		-- JSON parse
		local function json()
			-- (isi sama macam script asal, cuma buang semua referensi TButton.Text)
		end

		local function json2()
			repeat
				spawn(function() json() end)
				local ti = tick()
				repeat game.RunService.RenderStepped:Wait() until tick() - ti > 0.015
			until #_G.token == 0
			_G.available = true
		end

		-- ambil token player
		local function playertoken(gameid, target)
			-- (isi sama macam script asal, cuma buang semua TButton.Text = "...") 
		end

		-- mula jalan
		playertoken(placeId, user)
	end)
end
