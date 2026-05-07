-- Astro #rylax0322 - Custom UI Edition
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local VIS = game:GetService("VirtualInputService")
local Network = require(RS.Modules.Communication.Network)
local lp = Players.LocalPlayer

-- Services
local qte = lp.PlayerGui:WaitForChild("QTE")
local main = qte:WaitForChild("Main")
local line = main:WaitForChild("Line")
local bars = main:WaitForChild("Bars")

-- Settings
local methods = {
    method1 = false,
    method2 = false,
    method3 = false,
    method4 = false
}
local threshold = 5
local cooldown = 0.15
local lastTap = 0
local lastBar = nil
local hasPassed = false
local lastRotation = nil
local rotationSpeed = 0
local eventDelay = 0.5
local finishDelay = 0.01
local targetRarities = {Legendary = true}
local findMode = "Normal"
local normalWorker = 20
local foundLog = {}
local skipLog = {}
local isFinishing = false
local autoBrutal = false
local brutalWorker = 60
local brutalFoundLog = {}
local brutalSkipLog = {}
local brutalFinishing = false
local protectEnabled = false
local customName = "Milik sendiri"

-- Utility Functions
local function getBar()
    for _, b in pairs(bars:GetChildren()) do
        if b:IsA("ImageLabel") and b.Visible then
            return b
        end
    end
end

local function tap()
    local pos = main.AbsolutePosition + main.AbsoluteSize / 2
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.04)
    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    task.wait(0.1)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function isTargetRarity(rarity)
    return targetRarities[rarity] == true
end

local function protectIdentity()
    if not protectEnabled then return end
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.Name = customName
    end
    if lp.Character then
        for _, part in ipairs(lp.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = Color3.new(0, 0, 0)
            end
        end
    end
end

-- Method 2
local function startMethod2()
    task.spawn(function()
        while methods.method2 do
            pcall(function()
                local args1 = {buffer.fromstring("\016"), [3] = 16}
                RS:WaitForChild("ByteNetQuery"):InvokeServer(unpack(args1, 1, 3))
            end)
            task.wait(eventDelay)
            pcall(function()
                local args2 = {buffer.fromstring("*\001\002\000\002\000")}
                RS:WaitForChild("ByteNetReliable"):FireServer(unpack(args2))
            end)
            task.wait(finishDelay)
        end
    end)
end

-- Method 3
local function instantCollect()
    pcall(function()
        local args1 = {buffer.fromstring("\016"), [3] = 16}
        RS:WaitForChild("ByteNetQuery"):InvokeServer(unpack(args1, 1, 3))
    end)
    for i = 1, 15 do
        pcall(function()
            local args2 = {buffer.fromstring("*\001\002\000\002\000")}
            RS:WaitForChild("ByteNetReliable"):FireServer(unpack(args2))
        end)
    end
end

local function startMethod3()
    task.spawn(function()
        while methods.method3 do
            if isFinishing then task.wait(0.05) continue end
            pcall(function()
                local result = Network.QTE.queries.StartQTE.invoke()
                if result and result.rarity then
                    local rarity = result.rarity
                    if isTargetRarity(rarity) and not isFinishing then
                        isFinishing = true
                        table.insert(foundLog, 1, "FOUND: "..rarity)
                        instantCollect()
                        isFinishing = false
                    else
                        if not isFinishing then
                            table.insert(skipLog, 1, rarity)
                            Network.QTE.packets.CancelQTE.send()
                        end
                    end
                end
            end)
            task.wait(0.01)
        end
    end)
end

-- Method 4
local function brutalInstantCollect()
    pcall(function()
        local args1 = {buffer.fromstring("\016"), [3] = 16}
        RS:WaitForChild("ByteNetQuery"):InvokeServer(unpack(args1, 1, 3))
    end)
    for i = 1, 25 do
        pcall(function()
            local args2 = {buffer.fromstring("*\001\002\000\002\000")}
            RS:WaitForChild("ByteNetReliable"):FireServer(unpack(args2))
        end)
    end
end

local function startMethod4()
    task.spawn(function()
        while autoBrutal do
            if brutalFinishing then task.wait(0.005) continue end
            pcall(function()
                local result = Network.QTE.queries.StartQTE.invoke()
                if result and result.rarity then
                    local rarity = result.rarity
                    if isTargetRarity(rarity) and not brutalFinishing then
                        brutalFinishing = true
                        table.insert(brutalFoundLog, 1, "FOUND: "..rarity)
                        brutalInstantCollect()
                        brutalFinishing = false
                    else
                        if not brutalFinishing then
                            table.insert(brutalSkipLog, 1, rarity)
                            Network.QTE.packets.CancelQTE.send()
                        end
                    end
                end
            end)
            task.wait(0.005)
        end
    end)
end

-- ==================== CUSTOM UI ====================
local function createSmoothUI()
    local old = CoreGui:FindFirstChild("AstroUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AstroUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = false

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 16)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(100, 140, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.5

    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel", MainFrame)
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    Shadow.ZIndex = -1

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TopBar.BorderSizePixel = 0

    local TopCorner = Instance.new("UICorner", TopBar)
    TopCorner.CornerRadius = UDim.new(0, 16)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ Astro #rylax0322"
    Title.TextColor3 = Color3.fromRGB(140, 170, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TopBar
    MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    MinimizeBtn.Position = UDim2.new(1, -40, 0, 6)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold

    local BtnCorner = Instance.new("UICorner", MinimizeBtn)
    BtnCorner.CornerRadius = UDim.new(0, 10)

    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.Size = UDim2.new(1, 0, 1, -44)
    ContentFrame.Position = UDim2.new(0, 0, 0, 44)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0

    -- Scrolling Frame
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Parent = ContentFrame
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 3
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 140, 255)
    ScrollingFrame.BottomImage = ""
    ScrollingFrame.TopImage = ""

    local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local UIPadding = Instance.new("UIPadding", ScrollingFrame)
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)

    -- Function to create tab
    local currentTab = nil
    local tabButtons = {}
    local tabContents = {}

    local function createTabButton(name, order)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name.."_TabBtn"
        TabBtn.Parent = TopBar
        TabBtn.Size = UDim2.new(0, 60, 0, 28)
        TabBtn.Position = UDim2.new(0, 60 + (order-1)*64, 0, 8)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.BorderSizePixel = 0
        return TabBtn
    end

    -- Create tab contents
    local Tab1 = Instance.new("Frame")
    Tab1.Name = "Tab1"
    Tab1.Parent = ScrollingFrame
    Tab1.Size = UDim2.new(1, -20, 0, 0)
    Tab1.BackgroundTransparency = 1
    Tab1.BorderSizePixel = 0

    local Tab2 = Instance.new("Frame")
    Tab2.Name = "Tab2"
    Tab2.Parent = ScrollingFrame
    Tab2.Size = UDim2.new(1, -20, 0, 0)
    Tab2.BackgroundTransparency = 1
    Tab2.BorderSizePixel = 0
    Tab2.Visible = false

    local Tab3 = Instance.new("Frame")
    Tab3.Name = "Tab3"
    Tab3.Parent = ScrollingFrame
    Tab3.Size = UDim2.new(1, -20, 0, 0)
    Tab3.BackgroundTransparency = 1
    Tab3.BorderSizePixel = 0
    Tab3.Visible = false

    local Tab4 = Instance.new("Frame")
    Tab4.Name = "Tab4"
    Tab4.Parent = ScrollingFrame
    Tab4.Size = UDim2.new(1, -20, 0, 0)
    Tab4.BackgroundTransparency = 1
    Tab4.BorderSizePixel = 0
    Tab4.Visible = false

    local Tab5 = Instance.new("Frame")
    Tab5.Name = "Tab5"
    Tab5.Parent = ScrollingFrame
    Tab5.Size = UDim2.new(1, -20, 0, 0)
    Tab5.BackgroundTransparency = 1
    Tab5.BorderSizePixel = 0
    Tab5.Visible = false

    -- Tab buttons
    local Btn1 = createTabButton("Dig1", 1)
    local Btn2 = createTabButton("Dig2", 2)
    local Btn3 = createTabButton("Find", 3)
    local Btn4 = createTabButton("Brutal", 4)
    local Btn5 = createTabButton("Safe", 5)

    Btn1.MouseButton1Click:Connect(function()
        Tab1.Visible = true Tab2.Visible = false Tab3.Visible = false Tab4.Visible = false Tab5.Visible = false
        Btn1.TextColor3 = Color3.fromRGB(140, 170, 255) Btn2.TextColor3 = Color3.fromRGB(150, 150, 170) Btn3.TextColor3 = Color3.fromRGB(150, 150, 170) Btn4.TextColor3 = Color3.fromRGB(150, 150, 170) Btn5.TextColor3 = Color3.fromRGB(150, 150, 170)
    end)
    Btn2.MouseButton1Click:Connect(function()
        Tab1.Visible = false Tab2.Visible = true Tab3.Visible = false Tab4.Visible = false Tab5.Visible = false
        Btn1.TextColor3 = Color3.fromRGB(150, 150, 170) Btn2.TextColor3 = Color3.fromRGB(140, 170, 255) Btn3.TextColor3 = Color3.fromRGB(150, 150, 170) Btn4.TextColor3 = Color3.fromRGB(150, 150, 170) Btn5.TextColor3 = Color3.fromRGB(150, 150, 170)
    end)
    Btn3.MouseButton1Click:Connect(function()
        Tab1.Visible = false Tab2.Visible = false Tab3.Visible = true Tab4.Visible = false Tab5.Visible = false
        Btn1.TextColor3 = Color3.fromRGB(150, 150, 170) Btn2.TextColor3 = Color3.fromRGB(150, 150, 170) Btn3.TextColor3 = Color3.fromRGB(140, 170, 255) Btn4.TextColor3 = Color3.fromRGB(150, 150, 170) Btn5.TextColor3 = Color3.fromRGB(150, 150, 170)
    end)
    Btn4.MouseButton1Click:Connect(function()
        Tab1.Visible = false Tab2.Visible = false Tab3.Visible = false Tab4.Visible = true Tab5.Visible = false
        Btn1.TextColor3 = Color3.fromRGB(150, 150, 170) Btn2.TextColor3 = Color3.fromRGB(150, 150, 170) Btn3.TextColor3 = Color3.fromRGB(150, 150, 170) Btn4.TextColor3 = Color3.fromRGB(140, 170, 255) Btn5.TextColor3 = Color3.fromRGB(150, 150, 170)
    end)
    Btn5.MouseButton1Click:Connect(function()
        Tab1.Visible = false Tab2.Visible = false Tab3.Visible = false Tab4.Visible = false Tab5.Visible = true
        Btn1.TextColor3 = Color3.fromRGB(150, 150, 170) Btn2.TextColor3 = Color3.fromRGB(150, 150, 170) Btn3.TextColor3 = Color3.fromRGB(150, 150, 170) Btn4.TextColor3 = Color3.fromRGB(150, 150, 170) Btn5.TextColor3 = Color3.fromRGB(140, 170, 255)
    end)

    -- Helper function to create sections and toggles
    local function createSection(parent, title)
        local Section = Instance.new("Frame")
        Section.Name = title.."_Section"
        Section.Parent = parent
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        Section.BorderSizePixel = 0

        local SecCorner = Instance.new("UICorner", Section)
        SecCorner.CornerRadius = UDim.new(0, 12)

        local SecTitle = Instance.new("TextLabel")
        SecTitle.Name = "SecTitle"
        SecTitle.Parent = Section
        SecTitle.Size = UDim2.new(1, -16, 0, 28)
        SecTitle.Position = UDim2.new(0, 8, 0, 6)
        SecTitle.BackgroundTransparency = 1
        SecTitle.Text = title
        SecTitle.TextColor3 = Color3.fromRGB(140, 170, 255)
        SecTitle.TextSize = 13
        SecTitle.Font = Enum.Font.GothamBold
        SecTitle.TextXAlignment = Enum.TextXAlignment.Left

        local UIPad = Instance.new("UIPadding", Section)
        UIPad.PaddingTop = UDim.new(0, 34)
        UIPad.PaddingBottom = UDim.new(0, 8)

        local UIList = Instance.new("UIListLayout", Section)
        UIList.Padding = UDim.new(0, 6)
        UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local function addToggle(name, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = name.."_Toggle"
            ToggleFrame.Parent = Section
            ToggleFrame.Size = UDim2.new(1, -16, 0, 36)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.BorderSizePixel = 0

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "Btn"
            ToggleBtn.Parent = ToggleFrame
            ToggleBtn.Size = UDim2.new(0, 44, 0, 24)
            ToggleBtn.Position = UDim2.new(1, -44, 0, 6)
            ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(40, 40, 60)
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false

            local ToggleDot = Instance.new("Frame")
            ToggleDot.Name = "Dot"
            ToggleDot.Parent = ToggleBtn
            ToggleDot.Size = UDim2.new(0, 20, 0, 20)
            ToggleDot.Position = default and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
            ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleDot.BorderSizePixel = 0

            local ToggleCorner = Instance.new("UICorner", ToggleBtn)
            ToggleCorner.CornerRadius = UDim.new(0, 12)
            local DotCorner = Instance.new("UICorner", ToggleDot)
            DotCorner.CornerRadius = UDim.new(0, 10)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.Size = UDim2.new(1, -52, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 8, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = name
            ToggleLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.GothamSemibold
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local function setState(state)
                local goal = state and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
                local colorGoal = state and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(40, 40, 60)
                TweenService:Create(ToggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = goal}):Play()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = colorGoal}):Play()
            end

            local enabled = default
            ToggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                setState(enabled)
                callback(enabled)
            end)

            return ToggleFrame
        end

        local function addSlider(name, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = name.."_Slider"
            SliderFrame.Parent = Section
            SliderFrame.Size = UDim2.new(1, -16, 0, 50)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.BorderSizePixel = 0

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Parent = SliderFrame
            SliderLabel.Size = UDim2.new(1, 0, 0, 20)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = name .. ": " .. default
            SliderLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
            SliderLabel.TextSize = 12
            SliderLabel.Font = Enum.Font.GothamSemibold
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "Bar"
            SliderBar.Parent = SliderFrame
            SliderBar.Size = UDim2.new(1, 0, 0, 6)
            SliderBar.Position = UDim2.new(0, 0, 0, 28)
            SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            SliderBar.BorderSizePixel = 0

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Parent = SliderBar
            local percent = (default - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
            SliderFill.BorderSizePixel = 0

            local SliderDot = Instance.new("Frame")
            SliderDot.Name = "Dot"
            SliderDot.Parent = SliderFill
            SliderDot.Size = UDim2.new(0, 14, 0, 14)
            SliderDot.Position = UDim2.new(1, -7, 0.5, -7)
            SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderDot.BorderSizePixel = 0

            local BarCorner = Instance.new("UICorner", SliderBar)
            BarCorner.CornerRadius = UDim.new(0, 3)
            local FillCorner = Instance.new("UICorner", SliderFill)
            FillCorner.CornerRadius = UDim.new(0, 3)
            local DotCorner = Instance.new("UICorner", SliderDot)
            DotCorner.CornerRadius = UDim.new(0, 7)

            local function updateSlider(input)
                local barSize = SliderBar.AbsoluteSize.X
                local mouseX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, barSize)
                local percent = mouseX / barSize
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(min + (max - min) * percent)
                SliderLabel.Text = name .. ": " .. value
                callback(value)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            -- release
                        end
                    end)
                end
            end)

            local dragging = false
            SliderBar.MouseButton1Down:Connect(function()
                dragging = true
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            return SliderFrame
        end

        local function addButton(name, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = name.."_Btn"
            ButtonFrame.Parent = Section
            ButtonFrame.Size = UDim2.new(1, -16, 0, 36)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.BorderSizePixel = 0

            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Parent = ButtonFrame
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            Button.BorderSizePixel = 0
            Button.Text = name
            Button.TextColor3 = Color3.fromRGB(140, 170, 255)
            Button.TextSize = 13
            Button.Font = Enum.Font.GothamBold

            local BtnCorner = Instance.new("UICorner", Button)
            BtnCorner.CornerRadius = UDim.new(0, 10)

            Button.MouseButton1Click:Connect(callback)

            return ButtonFrame
        end

        return {
            addToggle = addToggle,
            addSlider = addSlider,
            addButton = addButton,
            Section = Section,
        }
    end

    -- Minimize Logic
    local minimized = false
    local originalSize = MainFrame.Size
    local originalPos = MainFrame.Position
    local originalContentSize = ContentFrame.Size
    local originalTopSize = TopBar.Size

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 320, 0, 44)}):Play()
            ContentFrame.Visible = false
            MinimizeBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = originalSize}):Play()
            ContentFrame.Visible = true
            MinimizeBtn.Text = "—"
        end
    end)

    -- Drag functionality
    local dragging = false
    local dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if startPos then
                TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset)}):Play()
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)

    -- ==================== POPULATE TABS ====================

    -- Tab 1: Method 1
    local sec1 = createSection(Tab1, "Manual 80% Perfect")
    sec1.addToggle("Enable Perfect Tap", false, function(v)
        methods.method1 = v
        if not v then
            lastBar = nil; hasPassed = false; lastRotation = nil
        end
    end)
    sec1.addSlider("Threshold", 3, 20, 5, function(v) threshold = v end)
    sec1.addSlider("Cooldown", 0.05, 0.5, 0.15, function(v) cooldown = v end)

    -- Tab 2: Method 2
    local sec2 = createSection(Tab2, "Instant Dig Blatant")
    sec2.addToggle("Enable Instant Dig", false, function(v)
        methods.method2 = v
        if v then startMethod2() end
    end)
    sec2.addSlider("Start Delay", 0.1, 5, 0.5, function(v) eventDelay = v end)
    sec2.addSlider("Finish Delay", 0.01, 0.5, 0.01, function(v) finishDelay = v end)

    -- Tab 3: Method 3
    local sec3 = createSection(Tab3, "Find Rarity")
    sec3.addToggle("Enable Find Rarity", false, function(v)
        methods.method3 = v
        if v then startMethod3() end
    end)
    for _, r in ipairs({"Rare", "Epic", "Legendary", "Mythic", "Exotic"}) do
        sec3.addToggle("Target: "..r, r == "Legendary", function(v) targetRarities[r] = v end)
    end
    sec3.addSlider("Worker Count", 1, 20, 20, function(v) normalWorker = v end)

    -- Tab 4: Method 4
    local sec4 = createSection(Tab4, "Brutal Dupe Mode")
    sec4.addToggle("Enable Brutal Mode", false, function(v)
        autoBrutal = v
        if v then startMethod4() end
    end)
    sec4.addSlider("Worker Count", 1, 100, 60, function(v) brutalWorker = v end)

    -- Tab 5: Protection
    local sec5 = createSection(Tab5, "Identity Protection")
    sec5.addToggle("Enable Protection", false, function(v) protectEnabled = v end)
    sec5.addButton("Apply Protection Now", protectIdentity)
    sec5.addSlider("Min Level", 1, 1000, 100, function(v) end)
    sec5.addSlider("Max Level", 1, 1000, 999, function(v) end)

    -- Auto-update UI sizes
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local totalHeight = 10
                for _, child in ipairs(ScrollingFrame:GetChildren()) do
                    if child:IsA("Frame") and child.Visible then
                        totalHeight = totalHeight + 10
                        for _, element in ipairs(child:GetChildren()) do
                            if element:IsA("Frame") then
                                totalHeight = totalHeight + element.Size.Y.Offset + 6
                            end
                        end
                    end
                end
                ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            end)
        end
    end)

    -- Initial tab setup
    Btn1.TextColor3 = Color3.fromRGB(140, 170, 255)
    Tab1.Visible = true
    Tab2.Visible = false
    Tab3.Visible = false
    Tab4.Visible = false
    Tab5.Visible = false

end

-- ==================== MAIN LOOP ====================

-- Method 1 Rendering
RunService.RenderStepped:Connect(function()
    if methods.method1 and qte.Enabled then
        pcall(function()
            local bar = getBar()
            if not bar then return end
            if bar ~= lastBar then
                hasPassed = false
                lastBar = bar
                lastRotation = nil
            end
            local br = bar.Rotation % 360
            if br < 0 then br = br + 360 end
            if lastRotation then
                rotationSpeed = math.abs(br - lastRotation)
                if rotationSpeed > 180 then rotationSpeed = 360 - rotationSpeed end
            end
            lastRotation = br
            local lr = line.Rotation % 360
            if lr < 0 then lr = lr + 360 end
            local diff = math.abs((br - lr) % 360)
            if diff > 180 then diff = 360 - diff end
            if diff > 25 then hasPassed = true end
            local predicted = diff - (rotationSpeed * 0.03)
            if hasPassed and predicted <= threshold and tick() - lastTap >= cooldown then
                lastTap = tick()
                hasPassed = false
                task.spawn(tap)
            end
        end)
    end
end)

-- Protect Identity Loop
task.spawn(function()
    while task.wait(2) do
        protectIdentity()
    end
end)

-- ==================== LOAD UI ====================
createSmoothUI()

print("Astro #rylax0322 - Custom UI Loaded!")
