local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}

-- [[ THEME CONFIGURATION ]]
local Theme = {
    Background = Color3.fromRGB(9, 9, 13),
    Sidebar = Color3.fromRGB(7, 15, 25),
    Section = Color3.fromRGB(0, 20, 40),
    Element = Color3.fromRGB(30, 45, 70), 
    ElementHover = Color3.fromRGB(40, 55, 80),
    Accent = Color3.fromRGB(61, 133, 224), -- "Neverlose Blue"
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Outline = Color3.fromRGB(0, 0, 0)
}

-- [[ UTILITY FUNCTIONS ]]
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        TweenService:Create(object, TweenInfo.new(0.15), {Position = pos}):Play()
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

-- [[ MAIN LIBRARY ]]

function Library:CreateWindow(options)
    local Name = options.Name or "Neverlose UI"
    local Keybind = options.Keybind or Enum.KeyCode.RightControl

    -- Destroy old instance if exists
    if CoreGui:FindFirstChild("NeverloseUI") then
        CoreGui.NeverloseUI:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "NeverloseUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -325, 0.5, -250),
        Size = UDim2.new(0, 650, 0, 500),
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})

    -- Top Bar / Drag Area
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(0,0,0), -- Invisible basically, just for drag
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40)
    })
    MakeDraggable(TopBar, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, 0)
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 6)})
    -- Fix corner on right side being rounded
    local SidebarCover = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0)
    })

    -- Title
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(0, 140, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = Name,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tab Container
    local TabContainer = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60)
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    -- Content Container
    local ContentContainer = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 190, 0, 10),
        Size = UDim2.new(0, 450, 1, -20)
    })

    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(name, iconId)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Sidebar, -- Transparent usually
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            Text = "",
            AutoButtonColor = false
        })

        local TabLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local TabContent = Create("ScrollingFrame", {
            Name = name.."Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false
        })
        Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local function Activate()
            for _, child in pairs(ContentContainer:GetChildren()) do
                child.Visible = false
            end
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                     TweenService:Create(child.TextLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
                end
            end
            TabContent.Visible = true
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Accent}):Play()
        end

        TabButton.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        function Tab:CreateSection(sectionName)
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(1, -5, 0, 30), 
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 5)})
            
            local SectionLayout = Create("UIListLayout", {
                Parent = SectionFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
            Create("UIPadding", {
                Parent = SectionFrame,
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })

            local SectionTitle = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = -1
            })

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, -5, 0, SectionLayout.AbsoluteContentSize.Y + 20)
                local totalHeight = 0
                for _, c in pairs(TabContent:GetChildren()) do
                    if c:IsA("Frame") then
                        totalHeight = totalHeight + c.AbsoluteSize.Y + 10
                    end
                end
                TabContent.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            end)

            function Section:CreateToggle(toggleName, callback)
                local Toggled = false
                local ToggleFrame = Create("TextButton", {
                    Parent = SectionFrame,
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 30),
                    Text = "",
                    AutoButtonColor = false
                })

                local ToggleText = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 200, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleName,
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ToggleIndicator = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Position = UDim2.new(1, -40, 0.5, -7),
                    Size = UDim2.new(0, 30, 0, 14)
                })
                Create("UICorner", {Parent = ToggleIndicator, CornerRadius = UDim.new(1, 0)})

                local ToggleCircle = Create("Frame", {
                    Parent = ToggleIndicator,
                    BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                    Position = UDim2.new(0, 2, 0.5, -5),
                    Size = UDim2.new(0, 10, 0, 10)
                })
                Create("UICorner", {Parent = ToggleCircle, CornerRadius = UDim.new(1, 0)})

                ToggleFrame.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    callback(Toggled)

                    if Toggled then
                        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Theme.Text}):Play()
                        TweenService:Create(ToggleText, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
                    else
                        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                        TweenService:Create(ToggleText, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
                    end
                end)
            end

            function Section:CreateSlider(sliderName, min, max, default, callback)
                local Value = default or min
                
                local SliderFrame = Create("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 45)
                })

                local SliderText = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderName,
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(Value),
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderTrack = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                Create("UICorner", {Parent = SliderTrack, CornerRadius = UDim.new(1, 0)})

                local SliderFill = Create("Frame", {
                    Parent = SliderTrack,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(1, 0)})

                local Dragging = false

                local function UpdateSlider(input)
                    local SizeX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(min + ((max - min) * SizeX))
                    Value = NewValue
                    ValueLabel.Text = tostring(Value)
                    SliderFill.Size = UDim2.new(SizeX, 0, 1, 0)
                    callback(Value)
                end

                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
            end

            function Section:CreateButton(buttonText, callback)
                local ButtonFrame = Create("TextButton", {
                    Parent = SectionFrame,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -20, 0, 30),
                    AutoButtonColor = false,
                    Text = "",
                })
                Create("UICorner", {Parent = ButtonFrame, CornerRadius = UDim.new(0, 5)})
                Create("UIStroke", {Parent = ButtonFrame, Color = Theme.Outline, Thickness = 1})

                local Label = Create("TextLabel", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = buttonText,
                    TextColor3 = Theme.Text,
                    TextSize = 13
                })

                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
                end)
                ButtonFrame.MouseButton1Click:Connect(function()
                    callback()
                end)
            end

            function Section:CreateDropdown(dropdownName, options, callback)
                local Dropdown = {}
                local Expanded = false
                
                local DropdownFrame = Create("TextButton", {
                    Parent = SectionFrame,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -20, 0, 35),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 5)})
                
                local DropdownLabel = Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = dropdownName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Arrow = Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 30, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = "v",
                    TextColor3 = Theme.TextDim,
                    TextSize = 13
                })

                local OptionsFrame = Create("Frame", {
                    Parent = SectionFrame,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -20, 0, 0),
                    Visible = false,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = OptionsFrame, CornerRadius = UDim.new(0, 5)})
                
                local OptionsLayout = Create("UIListLayout", {
                    Parent = OptionsFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })

                DropdownFrame.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    OptionsFrame.Visible = Expanded
                    
                    if Expanded then
                        Arrow.Text = "^"
                        Arrow.TextColor3 = Theme.Accent
                        local count = 0
                        for _, v in pairs(OptionsFrame:GetChildren()) do
                            if v:IsA("TextButton") then count = count + 1 end
                        end
                        OptionsFrame.Size = UDim2.new(1, -20, 0, count * 25 + 5)
                    else
                        Arrow.Text = "v"
                        Arrow.TextColor3 = Theme.TextDim
                        OptionsFrame.Size = UDim2.new(1, -20, 0, 0)
                    end
                end)

                for _, option in pairs(options) do
                    local OptionBtn = Create("TextButton", {
                        Parent = OptionsFrame,
                        BackgroundColor3 = Theme.Element,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Theme.TextDim,
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        DropdownLabel.Text = dropdownName .. ": " .. option
                        callback(option)
                        Expanded = false
                        OptionsFrame.Visible = false
                        OptionsFrame.Size = UDim2.new(1, -20, 0, 0)
                        Arrow.Text = "v"
                    end)
                end
            end

            return Section
        end

        return Tab
    end

    function Library:Notify(config)
        print("[Neverlose Notification] " .. (config.Title or "") .. ": " .. (config.Text or ""))
    end

    return Window
end

return Library
