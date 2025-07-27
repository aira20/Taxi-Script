-- ✅ Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ✅ Anti-AFK toggle
local antiAFKEnabled = false

local bot = Players.LocalPlayer
repeat task.wait() until bot.Character and bot.Character:FindFirstChild("HumanoidRootPart")

print("SUCCESSFULLY CONNECTED - HELLO BOSS TAXI")

-- ✅ Owners
local botOwners = {
    ["srhcarolinee"] = true,
    ["Aqwstudios"] = true,
    ["ColdFrost000"] = true,
    ["Taxi_Dig"] = true,
    ["coldfrost000"] = true,
    ["panjisquidoo"] = true,    
    ["GojekTuan"] = true,
}

-- ✅ Permissions
local Permissions = {
    tp = {},
    come = {},
    follow = {},
    allAllowed = false,
    allUsers = {},
}

-- ✅ Blacklist
local blockedUsers = {}

-- ✅ Toggleable protection
local protectionEnabled = true

-- ✅ Alias map
local aliasMap = {
    penguin = "penguins",
    penguins = "penguins",
    peng = "penguins",
    pizza = "penguins",
    merchant = "merchant",
    beach = "beach",
    shore = "beach",
    shores = "beach",
    pig = "verdant",
    verdant = "verdant",
    bakery = "tom",
    tom = "tom",
    mount = "mount",
    mountcinder = "mount",
    golden = "golden",
    nugget = "golden",
    gold = "golden",
    copper = "copper",
    mesa = "copper",
    alona = "bluemoon",
    bluemoon = "bluemoon",
    polarbear = "polar",
    polar = "polar",
    glacial = "glacial",
    hollow = "glacial",
    glacialhollow = "glacial",
    butter = "butter",
    butterfly = "butter",
    kingmushroom = "kingmushroom",
    kingmush = "kingmushroom",
    
}

-- ✅ Locations
local locations = {
    penguins = Vector3.new(4212, 1191, -4352),
    verdant = Vector3.new(3785, 84, 1631),
    guild = Vector3.new(2545, 82, 1257),
    fox = Vector3.new(2047, 112, -348),
    light = Vector3.new(878, 267, 680),
    tower = Vector3.new(4403, 228, -601),
    beach = Vector3.new(1401, 80, 536),
    rooftop = Vector3.new(3916, 226, -362),
    mount = Vector3.new(4575, 1103, -1734),
    flare = Vector3.new(5761, 1143, -3770),
    tom = Vector3.new(5635, 245, -66),
    gym = Vector3.new(5790, 449, -99),
    ferry = Vector3.new(1587, 78, -119),
    saloon = Vector3.new(-6122, 118, -1958),
    cavern = Vector3.new(3313, 74, -430),
    bluemoon = Vector3.new(-8007, 343, -1833),
    fernhill = Vector3.new(2324, 84, 655),
    golden = Vector3.new(-7012, 108, -1952),
    copper = Vector3.new(-5848, 80, -2411),
    grave = Vector3.new(3714, 228, -601),
    polar = Vector3.new(5130, 1112, -2043),
    glacial = Vector3.new(5114, 1124, -2691),
    butter =  Vector3.new(4029, 226,-458),
    kingmushroom = Vector3.new(9362, 524, -31920),
}

-- ✅ Cooldown handler
local lastCommand = {}
local function isOnCooldown(player)
    local now = tick()
    if lastCommand[player] and now - lastCommand[player] < 2 then
        return true
    end
    lastCommand[player] = now
    return false
end

-- ✅ Anti-AFK setup (DELTA compatible)
-- ✅ Safe Anti-AFK (No movement, safe in vehicles)
if antiAFKEnabled then
    task.spawn(function()
        while task.wait(60) do
            if antiAFKEnabled then
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                print("🛡️ Anti-AFK triggered (no movement, vehicle-safe)")
            end
        end
    end)
end


-- ✅ Permission functions
local function hasPermission(userId, cmd)
    return Permissions.allAllowed or (Permissions[cmd] and Permissions[cmd][userId])
end

local function setPermission(userId, cmd, allow)
    if not Permissions[cmd] then Permissions[cmd] = {} end
    Permissions[cmd][userId] = allow and true or nil
end

-- ✅ Player search
local function findPlayerByName(name)
    name = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == name or plr.DisplayName:lower() == name then return plr end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.DisplayName:lower():find(name) or plr.Name:lower():find(name) then
            return plr
        end
    end
    return nil
end

-- ✅ List Permissions
local lastListPermTime = 0
local function listPermissions()
    local now = tick()
    if now - lastListPermTime < 2 then return end
    lastListPermTime = now

    local result = "📜 Permission List:\n"
    result = result .. "🌍 Global Access: " .. (Permissions.allAllowed and "✅ Enabled" or "❌ Disabled") .. "\n"

    for cmd, userList in pairs(Permissions) do
        if cmd ~= "allAllowed" and cmd ~= "allUsers" then
            result = result .. "🔹 " .. cmd .. ": "
            local names = {}
            for user, _ in pairs(userList) do
                table.insert(names, user)
            end
            result = result .. (#names > 0 and table.concat(names, ", ") or "(none)") .. "\n"
        end
    end
    return result
end

-- ✅ Reply system (GUI-aware)
local lastReplyText, lastReplyTime = "", 0
local guiTextRef = nil
local function reply(text)
    local now = tick()
    if text == lastReplyText and now - lastReplyTime < 2 then return end
    lastReplyText = text
    lastReplyTime = now

    print("BOT: " .. text)
    if guiTextRef then
        guiTextRef.Text = text
    end
    logMessage(text) -- ✅ Add this line to log replies
end


-- ✅ Permission text builder
local lastListPermTime = 0
local function listPermissions()
    local now = tick()
    if now - lastListPermTime < 1 then return end
    lastListPermTime = now

    local result = "📜 Permission List:\n"
    result = result .. "🌍 Global Access: " .. (Permissions.allAllowed and "✅ Enabled" or "❌ Disabled") .. "\n"

    for cmd, userList in pairs(Permissions) do
        if cmd ~= "allAllowed" and cmd ~= "allUsers" then
            result = result .. "🔹 " .. cmd .. ": "
            local names = {}
            for user, _ in pairs(userList) do
                table.insert(names, user)
            end
            result = result .. (#names > 0 and table.concat(names, ", ") or "(none)") .. "\n"
        end
    end

    -- Show GUI
    guiTextRef = createPermissionGUI()
    if guiTextRef then
        guiTextRef.Text = result
    end

    return result
end


-- ✅ Auto sit
-- ✅ Auto sit with retry and lock
local function trySeat()
    local root = bot.Character and bot.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and not v.Occupant then
            local model = v:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild(bot.Name) then
                local d = (v.Position - root.Position).Magnitude
                if d < dist and d < 30 then
                    closest, dist = v, d
                end
            end
        end
    end

    if closest then
        bot.Character:PivotTo(CFrame.new(closest.Position + Vector3.new(0, 2, 0)))
        task.wait(0.5)

        -- Retry seat check
        local humanoid = bot.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and not humanoid.SeatPart then
            task.wait(0.2)
            if closest.Occupant == nil then
                bot.Character:PivotTo(CFrame.new(closest.Position + Vector3.new(0, 2, 0)))
            end
        end

        -- Watch for being ejected
        task.spawn(function()
            while true do
                task.wait(1.5)
                local human = bot.Character and bot.Character:FindFirstChildWhichIsA("Humanoid")
                if not human or not human.SeatPart then
                    trySeat() -- Re-seat
                    break
                end
            end
        end)

        return closest
    end
end


-- ✅ Teleport vehicle
local function teleportVehicleTo(position)
    local humanoid = bot.Character and bot.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return warn("❌ No humanoid") end

    local seat = humanoid.SeatPart or trySeat()
    if not seat then return warn("❌ Not seated") end

    local vehicle = seat:FindFirstAncestorOfClass("Model")
    if not vehicle then return warn("❌ No vehicle model") end

    if not vehicle.PrimaryPart then
        local base = vehicle:FindFirstChild("HumanoidRootPart") or vehicle:FindFirstChildWhichIsA("BasePart")
        if base then vehicle.PrimaryPart = base else return warn("❌ No PrimaryPart") end
    end

    task.wait(0.2)
    vehicle:SetPrimaryPartCFrame(CFrame.new(position))
end

-- ✅ Merchant teleport support
local function teleportToMerchant()
    local char = bot.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local merchantModel = workspace:FindFirstChild("World")
        and workspace.World:FindFirstChild("NPCs")
        and workspace.World.NPCs:FindFirstChild("Merchant Cart")
        and workspace.World.NPCs["Merchant Cart"]:FindFirstChild("Traveling Merchant")

    if not merchantModel then
        reply("❌ TRAVELLING MERCHANT IS NOT AVAILABLE")
        return
    end

    local part = merchantModel.PrimaryPart or merchantModel:FindFirstChild("Head") or merchantModel:FindFirstChildWhichIsA("BasePart")
    if not part then
        reply("❌ TRAVELLING MERCHANT IS NOT AVAILABLE")
        return
    end

    if not merchantModel.PrimaryPart then
        merchantModel.PrimaryPart = part
    end

    local forward = part.CFrame.LookVector
    local frontPos = part.Position + forward * 20

    local groundPos = Vector3.new(frontPos.X, part.Position.Y + 3, frontPos.Z)
    teleportVehicleTo(groundPos)
    reply("🧽 Teleported to Traveling Merchant")
end

-- ✅ Admin command handler
local function handleAdminCommand(sender, cmd, arg)
    if not botOwners[sender.Name] then return false end

    if cmd == "listperm" then
        reply(listPermissions())
        return true

    elseif cmd == "allow" or cmd == "revoke" then
        local action = (cmd == "allow")
        if arg == "all" then
            Permissions.allAllowed = action
            Permissions.allUsers = {}

            if action then
                for _, plr in ipairs(Players:GetPlayers()) do
                    table.insert(Permissions.allUsers, plr.Name:lower())
                end
                reply("✅ All players allowed.")
            else
                for perm, userList in pairs(Permissions) do
                    if perm ~= "allAllowed" and perm ~= "allUsers" then
                        for user in pairs(userList) do
                            userList[user] = nil
                        end
                    end
                end
                Permissions.allUsers = {}
                reply("🚫 All permissions revoked, including individual users.")
            end
            return true
        end

        local user, perm = arg:match("(.-)%s+(%w+)$")
        if not user then user = arg end
        local plr = findPlayerByName(user)
        local uid = plr and plr.Name:lower() or (user and user:lower())

        if user and not perm then
            for p, _ in pairs(Permissions) do
                if p ~= "allAllowed" and p ~= "allUsers" then
                    setPermission(uid, p, action)
                end
            end
            reply((action and "✅ Allowed " or "🚫 Revoked ") .. user .. " to use all commands")
            return true

        elseif user and perm and Permissions[perm] then
            setPermission(uid, perm, action)
            reply((action and "✅ Allowed " or "🚫 Revoked ") .. user .. " to use " .. perm)
            return true
        else
            reply("❌ Usage: !" .. cmd .. " username [tp|come|follow]")
            return true
        end

    elseif cmd == "afk" then
    if arg == "on" then
        antiAFKEnabled = true
        reply("✅ Anti-AFK is now enabled.")
    elseif arg == "off" then
        antiAFKEnabled = false
        reply("🚫 Anti-AFK is now disabled.")
    elseif arg == "status" then
        reply("📶 Anti-AFK is currently " .. (antiAFKEnabled and "✅ enabled" or "❌ disabled") .. ".")
    else
        reply("❌ Usage: !afk on | off | status")
    end
    return true

    end

    return false
end



-- ✅ Main command handler
local function handleCommand(sender, cmd, arg)
    local nameLower = sender.Name:lower()
    if blockedUsers[nameLower] and protectionEnabled then return end
    if isOnCooldown(nameLower) then return end

    if handleAdminCommand(sender, cmd, arg) then return end

    local isOwner = botOwners[sender.Name] == true
    local allowed = function(permission)
        return isOwner or hasPermission(nameLower, permission)
    end

    if cmd == "tp" and arg == "merchant" and allowed("tp") then
        teleportToMerchant()
    elseif cmd == "tp" and allowed("tp") then
        local locationKey = aliasMap[arg] or arg
        if locations[locationKey] then
            teleportVehicleTo(locations[locationKey])
            reply("📦 Teleported to " .. locationKey)
        else
            local target = findPlayerByName(arg)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                teleportVehicleTo(target.Character.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
                reply("📍 Teleported to " .. target.Name)
            else
                reply("❌ Player/location not found.")
            end
        end

    elseif cmd == "come" and allowed("come") then
        if sender.Character and sender.Character:FindFirstChild("HumanoidRootPart") then
            teleportVehicleTo(sender.Character.HumanoidRootPart.Position + Vector3.new(3, 0, 0))
            reply("🚗 Coming to you, " .. sender.Name)
        end
    end
end
-- ✅ Chat listener
local generalChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
if generalChannel then
    generalChannel.MessageReceived:Connect(function(message)
        local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
        if not sender then return end
        local text = message.Text

        local cmd, arg = text:match("^!(%w+)%s*(.*)$")
        if cmd then
            handleCommand(sender, cmd:lower(), arg)
        end
    end)
end

-- ✅ GUI Setup with Buttons
local function createPermissionGUI()
    local existing = bot.PlayerGui:FindFirstChild("PermLogUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PermLogUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = bot:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 400, 0, 320)
    frame.Position = UDim2.new(0.5, -200, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = "📜 Permission Log & Controls"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansSemibold
    title.TextSize = 20
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.Size = UDim2.new(1, 0, 1, -90)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local logText = Instance.new("TextLabel")
    logText.Name = "LogText"
    logText.Size = UDim2.new(1, -10, 0, 500)
    logText.Position = UDim2.new(0, 5, 0, 0)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(230, 230, 230)
    logText.Font = Enum.Font.Code
    logText.TextSize = 16
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
    logText.Text = "[ Waiting for permission data... ]"
    logText.Parent = scroll

    -- ✅ Buttons
    local function createButton(name, text, posX, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0.3, 0, 0, 30)
        btn.Position = UDim2.new(posX, 0, 1, -35)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = text
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
    end

    createButton("AllowAllBtn", "✅ Allow All", 0.05, function()
        Permissions.allAllowed = true
        Permissions.allUsers = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(Permissions.allUsers, plr.Name:lower())
        end
        logText.Text = listPermissions()
    end)

    createButton("RevokeAllBtn", "🚫 Revoke All", 0.35, function()
        Permissions.allAllowed = false
        Permissions.allUsers = {}
        for perm, userList in pairs(Permissions) do
            if perm ~= "allAllowed" and perm ~= "allUsers" then
                for user in pairs(userList) do
                    userList[user] = nil
                end
            end
        end
        logText.Text = listPermissions()
    end)

    createButton("AFKBtn", "🕒 Toggle AFK", 0.65, function()
        antiAFKEnabled = not antiAFKEnabled
        logText.Text = listPermissions() .. "\n\nAFK is now: " .. (antiAFKEnabled and "✅ ON" or "❌ OFF")
    end)

    return logText
end


local GuiState = {
    currentTab = "Permissions",
    panelVisible = true,
    afkStatus = antiAFKEnabled,
}

local logs = {}
function logMessage(txt)
    table.insert(logs, 1, txt)
    if #logs > 50 then table.remove(logs) end
end

local function updateContent(contentLabel)
    local tab = GuiState.currentTab
    if tab == "Permissions" then
        local text = "📜 Permissions:\n"
        text = text .. "🌍 Global Access: " .. (Permissions.allAllowed and "✅ Enabled" or "❌ Disabled") .. "\n"
        for cmd, userList in pairs(Permissions) do
            if cmd ~= "allAllowed" and cmd ~= "allUsers" then
                text = text .. "🔹 " .. cmd .. ": "
                local names = {}
                for user, _ in pairs(userList) do
                    table.insert(names, user)
                end
                text = text .. (#names > 0 and table.concat(names, ", ") or "(none)") .. "\n"
            end
        end
        contentLabel.Text = text

    elseif tab == "Logs" then
        local text = "📂 Log History:\n"
        for _, msg in ipairs(logs) do
            text = text .. "• " .. msg .. "\n"
        end
        contentLabel.Text = text

    elseif tab == "AFK" then
        contentLabel.Text = "🕒 Anti-AFK is currently: " .. (GuiState.afkStatus and "✅ ON" or "❌ OFF")
    end
end

local function createMainGUI()
    local existing = bot.PlayerGui:FindFirstChild("BotGUI")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BotGUI"
    gui.Parent = bot:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 100, 0, 40)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.SourceSansSemibold
    toggleBtn.TextSize = 18
    toggleBtn.Text = "📋 Menu"
    toggleBtn.Parent = gui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 520, 0, 370)
    panel.Position = UDim2.new(0, 140, 0.5, -185)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    panel.Visible = false
    panel.Parent = gui

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sidebar.Parent = panel

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -130, 1, -40)
    contentFrame.Position = UDim2.new(0, 130, 0, 0)
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    contentFrame.Parent = panel

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 1, -20)
    contentLabel.Position = UDim2.new(0, 10, 0, 10)
    contentLabel.BackgroundTransparency = 1
    contentLabel.TextColor3 = Color3.new(1, 1, 1)
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.Code
    contentLabel.TextSize = 16
    contentLabel.Text = "[Loading...]"
    contentLabel.TextScaled = false
    contentLabel.Parent = contentFrame

    local function createSidebarButton(text, tabName, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, 40 * (order - 1))
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Parent = sidebar

        btn.MouseButton1Click:Connect(function()
            GuiState.currentTab = tabName
            updateContent(contentLabel)
        end)
    end

    createSidebarButton("Permissions", "Permissions", 1)
    createSidebarButton("Logs", "Logs", 2)
    createSidebarButton("AFK Status", "AFK", 3)

    local afkBtn = Instance.new("TextButton")
    afkBtn.Size = UDim2.new(0, 130, 0, 30)
    afkBtn.Position = UDim2.new(1, -130, 1, -30)
    afkBtn.Text = "Toggle AFK"
    afkBtn.Font = Enum.Font.SourceSans
    afkBtn.TextSize = 16
    afkBtn.BackgroundColor3 = GuiState.afkStatus and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    afkBtn.TextColor3 = Color3.new(1, 1, 1)
    afkBtn.Parent = panel

    afkBtn.MouseButton1Click:Connect(function()
        GuiState.afkStatus = not GuiState.afkStatus
        antiAFKEnabled = GuiState.afkStatus
        afkBtn.BackgroundColor3 = GuiState.afkStatus and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        updateContent(contentLabel)
    end)

    local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
minimizeBtn.Text = "━"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = panel

minimizeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "✖"
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18
    closeBtn.Parent = panel

    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        GuiState.panelVisible = not GuiState.panelVisible
        panel.Visible = GuiState.panelVisible
        updateContent(contentLabel)
    end)

    return contentLabel
end

local contentRef = createMainGUI()
task.wait(0.5)
updateContent(contentRef)
