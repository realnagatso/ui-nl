local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function New(class, properties, children)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function Library:Init(config)
    config = config or {}
    local title = config.Title or "Soft UI"
    
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
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
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
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        BorderSizePixel = 0,
        Parent = BarBG
    }, {
        New("UICorner", { CornerRadius = UDim.new(1, 0) }),
        New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(100, 150, 255), Color3.fromRGB(150, 100, 255)) })
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
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.1,
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
        Size = UDim2.new(0, 130, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = MainFrame
    }, { New("UIListLayout", { Padding = UDim.new(0, 5) }) })

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
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
            Parent = ContentArea
        }, { New("UIListLayout", { Padding = UDim.new(0, 8) }) })

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(30,30,30), TextColor3 = Color3.fromRGB(150,150,150) }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(50,50,50), TextColor3 = Color3.fromRGB(255,255,255) }):Play()
        end)

        if #Window.Tabs == 0 then
            Page.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
            TabButton.TextColor3 = Color3.fromRGB(255,255,255)
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
                BackgroundColor3 = state and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(60, 60, 60),
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

            ClickBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(SwitchBG, TweenInfo.new(0.3), { BackgroundColor3 = state and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(60, 60, 60) }):Play()
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
                callback(state)
            end)
        end

        table.insert(Window.Tabs, { Button = TabButton, Page = Page })
        return Tab
    end

    return Window
end

return Library
