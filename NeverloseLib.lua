local Library = {
    Version = "1.1.0",
    AccentColor = Color3.fromRGB(255, 255, 255),
    ThemeObjects = {}
}
Library.__index = Library

print("SoftUI Library Loaded | Version: " .. Library.Version)

local function UpdateTabColors()
    for _, obj in pairs(Library.ThemeObjects) do
        if obj.Type == "Tab" then
            if obj.Page.Visible then
                obj.Instance.TextColor3 = Library.AccentColor
            else
                obj.Instance.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end
end

function Library:ChangeAccent(color)
    Library.AccentColor = color
    for _, obj in pairs(Library.ThemeObjects) do
        if obj.Type == "Background" then
            obj.Instance.BackgroundColor3 = color
        elseif obj.Type == "Toggle" and obj.GetState() then
            obj.Instance.BackgroundColor3 = color
        elseif obj.Type == "Slider" then
            obj.Instance.BackgroundColor3 = color
            obj.Label.TextColor3 = color
        elseif obj.Type == "Tab" then
            UpdateTabColors()
        end
    end
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function New(class, properties, children)
    local instance = Instance.new(class)
    local parent = properties.Parent
    properties.Parent = nil
    
    for property, value in pairs(properties) do
        instance[property] = value
    end
    
    if children then
        for _, child in pairs(children) do
            child.Parent = instance
        end
    end
    
    instance.Parent = parent
    return instance
end

function Library:Init(config)
    config = config or {}
    local title = config.Title or "Soft UI"
    if config.AccentColor then
        Library.AccentColor = config.AccentColor
    end
    
    local ScreenGui = New("ScreenGui", {
        Name = "SoftUI_Loading",
        Parent = CoreGui,
        IgnoreGuiInset = true
    })

    local Main = New("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- True Black
        BorderSizePixel = 0,
        Parent = ScreenGui,
        ClipsDescendants = true
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 12) }),
        New("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 2 })
    })

    local TitleLabel = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = Main
    })

    local BarBG = New("Frame", {
        Size = UDim2.new(0.8, 0, 0, 6),
        Position = UDim2.new(0.5, 0, 0.7, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent = Main
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local Bar = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Parent = BarBG
    }, {
        New("UICorner", { CornerRadius = UDim.new(1, 0) }),
        New("UIGradient", { Color = ColorSequence.new(Library.AccentColor, Color3.fromRGB(Library.AccentColor.R*255+30, Library.AccentColor.G*255+30, Library.AccentColor.B*255+30)) })
    })

    -- Animation
    Main.BackgroundTransparency = 1
    TitleLabel.TextTransparency = 1
    BarBG.BackgroundTransparency = 1
    
    TweenService:Create(Main, TweenInfo.new(1), { BackgroundTransparency = 0.1 }):Play()
    TweenService:Create(TitleLabel, TweenInfo.new(1), { TextTransparency = 0 }):Play()
    TweenService:Create(BarBG, TweenInfo.new(1), { BackgroundTransparency = 0 }):Play()
    
    task.wait(1)
    
    local tween = TweenService:Create(Bar, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
    tween:Play()
    tween.Completed:Wait()
    
    task.wait(0.5)
    
    local fadeOut = TweenService:Create(Main, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    ScreenGui:Destroy()
end

function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}

    local ScreenGui = New("ScreenGui", {
        Name = "SoftUI",
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    local MainFrame = New("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- True Black
        BorderSizePixel = 0,
        BackgroundTransparency = 0.05,
        Parent = ScreenGui
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 12) }),
        New("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 2 })
    })

    -- Top bar (Draggable)
    local TopBar = New("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    New("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 18,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    -- Draggable Functionality
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
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
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local Sidebar = New("ScrollingFrame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 130, 1, -110),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    }, { New("UIListLayout", { Padding = UDim.new(0, 5) }) })

    -- Profile Section (Discord-like)
    local Player = game:GetService("Players").LocalPlayer
    local ProfileFrame = New("Frame", {
        Name = "ProfileFrame",
        Size = UDim2.new(0, 120, 0, 50),
        Position = UDim2.new(0, 10, 1, -60),
        BackgroundColor3 = Color3.fromRGB(15,15,15), -- Slightly lighter black for depth
        Parent = MainFrame
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        New("UIStroke", { Color = Color3.fromRGB(45,45,45), Thickness = 1 })
    })

    local Avatar = New("ImageLabel", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        Image = "rbxthumb://type=AvatarHeadShot&id="..Player.UserId.."&w=150&h=150",
        Parent = ProfileFrame
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    New("TextLabel", {
        Size = UDim2.new(1, -50, 0.5, 0),
        Position = UDim2.new(0, 45, 0.2, 0),
        BackgroundTransparency = 1,
        Text = Player.DisplayName,
        TextColor3 = Color3.fromRGB(240,240,240),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ProfileFrame
    })

    New("TextLabel", {
        Size = UDim2.new(1, -50, 0.5, 0),
        Position = UDim2.new(0, 45, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "@"..Player.Name,
        TextColor3 = Color3.fromRGB(150,150,150),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ProfileFrame
    })

    -- Content Area
    local ContentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -145, 1, -50),
        Position = UDim2.new(0, 140, 0, 45),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    function Window:CreateTab(name)
        local Tab = { Elements = {} }
        
        local TabButton = New("TextButton", {
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 0.5,
            Text = name,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = Sidebar
        }, { New("UICorner", { CornerRadius = UDim.new(0, 6) }) })

        local Page = New("ScrollingFrame", {
            Name = "Page_"..name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 5,
            Parent = ContentArea
        }, { 
            New("UIListLayout", { 
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            })
        })

        table.insert(Library.ThemeObjects, { Type = "Tab", Instance = TabButton, Page = Page })

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(10,10,10), TextColor3 = Color3.fromRGB(150,150,150) }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(20,20,20), TextColor3 = Library.AccentColor }):Play()
        end)

        if #Window.Tabs == 0 then
            task.spawn(function()
                task.wait(0.1) -- small delay to ensure rendering
                Page.Visible = true
                TabButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
                TabButton.TextColor3 = Library.AccentColor
            end)
        end

        function Tab:CreateButton(text, callback)
            local Btn = New("TextButton", {
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                AutoButtonColor = false,
                ZIndex = 6,
                Parent = Page
            }, { New("UICorner", { CornerRadius = UDim.new(0, 8) }) })

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
            end)
            Btn.MouseButton1Click:Connect(function()
                Btn.TextSize = 12
                TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextSize = 14 }):Play()
                callback()
            end)
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local ToggleFrame = New("Frame", {
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                ZIndex = 6,
                Parent = Page
            }, { New("UICorner", { CornerRadius = UDim.new(0, 8) }) })

            New("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })

            local SwitchBG = New("Frame", {
                Size = UDim2.new(0, 35, 0, 20),
                Position = UDim2.new(1, -45, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = state and Library.AccentColor or Color3.fromRGB(60, 60, 60),
                Parent = ToggleFrame
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Circle = New("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SwitchBG
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local ClickBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ToggleFrame
            })

            table.insert(Library.ThemeObjects, { 
                Type = "Toggle", 
                Instance = SwitchBG, 
                GetState = function() return state end 
            })

            ClickBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(SwitchBG, TweenInfo.new(0.3), { BackgroundColor3 = state and Library.AccentColor or Color3.fromRGB(60, 60, 60) }):Play()
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
                callback(state)
            end)
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local SliderFrame = New("Frame", {
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                ZIndex = 6,
                Parent = Page
            }, { New("UICorner", { CornerRadius = UDim.new(0, 8) }) })

            New("TextLabel", {
                Size = UDim2.new(1, -60, 0, 30),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })

            local ValueLabel = New("TextLabel", {
                Size = UDim2.new(0, 40, 0, 30),
                Position = UDim2.new(1, -55, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = Library.AccentColor,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                Parent = SliderFrame
            })

            local SliderBG = New("Frame", {
                Size = UDim2.new(1, -30, 0, 4),
                Position = UDim2.new(0.5, 0, 0.8, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Parent = SliderFrame
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local SliderBar = New("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Library.AccentColor,
                Parent = SliderBG
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            table.insert(Library.ThemeObjects, { 
                Type = "Slider", 
                Instance = SliderBar, 
                Label = ValueLabel 
            })

            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(val)
                TweenService:Create(SliderBar, TweenInfo.new(0.1), { Size = UDim2.new(pos, 0, 1, 0) }):Play()
                callback(val)
            end

            local dragging = false
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            SliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end

        function Tab:CreateColorPicker(text, default, callback)
            local CPFrame = New("Frame", {
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                ZIndex = 6,
                Parent = Page
            }, { New("UICorner", { CornerRadius = UDim.new(0, 8) }) })

            New("TextLabel", {
                Size = UDim2.new(1, -60, 0, 30),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = CPFrame
            })

            local ColorPreview = New("Frame", {
                Size = UDim2.new(0, 32, 0, 20),
                Position = UDim2.new(1, -45, 0, 5),
                BackgroundColor3 = default,
                Parent = CPFrame
            }, { New("UICorner", { CornerRadius = UDim.new(0, 4) }) })

            local HueSliderBG = New("Frame", {
                Size = UDim2.new(1, -30, 0, 10),
                Position = UDim2.new(0.5, 0, 0.8, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 0,
                Parent = CPFrame
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 4) }),
                New("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, 1)),
                        ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, 1)),
                        ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, 1)),
                        ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                    })
                })
            })

            local HueCursor = New("Frame", {
                Size = UDim2.new(0, 4, 1, 4),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = HueSliderBG
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local function Update(input)
                local pos = math.clamp((input.Position.X - HueSliderBG.AbsolutePosition.X) / HueSliderBG.AbsoluteSize.X, 0, 1)
                local color = Color3.fromHSV(pos, 1, 1)
                HueCursor.Position = UDim2.new(pos, 0, 0.5, 0)
                ColorPreview.BackgroundColor3 = color
                callback(color)
            end

            local dragging = false
            CPFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            CPFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end

        table.insert(Window.Tabs, { Button = TabButton, Page = Page })
        return Tab
    end

    return Window
end

return Library
