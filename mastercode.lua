local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Network = require(RS.Modules.Communication.Network)

local lp = Players.LocalPlayer
local qte = lp.PlayerGui:WaitForChild("QTE")
local main = qte:WaitForChild("Main")
local line = main:WaitForChild("Line")
local bars = main:WaitForChild("Bars")
local wayStones = workspace:WaitForChild("WayStones")

-- Method 1 variables
local autoDigBarMethod = false
local threshold = 5
local cooldown = 0.15
local lastTap = 0
local lastBar = nil
local hasPassed = false
local lastRotation = nil
local rotationSpeed = 0

-- Method 2 variables
local autoDigEventMethod = false
local eventDelay = 0.5
local finishDelay = 0.01
local stuckTimeout = 1

-- Method 3 variables
local autoTargetDig3 = false
local targetRarities3 = {Legendary = true}
local normalWorker = 20
local foundLog3 = {}
local skipLog3 = {}
local isFinishing3 = false

-- Method 4 variables
local autoBrutal = false
local targetRarities4 = {Legendary = true}
local brutalWorker = 60
local brutalRefresh = 0.8
local foundLog4 = {}
local skipLog4 = {}
local isFinishing4 = false

-- Other features
local autoSell = false
local autoMerchant = false
local sellDelay = 30
local favoritedItems = {}
local weightFilters = {}
local selectedWeightItem = ""
local selectedBuyTool = ""
local minWeightInput = 0

local fishList = {}
local shellTools = RS:WaitForChild("Assets"):WaitForChild("Shells"):WaitForChild("Tools")
for _, item in pairs(shellTools:GetChildren()) do
    table.insert(fishList, item.Name)
end
table.sort(fishList)

local equipList = {}
local equipTools = RS:WaitForChild("Assets"):WaitForChild("Equipment"):WaitForChild("Tools")
task.wait(3)
for _, item in pairs(equipTools:GetChildren()) do
    table.insert(equipList, item.Name)
end
table.sort(equipList)

local islandList = {}
for _, island in pairs(wayStones:GetChildren()) do
    table.insert(islandList, island.Name)
end
table.sort(islandList)

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

-- Old features functions
local function favoriteAll()
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        local fishName = tool.Name:split("_")[1]
        if favoritedItems[fishName] then
            pcall(function()
                local args = {buffer.fromstring("\003\001\001"), {tool}}
                RS:WaitForChild("ByteNetReliable"):FireServer(unpack(args))
            end)
        end
    end
end

local function favoriteByWeight()
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        local fishName = tool.Name:split("_")[1]
        local minWeight = weightFilters[fishName]
        if minWeight then
            local weight = tool:GetAttribute("Weight")
            if weight and weight >= minWeight then
                pcall(function()
                    local args = {buffer.fromstring("\003\001\001"), {tool}}
                    RS:WaitForChild("ByteNetReliable"):FireServer(unpack(args))
                end)
            end
        end
    end
end

local function teleportTo(islandName)
    local island = wayStones:FindFirstChild(islandName)
    if island then
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = island:GetModelCFrame()
        end
    end
end

local function buyAllMerchant()
    local buying = true
    while buying do
        buying = false
        local result = Network.TravellingMerchant.queries.GetShop.invoke()
        if result then
            local data = HttpService:JSONDecode(result)
            if data.isActive then
                for item, stock in pairs(data.stock or {}) do
                    if stock > 0 then
                        pcall(function()
                            local buyResult = Network.TravellingMerchant.queries.BuyItem.invoke(item)
                            if buyResult and buyResult.success then
                                if buyResult.remaining > 0 then buying = true end
                            end
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end

-- Method 2
local function startMethod2()
    task.spawn(function()
        while autoDigEventMethod do
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

-- Method 3 collect function
local function instantCollect3()
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
    task.wait(0.5)
end

local function spawnMethod3()
    for i = 1, normalWorker do
        task.spawn(function()
            while autoTargetDig3 do
                if isFinishing3 then task.wait(0.05) continue end
                pcall(function()
                    local result = Network.QTE.queries.StartQTE.invoke()
                    if result and result.rarity then
                        local rarity = result.rarity
                        if targetRarities3[rarity] and not isFinishing3 then
                            isFinishing3 = true
                            table.insert(foundLog3, 1, "COLLECTED "..rarity)
                            instantCollect3()
                            isFinishing3 = false
                        else
                            if not isFinishing3 then
                                table.insert(skipLog3, 1, rarity)
                                Network.QTE.packets.CancelQTE.send()
                            end
                        end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end
end

-- Method 4 collect function
local function instantCollect4()
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

local function spawnMethod4()
    task.spawn(function()
        while autoBrutal do
            if isFinishing4 then task.wait(0.005) continue end
            pcall(function()
                local result = Network.QTE.queries.StartQTE.invoke()
                if result and result.rarity then
                    local rarity = result.rarity
                    if targetRarities4[rarity] and not isFinishing4 then
                        isFinishing4 = true
                        table.insert(foundLog4, 1, "COLLECTED "..rarity)
                        instantCollect4()
                        isFinishing4 = false
                    else
                        if not isFinishing4 then
                            table.insert(skipLog4, 1, rarity)
                            Network.QTE.packets.CancelQTE.send()
                            Network.QTE.packets.CancelQTE.send()
                        end
                    end
                end
            end)
            task.wait(0.005)
        end
    end)
    -- Double spawn
    for i = 1, brutalWorker do
        task.spawn(function()
            while autoBrutal do
                if isFinishing4 then task.wait(0.005) continue end
                pcall(function()
                    local result = Network.QTE.queries.StartQTE.invoke()
                    if result and result.rarity then
                        local rarity = result.rarity
                        if targetRarities4[rarity] and not isFinishing4 then
                            isFinishing4 = true
                            table.insert(foundLog4, 1, "COLLECTED "..rarity)
                            instantCollect4()
                            isFinishing4 = false
                        else
                            if not isFinishing4 then
                                table.insert(skipLog4, 1, rarity)
                                Network.QTE.packets.CancelQTE.send()
                            end
                        end
                    end
                end)
                task.wait(0.005)
            end
        end)
    end
    -- Refresh loop
    task.spawn(function()
        while autoBrutal do
            task.wait(brutalRefresh)
            spawnMethod4()
        end
    end)
end

-- ==================== RAYFIELD UI ====================
local Window = Rayfield:CreateWindow({
    Name = "Astro #rylax0322",
    LoadingTitle = "Astro #rylax0322",
    LoadingSubtitle = "Loading...",
    Theme = {
        Background = Color3.fromRGB(12, 12, 28),
        Topbar = Color3.fromRGB(18, 18, 40),
        Shadow = Color3.fromRGB(5, 5, 15),
        NotificationBackground = Color3.fromRGB(18, 18, 40),
        NotificationActionsBackground = Color3.fromRGB(22, 22, 48),
        TabBackground = Color3.fromRGB(14, 14, 32),
        TabStroke = Color3.fromRGB(40, 40, 80),
        TabBackgroundSelected = Color3.fromRGB(25, 25, 60),
        TabTextColor = Color3.fromRGB(120, 120, 180),
        SelectedTabTextColor = Color3.fromRGB(140, 160, 255),
        ElementBackground = Color3.fromRGB(20, 20, 45),
        ElementBackgroundHover = Color3.fromRGB(28, 28, 60),
        SecondaryElementBackground = Color3.fromRGB(22, 22, 50),
        ElementStroke = Color3.fromRGB(45, 45, 90),
        SecondaryElementStroke = Color3.fromRGB(38, 38, 75),
        SliderBackground = Color3.fromRGB(30, 30, 65),
        SliderProgress = Color3.fromRGB(100, 120, 255),
        SliderStroke = Color3.fromRGB(50, 50, 100),
        ToggleBackground = Color3.fromRGB(30, 30, 65),
        ToggleEnabled = Color3.fromRGB(100, 120, 255),
        ToggleDisabled = Color3.fromRGB(50, 50, 90),
        ToggleEnabledStroke = Color3.fromRGB(80, 100, 220),
        ToggleDisabledStroke = Color3.fromRGB(40, 40, 80),
        ToggleEnabledOuterStroke = Color3.fromRGB(60, 80, 180),
        ToggleDisabledOuterStroke = Color3.fromRGB(30, 30, 65),
        DropdownSelected = Color3.fromRGB(100, 120, 255),
        DropdownUnselected = Color3.fromRGB(35, 35, 70),
        InputBackground = Color3.fromRGB(20, 20, 45),
        InputStroke = Color3.fromRGB(45, 45, 90),
        PlaceholderColor = Color3.fromRGB(90, 90, 140),
        TextColor = Color3.fromRGB(210, 215, 255),
        SubTextColor = Color3.fromRGB(140, 145, 200),
        PureTitleTextColor = Color3.fromRGB(160, 175, 255),
        TitleTextColor = Color3.fromRGB(160, 175, 255),
        ButtonColor = Color3.fromRGB(55, 60, 140),
        ButtonStroke = Color3.fromRGB(80, 90, 180),
        ButtonTextColor = Color3.fromRGB(220, 225, 255),
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- Tab 1: Method 1
local Tab1 = Window:CreateTab("Method 1", nil)
Tab1:CreateSection("Manual 80% Perfect")
Tab1:CreateToggle({
    Name = "Perfect Bar Follow",
    CurrentValue = false,
    Callback = function(v)
        autoDigBarMethod = v
        if not v then lastBar = nil; hasPassed = false; lastRotation = nil end
    end
})
Tab1:CreateSlider({
    Name = "Threshold", Range = {3, 20}, Increment = 1, CurrentValue = 5,
    Callback = function(v) threshold = v end
})
Tab1:CreateSlider({
    Name = "Cooldown", Range = {0.05, 0.5}, Increment = 0.01, CurrentValue = 0.15,
    Callback = function(v) cooldown = v end
})

-- Tab 2: Method 2
local Tab2 = Window:CreateTab("Method 2", nil)
Tab2:CreateSection("Instant Dig Blatant")
Tab2:CreateToggle({
    Name = "Instant Dig",
    CurrentValue = false,
    Callback = function(v)
        autoDigEventMethod = v
        if v then startMethod2() end
    end
})
Tab2:CreateSlider({
    Name = "Start Delay", Range = {0.1, 5}, Increment = 0.1, CurrentValue = 0.5,
    Callback = function(v) eventDelay = v end
})
Tab2:CreateSlider({
    Name = "Finish Delay", Range = {0.01, 0.5}, Increment = 0.01, CurrentValue = 0.01,
    Callback = function(v) finishDelay = v end
})

-- Tab 3: Method 3
local Tab3 = Window:CreateTab("Method 3", nil)
Tab3:CreateSection("Find Rarity Normal")
for _, r in ipairs({"Rare", "Epic", "Legendary", "Mythic", "Exotic"}) do
    Tab3:CreateToggle({
        Name = "Target: "..r, CurrentValue = (r == "Legendary"),
        Callback = function(v) targetRarities3[r] = v end
    })
end
Tab3:CreateSlider({
    Name = "Worker Count", Range = {1, 20}, Increment = 1, CurrentValue = 20,
    Callback = function(v) normalWorker = v end
})
Tab3:CreateToggle({
    Name = "Start Method 3", CurrentValue = false,
    Callback = function(v)
        autoTargetDig3 = v
        if v then foundLog3 = {}; skipLog3 = {}; isFinishing3 = false; spawnMethod3() end
    end
})
local Found3 = Tab3:CreateParagraph({Title = "Found", Content = "..."})
local Skip3 = Tab3:CreateParagraph({Title = "Skipped", Content = "..."})

-- Tab 4: Method 4
local Tab4 = Window:CreateTab("Method 4", nil)
Tab4:CreateSection("Brutal Dupe Mode")
for _, r in ipairs({"Rare", "Epic", "Legendary", "Mythic", "Exotic"}) do
    Tab4:CreateToggle({
        Name = "Target: "..r, CurrentValue = (r == "Legendary"),
        Callback = function(v) targetRarities4[r] = v end
    })
end
Tab4:CreateSlider({
    Name = "Worker Count", Range = {1, 100}, Increment = 1, CurrentValue = 60,
    Callback = function(v) brutalWorker = v end
})
Tab4:CreateSlider({
    Name = "Refresh Rate", Range = {0.1, 3}, Increment = 0.1, CurrentValue = 0.8,
    Callback = function(v) brutalRefresh = v end
})
Tab4:CreateToggle({
    Name = "Start Brutal Mode", CurrentValue = false,
    Callback = function(v)
        autoBrutal = v
        if v then foundLog4 = {}; skipLog4 = {}; isFinishing4 = false; spawnMethod4() end
    end
})
local Found4 = Tab4:CreateParagraph({Title = "Found", Content = "..."})
local Skip4 = Tab4:CreateParagraph({Title = "Skipped", Content = "..."})

-- Tab 5: Auto Sell
local SellTab = Window:CreateTab("Auto Sell", nil)
SellTab:CreateSection("Auto Sell")
SellTab:CreateToggle({
    Name = "Auto Sell", CurrentValue = false,
    Callback = function(v)
        autoSell = v
        if v then
            task.spawn(function()
                while autoSell do
                    pcall(function() Network.Merchant.packets.SellAll.send() end)
                    task.wait(sellDelay)
                end
            end)
        end
    end
})
SellTab:CreateSlider({
    Name = "Sell Delay (s)", Range = {10, 60}, Increment = 5, CurrentValue = 30,
    Callback = function(v) sellDelay = v end
})

-- Tab 6: Auto Favorite
local FavTab = Window:CreateTab("Auto Favorite", nil)
FavTab:CreateSection("Select Items to Favorite")
for _, fishName in pairs(fishList) do
    FavTab:CreateToggle({
        Name = fishName, CurrentValue = false,
        Callback = function(v) favoritedItems[fishName] = v end
    })
end
FavTab:CreateSection("Run")
FavTab:CreateButton({
    Name = "Favorite Selected Now",
    Callback = function()
        favoriteAll()
        Rayfield:Notify({Title = "Auto Favorite", Content = "Favorited all selected items!", Duration = 2})
    end
})
FavTab:CreateToggle({
    Name = "Auto Favorite on Backpack Change", CurrentValue = false,
    Callback = function(v)
        if v then
            lp.Backpack.ChildAdded:Connect(function() task.wait(0.1); favoriteAll() end)
        end
    end
})

-- Tab 7: Fav by Weight
local FavWeightTab = Window:CreateTab("Fav by Weight", nil)
FavWeightTab:CreateSection("Add Weight Filter")
FavWeightTab:CreateDropdown({
    Name = "Select Item", Options = fishList, CurrentOption = {fishList[1]},
    Callback = function(v) selectedWeightItem = v[1] or v end
})
FavWeightTab:CreateInput({
    Name = "Minimum Weight (kg)", PlaceholderText = "e.g. 50",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) minWeightInput = tonumber(v) or 0 end
})
local weightListLabel = FavWeightTab:CreateParagraph({Title = "Active Filters", Content = "None"})
local function updateWeightList()
    local lines = {}
    for name, w in pairs(weightFilters) do
        table.insert(lines, name .. " >= " .. w .. " kg")
    end
    weightListLabel:Set({Title = "Active Filters", Content = #lines > 0 and table.concat(lines, "\n") or "None"})
end
FavWeightTab:CreateButton({
    Name = "Add Filter",
    Callback = function()
        if selectedWeightItem ~= "" and minWeightInput > 0 then
            weightFilters[selectedWeightItem] = minWeightInput
            updateWeightList()
            Rayfield:Notify({Title = "Filter Added", Content = selectedWeightItem .. " >= " .. minWeightInput .. " kg", Duration = 2})
        else
            Rayfield:Notify({Title = "Error", Content = "Select item and enter valid weight!", Duration = 2})
        end
    end
})
FavWeightTab:CreateButton({
    Name = "Remove Selected Filter",
    Callback = function()
        if weightFilters[selectedWeightItem] then
            weightFilters[selectedWeightItem] = nil
            updateWeightList()
            Rayfield:Notify({Title = "Filter Removed", Content = selectedWeightItem .. " removed.", Duration = 2})
        end
    end
})
FavWeightTab:CreateSection("Run")
FavWeightTab:CreateButton({
    Name = "Favorite by Weight Now",
    Callback = function()
        favoriteByWeight()
        Rayfield:Notify({Title = "Auto Favorite", Content = "Favorited matching weight!", Duration = 2})
    end
})
FavWeightTab:CreateToggle({
    Name = "Auto Favorite by Weight on Backpack Change", CurrentValue = false,
    Callback = function(v)
        if v then
            lp.Backpack.ChildAdded:Connect(function() task.wait(0.1); favoriteByWeight() end)
        end
    end
})

-- Tab 8: Buy Tool
local BuyTab = Window:CreateTab("Buy Tool", nil)
BuyTab:CreateSection("Select Tool to Buy")
BuyTab:CreateDropdown({
    Name = "Select Tool", Options = equipList, CurrentOption = {equipList[1]},
    Callback = function(v) selectedBuyTool = v[1] or v end
})
BuyTab:CreateButton({
    Name = "Buy",
    Callback = function()
        if selectedBuyTool ~= "" then
            pcall(function() Network.Equipment.queries.Buy.invoke(selectedBuyTool) end)
            Rayfield:Notify({Title = "Buy Tool", Content = "Bought: " .. selectedBuyTool, Duration = 2})
        end
    end
})

-- Tab 9: Teleport
local TpTab = Window:CreateTab("Teleport", nil)
TpTab:CreateSection("Islands")
for _, name in pairs(islandList) do
    TpTab:CreateButton({
        Name = name,
        Callback = function()
            teleportTo(name)
            Rayfield:Notify({Title = "Teleport", Content = "Teleported to " .. name, Duration = 2})
        end
    })
end

-- Tab 10: Merchant
local MerchantTab = Window:CreateTab("Merchant", nil)
MerchantTab:CreateSection("Travelling Merchant")
MerchantTab:CreateButton({
    Name = "Check Merchant Status",
    Callback = function()
        pcall(function()
            local result = Network.TravellingMerchant.queries.GetShop.invoke()
            if result then
                local data = HttpService:JSONDecode(result)
                if data.isActive then
                    Rayfield:Notify({Title = "Merchant", Content = "ACTIVE!", Duration = 3})
                else
                    local timeLeft = data.nextChangeTime - os.time()
                    local mins = math.floor(timeLeft / 60)
                    local secs = timeLeft % 60
                    Rayfield:Notify({Title = "Merchant", Content = "Arrives in: " .. mins .. "m " .. secs .. "s", Duration = 3})
                end
            end
        end)
    end
})
MerchantTab:CreateButton({
    Name = "Buy All Now",
    Callback = function()
        pcall(function()
            local result = Network.TravellingMerchant.queries.GetShop.invoke()
            if result then
                local data = HttpService:JSONDecode(result)
                if data.isActive then
                    task.spawn(buyAllMerchant)
                    Rayfield:Notify({Title = "Merchant", Content = "Buying all!", Duration = 2})
                else
                    Rayfield:Notify({Title = "Merchant", Content = "Not active!", Duration = 2})
                end
            end
        end)
    end
})
MerchantTab:CreateToggle({
    Name = "Auto Buy When Merchant Arrives", CurrentValue = false,
    Callback = function(v)
        autoMerchant = v
        if v then
            task.spawn(function()
                local merchantBought = false
                while autoMerchant do
                    pcall(function()
                        local result = Network.TravellingMerchant.queries.GetShop.invoke()
                        if result then
                            local data = HttpService:JSONDecode(result)
                            if data.isActive and not merchantBought then
                                buyAllMerchant()
                                merchantBought = true
                            elseif not data.isActive then
                                merchantBought = false
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

-- Live update paragraphs
task.spawn(function()
    while task.wait(0.3) do
        if autoTargetDig3 then
            Found3:Set({Title = "Found ["..#foundLog3.."]", Content = #foundLog3 > 0 and table.concat(foundLog3, "\n") or "None"})
            Skip3:Set({Title = "Skipped ["..#skipLog3.."]", Content = #skipLog3 > 0 and table.concat(skipLog3, "\n") or "None"})
        end
        if autoBrutal then
            Found4:Set({Title = "Found ["..#foundLog4.."]", Content = #foundLog4 > 0 and table.concat(foundLog4, "\n") or "None"})
            Skip4:Set({Title = "Skipped ["..#skipLog4.."]", Content = #skipLog4 > 0 and table.concat(skipLog4, "\n") or "None"})
        end
    end
end)

-- Method 1 RenderStepped
RunService.RenderStepped:Connect(function()
    if autoDigBarMethod and qte.Enabled then
        pcall(function()
            local bar = getBar()
            if not bar then return end
            if bar ~= lastBar then
                hasPassed = false; lastBar = bar; lastRotation = nil
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
                lastTap = tick(); hasPassed = false
                task.spawn(tap)
            end
        end)
    end
end)

Rayfield:Notify({
    Title = "Astro #rylax0322",
    Content = "Loaded successfully!",
    Duration = 3,
})
