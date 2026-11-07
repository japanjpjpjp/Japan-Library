--[[
    JapanLibrary
    Obsidian風 クリーンUIライブラリ
]]

local JapanLibrary = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- よりObsidianに近いテーマ
local Theme = {
    Background   = Color3.fromRGB(18, 18, 23),
    Secondary    = Color3.fromRGB(24, 24, 31),
    Tertiary     = Color3.fromRGB(32, 32, 41),
    Accent       = Color3.fromRGB(124, 109, 255), -- 紫寄り
    AccentHover  = Color3.fromRGB(145, 130, 255),
    Text         = Color3.fromRGB(240, 240, 250),
    TextDim      = Color3.fromRGB(170, 170, 190),
    TextMuted    = Color3.fromRGB(130, 130, 150),
    Border       = Color3.fromRGB(45, 45, 58),
    Error        = Color3.fromRGB(240, 80, 80),
}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function JapanLibrary:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "JapanLibrary"
    local Size = options.Size or UDim2.new(0, 580, 0, 420)

    -- 既存削除
    pcall(function()
        if PlayerGui:FindFirstChild("JapanLibrary") then
            PlayerGui.JapanLibrary:Destroy()
        end
    end)

    local ScreenGui = Create("ScreenGui", {
        Name = "JapanLibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })

    local Main = Create("Frame", {
        Size = Size,
        Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.25,
        Parent = Main
    })

    -- タイトルバー
    local TitleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TitleBar})
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TitleBar
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = Title,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- 閉じるボタン
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -42, 0, 3),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.TextMuted,
        Parent = TitleBar
    })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {TextColor3 = Theme.Error}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {TextColor3 = Theme.TextMuted}) end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- サイドバー
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 148, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main
    })

    local TabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList
    })

    -- コンテンツ
    local Content = Create("Frame", {
        Size = UDim2.new(1, -148, 1, -42),
        Position = UDim2.new(0, 148, 0, 42),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- ドラッグ
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {}
    local Pages = {}
    local CurrentTab = nil

    function Window:AddTab(name)
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "  " .. name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = TabList
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = TabButton})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = Content
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 16),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
            Parent = Page
        })

        local function Select()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, btn in pairs(TabList:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim})
                end
            end
            Page.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Theme.Text})
            CurrentTab = TabButton
        end

        TabButton.MouseButton1Click:Connect(Select)
        if not CurrentTab then Select() end
        Pages[name] = Page

        local Tab = {}

        function Tab:AddSection(title)
            local Section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Parent = Page
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = Section})
            Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.4,
                Parent = Section
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -24, 0, 30),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text = title,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })

            local Container = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 36),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = Section
            })
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Container
            })
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 14),
                Parent = Section
            })

            local API = {}

            function API:AddButton(text, callback)
                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = Btn})

                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(42, 42, 54)}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Tertiary}) end)
                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                return Btn
            end

            function API:AddToggle(text, default, callback)
                default = default or false
                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = Container
                })
                Create("TextLabel", {
                    Size = UDim2.new(1, -52, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder
                })

                local Bg = Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 55, 70),
                    Parent = Holder
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bg})

                local Circle = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Bg
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local state = default
                local function Set(v)
                    state = v
                    Tween(Bg, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 70)})
                    Tween(Circle, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                    if callback then callback(state) end
                end

                Bg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Set(not state)
                    end
                end)

                return {Set = Set, Get = function() return state end}
            end

            function API:AddLabel(text)
                return Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
            end

            function API:AddSlider(text, min, max, default, callback)
                min, max, default = min or 0, max or 100, default or min
                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    Parent = Container
                })
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text .. "  " .. default,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder
                })
                local Track = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 65),
                    Parent = Holder
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
                local Fill = Create("Frame", {
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    Parent = Track
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

                local value = default
                local sliding = false
                local function Update(v)
                    value = math.clamp(math.floor(v + 0.5), min, max)
                    Fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                    Label.Text = text .. "  " .. value
                    if callback then callback(value) end
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        Update(min + (max - min) * rel)
                    end
                end)

                return {Set = Update, Get = function() return value end}
            end

            return API
        end

        return Tab
    end

    return Window
end

return JapanLibrary
