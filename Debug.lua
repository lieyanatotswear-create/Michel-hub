local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DebugGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

if syn and syn.protect_gui then
    syn.protect_gui(gui)
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 380)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -190)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = gui

local container = Instance.new("Frame")
container.BackgroundTransparency = 1
container.Size = UDim2.new(1, 0, 1, 0)
container.Position = UDim2.new(0, 0, 0, 0)
container.Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = container
UIScale.Scale = 0.5

local Tween = TweenService:Create(UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
Tween:Play()

-- Add a sample label to confirm UI load
local label = Instance.new("TextLabel")
label.Text = "Modern Hub UI Loaded!"
label.Size = UDim2.new(1, -20, 0, 40)
label.Position = UDim2.new(0, 10, 0, 10)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 24
label.TextColor3 = Color3.new(1,1,1)
label.BackgroundTransparency = 1
label.Parent = container
