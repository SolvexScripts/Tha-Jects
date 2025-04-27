-- Load Fluent UI and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Fluent window
local Window = Fluent:CreateWindow({
    Title = "Solvex | Free",
    SubTitle = "Tha Jects",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Define Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "🏠" }),
    Autofarm = Window:AddTab({ Title = "Autofarm", Icon = "🔁" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "⚔️" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "🌐" }),
    Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "📋" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "⚙️" })
}

local Options = Fluent.Options

-- Define fireproximityprompt with retry mechanism
if not fireproximityprompt then
    fireproximityprompt = function(prompt, holdDuration, retries)
        retries = retries or 3
        holdDuration = holdDuration or 0.1
        if prompt and prompt:IsA("ProximityPrompt") then
            for i = 1, retries do
                if prompt.InputType == Enum.ProximityPromptInputType.Keyboard then
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, prompt.Parent, 0)
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, prompt.Parent, 1)
                    return true
                else
                    local success, err = pcall(function()
                        prompt:InputHoldBegin()
                        task.wait(holdDuration)
                        prompt:InputHoldEnd()
                    end)
                    if success then
                        return true
                    else
                        warn("Failed to fire prompt: " .. tostring(err) .. " - Retry " .. i .. "/" .. retries)
                        task.wait(0.2)
                    end
                end
            end
            warn("Prompt failed after " .. retries .. " retries: " .. tostring(prompt:GetFullName()))
            return false
        end
        warn("Prompt is nil or not a ProximityPrompt")
        return false
    end
end

-- Combat Tab: Hitbox Expander Button
Tabs.Combat:AddButton({
    Title = "Hitbox Expander",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/itsopyy/JoinPedos/refs/heads/main/hitboxnigger.lua", true))()
        end)
        if success then
            Fluent:Notify({
                Title = "Hitbox Expander",
                Content = "Hitbox Expander activated",
                Duration = 3
            })
        else
            warn("Failed to load hitbox expander: " .. tostring(err))
            Fluent:Notify({
                Title = "Hitbox Expander",
                Content = "Failed to activate: " .. tostring(err),
                Duration = 5
            })
        end
    end
})

-- Main Tab: Teleport To Player Dropdown
local function getPlayerList()
    local players = game:GetService("Players"):GetPlayers()
    local playerNames = {}
    for _, player in ipairs(players) do
        if player ~= game.Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

Tabs.Main:AddDropdown("TeleportToPlayer", {
    Title = "Teleport To Player",
    Description = "Select a player to teleport to their position",
    Values = getPlayerList(),
    Default = nil,
    Callback = function(value)
        local targetPlayer = game.Players:FindFirstChild(value)
        if not targetPlayer then
            warn("Player not found: " .. tostring(value))
            return
        end

        local localChar = game.Players.LocalPlayer.Character
        local targetChar = targetPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
            warn("Local player's character or HumanoidRootPart not found")
            return
        end
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            warn("Target player's character or HumanoidRootPart not found")
            return
        end

        local targetPosition = targetChar.HumanoidRootPart.Position
        localChar:PivotTo(CFrame.new(targetPosition + Vector3.new(0, 2, 0)))
        print("Teleported to " .. targetPlayer.Name .. " at position: " .. tostring(targetPosition))
    end
})

-- Update dropdown when players join or leave
game.Players.PlayerAdded:Connect(function()
    Options.TeleportToPlayer:SetValues(getPlayerList())
end)
game.Players.PlayerRemoving:Connect(function()
    Options.TeleportToPlayer:SetValues(getPlayerList())
end)

-- Autofarm Tab: Search All Trashcans Button
Tabs.Autofarm:AddButton({
    Title = "Search All Trashcans",
    Description = "Searches all trashcans and returns you to your original position",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            return
        end
        local originalPosition = char:GetPivot()

        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end

        local gameFolder = workspace:FindFirstChild("Game")
        local promptsFolder = gameFolder and gameFolder:FindFirstChild("Proximity Prompts")
        if not promptsFolder then
            warn("Proximity Prompts folder not found in workspace.Game")
            return
        end

        local function findPromptByName(name)
            return promptsFolder:FindFirstChild(name) and promptsFolder[name]:FindFirstChild("ProximityPrompt")
        end

        local trashcans = {
            { position = Vector3.new(45.52043151855469, 8.746527671813965, -170.49954223632812), prompt = promptsFolder:FindFirstChild("Trash") and promptsFolder["Trash"]:FindFirstChild("ProximityPrompt"), name = "Trash1" },
            { position = Vector3.new(-356.5718688964844, 8.046199798583984, 39.262237548828125), prompt = findPromptByName("Trash2") or (promptsFolder:GetChildren()[10] and promptsFolder:GetChildren()[10]:FindFirstChild("ProximityPrompt")), name = "Trash2" },
            { position = Vector3.new(119.57083129882812, 8.715627670288086, 74.38800048828125), prompt = findPromptByName("Trash3") or (promptsFolder:GetChildren()[15] and promptsFolder:GetChildren()[15]:FindFirstChild("ProximityPrompt")), name = "Trash3" },
            { position = Vector3.new(167.3494415283203, 8.779533386230469, 486.8727111816406), prompt = findPromptByName("Trash4") or (promptsFolder:GetChildren()[14] and promptsFolder:GetChildren()[14]:FindFirstChild("ProximityPrompt")), name = "Trash4" },
            { position = Vector3.new(26.43505859375, 8.78406047821045, 773.7100830078125), prompt = findPromptByName("Trash5") or (promptsFolder:GetChildren()[12] and promptsFolder:GetChildren()[12]:FindFirstChild("ProximityPrompt")), name = "Trash5" },
            { position = Vector3.new(-117.12484741210938, 9.441628456115723, 366.40911865234375), prompt = findPromptByName("Trash6") or (promptsFolder:GetChildren()[11] and promptsFolder:GetChildren()[11]:FindFirstChild("ProximityPrompt")), name = "Trash6" },
            { position = Vector3.new(-116.9608383178711, 9.492852210998535, 366.14703369140625), prompt = findPromptByName("Trash7") or (promptsFolder:GetChildren()[11] and promptsFolder:GetChildren()[11]:FindFirstChild("ProximityPrompt")), name = "Trash7" },
            { position = Vector3.new(-91.92422485351562, 8.734339714050293, 57.360321044921875), prompt = findPromptByName("Trash8") or (promptsFolder:GetChildren()[9] and promptsFolder:GetChildren()[9]:FindFirstChild("ProximityPrompt")), name = "Trash8" },
            { position = Vector3.new(116.04224395751953, 8.73572063446045, -389.98822021484375), prompt = findPromptByName("Trash9") or (promptsFolder:GetChildren()[8] and promptsFolder:GetChildren()[8]:FindFirstChild("ProximityPrompt")), name = "Trash9" }
        }

        for i, trashcan in ipairs(trashcans) do
            if trashcan.prompt then
                print("Attempting to teleport to " .. trashcan.name .. " at position: " .. tostring(trashcan.position))
                char:PivotTo(CFrame.new(trashcan.position))
                task.wait(0.2)
                print("Firing prompt for " .. trashcan.name)
                local success = fireproximityprompt(trashcan.prompt)
                if success then
                    print("Successfully fired prompt for " .. trashcan.name)
                else
                    warn("Failed to fire prompt for " .. trashcan.name)
                end
                task.wait(0.5)
            else
                warn("Prompt not found for " .. trashcan.name .. " (Trashcan #" .. i .. ")")
            end
        end

        print("Teleporting back to original position: " .. tostring(originalPosition.Position))
        char:PivotTo(originalPosition)
    end
})

-- Autofarm Tab: Deli Autofarm Toggle
local autoFarmDeli = false
Tabs.Autofarm:AddToggle("ToggleDeliFarm", {
    Title = "Deli Autofarm",
    Default = false,
    Callback = function(value)
        autoFarmDeli = value
        if value then
            for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end

            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            local gameFolder = workspace:FindFirstChild("Game")
            local prompts = gameFolder and gameFolder:FindFirstChild("Proximity Prompts")
            if prompts then
                char:PivotTo(CFrame.new(267.4908447265625, 8.62241268157959, -282.4407958984375))
                task.wait(0.1)
                local pickupPrompt = prompts:FindFirstChild("Deli Pickup") and prompts["Deli Pickup"]:FindFirstChild("ProximityPrompt")
                if pickupPrompt then
                    fireproximityprompt(pickupPrompt)
                end

                char:PivotTo(CFrame.new(275.50250244140625, 6.6166510581970215, -362.8531799316406))
                task.wait(0.1)
                local deliveryPrompt = prompts:FindFirstChild("Deli Delivery") and prompts["Deli Delivery"]:FindFirstChild("ProximityPrompt")
                if deliveryPrompt then
                    fireproximityprompt(deliveryPrompt)
                end
            end
        end
    end
})

-- Autofarm Tab: Trash Autofarm Toggle
local autoFarmTrash = false
Tabs.Autofarm:AddToggle("ToggleTrashFarm", {
    Title = "Trash Autofarm",
    Default = false,
    Callback = function(value)
        autoFarmTrash = value
        if value then
            for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end

            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            local gameFolder = workspace:FindFirstChild("Game")
            local prompts = gameFolder and gameFolder:FindFirstChild("Proximity Prompts")
            if prompts then
                char:PivotTo(CFrame.new(-243.39373779296875, 9.105902671813965, 119.425048828125))
                task.wait(0.1)
                local pickupPrompt = prompts:FindFirstChild("Trash Pickup") and prompts["Trash Pickup"]:FindFirstChild("ProximityPrompt")
                if pickupPrompt then
                    fireproximityprompt(pickupPrompt)
                end

                char:PivotTo(CFrame.new(-395.3404541015625, 7.131561756134033, 76.11133575439453))
                task.wait(0.1)
                local deliveryPrompt = prompts:FindFirstChild("Trash Delivery") and prompts["Trash Delivery"]:FindFirstChild("ProximityPrompt")
                if deliveryPrompt then
                    fireproximityprompt(deliveryPrompt)
                end
            end
        end
    end
})

-- Teleport Tab: Teleport Buttons for Specified Locations
Tabs.Teleport:AddButton({
    Title = "Teleport to Deli",
    Description = "Teleports to the Deli location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(244.23374938964844, 5.096978664398193, -386.49261474609375))
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to Deli",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Gun Store",
    Description = "Teleports to the Gun Store location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(87.08739471435547, 5.1224751472473145, -383.74371337890625))
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to Gun Store",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Laundromat",
    Description = "Teleports to the Laundromat location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(41.84989929199219, 5.1978230476379395, 50.76091384887695))
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to Laundromat",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Food Mart",
    Description = "Teleports to the Food Mart location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(-134.341796875, 5.129141807556152, 318.21600341796875))
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to Food Mart",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to 1st Street Auto/Customs",
    Description = "Teleports to the 1st Street Auto/Customs location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(-226.2700958251953, 5.097738742828369, 67.08649444580078))
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to 1st Street Auto/Customs",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Tha Plug",
    Description = "Teleports to the Tha Plug location",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Character or HumanoidRootPart not found")
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Character or HumanoidRootPart not found",
                Duration = 3
            })
            return
        end
        char:PivotTo(CFrame.new(0, 5, 0)) -- Placeholder; update with correct coordinates if needed
        Fluent:Notify({
            Title = "Teleport Success",
            Content = "Teleported to Tha Plug",
            Duration = 3
        })
    end
})

-- Miscellaneous Tab: Infinite Yield Button
Tabs.Miscellaneous:AddButton({
    Title = "Infinite Yield",
    Description = "Loads the Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Fluent:Notify({
            Title = "Infinite Yield",
            Content = "Infinite Yield script loaded",
            Duration = 3
        })
    end
})

-- Settings Tab: Configuration Saving
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentDeliFarm")
SaveManager:SetFolder("FluentDeliFarm")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Loop logic for autofarms (Deli and Trash only)
task.spawn(function()
    while true do
        if autoFarmDeli then
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end

            local gameFolder = workspace:FindFirstChild("Game")
            local prompts = gameFolder and gameFolder:FindFirstChild("Proximity Prompts")
            if prompts then
                char:PivotTo(CFrame.new(267.4908447265625, 8.62241268157959, -282.4407958984375))
                task.wait(0.5)
                local pickupPrompt = prompts:FindFirstChild("Deli Pickup") and prompts["Deli Pickup"]:FindFirstChild("ProximityPrompt")
                if pickupPrompt then
                    fireproximityprompt(pickupPrompt)
                end

                char:PivotTo(CFrame.new(275.50250244140625, 6.6166510581970215, -362.8531799316406))
                task.wait(0.3)
                local deliveryPrompt = prompts:FindFirstChild("Deli Delivery") and prompts["Deli Delivery"]:FindFirstChild("ProximityPrompt")
                if deliveryPrompt then
                    fireproximityprompt(deliveryPrompt)
                end
            end
        end

        if autoFarmTrash then
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end

            local gameFolder = workspace:FindFirstChild("Game")
            local prompts = gameFolder and gameFolder:FindFirstChild("Proximity Prompts")
            if prompts then
                char:PivotTo(CFrame.new(-243.39373779296875, 9.105902671813965, 119.425048828125))
                task.wait(0.5)
                local pickupPrompt = prompts:FindFirstChild("Trash Pickup") and prompts["Trash Pickup"]:FindFirstChild("ProximityPrompt")
                if pickupPrompt then
                    fireproximityprompt(pickupPrompt)
                end

                char:PivotTo(CFrame.new(-395.3404541015625, 7.131561756134033, 76.11133575439453))
                task.wait(0.3)
                local deliveryPrompt = prompts:FindFirstChild("Trash Delivery") and prompts["Trash Delivery"]:FindFirstChild("ProximityPrompt")
                if deliveryPrompt then
                    fireproximityprompt(deliveryPrompt)
                end
            end
        end
        task.wait(0.3)
    end
end)
