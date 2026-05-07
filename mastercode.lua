-- Astro #rylax0322 - Fixed UI Edition
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Network = require(RS.Modules.Communication.Network)
local lp = Players.LocalPlayer

-- Services
local qte = lp.PlayerGui:WaitForChild("QTE")
local main = qte:WaitForChild("Main")
local line = main:WaitForChild("Line")
local bars = main:WaitForChild("Bars")

-- Settings
local methods = {method1 = false, method2 = false, method3 = false, method4 = false}
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

-- Utility
local function getBar()
    for _, b in pairs(bars:GetChildren()) do
        if b:IsA("ImageLabel") and b.Visible then return b end
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
                        instantCollect()
                        isFinishing = false
                    else
                        if not isFinishing then Network.QTE.packets.CancelQTE.send() end
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
                        brutalInstantCollect()
                        brutalFinishing = false
                    else
                        if not brutalFinishing then Network.QTE.packets.CancelQTE.send() end
                    end
                end
            end)
            task.wait(0.005)
        end
    end)
end

-- ==================== CUSTOM UI V2 ====================
local function createSmoothUI()
    local old = CoreGui:FindFirstChild("AstroUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AstroUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Toggle Button (di pojok kanan bawah)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
    ToggleBtn.Position = UDim2.new(1, -60, 1, -60)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "⚡"
    ToggleBtn.TextColor3 = Color3.fromRGB(140, 170, 255)
    ToggleBtn.TextSize = 22
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 100

    local ToggleCorner = Instance.new("UICorner", ToggleBtn)
    ToggleCorner.CornerRadius = UDim.new(0, 14)

    local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
    ToggleStroke.Color = Color3.fromRGB(100, 140, 255)
    ToggleStroke.Thickness = 1.5

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 340, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -170, 1, -500)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.ZIndex = 99

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 14)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(100, 140, 255)
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.4

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    TopBar.BorderSizePixel = 0

    local TopCorner = Instance.new("UICorner", TopBar)
    TopCorner.CornerRadius = UDim.new(0, 14)

    local TopFix = Instance.new("Frame")
    TopFix.Parent = TopBar
    TopFix.Size = UDim2.new(1, 0, 0.5, 0)
    TopFix.Position = UDim2.new(0, 0, 0.5, 0)
    TopFix.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    TopFix.BorderSizePixel = 0

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ Astro #rylax0322"
    Title.TextColor3 = Color3.fromRGB(160, 185, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false

    local CloseCorner = Instance.new("UICorner", CloseBtn)
    CloseCorner.CornerRadius = UDim.new(0, 8)

    -- Content
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Parent = MainFrame
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0

    -- Tab Buttons Container
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Parent = ContentFrame
    TabBar.Size = UDim2.new(1, 0, 0, 32)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabBar)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 4)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local UIPad = Instance.new("UIPadding", TabBar)
    UIPad.PaddingLeft = UDim.new(0, 4)

    -- Pages
    local Pages = {}
    local TabButtons = {}
    local tabNames = {"Method 1", "Method 2", "Method 3", "Method 4", "Safe"}

    for i, name in ipairs(tabNames) do
        local Page = Instance.new("Frame")
        Page.Name = "Page"..i
        Page.Parent = ContentFrame
        Page.Size = UDim2.new(1, -16, 1, -44)
        Page.Position = UDim2.new(0, 8, 0, 40)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = (i == 1)
        Pages[i] = Page

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab"..i
        TabBtn.Parent = TabBar
        TabBtn.Size = UDim2.new(0, 55, 0, 26)
        TabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(25, 25, 45)
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = name == "Safe" and "🛡" or "#"..i
        TabBtn.TextColor3 = Color3.fromRGB(210, 220, 255)
        TabBtn.TextSize = 11
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.AutoButtonColor = false

        local TabCorner = Instance.new("UICorner", TabBtn)
        TabCorner.CornerRadius = UDim.new(0, 8)

        TabButtons[i] = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for j, p in ipairs(Pages) do
                p.Visible = (j == i)
            end
            for j, btn in ipairs(TabButtons) do
                btn.BackgroundColor3 = (j == i) and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(25, 25, 45)
            end
        end)
    end

    -- Close function
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    -- Toggle function
    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -170, 0.5, -210)}):Play()
        end
    end)

    -- Helper: create section
    local function createSection(parent, title)
        local Section = Instance.new("Frame")
        Section.Name = "Sec_"..title
        Section.Parent = parent
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
        Section.BorderSizePixel = 0

        local SecCorner = Instance.new("UICorner", Section)
        SecCorner.CornerRadius = UDim.new(0, 10)

        local SecTitle = Instance.new("TextLabel")
        SecTitle.Parent = Section
        SecTitle.Size = UDim2.new(1, -12, 0, 24)
        SecTitle.Position = UDim2.new(0, 6, 0, 4)
        SecTitle.BackgroundTransparency = 1
        SecTitle.Text = title
        SecTitle.TextColor3 = Color3.fromRGB(140, 170, 255)
        SecTitle.TextSize = 11
        SecTitle.Font = Enum.Font.GothamBold
        SecTitle.TextXAlignment = Enum.TextXAlignment.Left

        local SPadding = Instance.new("UIPadding", Section)
        SPadding.PaddingTop = UDim.new(0, 30)
        SPadding.PaddingBottom = UDim.new(0, 6)
        SPadding.PaddingLeft = UDim.new(0, 6)
        SPadding.PaddingRight = UDim.new(0, 6)

        local SList = Instance.new("UIListLayout", Section)
        SList.Padding = UDim.new(0, 4)
        SList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local widgets = {}

        function widgets:addToggle(name, default, callback)
            local TFrame = Instance.new("Frame")
            TFrame.Parent = Section
            TFrame.Size = UDim2.new(1, 0, 0, 32)
            TFrame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = TFrame
            Label.Size = UDim2.new(1, -48, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(200, 210, 255)
            Label.TextSize = 12
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local TBtn = Instance.new("TextButton")
            TBtn.Parent = TFrame
            TBtn.Size = UDim2.new(0, 40, 0, 22)
            TBtn.Position = UDim2.new(1, -40, 0, 5)
            TBtn.BackgroundColor3 = default and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(40, 40, 65)
            TBtn.BorderSizePixel = 0
            TBtn.Text = ""
            TBtn.AutoButtonColor = false

            local TCorner = Instance.new("UICorner", TBtn)
            TCorner.CornerRadius = UDim.new(0, 11)

            local Dot = Instance.new("Frame")
            Dot.Parent = TBtn
            Dot.Size = UDim2.new(0, 18, 0, 18)
            Dot.Position = default and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Dot.BorderSizePixel = 0

            local DotCorner = Instance.new("UICorner", Dot)
            DotCorner.CornerRadius = UDim.new(0, 9)

            local state = default
            TBtn.MouseButton1Click:Connect(function()
                state = not state
                local goal = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
                local col = state and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(40, 40, 65)
                TweenService:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = goal}):Play()
                TweenService:Create(TBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = col}):Play()
                callback(state)
            end)
        end

        function widgets:addSlider(name, min, max, default, callback)
            local SFrame = Instance.new("Frame")
            SFrame.Parent = Section
            SFrame.Size = UDim2.new(1, 0, 0, 40)
            SFrame.BackgroundTransparency = 1

            local SLabel = Instance.new("TextLabel")
            SLabel.Parent = SFrame
            SLabel.Size = UDim2.new(1, 0, 0, 16)
            SLabel.BackgroundTransparency = 1
            SLabel.Text = name .. ": " .. default
            SLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
            SLabel.TextSize = 11
            SLabel.Font = Enum.Font.Gotham
            SLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Bar = Instance.new("Frame")
            Bar.Parent = SFrame
            Bar.Size = UDim2.new(1, 0, 0, 4)
            Bar.Position = UDim2.new(0, 0, 0, 22)
            Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
            Bar.BorderSizePixel = 0

            local BarCorner = Instance.new("UICorner", Bar)
            BarCorner.CornerRadius = UDim.new(0, 2)

            local Fill = Instance.new("Frame")
            Fill.Parent = Bar
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
            Fill.BorderSizePixel = 0

            local FillCorner = Instance.new("UICorner", Fill)
            FillCorner.CornerRadius = UDim.new(0, 2)

            local Hitbox = Instance.new("TextButton")
            Hitbox.Parent = Bar
            Hitbox.Size = UDim2.new(1, 20, 1, 20)
            Hitbox.Position = UDim2.new(0, -10, 0, -10)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""

            local dragging = false
            local function update(input)
                local barSize = Bar.AbsoluteSize.X
                local mouseX = math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, barSize)
                local percent = mouseX / barSize
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(min + (max - min) * percent)
                SLabel.Text = name .. ": " .. value
                callback(value)
            end

            Hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            Hitbox.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        function widgets:addButton(name, callback)
            local BFrame = Instance.new("Frame")
            BFrame.Parent = Section
            BFrame.Size = UDim2.new(1, 0, 0, 30)
            BFrame.BackgroundTransparency = 1

            local Btn = Instance.new("TextButton")
            Btn.Parent = BFrame
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
            Btn.BorderSizePixel = 0
            Btn.Text = name
            Btn.TextColor3 = Color3.fromRGB(140, 170, 255)
            Btn.TextSize = 12
            Btn.Font = Enum.Font.GothamBold
            Btn.AutoButtonColor = false

            local BCorner = Instance.new("UICorner", Btn)
            BCorner.CornerRadius = UDim.new(0, 8)

            Btn.MouseButton1Click:Connect(callback)
        end

        return widgets
    end

    -- ==================== FILL PAGES ====================

    -- Page 1: Method 1
    local p1List = Instance.new("UIListLayout", Pages[1])
    p1List.Padding = UDim.new(0, 6)
    p1List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local s1 = createSection(Pages[1], "Manual 80% Perfect")
    s1:addToggle("Enable Perfect Tap", false, function(v)
        methods.method1 = v
        if not v then lastBar = nil; hasPassed = false; lastRotation = nil end
    end)
    s1:addSlider("Threshold", 3, 20, 5, function(v) threshold = v end)
    s1:addSlider("Cooldown", 0.05, 0.5, 0.15, function(v) cooldown = v end)

    -- Page 2: Method 2
    local p2List = Instance.new("UIListLayout", Pages[2])
    p2List.Padding = UDim.new(0, 6)
    p2List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local s2 = createSection(Pages[2], "Instant Dig Blatant")
    s2:addToggle("Enable Instant Dig", false, function(v)
        methods.method2 = v
        if v then startMethod2() end
    end)
    s2:addSlider("Start Delay", 0.1, 5, 0.5, function(v) eventDelay = v end)
    s2:addSlider("Finish Delay", 0.01, 0.5, 0.01, function(v) finishDelay = v end)

    -- Page 3: Method 3
    local p3List = Instance.new("UIListLayout", Pages[3])
    p3List.Padding = UDim.new(0, 6)
    p3List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local s3 = createSection(Pages[3], "Find Rarity")
    s3:addToggle("Enable Find Rarity", false, function(v)
        methods.method3 = v
        if v then startMethod3() end
    end)
    for _, r in ipairs({"Rare", "Epic", "Legendary", "Mythic", "Exotic"}) do
        s3:addToggle("Target: "..r, r == "Legendary", function(v) targetRarities[r] = v end)
    end
    s3:addSlider("Worker Count", 1, 20, 20, function(v) normalWorker = v end)

    -- Page 4: Method 4
    local p4List = Instance.new("UIListLayout", Pages[4])
    p4List.Padding = UDim.new(0, 6)
    p4List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local s4 = createSection(Pages[4], "Brutal Dupe Mode")
    s4:addToggle("Enable Brutal Mode", false, function(v)
        autoBrutal = v
        if v then startMethod4() end
    end)
    s4:addSlider("Worker Count", 1, 100, 60, function(v) brutalWorker = v end)

    -- Page 5: Safe
    local p5List = Instance.new("UIListLayout", Pages[5])
    p5List.Padding = UDim.new(0, 6)
    p5List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local s5 = createSection(Pages[5], "Identity Protection")
    s5:addToggle("Enable Protection", false, function(v) protectEnabled = v end)
    s5:addButton("Apply Protection Now", protectIdentity)

    -- Drag functionality
    local dragging = false
    local dragStartPos, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

end

-- ==================== MAIN LOOPS ====================
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

task.spawn(function()
    while task.wait(2) do protectIdentity() end
end)

-- ==================== LOAD ====================
createSmoothUI()
