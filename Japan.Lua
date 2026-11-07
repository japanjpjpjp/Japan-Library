--[[
    Japan UI - Dopagaki風
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 既存削除
pcall(function()
	if PlayerGui:FindFirstChild("JapanUI") then
		PlayerGui.JapanUI:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JapanUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ==================== 上のウォーターマーク ====================
local Watermark = Instance.new("Frame")
Watermark.Size = UDim2.new(0, 320, 0, 26)
Watermark.Position = UDim2.new(0.5, -160, 0, 12)
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.Parent = ScreenGui

local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(0, 8)
WMCorner.Parent = Watermark

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Color3.fromRGB(50, 50, 65)
WMStroke.Thickness = 1
WMStroke.Transparency = 0.4
WMStroke.Parent = Watermark

local WMText = Instance.new("TextLabel")
WMText.Size = UDim2.new(1, -10, 1, 0)
WMText.Position = UDim2.new(0, 8, 0, 0)
WMText.BackgroundTransparency = 1
WMText.Font = Enum.Font.GothamMedium
WMText.TextSize = 12
WMText.TextColor3 = Color3.fromRGB(220, 220, 235)
WMText.TextXAlignment = Enum.TextXAlignment.Left
WMText.Text = "Japan  |  0 fps  |  0 ms  |  00:00  |  " .. LocalPlayer.Name
WMText.Parent = Watermark

-- ウォーターマーク更新
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
	if tick() - lastUpdate < 0.5 then return end
	lastUpdate = tick()

	local fps = math.floor(1 / RunService.RenderStepped:Wait())
	local ping = 0
	pcall(function()
		ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)
	local timeStr = os.date("%H:%M")

	WMText.Text = string.format("Japan  |  %d fps  |  %d ms  |  %s  |  %s", fps, ping, timeStr, LocalPlayer.Name)
end)

-- ウォーターマークドラッグ
local wmDragging, wmStart, wmPos
Watermark.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		wmDragging = true
		wmStart = input.Position
		wmPos = Watermark.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then wmDragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - wmStart
		Watermark.Position = UDim2.new(wmPos.X.Scale, wmPos.X.Offset + delta.X, wmPos.Y.Scale, wmPos.Y.Offset + delta.Y)
	end
end)

-- ==================== メインウィンドウ ====================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 60)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFill = Instance.new("Frame")
TitleFill.Size = UDim2.new(1, 0, 0, 12)
TitleFill.Position = UDim2.new(0, 0, 1, -12)
TitleFill.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TitleFill.BorderSizePixel = 0
TitleFill.Parent = TitleBar

-- ロゴ的な部分
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 8, 0, 4)
Logo.BackgroundTransparency = 1
Logo.Text = "✦"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 18
Logo.TextColor3 = Color3.fromRGB(180, 160, 255)
Logo.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 20)
TitleText.Position = UDim2.new(0, 38, 0, 3)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Japan"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextColor3 = Color3.fromRGB(240, 240, 250)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 0, 14)
SubTitle.Position = UDim2.new(0, 38, 0, 20)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Fling things and people"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextColor3 = Color3.fromRGB(140, 140, 160)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- 検索バー
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 140, 0, 24)
SearchBox.Position = UDim2.new(1, -220, 0, 7)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search"
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.TextColor3 = Color3.fromRGB(220, 220, 235)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = TitleBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent =
